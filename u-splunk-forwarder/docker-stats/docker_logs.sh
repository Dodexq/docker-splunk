#!/bin/bash
DOCKER_BIN=/docker/docker
LOGS_PATH=/splunkforwarder/bin/scripts

for container_id in $("$DOCKER_BIN" ps -q); do
    LOGS=$("$DOCKER_BIN" logs "$container_id" 2> /dev/null | 
    sed "s/^/$("$DOCKER_BIN" ps -af "id=$container_id" --format "{{.Names}}"), /")

    if [ ! -f "$LOGS_PATH/logs.id-$container_id" ]; then
    touch "$LOGS_PATH/logs.id-$container_id"
    fi
    
    if ! diff -q <(echo "$LOGS") "$LOGS_PATH/logs.id-$container_id" > /dev/null; then
        DIFF_LOGS=$(diff -d --changed-group-format='%>' --unchanged-group-format='' "$LOGS_PATH/logs.id-$container_id" <(echo "$LOGS"))
        echo "$LOGS" > "$LOGS_PATH/logs.id-$container_id"
        echo "$DIFF_LOGS"
    fi
done