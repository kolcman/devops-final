#!/usr/bin/env bash
set -euo pipefail

BACKUP_ROOT="${BACKUP_ROOT:-/var/backups/linux-final}"
LOG_DIR="${LOG_DIR:-$BACKUP_ROOT/logs}"
STATE_DIR="${STATE_DIR:-$BACKUP_ROOT/state}"
WORK_DIR="${WORK_DIR:-$BACKUP_ROOT/work}"
LOCK_FILE="${LOCK_FILE:-/var/lock/linux-final-backup.lock}"
TEXTFILE_DIR="${TEXTFILE_DIR:-/var/lib/prometheus/node-exporter}"
METRICS_FILE="${METRICS_FILE:-$TEXTFILE_DIR/linux_final_backup.prom}"

TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
HOSTNAME_SHORT="$(hostname -s 2>/dev/null || hostname)"
ARCHIVE_BASENAME="backup-${HOSTNAME_SHORT}-${TIMESTAMP}.tar.gz"
ARCHIVE_PATH="$BACKUP_ROOT/$ARCHIVE_BASENAME"
CHECKSUM_PATH="$ARCHIVE_PATH.sha256"
LATEST_OK_FILE="$STATE_DIR/last_success_epoch"
LOG_FILE="$LOG_DIR/backup-${TIMESTAMP}.log"

declare -a SOURCES=(
  "/etc/openvpn"
  "/etc/prometheus"
  "/etc/alertmanager"
  "/etc/systemd/system"
  "/var/lib/ca-server/pki"
)

log() {
  printf '%s %s\n' "$(date -u +%FT%TZ)" "$*"
}

die() {
  log "ERROR: $*"
  exit 1
}

require_root() {
  [[ ${EUID:-0} -eq 0 ]] || die "Run as root"
}

prepare_dirs() {
  install -d -m 0750 "$BACKUP_ROOT" "$LOG_DIR" "$STATE_DIR" "$WORK_DIR"
}

setup_logging() {
  exec > >(tee -a "$LOG_FILE") 2>&1
}

acquire_lock() {
  exec 9>"$LOCK_FILE"
  flock -n 9 || die "Another backup job is already running"
}

collect_existing_sources() {
  local src
  EXISTING_SOURCES=()
  for src in "${SOURCES[@]}"; do
    if [[ -e "$src" ]]; then
      EXISTING_SOURCES+=("$src")
    else
      log "[backup] Skipping missing path: $src"
    fi
  done
  [[ ${#EXISTING_SOURCES[@]} -gt 0 ]] || die "No backup sources exist on this host"
}

build_manifest() {
  local manifest="$WORK_DIR/manifest-${TIMESTAMP}.txt"
  printf 'timestamp=%s\nhost=%s\n' "$TIMESTAMP" "$HOSTNAME_SHORT" >"$manifest"
  printf 'sources:\n' >>"$manifest"
  printf '  - %s\n' "${EXISTING_SOURCES[@]}" >>"$manifest"
  echo "$manifest"
}

create_archive() {
  local manifest="$1"
  log "[backup] Creating archive: $ARCHIVE_PATH"
  tar -czf "$ARCHIVE_PATH" \
    --warning=no-file-changed \
    --absolute-names \
    "$manifest" \
    "${EXISTING_SOURCES[@]}" || die "Failed to create backup archive"
}

write_checksum() {
  sha256sum "$ARCHIVE_PATH" >"$CHECKSUM_PATH" || die "Failed to generate checksum"
}

update_state() {
  date +%s >"$LATEST_OK_FILE"
}

write_metrics() {
  local run_epoch="$1"
  local status="$2"
  local success_epoch="$3"
  local tmp_file

  if [[ ! -d "$TEXTFILE_DIR" ]]; then
    log "[backup] Metrics directory not found, skipping export: $TEXTFILE_DIR"
    return 0
  fi

  tmp_file="$(mktemp "$TEXTFILE_DIR/.linux_final_backup.prom.tmp.XXXXXX")"
  {
    printf '# HELP linux_final_backup_last_run_unixtime Last backup run timestamp.\n'
    printf '# TYPE linux_final_backup_last_run_unixtime gauge\n'
    printf 'linux_final_backup_last_run_unixtime %s\n' "$run_epoch"
    printf '# HELP linux_final_backup_last_run_status Last backup run status (1=success, 0=failed).\n'
    printf '# TYPE linux_final_backup_last_run_status gauge\n'
    printf 'linux_final_backup_last_run_status %s\n' "$status"
    printf '# HELP linux_final_backup_last_success_unixtime Last successful backup timestamp.\n'
    printf '# TYPE linux_final_backup_last_success_unixtime gauge\n'
    printf 'linux_final_backup_last_success_unixtime %s\n' "$success_epoch"
  } >"$tmp_file"

  mv -f "$tmp_file" "$METRICS_FILE"
}

on_error() {
  local run_epoch
  run_epoch="$(date +%s)"
  write_metrics "$run_epoch" "0" "0" || true
}

main() {
  trap on_error ERR
  require_root
  prepare_dirs
  setup_logging
  acquire_lock
  log "[backup] Started on $HOSTNAME_SHORT"

  collect_existing_sources
  manifest_path="$(build_manifest)"
  create_archive "$manifest_path"
  write_checksum
  update_state
  success_epoch="$(date +%s)"
  write_metrics "$success_epoch" "1" "$success_epoch"

  rm -f "$manifest_path"
  log "[backup] Success"
  log "[backup] Archive: $ARCHIVE_PATH"
  log "[backup] Checksum: $CHECKSUM_PATH"
}

main "$@"
