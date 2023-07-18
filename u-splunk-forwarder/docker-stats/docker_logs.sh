#!/bin/bash

DOCKER_BIN=/docker/docker

for container_id in $("$DOCKER_BIN" ps -q); do
  command_date=$(date -u +%Y-%m-%dT%H:%M:%S%z)
  "$DOCKER_BIN" logs $container_id | sed "s/^/$container_id,/"

done