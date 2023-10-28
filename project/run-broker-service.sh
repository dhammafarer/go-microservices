#!/bin/sh

podman run -d --name broker-service \
    -p 8080:8080 \
    --restart always \
    microservices/broker-service
