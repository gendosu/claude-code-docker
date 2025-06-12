# Docker Hub Multi-Platform Image Push Setup Checklist

## Prerequisites
- [ ] Docker Hub account created
- [ ] GitHub repository admin permissions confirmed

## Setup Tasks

### 1. Docker Hub Access Token
- [ ] Log in to [Docker Hub](https://hub.docker.com)
- [ ] Navigate to Account Settings → Security
- [ ] Click "New Access Token"
- [ ] Name the token (e.g., `github-actions`)
- [ ] Select "Read, Write, Delete" permissions
- [ ] Click "Generate"
- [ ] Copy and save the token securely

### 2. GitHub Repository Secrets
- [ ] Open GitHub repository Settings
- [ ] Navigate to Secrets and variables → Actions
- [ ] Add secret: `DOCKERHUB_USERNAME`
  - [ ] Enter your Docker Hub username
- [ ] Add secret: `DOCKERHUB_TOKEN`
  - [ ] Enter the access token from step 1

### 3. Docker Hub Repository
- [ ] Log in to Docker Hub
- [ ] Click "Create Repository"
- [ ] Enter repository name: `claude-code-docker`
- [ ] Select visibility (Public/Private)
- [ ] Click "Create"

### 4. Workflow Execution
- [ ] Choose trigger method:
  - [ ] Push to `main` branch
  - [ ] Manual dispatch from Actions tab
  - [ ] Wait for daily cron (21:00 UTC / 6:00 JST)
- [ ] Monitor GitHub Actions run

### 5. Verification
- [ ] Check GitHub Actions logs
  - [ ] All steps completed successfully
  - [ ] No error messages
- [ ] Verify on Docker Hub
  - [ ] Repository exists
  - [ ] `latest` tag is present
  - [ ] Both `linux/amd64` and `linux/arm64` platforms listed
- [ ] Test image pull
  - [ ] AMD64: `docker pull <username>/claude-code-docker:latest`
  - [ ] ARM64: `docker pull <username>/claude-code-docker:latest`

## Troubleshooting Checklist

### Authentication Issues
- [ ] Verify `DOCKERHUB_USERNAME` secret is correct
- [ ] Verify `DOCKERHUB_TOKEN` secret is valid
- [ ] Check token permissions include Read, Write, Delete

### Repository Access Issues
- [ ] Confirm Docker Hub repository name matches workflow
- [ ] Verify repository exists before push
- [ ] Check username in workflow matches Docker Hub account

### Platform Build Issues
- [ ] QEMU action is present in workflow
- [ ] Docker Buildx action is configured
- [ ] `platforms: linux/amd64,linux/arm64` is specified

## Post-Setup Maintenance
- [ ] Document Docker Hub username for team
- [ ] Set reminder to rotate access token (every 90 days)
- [ ] Monitor build times and optimize if needed
- [ ] Review Docker Hub usage limits