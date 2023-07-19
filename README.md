## Docker container logs to Splunk
### Два способа передачи логов из контейнеров Docker в приложение Splunk

1. Способ HTTP Event Collector
2. Splunk-forwarder собрать Image ./u-splunk-forwarder


## Настройка Splunk сервера + передача логов по HEC из рантайм Docker контейнеров 

Запуск сервера Splunk-enterprise `docker-compose up so1 -d`

UI Splunk доступен на порту 8000 `http://localhost:8000`

Login `admin` pass: `admin!@#` - можно изменить env: `- SPLUNK_PASSWORD=admin!@#`

Если не будет SSL (обязательно): `Settings > Data inputs > HTTP Event Collector > Global Settings` убираем `Enable SSL`, проверяем порт `8088`

<p align="center"> 
<a href="https://raw.githubusercontent.com/Dodexq/docker-splunk/main/screenshots/1.png" rel="some text"><img src="https://raw.githubusercontent.com/Dodexq/docker-splunk/main/screenshots/1.png" alt="" width="500" /></a>
</p>

Добавляем HEC токен `New token`: `Name: docker-hec > Input Settings: Create a new index` название токена прописано в docker-compose: `splunk-index: splunk_index`

<p align="center"> 
<a href="https://raw.githubusercontent.com/Dodexq/docker-splunk/main/screenshots/2.png" rel="some text"><img src="https://raw.githubusercontent.com/Dodexq/docker-splunk/main/screenshots/2.png" alt="" width="500" /></a>
</p>

Token Value следует скопировать, будем использовать при подключении в docker-compose `splunk-token: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`

Следующий код необходимо добавлять ко всем контейнерам, с которых будут собираться логи:

```
    logging:
        driver: splunk
        options:
            splunk-url: http://<splunk_hostname_or_ip>:8088
            splunk-token: <xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx>
            splunk-index: <splunk_index>
            splunk-insecureskipverify: "true"
            splunk-format: "json"
            tag: "{{.Name}}/{{.ID}}"
```

Для тестирования запустим контейнер nginx из docker-compose:

```
  nginx1:
    image: nginx
    hostname: nginx1
    container_name: nginx1
    networks:
      - splunknet
    logging:
        driver: splunk
        options:
            splunk-url: http://172.23.0.2:8088
            splunk-token: f16ff2ee-0773-43e3-9bbd-21f1bca57110
            splunk-index: splunk_index
            splunk-insecureskipverify: "true"
            splunk-format: "json"
            tag: "{{.Name}}/{{.ID}}"
    ports:
      - 80:80
```

Просмотр входящих логов: `Apps > Search & Reporting` и поиск по индексу `index="splunk_index"`

<p align="center"> 
<a href="https://raw.githubusercontent.com/Dodexq/docker-splunk/main/screenshots/3.png" rel="some text"><img src="https://raw.githubusercontent.com/Dodexq/docker-splunk/main/screenshots/3.png" alt="" width="500" /></a>
</p>

По тегам можно выбрать контейнер.
