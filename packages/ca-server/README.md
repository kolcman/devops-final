# ca-server (deb package)

Этот каталог содержит **исходники** deb‑пакета `ca-server`.

## Что делает пакет

- Ставит скрипт `ca-server-init` в `/usr/sbin/ca-server-init`
- Добавляет systemd‑юнит `ca-server-init.service` (oneshot), который **один раз** инициализирует PKI (Easy‑RSA) в `/var/lib/ca-server/pki`
- Ключи/сертификаты **не хранятся в репозитории** и не упаковываются в `.deb` заранее — они создаются на целевой машине при первом запуске

## Где лежат данные

- PKI: `/var/lib/ca-server/pki`
- Конфиг: `/etc/ca-server/ca-server.conf`

## Сборка пакета (локально)

На Debian/Ubuntu:

```bash
sudo apt-get update
sudo apt-get install -y debhelper build-essential

cd packages/ca-server
dpkg-buildpackage -us -uc
```

Готовый `.deb` появится уровнем выше (в `packages/`).

