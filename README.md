## Docker container logs to Splunk
### Два способа передачи логов из контейнеров Docker в приложение Splunk

1. Способ HTTP Event Collector
2. Splunk-forwarder собрать Image ./u-splunk-forwarder


## Настройка Splunk

Запуск сервера Splunk-enterprise `docker-compose up so1 -d`

UI Splunk доступен на порту 8000 `http://localhost:8000`

Login `admin` pass: `admin!@#` - можно изменить env: `- SPLUNK_PASSWORD=admin!@#`
