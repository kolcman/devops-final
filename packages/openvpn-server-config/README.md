# openvpn-server-config (deb package)

Исходники deb‑пакета для блока 2 (VPN).

## Что ставит пакет

- `/etc/openvpn/server/server.conf` — базовый конфиг OpenVPN сервера
- `/usr/sbin/vpn-gen-server-csr` — helper для генерации `server.key` и `server.req`
- `/etc/default/openvpn-server-config` — настройки для helper-скрипта

## Зависимости

В `debian/control` указаны:
- `easy-rsa` (обязательно по брифу)
- `openvpn`

## Сборка

```bash
sudo apt-get update
sudo apt-get install -y debhelper-compat build-essential

cd packages/openvpn-server-config
dpkg-buildpackage -us -uc -b
```

