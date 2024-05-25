#!/bin/sh

# 封裝停止 Script

docker compose -f ./plane-selfhost/plane-app/docker-compose.yaml --env-file ./plane-selfhost/plane-app/.env down

docker compose -f ./docker-compose.yml --env-file ./.env down


