#!/bin/sh

pod_name=microservices

pgsql_image="docker.io/library/postgres:14.2"

podman pod create --replace --name $pod_name \
    -p 8080:8080 \
    -p 8280:8280 \
    -p 5432:5432

podman create --name broker-service \
    --pod $pod_name \
    --restart always \
    microservices/broker-service

podman create --name authentication-service \
    --pod $pod_name \
    --restart always \
    -e DSN="host=127.0.0.1 port=5432 user=postgres password=password \
    dbname=users sslmode=disable timezone=UTC connect_timeout=5" \
    microservices/authentication-service

podman create --name postgresql \
    --pod $pod_name \
    --restart always \
    -e POSTGRES_USER="postgres" \
    -e POSTGRES_PASSWORD="password" \
    -e POSTGRES_DB="users" \
    -v ./db-data/postgres/:/var/lib/postgresql/data/:Z \
    $pgsql_image
