# Учебный проект: PKI + OpenVPN + Monitoring

Финальная работа по курсу “Старт в DevOps”: небольшая инфраструктура в облаке — **PKI (Easy‑RSA)**, **OpenVPN**, **Prometheus/Alertmanager** и документация.

## Что уже готово

- **PKI**: выпуск корневого сертификата и подпись запросов (CSR).
- **VPN**: сервер OpenVPN и процесс выдачи доступа пользователям.
- **Мониторинг**: сбор метрик и алерты (Prometheus + Alertmanager).

## Что в работе

- **Бэкап** (блок 4 брифа).
- Дополнение документации по оставшимся блокам.

## Структура репозитория

```text
.
├── scripts/                 # bash-скрипты развёртывания/настройки/обслуживания
│   ├── vpn/
│   └── monitoring/
├── monitoring/              # шаблоны конфигов Prometheus/Alertmanager
│   ├── prometheus/
│   └── alertmanager/
├── packages/                # исходники deb-пакетов (debian/*, control, postinst и т.п.)
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
- **Скрипт настройки VPN‑VM**: `scripts/vpn/setup-vpn.sh`
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

## Важно по секретам

- SMTP пароль и другие секреты не хранятся в репозитории.
- В шаблоне `monitoring/alertmanager/alertmanager.yml` используется плейсхолдер `__SET_IN_VM__`.

## Формат сдачи

- **Архив** со всеми документами/скриптами/пакетами + файл с пояснениями к именам.
- **Ссылка на папку** (например, Google Drive) + документ со ссылками и пояснениями.
- **Ссылка на git‑репозиторий** + документы в Google Docs + документ со ссылками и пояснениями.

