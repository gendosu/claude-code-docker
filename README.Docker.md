### Building and running your application

When you're ready, start your application by running:
`docker compose up --build`.

Your application will be available at http://localhost:3000.

### Deploying your application to the cloud

First, build your image, e.g.: `docker build -t myapp .`.
If your cloud uses a different CPU architecture than your development
machine (e.g., you are on a Mac M1 and your cloud provider is amd64),
you'll want to build the image for that platform, e.g.:
`docker build --platform=linux/amd64 -t myapp .`.

Then, push it to your registry, e.g. `docker push myregistry.com/myapp`.

Consult Docker's [getting started](https://docs.docker.com/go/get-started-sharing/)
docs for more detail on building and pushing.

### Triggering Multi-Platform Builds and Releases

We have set up a GitHub Actions workflow to automate multi-platform builds and releases to GitHub Container Registry (ghcr). The workflow file is located at `.github/workflows/build-and-push.yml`.

#### Triggering the Workflow

The workflow is triggered automatically on push to the `main` branch. You can also manually trigger the workflow from the GitHub Actions tab.

1. Go to the "Actions" tab in your GitHub repository.
2. Select the "Build and Push Docker Image" workflow from the list.
3. Click the "Run workflow" button.

This will start the multi-platform build and release process.

### References
* [Docker's Node.js guide](https://docs.docker.com/language/nodejs/)
