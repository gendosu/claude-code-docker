# Implementation Guide for Claude Code Docker Container Reuse

## Implementation Overview

In this project, we've implemented a feature to make the Claude Code Docker container reusable. Specifically, we achieve the following process flow:

1. Pull the image if it doesn't exist
2. Create a container if the image exists but the container doesn't
3. Start the existing container if it already exists

This enables container reuse similar to Docker Compose.

## Implementation Method

### 1. Shell Script (claude-code-docker-run.sh)

This script checks the Docker container's state and performs the appropriate action:

```bash
#!/bin/bash

# Container and image name settings
CONTAINER_NAME="claude-code-container"
IMAGE_NAME="ghcr.io/gendosu/claude-code-docker:latest"

# Check if image exists
if ! docker image inspect "$IMAGE_NAME" &> /dev/null; then
  echo "Image not found. Pulling..."
  docker pull "$IMAGE_NAME"
fi

# Check if container exists
if docker container inspect "$CONTAINER_NAME" &> /dev/null; then
  # Check container status
  CONTAINER_STATUS=$(docker container inspect -f '{{.State.Status}}' "$CONTAINER_NAME")
  
  if [ "$CONTAINER_STATUS" = "running" ]; then
    echo "Container is already running"
  else
    echo "Starting container..."
    docker start -i "$CONTAINER_NAME"
  fi
else
  # Create and start a new container if it doesn't exist
  echo "Creating and starting container..."
  docker run -it \
    --name "$CONTAINER_NAME" \
    -e GITHUB_TOKEN \
    -w "$(pwd)" \
    -v "$(pwd):$(pwd)" \
    "$IMAGE_NAME" "$@"
fi
```

### 2. Docker Compose Configuration (compose.yaml)

When using Docker Compose, specify a container name explicitly with the following configuration:

```yaml
services:
  app:
    image: ghcr.io/gendosu/claude-code-docker:latest
    container_name: claude-code-container
    environment:
      NODE_ENV: production
      GITHUB_TOKEN: ${GITHUB_TOKEN}
      GITHUB_ID: ${GITHUB_ID}
    volumes:
      - ${PWD}:${PWD}
    working_dir: ${PWD}
    stdin_open: true  # equivalent to -i
    tty: true         # equivalent to -t
```

## Deployment Methods

### Method 1: Using the Shell Script

1. Download the `claude-code-docker-run.sh` script
2. Make it executable:
   ```bash
   chmod +x claude-code-docker-run.sh
   ```
3. Run the script:
   ```bash
   ./claude-code-docker-run.sh
   ```

### Method 2: Using Docker Compose

1. Update the `compose.yaml` file
2. Run Docker Compose:
   ```bash
   docker compose up
   ```
3. For subsequent runs, the same container will be reused:
   ```bash
   docker compose start
   ```

### Method 3: Manually Running Docker Commands

For the first run (container creation):
```bash
docker run -it \
  --name claude-code-container \
  -e GITHUB_TOKEN \
  -w $(pwd) \
  -v $(pwd):$(pwd) \
  ghcr.io/gendosu/claude-code-docker:latest
```

For subsequent runs (container reuse):
```bash
docker start -i claude-code-container
```

## Technical Notes

1. **Fixed Container Name**: We set a fixed container name (e.g., `claude-code-container`) to enable reuse
2. **Removal of `--rm` Flag**: We removed the `--rm` flag to prevent the container from being automatically deleted
3. **Interactive Mode**: We use `-it` (`stdin_open: true` and `tty: true`) to maintain interactive mode
4. **Volume Mounting**: We mount the current directory at the same path
5. **Container Status Check**: The script checks whether the container is already running

## Troubleshooting

- **Container Deletion**: To completely remove the container, run `docker rm claude-code-container`
- **Image Update**: To get a new image, run `docker pull ghcr.io/gendosu/claude-code-docker:latest` and delete the old container
- **Permission Issues**: If you encounter permission problems with volume mounting, check the appropriate user permissions
