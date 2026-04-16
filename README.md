# Infrastructure: PKI + OpenVPN + Monitoring + Backup

Небольшая инфраструктура в облаке: **PKI (Easy-RSA)**, **OpenVPN**, **Prometheus/Alertmanager**, **Backup/Restore** и документация для эксплуатации.

## Состав

- **PKI**: выпуск корневого сертификата и подпись CSR.
- **VPN**: OpenVPN сервер и выдача доступов пользователям.
- **Мониторинг**: Prometheus + Alertmanager, системные и backup-алерты.
- **Резервное копирование**: backup/restore/rotation скрипты, systemd timers, deb-пакет.

## Структура репозитория

```text
.
├── scripts/                 # bash-скрипты развёртывания/настройки/обслуживания
│   ├── backup/
│   ├── vpn/
│   └── monitoring/
├── monitoring/              # шаблоны конфигов Prometheus/Alertmanager
│   ├── prometheus/
│   └── alertmanager/
├── packages/                # исходники deb-пакетов (debian/*, control, postinst и т.п.)
│   ├── backup-system-config/
│   ├── ca-server/
│   └── openvpn-server-config/
├── docs/                    # вся документация проекта
│   ├── 02-infrastructure-diagram.md
│   ├── 08-data-flow-diagram.md
│   ├── 01-monitoring-design.md
│   ├── 03-vpn-user-guide.md
│   ├── 04-backup-design.md
│   ├── 05-dr-test-report.md
│   ├── 06-admin-guide.md
│   ├── 07-roadmap.md
│   └── 99-submission-index.md
└── README.md
```

## Как начать

1. Просмотреть документацию в `docs/`.
2. Собрать нужные deb-пакеты из `packages/`.
3. Применить скрипты из `scripts/` на целевых VM.

## Быстрые ссылки

- **Deb‑пакет CA (исходники)**: `packages/ca-server/`
- **Deb‑пакет VPN (исходники)**: `packages/openvpn-server-config/`
- **Deb‑пакет Backup (исходники)**: `packages/backup-system-config/`
- **Скрипт настройки VPN‑VM**: `scripts/vpn/setup-vpn.sh`
- **Скрипты бэкапов**:
  - `scripts/backup/backup-run.sh`
  - `scripts/backup/restore-run.sh`
  - `scripts/backup/backup-rotate.sh`
- **Скрипты мониторинга**:
  - `scripts/monitoring/setup-node-exporter.sh`
  - `scripts/monitoring/setup-monitoring-stack.sh`
- **Шаблоны мониторинга**:
  - `monitoring/prometheus/prometheus.yml`
  - `monitoring/prometheus/alert.rules.yml`
  - `monitoring/alertmanager/alertmanager.yml`
- **Документация проекта**:
  - `docs/01-monitoring-design.md`
  - `docs/02-infrastructure-diagram.md`
  - `docs/03-vpn-user-guide.md`
  - `docs/04-backup-design.md`
  - `docs/05-dr-test-report.md`
  - `docs/06-admin-guide.md`
  - `docs/07-roadmap.md`
  - `docs/08-data-flow-diagram.md`
  - `docs/99-submission-index.md`

## Проверка готовности

- Таймеры backup активны: `linux-final-backup.timer`, `linux-final-backup-rotate.timer`.
- Ручной backup выполняется без ошибок: `linux-final-backup.service`.
- Restore проходит в тестовый каталог через `/usr/sbin/restore-run.sh`.
- Контрольная сумма архива подтверждается через `sha256sum -c`.

## Важно по секретам

- SMTP пароль и другие секреты не хранятся в репозитории.
- В шаблоне `monitoring/alertmanager/alertmanager.yml` используется плейсхолдер `__SET_IN_VM__`.

