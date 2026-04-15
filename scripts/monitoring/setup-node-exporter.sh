#!/usr/bin/env bash
set -euo pipefail

log() { printf '%s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

[[ ${EUID:-0} -eq 0 ]] || die "Run as root"

log "[monitoring] Installing node_exporter..."
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y prometheus-node-exporter

systemctl enable --now prometheus-node-exporter
systemctl is-active --quiet prometheus-node-exporter || die "prometheus-node-exporter is not active"

log "[monitoring] node_exporter is running on :9100"

