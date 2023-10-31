#!/bin/sh

POD_NAME=microservices

PGSQL_IMAGE="docker.io/library/postgres:14.2"
PGADMIN_IMAGE=docker.io/dpage/pgadmin4:latest

PGADMIN_EMAIL=pgadmin@example.com
PGADMIN_PASSWORD=K4HeAk1xzNg4OZ9zAZVKSSwXs
PGADMIN_PORT=5050

MONGO_IMAGE="docker.io/library/mongo:4.2.16-bionic"

podman pod create --replace --name $POD_NAME \
    -p 8081-8083:8081-8083 \
    -p 5050:5050 \
    -p 27017:27017 \
    -p 5432:5432

podman create --name ${POD_NAME}-broker-service \
    --pod $POD_NAME \
    --restart always \
    microservices/broker-service

podman create --name ${POD_NAME}-authentication-service \
    --pod $POD_NAME \
    --restart always \
    -e DSN="host=127.0.0.1 port=5432 user=postgres password=password \
    dbname=users sslmode=disable timezone=UTC connect_timeout=5" \
    microservices/authentication-service

podman create --name ${POD_NAME}-pgadmin \
    -e "PGADMIN_DEFAULT_EMAIL=${PGADMIN_EMAIL}" \
    -e "PGADMIN_DEFAULT_PASSWORD=${PGADMIN_PASSWORD}" \
    -e "PGADMIN_LISTEN_PORT=${PGADMIN_PORT}" \
    -v ./db-data/servers.json:/pgadmin4/servers.json:Z \
    --pod $POD_NAME \
    $PGADMIN_IMAGE

podman create --name ${POD_NAME}-postgres \
    --pod $POD_NAME \
    --restart always \
    -e POSTGRES_USER="postgres" \
    -e POSTGRES_PASSWORD="password" \
    -e POSTGRES_DB="users" \
    -v ./db-data/postgres/:/var/lib/postgresql/data/:Z \
    -v ./initdb/:/docker-entrypoint-initdb.d/:Z \
    $PGSQL_IMAGE

podman create --name ${POD_NAME}-mongo \
    --pod $POD_NAME \
    --restart always \
    -e MONGO_INITDB_DATABASE="logs" \
    -e MONGO_INITDB_ROOT_USERNAME="admin" \
    -e MONGO_INITDB_ROOT_PASSWORD="password" \
    -v ./db-data/mongo/:/data/db:Z \
    $MONGO_IMAGE
