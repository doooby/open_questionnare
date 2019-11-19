#!/usr/bin/env bash

set -e

cd /opt/oq/repo
git pull origin master

compose_file=ops/docker-compose.yml
docker-compose -f $compose_file build --pull
docker-compose -f $compose_file run --rm web bundle install
docker-compose -f $compose_file up -d
