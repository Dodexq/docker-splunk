#!/bin/bash

DOCKER_BIN=docker
"$DOCKER_BIN" inspect $("$DOCKER_BIN" ps -aq) | jq -c -M -r ".[]"
