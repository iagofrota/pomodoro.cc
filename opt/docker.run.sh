#!/bin/bash

id_for_container(){
  CONTAINER="$1\s*$"
  CONTAINER_ID="$(docker ps -a | grep "$CONTAINER" | awk '{print $1}')"
  echo $CONTAINER_ID
}

if [ -z "$(id_for_container 'pomodoro-api-sessions')" ]; then
  echo "\n ===> starting 'pomodoro-api-sessions'"
  docker run --name pomodoro-api-sessions \
    --restart=always \
    -d \
    redis:latest \
    redis-server
fi

if [ -z "$(id_for_container 'pomodoro-api-db')" ]; then
  echo "\n ===> starting 'pomodoro-api-db'"
  docker run --name pomodoro-api-db \
    --restart=always \
    -d \
    -v /pomodoro.cc/db:/data/db \
    dockerfile/mongodb
fi

docker run --name pomodoro-api-1 \
  --restart=always \
  -d \
  -v /pomodoro.cc/credentials.json:/credentials.json \
  --link pomodoro-api-sessions:pomodoro-api-sessions \
  --link pomodoro-api-db:pomodoro-api-db \
  christianfei/pomodoro-api

docker run --name pomodoro-api-2 \
  --restart=always \
  -d \
  -v /pomodoro.cc/credentials.json:/credentials.json \
  --link pomodoro-api-sessions:pomodoro-api-sessions \
  --link pomodoro-api-db:pomodoro-api-db \
  christianfei/pomodoro-api

docker run --name pomodoro-socket-io \
  --restart=always \
  -d \
  christianfei/pomodoro-socket-io

docker run --name pomodoro-app \
  --restart=always \
  -d \
  -p 80:80 \
  -p 443:443 \
  --link pomodoro-api-1:pomodoro-api-1 \
  --link pomodoro-api-2:pomodoro-api-2 \
  --link pomodoro-socket-io:pomodoro-socket-io \
  -v /pomodoro.cc/ssl:/etc/nginx/ssl/pomodoro.cc \
  -v /pomodoro.cc/app/www:/var/www/pomodoro.cc/ \
  christianfei/pomodoro-app