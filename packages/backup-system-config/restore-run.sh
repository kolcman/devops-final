#!/usr/bin/env bash
set -euo pipefail

BACKUP_ROOT="${BACKUP_ROOT:-/var/backups/linux-final}"
RESTORE_ROOT="${RESTORE_ROOT:-/}"
LOG_DIR="${LOG_DIR:-$BACKUP_ROOT/logs}"
LOCK_FILE="${LOCK_FILE:-/var/lock/linux-final-restore.lock}"
FORCE="${FORCE:-0}"

ARCHIVE_PATH="${1:-}"
TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
LOG_FILE="$LOG_DIR/restore-${TIMESTAMP}.log"

log() {
  printf '%s %s\n' "$(date -u +%FT%TZ)" "$*"
}

die() {
  log "ERROR: $*"
  exit 1
}

usage() {
  cat <<'EOF'
Usage:
  restore-run.sh /path/to/backup-*.tar.gz

Environment:
  BACKUP_ROOT   Backup root directory (default: /var/backups/linux-final)
  RESTORE_ROOT  Restore destination root (default: /)
  FORCE         Set to 1 to allow restore into non-root directory
EOF
}

require_root() {
  [[ ${EUID:-0} -eq 0 ]] || die "Run as root"
}

prepare_dirs() {
  install -d -m 0750 "$LOG_DIR"
}

setup_logging() {
  exec > >(tee -a "$LOG_FILE") 2>&1
}

acquire_lock() {
  exec 9>"$LOCK_FILE"
  flock -n 9 || die "Another restore job is already running"
}

validate_inputs() {
  [[ -n "$ARCHIVE_PATH" ]] || {
    usage
    die "Archive path is required"
  }

  [[ -f "$ARCHIVE_PATH" ]] || die "Archive not found: $ARCHIVE_PATH"

  if [[ "$RESTORE_ROOT" != "/" && "$FORCE" != "1" ]]; then
    die "RESTORE_ROOT is not '/'. Set FORCE=1 to continue intentionally"
  fi
}

verify_checksum_if_present() {
  local checksum_file
  checksum_file="${ARCHIVE_PATH}.sha256"

  if [[ -f "$checksum_file" ]]; then
    log "[restore] Verifying checksum: $checksum_file"
    sha256sum -c "$checksum_file" || die "Checksum verification failed"
  else
    log "[restore] Checksum file not found, continuing without checksum validation"
  fi
}

preview_archive() {
  log "[restore] Checking archive readability"
  tar -tzf "$ARCHIVE_PATH" >/dev/null || die "Archive is unreadable or corrupted"
}

perform_restore() {
  log "[restore] Restoring archive to: $RESTORE_ROOT"
  tar -xzf "$ARCHIVE_PATH" -C "$RESTORE_ROOT" --absolute-names || die "Restore failed"
}

main() {
  require_root
  prepare_dirs
  setup_logging
  acquire_lock
  validate_inputs

  log "[restore] Started"
  log "[restore] Archive: $ARCHIVE_PATH"
  log "[restore] Destination: $RESTORE_ROOT"

  verify_checksum_if_present
  preview_archive
  perform_restore

  log "[restore] Success"
}

main "$@"
