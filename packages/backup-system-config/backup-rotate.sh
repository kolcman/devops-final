#!/usr/bin/env bash
set -euo pipefail

BACKUP_ROOT="${BACKUP_ROOT:-/var/backups/linux-final}"
LOG_DIR="${LOG_DIR:-$BACKUP_ROOT/logs}"
LOCK_FILE="${LOCK_FILE:-/var/lock/linux-final-backup-rotate.lock}"
DAILY_KEEP="${DAILY_KEEP:-7}"
WEEKLY_KEEP="${WEEKLY_KEEP:-4}"

TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
LOG_FILE="$LOG_DIR/rotate-${TIMESTAMP}.log"

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
  [[ -d "$BACKUP_ROOT" ]] || die "Backup root does not exist: $BACKUP_ROOT"
  install -d -m 0750 "$LOG_DIR"
}

setup_logging() {
  exec > >(tee -a "$LOG_FILE") 2>&1
}

acquire_lock() {
  exec 9>"$LOCK_FILE"
  flock -n 9 || die "Another rotation job is already running"
}

list_archives_newest_first() {
  find "$BACKUP_ROOT" -maxdepth 1 -type f -name 'backup-*.tar.gz' -printf '%T@ %p\n' \
    | sort -nr \
    | awk '{print $2}'
}

delete_archive_pair() {
  local archive="$1"
  local checksum="${archive}.sha256"
  rm -f -- "$archive"
  rm -f -- "$checksum"
  log "[rotate] Deleted: $archive"
}

mark_weekly_keep_set() {
  local -n _archives_ref="$1"
  local -n _weekly_keep_ref="$2"
  local last_week=""
  local weekly_count=0
  local archive

  for archive in "${_archives_ref[@]}"; do
    if [[ $weekly_count -ge $WEEKLY_KEEP ]]; then
      break
    fi

    local mtime week_key
    mtime="$(date -u -r "$archive" +%Y-%m-%dT%H:%M:%SZ)"
    week_key="$(date -u -d "$mtime" +%G-W%V)"

    if [[ "$week_key" != "$last_week" ]]; then
      _weekly_keep_ref["$archive"]=1
      last_week="$week_key"
      weekly_count=$((weekly_count + 1))
    fi
  done
}

rotate_archives() {
  mapfile -t archives < <(list_archives_newest_first)
  [[ ${#archives[@]} -gt 0 ]] || {
    log "[rotate] No archives found, nothing to do"
    return 0
  }

  log "[rotate] Total archives found: ${#archives[@]}"
  log "[rotate] Policy: keep last $DAILY_KEEP daily + $WEEKLY_KEEP weekly snapshots"

  declare -A keep_map=()
  local i archive

  for ((i = 0; i < ${#archives[@]} && i < DAILY_KEEP; i++)); do
    keep_map["${archives[$i]}"]=1
  done

  declare -A weekly_keep_map=()
  mark_weekly_keep_set archives weekly_keep_map

  for archive in "${!weekly_keep_map[@]}"; do
    keep_map["$archive"]=1
  done

  local kept=0
  local deleted=0
  for archive in "${archives[@]}"; do
    if [[ -n "${keep_map[$archive]:-}" ]]; then
      kept=$((kept + 1))
      log "[rotate] Keep: $archive"
    else
      delete_archive_pair "$archive"
      deleted=$((deleted + 1))
    fi
  done

  log "[rotate] Done. Kept: $kept, Deleted: $deleted"
}

main() {
  require_root
  prepare_dirs
  setup_logging
  acquire_lock
  rotate_archives
}

main "$@"
