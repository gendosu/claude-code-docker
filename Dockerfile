# syntax=docker/dockerfile:1

ARG NODE_VERSION=22.11.0
ARG PNPM_VERSION=latest
ARG GITHUB_TOKEN

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

RUN npm install -g @anthropic-ai/claude-code

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

RUN git clone https://github.com/nodenv/nodenv.git ~/.nodenv

RUN git clone https://github.com/nodenv/node-build.git "$($HOME/.nodenv/bin/nodenv root)"/plugins/node-build

RUN echo 'export PATH="$HOME/.nodenv/bin:$PATH"' >> ~/.bashrc

RUN echo 'eval "$(nodenv init - bash)"' >> ~/.bashrc

# 必要であれば、ここでボリューム内のディレクトリのパーミッションを変更
RUN mkdir -p /home/appuser/.nodenv/versions
RUN chown -R appuser:appuser /home/appuser/.nodenv/versions

# Run the application.
ENTRYPOINT ["npx", "claude"]
