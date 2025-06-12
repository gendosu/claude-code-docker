
ARG NODE_VERSION=22.11.0
ARG PNPM_VERSION=latest
ARG GITHUB_TOKEN
ARG CLAUDE_CODE_VERSION=latest

################################################################################
# Use node image for base image for all stages.
FROM node:${NODE_VERSION}-slim AS base

# Set working directory for all build stages.
WORKDIR /app

################################################################################
# Create a stage for installing production dependencies.
FROM base AS deps

# Install pnpm and clean up in the same layer
RUN npm install -g pnpm@${PNPM_VERSION} \
    && npm cache clean --force

# Download dependencies as a separate step to take advantage of Docker's caching.
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --prod --frozen-lockfile \
    && pnpm store prune \
    && rm -rf /root/.npm/_cacache

################################################################################
# Create a new stage to run the application with minimal runtime dependencies
FROM node:${NODE_VERSION}-slim AS final

# Use production node environment by default.
ENV NODE_ENV=production
ENV SHELL=/bin/bash

WORKDIR /app

ARG CLAUDE_CODE_VERSION
RUN echo "Installing claude-code version: ${CLAUDE_CODE_VERSION}" && npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}

# Install shell
RUN apt-get update && apt-get install -y bash curl && rm -rf /var/lib/apt/lists/*

# gh install
RUN apt-get update && apt-get install -y git gh && rm -rf /var/lib/apt/lists/*

# jq install
RUN apt-get update && apt-get install -y jq && rm -rf /var/lib/apt/lists/*

# Copy only necessary files from deps stage
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Create a non-root user with limited permissions
RUN useradd -m appuser \
    && chown -R appuser:appuser /app
USER appuser

# Install nodenv and node-build plugin
RUN git clone https://github.com/nodenv/nodenv.git ~/.nodenv
RUN git clone https://github.com/nodenv/node-build.git "$($HOME/.nodenv/bin/nodenv root)"/plugins/node-build

# Create necessary directories with proper permissions
RUN mkdir -p /home/appuser/.nodenv/versions \
    && chown -R appuser:appuser /home/appuser/.nodenv/versions

# Set up nodenv environment variables globally
ENV PATH="/home/appuser/.nodenv/bin:/home/appuser/.nodenv/shims:$PATH"
ENV NODENV_ROOT="/home/appuser/.nodenv"

# Configure shell initialization files for both interactive and non-interactive shells
RUN echo 'export PATH="$HOME/.nodenv/bin:$PATH"' >> ~/.bashrc \
    && echo 'eval "$(nodenv init - bash)"' >> ~/.bashrc \
    && echo 'export PATH="$HOME/.nodenv/bin:$PATH"' >> ~/.profile \
    && echo 'eval "$(nodenv init - bash)"' >> ~/.profile

# Initialize nodenv shims directory
RUN /home/appuser/.nodenv/bin/nodenv init - bash > /dev/null || true

# Run the application.
ENTRYPOINT ["npx", "claude"]
