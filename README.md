# Учебный проект: PKI + OpenVPN + Monitoring + Backups

Финальная работа по курсу “Старт в DevOps”: небольшая инфраструктура в облаке — **PKI (Easy‑RSA)**, **OpenVPN**, **Prometheus/Alertmanager**, **бэкапы** и документация.

## Что реализуется

- **PKI**: выпуск корневого сертификата и подпись запросов (CSR).
- **VPN**: сервер OpenVPN и процесс выдачи доступа пользователям.
- **Мониторинг**: сбор метрик и алерты (Prometheus + Alertmanager).
- **Бэкап**: план + автоматизация резервного копирования данных и артефактов.

## Структура репозитория

```text
.
├── scripts/                 # bash-скрипты развёртывания/настройки/обслуживания
│   ├── pki/
│   ├── vpn/
│   ├── monitoring/
│   └── backup/
├── packages/                # исходники deb-пакетов (debian/*, control, postinst и т.п.)
│   ├── pki/
│   ├── vpn/
│   ├── monitoring/
│   └── backup/
├── docs/                    # вся документация проекта
│   ├── 01-monitoring-design.md
│   ├── 02-backup-design.md
│   ├── 03-vpn-user-guide.md
│   ├── 04-admin-guide.md
│   ├── 05-roadmap.md
│   └── diagrams/
│       ├── infra.png
│       └── dataflows.png
└── README.md
```

## Как начать

- **Скрипты**: `scripts/`
- **Deb‑пакеты (исходники)**: `packages/`
- **Документация и схемы**: `docs/`

## Ссылки

- **Бриф/условие задания**: `Бриф. Старт в DevOps — системное администрирование для начинающих.pdf`
- **Документация проекта** (если добавлена): `docs/`
  - `docs/01-monitoring-design.md`
  - `docs/02-backup-design.md`
  - `docs/03-vpn-user-guide.md`
  - `docs/04-admin-guide.md`
  - `docs/05-roadmap.md`

## Формат сдачи

- **Архив** со всеми документами/скриптами/пакетами + файл с пояснениями к именам.
- **Ссылка на папку** (например, Google Drive) + документ со ссылками и пояснениями.
- **Ссылка на git‑репозиторий** + документы в Google Docs + документ со ссылками и пояснениями.

