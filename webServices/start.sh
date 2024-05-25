#!/bin/sh

# 封裝啟動 Script

# 先啟動 Plane..等其他服務
docker compose -f ./plane-selfhost/plane-app/docker-compose.yaml --env-file ./plane-selfhost/plane-app/.env up -d


# 最後才啟動 Nginx
docker compose -f ./docker-compose.yml --env-file ./.env up -d
