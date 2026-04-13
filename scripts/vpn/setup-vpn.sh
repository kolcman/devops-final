#!/usr/bin/env bash
set -euo pipefail

VPN_PORT="${VPN_PORT:-1194}"
VPN_PROTO="${VPN_PROTO:-udp}"
VPN_NETWORK="${VPN_NETWORK:-10.8.0.0}"
VPN_NETMASK="${VPN_NETMASK:-255.255.255.0}"
WAN_IFACE="${WAN_IFACE:-}"
SERVER_CONF="${SERVER_CONF:-/etc/openvpn/server/server.conf}"

log() { printf '%s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

require_root() {
  [[ $EUID -eq 0 ]] || die "Run as root"
}

detect_wan_iface() {
  if [[ -n "$WAN_IFACE" ]]; then
    return 0
  fi
  WAN_IFACE="$(ip route | awk '/default/ {print $5; exit}')"
  [[ -n "$WAN_IFACE" ]] || die "Cannot detect WAN interface"
}

install_packages() {
  log "[vpn] Installing packages..."
  apt-get update -y
  DEBIAN_FRONTEND=noninteractive apt-get install -y openvpn easy-rsa iptables-persistent
}

ensure_server_config() {
  [[ -f "$SERVER_CONF" ]] || die "Missing server config: $SERVER_CONF"
  install -d -m 0755 /etc/openvpn/server/pki
}

enable_ip_forward() {
  cat >/etc/sysctl.d/99-openvpn.conf <<'EOF'
net.ipv4.ip_forward=1
EOF
  sysctl --system >/dev/null
}

apply_firewall() {
  log "[vpn] Applying iptables rules..."
  iptables -t nat -C POSTROUTING -s "${VPN_NETWORK}/24" -o "$WAN_IFACE" -j MASQUERADE 2>/dev/null || \
    iptables -t nat -A POSTROUTING -s "${VPN_NETWORK}/24" -o "$WAN_IFACE" -j MASQUERADE

  iptables -C INPUT -p "$VPN_PROTO" --dport "$VPN_PORT" -j ACCEPT 2>/dev/null || \
    iptables -A INPUT -p "$VPN_PROTO" --dport "$VPN_PORT" -j ACCEPT

  iptables -C FORWARD -i tun0 -o "$WAN_IFACE" -j ACCEPT 2>/dev/null || \
    iptables -A FORWARD -i tun0 -o "$WAN_IFACE" -j ACCEPT

  iptables -C FORWARD -i "$WAN_IFACE" -o tun0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || \
    iptables -A FORWARD -i "$WAN_IFACE" -o tun0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

  netfilter-persistent save >/dev/null
}

enable_service() {
  systemctl daemon-reload
  systemctl enable --now openvpn-server@server
  systemctl is-active --quiet openvpn-server@server || die "OpenVPN service is not active"
}

main() {
  require_root
  detect_wan_iface
  install_packages
  ensure_server_config
  enable_ip_forward
  apply_firewall
  enable_service
  log "[vpn] Done"
}

main "$@"

