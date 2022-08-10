#!/bin/sh
set -e

APPARMOR_URL="https://version.home-assistant.io/apparmor.txt"

# Make sure we can talk to the Docker daemon
echo "Waiting for Docker daemon..."
while ! docker version 2> /dev/null > /dev/null; do
	sleep 1
done

# Install Supervisor, plug-ins and landing page
echo "Loading containers..."
for image in /build/images/*.tar; do
	docker load --input "${image}"
done

# Tag the Supervisor how the OS expects it to be tagged
supervisor=$(docker images --filter "label=io.hass.type=supervisor" --quiet)
arch=$(docker inspect --format '{{ index .Config.Labels "io.hass.arch" }}' "${supervisor}")
docker tag "${supervisor}" "ghcr.io/home-assistant/${arch}-hassio-supervisor:latest"

# Setup AppArmor
mkdir -p "/data/supervisor/apparmor"
wget -O "/data/supervisor/apparmor/hassio-supervisor" "${APPARMOR_URL}"

