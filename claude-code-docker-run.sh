#!/bin/bash

# Script to reuse Claude Code Docker container
# Creates a new container if it doesn't exist, reuses existing container if it does

# Container and image name settings
CONTAINER_NAME="claude-code-container"
IMAGE_NAME="ghcr.io/gendosu/claude-code-docker:latest"

# Get current directory
CURRENT_DIR=$(pwd)

# Check for required environment variables
if [ -z "$GITHUB_TOKEN" ]; then
  echo "Warning: GITHUB_TOKEN environment variable is not set"
  # exit 1
fi

# Check if image exists
if ! docker image inspect "$IMAGE_NAME" &> /dev/null; then
  echo "Image $IMAGE_NAME not found. Pulling..."
  docker pull "$IMAGE_NAME"
  if [ $? -ne 0 ]; then
    echo "Failed to pull image"
    exit 1
  fi
fi

# Check if container exists
if docker container inspect "$CONTAINER_NAME" &> /dev/null; then
  # Container exists
  
  # Check container status
  CONTAINER_STATUS=$(docker container inspect -f '{{.State.Status}}' "$CONTAINER_NAME")
  
  if [ "$CONTAINER_STATUS" = "running" ]; then
    echo "Container $CONTAINER_NAME is already running"
  else
    echo "Starting container $CONTAINER_NAME..."
    docker start -i "$CONTAINER_NAME"
  fi
else
  # Container does not exist, create and start a new one
  echo "Creating and starting container $CONTAINER_NAME..."
  
  # Create and start container (without --rm flag)
  docker run -it \
    --name "$CONTAINER_NAME" \
    -e GITHUB_TOKEN \
    -w "$CURRENT_DIR" \
    -v "$CURRENT_DIR:$CURRENT_DIR" \
    "$IMAGE_NAME" "$@"
fi

exit 0
