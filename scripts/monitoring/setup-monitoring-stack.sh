#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="${PROJECT_ROOT:-$PWD}"
PROM_CFG_SRC="${PROM_CFG_SRC:-$PROJECT_ROOT/monitoring/prometheus/prometheus.yml}"
RULES_CFG_SRC="${RULES_CFG_SRC:-$PROJECT_ROOT/monitoring/prometheus/alert.rules.yml}"
AM_CFG_SRC="${AM_CFG_SRC:-$PROJECT_ROOT/monitoring/alertmanager/alertmanager.yml}"

log() { printf '%s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

[[ ${EUID:-0} -eq 0 ]] || die "Run as root"
[[ -f "$PROM_CFG_SRC" ]] || die "Missing $PROM_CFG_SRC"
[[ -f "$RULES_CFG_SRC" ]] || die "Missing $RULES_CFG_SRC"
[[ -f "$AM_CFG_SRC" ]] || die "Missing $AM_CFG_SRC"

install_prometheus_bin() {
  if [[ -x /usr/local/bin/prometheus && -x /usr/local/bin/promtool ]]; then
    log "[monitoring] Prometheus binary already installed"
    return 0
  fi

  local ver archive dir
  ver="$(curl -s https://api.github.com/repos/prometheus/prometheus/releases/latest | awk -F '"' '/tag_name/ {print $4; exit}')"
  [[ -n "$ver" ]] || die "Cannot detect latest Prometheus version"
  archive="prometheus-${ver#v}.linux-amd64.tar.gz"

  log "[monitoring] Installing Prometheus $ver"
  cd /tmp
  curl -fsSLO "https://github.com/prometheus/prometheus/releases/download/${ver}/${archive}"
  tar xzf "$archive"
  dir="prometheus-${ver#v}.linux-amd64"

  install -m 0755 "$dir/prometheus" /usr/local/bin/prometheus
  install -m 0755 "$dir/promtool" /usr/local/bin/promtool
}

install_alertmanager_bin() {
  if [[ -x /usr/local/bin/alertmanager && -x /usr/local/bin/amtool ]]; then
    log "[monitoring] Alertmanager binary already installed"
    return 0
  fi

  local ver archive dir
  ver="$(curl -s https://api.github.com/repos/prometheus/alertmanager/releases/latest | awk -F '"' '/tag_name/ {print $4; exit}')"
  [[ -n "$ver" ]] || die "Cannot detect latest Alertmanager version"
  archive="alertmanager-${ver#v}.linux-amd64.tar.gz"

  log "[monitoring] Installing Alertmanager $ver"
  cd /tmp
  curl -fsSLO "https://github.com/prometheus/alertmanager/releases/download/${ver}/${archive}"
  tar xzf "$archive"
  dir="alertmanager-${ver#v}.linux-amd64"

  install -m 0755 "$dir/alertmanager" /usr/local/bin/alertmanager
  install -m 0755 "$dir/amtool" /usr/local/bin/amtool
}

setup_users_dirs() {
  useradd --no-create-home --shell /usr/sbin/nologin prometheus 2>/dev/null || true
  useradd --no-create-home --shell /usr/sbin/nologin alertmanager 2>/dev/null || true

  install -d -m 0755 /etc/prometheus /var/lib/prometheus /etc/alertmanager /var/lib/alertmanager
  chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus
  chown -R alertmanager:alertmanager /etc/alertmanager /var/lib/alertmanager
}

install_configs() {
  install -m 0644 "$PROM_CFG_SRC" /etc/prometheus/prometheus.yml
  install -m 0644 "$RULES_CFG_SRC" /etc/prometheus/alert.rules.yml
  install -m 0640 "$AM_CFG_SRC" /etc/alertmanager/alertmanager.yml

  chown prometheus:prometheus /etc/prometheus/prometheus.yml /etc/prometheus/alert.rules.yml
  chown alertmanager:alertmanager /etc/alertmanager/alertmanager.yml
}

install_units() {
  cat >/etc/systemd/system/prometheus.service <<'EOF'
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus \
  --web.listen-address=0.0.0.0:9090
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

  cat >/etc/systemd/system/alertmanager.service <<'EOF'
[Unit]
Description=Alertmanager
After=network.target

[Service]
User=alertmanager
Group=alertmanager
Type=simple
ExecStart=/usr/local/bin/alertmanager \
  --config.file=/etc/alertmanager/alertmanager.yml \
  --storage.path=/var/lib/alertmanager \
  --web.listen-address=0.0.0.0:9093 \
  --cluster.listen-address=""
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
}

validate_and_start() {
  /usr/local/bin/promtool check config /etc/prometheus/prometheus.yml
  /usr/local/bin/promtool check rules /etc/prometheus/alert.rules.yml
  /usr/local/bin/amtool check-config /etc/alertmanager/alertmanager.yml

  systemctl daemon-reload
  systemctl enable --now prometheus alertmanager
  systemctl is-active --quiet prometheus || die "prometheus is not active"
  systemctl is-active --quiet alertmanager || die "alertmanager is not active"
}

main() {
  install_prometheus_bin
  install_alertmanager_bin
  setup_users_dirs
  install_configs
  install_units
  validate_and_start
  log "[monitoring] Prometheus is ready on :9090"
  log "[monitoring] Alertmanager is ready on :9093"
}

main "$@"

