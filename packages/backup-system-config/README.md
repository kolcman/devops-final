# backup-system-config (deb package)

Исходники deb-пакета для блока 4 (резервное копирование).

## Что ставит пакет

- `/usr/sbin/backup-run.sh` — запуск бэкапа
- `/usr/sbin/backup-rotate.sh` — ротация архивов
- `/usr/sbin/restore-run.sh` — восстановление из архива
- `/etc/systemd/system/linux-final-backup.service`
- `/etc/systemd/system/linux-final-backup.timer`
- `/etc/systemd/system/linux-final-backup-rotate.service`
- `/etc/systemd/system/linux-final-backup-rotate.timer`

## Поведение после установки

`postinst` выполняет:
- `systemctl daemon-reload`
- `systemctl enable --now linux-final-backup.timer`
- `systemctl enable --now linux-final-backup-rotate.timer`

## Сборка

```bash
sudo apt-get update
sudo apt-get install -y debhelper-compat build-essential

cd packages/backup-system-config
dpkg-buildpackage -us -uc -b
```
