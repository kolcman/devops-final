# Руководство системного администратора

Рабочее руководство по администрированию инфраструктуры.

## 1. Общая информация о системе

- Проект: инфраструктура PKI + OpenVPN + Monitoring + Backup
- Облачный провайдер: VM в публичном облаке
- Компоненты: CA, VPN, Prometheus/Alertmanager, backup scripts + deb packages

## 2. Доступы и ответственность

- Администраторы: инженер инфраструктуры (основной), резервный инженер.
- Доступ к VM: SSH по ключам.
- Доступ к почтовому каналу алертов: только ответственные за мониторинг.

## 3. Инвентарь хостов и сервисов

- CA VM: `192.168.10.31` / `111.88.148.119`
- VPN VM: `192.168.10.7` / `111.88.153.158`
- Monitoring VM: `192.168.10.4` / `111.88.156.197`

Сервисы:
- OpenVPN: `udp/1194`
- Prometheus: `tcp/9090`
- Alertmanager: `tcp/9093`
- node_exporter: `tcp/9100`

## 4. Где лежат артефакты

- Скрипты: `scripts/`
- Deb-пакеты (исходники): `packages/`
- Конфиги мониторинга: `monitoring/`
- Документация: `docs/`

## 5. Быстрый runbook по серверам

### 5.1 CA VM

Назначение:
- выпуск и подпись сертификатов (Easy-RSA).

Проверка:

```bash
sudo systemctl status ca-server-init.service --no-pager
sudo ls -la /var/lib/ca-server/pki
```

### 5.2 VPN VM

Назначение:
- OpenVPN сервер для пользователей.

Проверка:

```bash
sudo systemctl status openvpn-server@server --no-pager
sudo ss -lunpt | grep 1194
```

### 5.3 Monitoring VM

Назначение:
- Prometheus и Alertmanager.

Проверка:

```bash
sudo systemctl status prometheus alertmanager --no-pager
sudo ss -lntp | grep -E '9090|9093'
```

### 5.4 Backup component

Назначение:
- резервное копирование и восстановление.

Проверка:

```bash
sudo systemctl list-timers --all | grep linux-final-backup
sudo systemctl status linux-final-backup.service --no-pager
```

## 6. Переустановка и разворачивание

Рекомендуемый порядок:
1. CA (PKI)
2. VPN
3. Monitoring
4. Backup

Deb-пакеты:
- `packages/ca-server/`
- `packages/openvpn-server-config/`
- `packages/backup-system-config/`

## 7. Backup/Restore

- Архитектура: `docs/04-backup-design.md`
- Отчет теста восстановления: `docs/05-dr-test-report.md`

Ключевые команды:

```bash
sudo systemctl start linux-final-backup.service
LATEST="$(sudo bash -c 'ls -1t /var/backups/linux-final/backup-*.tar.gz | head -n1')"
sudo FORCE=1 RESTORE_ROOT=/tmp/restore-check /usr/sbin/restore-run.sh "$LATEST"
```

## 8. Мониторинг и алерты

Основные алерты:
- `InstanceDown`
- `VPNServerDown`
- `HighCPUUsage`
- `HighMemoryUsage`
- `LowDiskSpace`
- `BackupJobFailed`
- `BackupStale`
- `BackupStorageLowSpace`

Действия при срабатывании:
1. Подтвердить алерт в Prometheus/Alertmanager.
2. Проверить состояние сервиса на целевой VM.
3. Выполнить восстановление по runbook.
4. Зафиксировать инцидент и RCA.

## 9. Ссылки на документы

- Схема инфраструктуры: `docs/02-infrastructure-diagram.md`
- Схема потоков данных: `docs/08-data-flow-diagram.md`
- Руководство пользователя: `docs/03-vpn-user-guide.md`
- Мониторинг: `docs/01-monitoring-design.md`
- Backup дизайн: `docs/04-backup-design.md`
- DR test report: `docs/05-dr-test-report.md`
