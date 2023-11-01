FRONT_END_BINARY=frontApp
BROKER_BINARY=brokerApp
AUTH_BINARY=authApp
LOGGER_BINARY=loggerApp
MAILER_BINARY=mailerApp

POD_NAME=microservices

## up: starts all containers in the background without forcing build
up:
	@echo "Starting pod..."
	sh ./pod.sh
	podman pod start ${POD_NAME}
	@echo "Pod started!"

## up_build: stops pod (if running), builds all projects and starts pod again
up_build: build_broker build_auth build_logger build_mailer
	@echo "Stopping pod (if running...)"
	podman pod stop -i ${POD_NAME}
	@echo "Removing pod"
	podman pod rm -i ${POD_NAME}
	@echo "Building (when required)..."
	cd ../broker-service && podman build . -t microservices/broker-service
	cd ../authentication-service && podman build . -t microservices/authentication-service
	cd ../logger-service && podman build . -t microservices/logger-service
	cd ../mail-service && podman build . -t microservices/mailer-service
	@echo "Starting pod..."
	sh ./pod.sh
	podman pod start ${POD_NAME}
	@echo "Pod images built and started!"

## down: stop pod
down:
	@echo "Stopping pod..."
	podman pod stop -i ${POD_NAME}
	podman pod rm -i ${POD_NAME}
	@echo "Done!"

## build_broker: builds the broker binary as a linux executable
build_broker:
	@echo "Building broker binary..."
	cd ../broker-service && env GOOS=linux CGO_ENABLED=0 go build -o ${BROKER_BINARY} ./cmd/api
	@echo "Done!"

## build_mailer: builds the mailer binary as a linux executable
build_mailer:
	@echo "Building mailer binary..."
	cd ../mail-service && env GOOS=linux CGO_ENABLED=0 go build -o ${MAILER_BINARY} ./cmd/api
	@echo "Done!"

## build_auth: builds the auth binary as a linux executable
build_auth:
	@echo "Building auth binary..."
	cd ../authentication-service && env GOOS=linux CGO_ENABLED=0 go build -o ${AUTH_BINARY} ./cmd/api
	@echo "Done!"

## build_logger: builds the logger binary as a linux executable
build_logger:
	@echo "Building logger binary..."
	cd ../logger-service && env GOOS=linux CGO_ENABLED=0 go build -o ${LOGGER_BINARY} ./cmd/api
	@echo "Done!"

## build_front: builds the front end binary
build_front:
	@echo "Building front end binary..."
	cd ../front-end && env CGO_ENABLED=0 go build -o ${FRONT_END_BINARY} ./cmd/web
	@echo "Done!"

## start: starts the front end
start: build_front
	@echo "Starting front end"
	cd ../front-end && ./${FRONT_END_BINARY} &

## stop: stop the front end
stop:
	@echo "Stopping front end..."
	@-pkill -SIGTERM -f "./${FRONT_END_BINARY}"
	@echo "Stopped front end!"
