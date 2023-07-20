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

## Настройка Splunk сервера + сборка docker image "splunk-forward" с пушем метрик и логов Docker сокета

Запуск сервера Splunk-enterprise `docker-compose up so1 -d`

UI Splunk доступен на порту 8000 `http://localhost:8000`

Login `admin` pass: `admin!@#` - можно изменить env: `- SPLUNK_PASSWORD=admin!@#`

Проверяем, доступен ли 9997 порт `Settings > Forwarding and receiving > Configure receiving > status:Enabled`

<p align="center"> 
<a href="https://raw.githubusercontent.com/Dodexq/docker-splunk/main/screenshots/4.png" rel="some text"><img src="https://raw.githubusercontent.com/Dodexq/docker-splunk/main/screenshots/4.png" alt="" width="500" /></a>
</p>

Добавляем два индекса: `dev_docker_node` и `dev_docker_stats`
`Settings > Indexes > New Index`

Build images: `cd ./u-splunk-forwarder > docker build --tag="$USER/uforward" .`

По дефолту user:pass `adminforward:admin4orward` создается при первом старте `./u-splunk-forwarder/first_start.sh`

Так же, при билде биндится адрес Slunk сервера:

```
/splunkforwarder/bin/splunk add forward-server <host_or_ip>:9997 -auth 'adminforward:admin4orward' \
```


Название images следует изменить в docker-compose: 

```
services:
  uf1:
    image: <images>
    hostname: uf1
    container_name: uf1
    networks:
      - splunknet
    environment:
      - SPLUNK_STANDALONE_URL=so1
      - SPLUNK_INDEX=dev
    volumes:
       - /var/lib/docker/containers:/host/containers:ro
       - /var/run/docker.sock:/var/run/docker.sock:ro
```

* Скрипты вывода метрик и логов в Splunk: `./u-splunk-forwarder/docker-stats`
* Передаваемые поля: `./u-splunk-forwarder/docker-stats/props.conf`
* Время срабатывания скриптов: `/u-splunk-forwarder/init/inputs.conf`

Скрипт, выдающий только diff логи:

```
#!/bin/bash
DOCKER_BIN=/docker/docker
LOGS_PATH=/splunkforwarder/bin/scripts

for container_id in $("$DOCKER_BIN" ps -q); do
    LOGS=$("$DOCKER_BIN" logs "$container_id" 2> /dev/null)

    if [ ! -f "$LOGS_PATH/logs.id-$container_id" ]; then
    touch "$LOGS_PATH/logs.id-$container_id"
    fi
    
    if ! diff -q <(echo "$LOGS") "$LOGS_PATH/logs.id-$container_id" > /dev/null; then
        DIFF_LOGS=$(diff -d --changed-group-format='%>' --unchanged-group-format='' "$LOGS_PATH/logs.id-$container_id" <(echo "$LOGS"))
        echo "$LOGS" > "$LOGS_PATH/logs.id-$container_id"
        echo "$DIFF_LOGS"
    fi
done
```

За основу взят: https://github.com/outcoldman/docker-stats-splunk-forwarder/tree/master