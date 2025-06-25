#!/bin/sh

docker compose down
# 24June2025 : dont delete this volume = restore from VM snapshot otherwise ..
#docker volume rm limesurvey_db_data
docker compose up -d
