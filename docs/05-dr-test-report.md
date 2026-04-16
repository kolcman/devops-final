# Отчёт о тесте восстановления (DR test)

## Цель

Проверить работоспособность сценария восстановления из резервной копии после установки пакета `backup-system-config`.

## Среда

- Backup/Monitoring VM: `compute-prom` (`111.88.156.197`)
- Пользователь: `cdn13`
- Пакет: `backup-system-config_1.1_all.deb`

## Выполненные шаги

1. Проверка активных таймеров backup:
   - `linux-final-backup.timer`
   - `linux-final-backup-rotate.timer`
2. Ручной запуск `linux-final-backup.service`.
3. Проверка появления архивов `backup-*.tar.gz` и checksum-файлов `*.sha256`.
4. Выбор последнего архива для восстановления.
5. Восстановление в тестовый каталог:
   - `FORCE=1 RESTORE_ROOT=/tmp/restore-check /usr/sbin/restore-run.sh "$LATEST"`
6. Проверка наличия восстановленных данных в `/tmp/restore-check/etc` и `/tmp/restore-check/var`.
7. Проверка целостности архива:
   - `sha256sum -c "${LATEST}.sha256"`

## Результат

- Backup-job выполнен успешно (`status=0/SUCCESS`).
- Архив и checksum созданы.
- Восстановление выполнено успешно.
- Контрольная сумма совпадает (`OK`).

## Артефакты для сдачи

Приложить скриншоты/вывод:

1. `systemctl status linux-final-backup.service --no-pager -l`
2. `ls -lh /var/backups/linux-final | grep 'backup-.*tar.gz'`
3. `ls -lh /var/backups/linux-final | grep '\.sha256'`
4. `restore-run.sh` с успешным завершением
5. `sha256sum -c ...` со статусом `OK`

## Команды, использованные в тесте

```bash
sudo systemctl list-timers --all | grep linux-final-backup
sudo systemctl start linux-final-backup.service
sudo systemctl status linux-final-backup.service --no-pager -l
sudo ls -lh /var/backups/linux-final | grep 'backup-.*tar.gz'
sudo ls -lh /var/backups/linux-final | grep '\.sha256'
LATEST="$(sudo bash -c 'ls -1t /var/backups/linux-final/backup-*.tar.gz | head -n1')"
sudo rm -rf /tmp/restore-check
sudo mkdir -p /tmp/restore-check
sudo FORCE=1 RESTORE_ROOT=/tmp/restore-check /usr/sbin/restore-run.sh "$LATEST"
sudo ls -la /tmp/restore-check/etc | head
sudo ls -la /tmp/restore-check/var | head
sudo sha256sum -c "${LATEST}.sha256"
```
