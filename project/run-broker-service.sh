#!/bin/sh

podman run --rm -d --name broker-service \
    -p 8080:8080 \
    microservices/broker-service
