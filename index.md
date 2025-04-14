# claude-code-docker AI Index

This document serves as an index for AI to understand the claude-code-docker project.

## Project Overview

claude-code-docker is a project designed to run [Claude Code](https://github.com/anthropics/claude-code) inside a Docker container. Claude Code is an AI coding assistant provided by Anthropic, and this project makes it easy to use Claude Code in a Docker environment.

## Key Features

- Docker image based on Node.js 22.11.0
- Pre-installed @anthropic-ai/claude-code package
- Multi-platform support (linux/amd64, linux/arm64)
- **Container Reuse Feature** - Maintain container state for continuous use
- Integration with Claude Desktop and VSCode

## Project Structure

```
claude-code-docker/
├── Dockerfile                   # Docker image build definition
├── Implementation-Guide.ja.md   # Implementation Guide (Japanese)
├── Implementation-Guide.md      # Implementation Guide (English)
├── README.Docker.md             # Additional Docker information
├── README.ja.md                # Main documentation (Japanese)
├── README.md                    # Main documentation (English)
├── claude-code-docker-run.sh    # Shell script for container reuse
├── claude_desktop_config.json   # Claude Desktop configuration example
├── compose.yaml                 # Docker Compose configuration
├── package.json                 # npm package definition
├── pnpm-lock.yaml              # pnpm dependency lock file
├── src/                         # Source code
│   ├── index.ts                 # Entry point
│   └── types/                   # TypeScript type definitions
│       └── index.ts
└── tsconfig.json                # TypeScript configuration
```

## AI Access Control

The `.aiexclude` file can be used to specify files that AI should not access. This file uses the same format as `.gitignore` and restricts AI access to matching files and directories.

Example:
```
# Exclude secret files
secrets.json
.env*

# Exclude specific directories
private/
confidential/
```

Files and directories that match patterns in the `.aiexclude` file will be prohibited from being read by AI. This helps protect sensitive information and private data from AI access.

## Key Components

### Dockerfile

- Built on Node.js 22.11.0 base
- Uses multiple build stages for optimization
- Globally installs @anthropic-ai/claude-code
- Includes Git and GitHub CLI (gh)
- Uses non-root user (appuser) for enhanced security

### claude-code-docker-run.sh

A shell script that enables container reuse with the following features:

1. Automatically pulls the image if not present
2. Creates a new container if none exists
3. Reuses existing container (connects if running, starts if stopped)

### compose.yaml

Docker Compose configuration file:
- Environment variable setup (GITHUB_TOKEN, GITHUB_ID)
- Current directory mounting
- Interactive mode configuration

## Usage

### Recommended: Using the Shell Script

```bash
chmod +x claude-code-docker-run.sh
./claude-code-docker-run.sh
```

With additional options:
```bash
./claude-code-docker-run.sh mcp serve
```

### Using Docker Compose

```bash
# First launch
docker compose up

# Subsequent launches (container reuse)
docker compose start
```

### Using Docker Commands Directly

```bash
# First launch (container creation)
docker run -it \
  --name claude-code-container \
  -e GITHUB_TOKEN \
  -w `pwd` \
  -v `pwd`:`pwd` \
  ghcr.io/gendosu/claude-code-docker:latest

# Subsequent launches (container reuse)
docker start -i claude-code-container
```

## Integration with Claude Desktop

Example `claude_desktop_config.json`:

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

## Technical Details

- **Fixed Container Name**: Container name is fixed for reuse
- **Removal of --rm Flag**: Prevents automatic container deletion
- **Interactive Mode**: Uses -it (stdin_open: true, tty: true)
- **Volume Mounting**: Mounts current directory at the same path
- **Container State Check**: Logic to check if already running

## Troubleshooting

- Remove container: `docker rm claude-code-container`
- Update image: 
  ```bash
  docker pull ghcr.io/gendosu/claude-code-docker:latest
  docker rm claude-code-container
  ```
- Permission issues: Check volume mount permissions

## Metadata

- **Repository**: https://github.com/gendosu/claude-code-docker
- **Image**: ghcr.io/gendosu/claude-code-docker:latest
- **License**: MIT
- **Author**: gendosu
