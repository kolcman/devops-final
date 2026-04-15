# Проектирование мониторинга

## Цели

- Видеть доступность VM и основных сервисов.
- Рано узнавать о нехватке ресурсов.
- Получать уведомления на email через Alertmanager.

## Компоненты

- Prometheus VM: `192.168.10.4` (`111.88.156.197`)
- VPN VM: `192.168.10.7` (`111.88.153.158`)
- CA VM: `192.168.10.31` (`111.88.148.119`)
- Exporter: `prometheus-node-exporter` на VPN/CA

## Метрики

- `up` — доступность targets
- `node_cpu_seconds_total` — CPU
- `node_memory_MemAvailable_bytes`, `node_memory_MemTotal_bytes` — RAM
- `node_filesystem_*` — свободное место

## Алерты

- `InstanceDown` (critical)
- `HighCPUUsage` (warning)
- `HighMemoryUsage` (warning)
- `LowDiskSpace` (critical)
- `VPNServerDown` (critical)

## Уведомления

- Канал: email через SMTP Yandex (`smtp.yandex.ru:587`)
- Доставка выполняется Alertmanager.

## Безопасность

- Доступ к exporter по порту `9100` ограничен источником (Prometheus VM).
- SMTP пароль не хранится в репозитории, в шаблоне используется плейсхолдер.

