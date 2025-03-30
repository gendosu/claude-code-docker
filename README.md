# claude-code-docker

A Docker image for Claude Code that allows you to run Claude Code in a container environment.

## Features

- Based on Node.js 22.11.0
- Pre-installed with @anthropic-ai/claude-code
- Multi-platform support (linux/amd64, linux/arm64)
- **Container reuse capability** (new feature)

## Usage

### Using the Script (Recommended)

1. Download the `claude-code-docker-run.sh` script and make it executable:
```bash
chmod +x claude-code-docker-run.sh
```

2. Run the script:
```bash
./claude-code-docker-run.sh
```
Or specify additional options:
```bash
./claude-code-docker-run.sh mcp serve
```

This script performs the following operations:
- Automatically pulls the image if it doesn't exist
- Creates a new container if it doesn't exist
- Reuses the container if it exists (connects if running, starts if stopped)

### Using Docker Compose

1. Set environment variables:
```env
GITHUB_TOKEN=your_github_token
GITHUB_ID=your_github_id
```

2. Start the container:
```bash
docker compose up
```

3. For subsequent runs, the same container will be reused:
```bash
docker compose start
```

### Using Docker Directly (Manual Reuse)

First run (container creation):
```bash
docker run -it \
  --name claude-code-container \
  -e GITHUB_TOKEN \
  -w `pwd` \
  -v `pwd`:`pwd` \
  ghcr.io/gendosu/claude-code-docker:latest
```

Subsequent runs (container reuse):
```bash
docker start -i claude-code-container
```

### Example Configuration for Claude Desktop MCP Server

Add the following configuration to your Claude Desktop config file (`claude_desktop_config.json`) to use the Claude Code feature:

```json
{
  "mcpServers": {
    "claude-code": {
      "command": "/path/to/claude-code-docker-run.sh",
      "args": [
        "mcp",
        "serve"
      ],
      "env": {
        "NODENV_VERSION": "22.11.0",
        "GITHUB_TOKEN": "<Your GitHub Token>"
      }
    }
  }
}
```

Configuration details:
- `command`: Path to the created script
- `args`: Arguments needed for starting the MCP server

Note: This configuration is specific to Claude Desktop. VSCode requires a different configuration method.

## GitHub Container Registry

This image is available on GitHub Container Registry:

```bash
docker pull ghcr.io/gendosu/claude-code-docker:latest
```

## License

MIT

## Author

gendosu
