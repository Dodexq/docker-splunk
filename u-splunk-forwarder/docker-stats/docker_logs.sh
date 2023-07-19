#!/bin/bash
DOCKER_BIN=/docker/docker

for container_id in $("$DOCKER_BIN" ps -q); do
    LOGS=$("$DOCKER_BIN" logs "$container_id" 2> /dev/null)

    if [ ! -f "logs.id-$container_id" ]; then
    touch "logs.id-$container_id"
    fi
    
    if ! diff -q <(echo "$LOGS") "logs.id-$container_id" > /dev/null; then
        DIFF_LOGS=$(diff -d --changed-group-format='%>' --unchanged-group-format='' "logs.id-$container_id" <(echo "$LOGS"))
        echo "$LOGS" > "logs.id-$container_id"
        echo "$DIFF_LOGS"
    fi
done