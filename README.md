# Учебный проект: PKI + OpenVPN + Monitoring + Backup

Финальная работа по курсу “Старт в DevOps”: небольшая инфраструктура в облаке — **PKI (Easy-RSA)**, **OpenVPN**, **Prometheus/Alertmanager**, **Backup/Restore** и документация.

## Что уже готово

- **PKI**: выпуск корневого сертификата и подпись запросов (CSR).
- **VPN**: сервер OpenVPN и процесс выдачи доступа пользователям.
- **Мониторинг**: сбор метрик и алерты (Prometheus + Alertmanager).
- **Бэкап**: скрипты backup/restore/rotation, systemd timers, deb-пакет backup-компонента.

## Что в работе

- Финальная проверка артефактов блока 4 на VM.
- Дополнение документации по оставшимся блокам.

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
│   ├── 01-monitoring-design.md
│   └── 03-vpn-user-guide.md
└── README.md
```

## Как начать

- **Скрипты**: `scripts/`
- **Deb‑пакеты (исходники)**: `packages/`
- **Документация и схемы**: `docs/`

## Ссылки

- **Бриф/условие задания**: `Бриф. Старт в DevOps — системное администрирование для начинающих.pdf`
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
  - `docs/03-vpn-user-guide.md`
  - `docs/04-backup-design.md`
  - `docs/05-dr-test-report.md`

## Важно по секретам

- SMTP пароль и другие секреты не хранятся в репозитории.
- В шаблоне `monitoring/alertmanager/alertmanager.yml` используется плейсхолдер `__SET_IN_VM__`.

## Формат сдачи

- **Архив** со всеми документами/скриптами/пакетами + файл с пояснениями к именам.
- **Ссылка на папку** (например, Google Drive) + документ со ссылками и пояснениями.
- **Ссылка на git‑репозиторий** + документы в Google Docs + документ со ссылками и пояснениями.

