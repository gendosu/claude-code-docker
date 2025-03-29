# claude-code-docker

A Docker image for Claude Code that allows you to run Claude Code in a container environment.

## Features

- Based on Node.js 22.11.0
- Pre-installed with @anthropic-ai/claude-code
- Multi-platform support (linux/amd64, linux/arm64)

## Usage

### Using Docker Compose

1. Set environment variables:
```env
GITHUB_TOKEN=your_github_token
GITHUB_ID=your_github_id
```

2. Start the container:
```bash
docker compose up --build
```

### Using Docker

```bash
docker run --rm -it \
  -e GITHUB_TOKEN \
  -w `pwd` \
  -v `pwd`:`pwd` \
  ghcr.io/gendosu/claude-code-docker:latest
```

### Example Configuration for Claude Desktop MCP Server

Add the following configuration to your Claude Desktop config file (`claude_desktop_config.json`) to use the Claude Code feature:

```json
{
  "mcpServers": {
    "claude-code": {
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-i",
        "-e",
        "GITHUB_TOKEN",
        "-w",
        "/path/to/your/workspace",
        "-v",
        "/path/to/your/workspace:/path/to/your/workspace",
        "ghcr.io/gendosu/claude-code-docker:latest",
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
- `command`: Specify the Docker command
- `args`: 
  - `-w`: Specify the working directory
  - `-v`: Specify volume mount between host and container
  - `mcp serve`: Start the Claude Code MCP server

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
