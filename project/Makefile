FRONT_END_BINARY=frontApp
BROKER_BINARY=brokerApp
AUTH_BINARY=authApp
LOGGER_BINARY=loggerApp
MAILER_BINARY=mailerApp
LISTENER_BINARY=listenerApp
FRONT_BINARY=frontendApp

POD_NAME=microservices

up:
	@echo "Starting Docker images..."
	podman-compose up -d
	@echo "Docker images started!"

up_build: build_broker build_auth build_logger build_mailer build_listener build_front
	@echo "Stopping docker images (if running...)"
	podman-compose down
	@echo "Building (when required) and starting docker images..."
	podman-compose up --build -d
	@echo "Docker images built and started!"

down:
	@echo "Stopping docker compose..."
	podman-compose down
	@echo "Done!"

build_broker:
	@echo "Building broker binary..."
	cd ../broker-service && env GOOS=linux CGO_ENABLED=0 go build -o ${BROKER_BINARY} ./cmd/api
	@echo "Done!"

build_listener:
	@echo "Building listener binary..."
	cd ../listener-service && env GOOS=linux CGO_ENABLED=0 go build -o ${LISTENER_BINARY} .
	@echo "Done!"

build_mailer:
	@echo "Building mailer binary..."
	cd ../mail-service && env GOOS=linux CGO_ENABLED=0 go build -o ${MAILER_BINARY} ./cmd/api
	@echo "Done!"

build_auth:
	@echo "Building auth binary..."
	cd ../authentication-service && env GOOS=linux CGO_ENABLED=0 go build -o ${AUTH_BINARY} ./cmd/api
	@echo "Done!"

build_logger:
	@echo "Building logger binary..."
	cd ../logger-service && env GOOS=linux CGO_ENABLED=0 go build -o ${LOGGER_BINARY} ./cmd/api
	@echo "Done!"

build_front:
	@echo "Building front end binary..."
	cd ../front-end && env CGO_ENABLED=0 go build -o ${FRONT_BINARY} ./cmd/web
	@echo "Done!"

build_frontend:
	@echo "Building front end binary..."
	cd ../front-end && env CGO_ENABLED=0 go build -o ${FRONT_END_BINARY} ./cmd/web
	@echo "Done!"

start: build_front
	@echo "Starting front end"
	cd ../front-end && ./${FRONT_END_BINARY} &

stop:
	@echo "Stopping front end..."
	@-pkill -SIGTERM -f "./${FRONT_END_BINARY}"
	@echo "Stopped front end!"
