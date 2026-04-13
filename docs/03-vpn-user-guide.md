# Руководство пользователя VPN

Короткая инструкция для подключения к OpenVPN.

## Что нужно получить от администратора

- Файл `client.ovpn` (или отдельные `ca.crt`, `client.crt`, `client.key`)
- Адрес VPN-сервера и порт (по умолчанию `111.88.145.140:1194/udp`)

## Linux (Ubuntu/Debian)

1. Установить клиент:

```bash
sudo apt-get update
sudo apt-get install -y openvpn
```

2. Подключиться:

```bash
cd ~/vpn-client
sudo openvpn --config client.ovpn
```

3. Признак успешного подключения:
- в выводе есть `Initialization Sequence Completed`

## Проверка, что VPN работает

1. До подключения:

```bash
curl ifconfig.me
```

2. После подключения (в другом терминале):

```bash
curl ifconfig.me
```

Ожидаемо: второй IP равен IP VPN-сервера.

## Как отключиться

- В окне, где запущен OpenVPN, нажать `Ctrl+C`.

