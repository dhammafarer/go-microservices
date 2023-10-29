#!/bin/sh

pod_name=microservices

podman pod create --name $pod_name \
    -p 8080:8080

podman create --name broker-service \
    --pod $pod_name \
    --restart always \
    microservices/broker-service
