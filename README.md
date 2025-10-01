# Create OCP Namespace SWT Workflow

This repository contains an advanced serverless workflow example named`create-ocp-namespace-swt`. The workflow creates a namespace on behalf of an OpenShift user. If the user requests a large namespace, an issue is opened in a GitLab repository and the workflow waits for the issue to be labelled as `approved`. The workflow uses a Backstage Software Template behind the scenes to create the namespace via GitOps after approval.

Note, this is designed for use with the **Orchestrator feature in Red Hat Developer Hub**.

## Prerequisites

Before deploying this workflow, you must have:

1. **Red Hat Developer Hub** with Orchestrator feature enabled
2. **OpenShift Cluster** (4.18+)
3. **SonataFlow Operator** installed on your cluster
4. **PostgreSQL database** for workflow persistence (can use the existing Red Hat Developer Hub PostgreSQL)
5. **Helm 3.x** for deployment
6. **GitLab instance** with API access

## Installation

### Quick Start

The easiest way to deploy this workflow is using Helm:

```bash
# Add the Helm repository
helm repo add advanced-workflows http://evanshortiss.com/orchestrator-serverless-workflows/
helm repo update

# Install the workflow
helm install create-ocp-namespace-swt advanced-workflows/create-ocp-namespace-swt \
  --set env.backstageBackendUrl="https://your-rhdh-instance.com" \
  --set env.backstageBackendBearerToken="your-backstage-token" \
  --set env.gitlabUrl="https://gitlab.your-domain.com" \
  --set env.gitlabToken="your-gitlab-token"
```

### Advanced Installation

For more control over the configuration, especially PostgreSQL, create a custom values file:

```bash
# Create a values file
cat > my-values.yaml <<EOF
env:
  backstageBackendUrl: "https://your-rhdh-instance.com"
  backstageBackendBearerToken: "your-backstage-token"
  gitlabUrl: "https://gitlab.your-domain.com"
  gitlabToken: "your-gitlab-token"
  swtRef: "template:default/orchestrator-namespace-request"

persistence:
  postgresql:
    secretRef:
      name: backstage-psql-secret
      userKey: POSTGRES_USER
      passwordKey: POSTGRES_PASSWORD
    serviceRef:
      name: backstage-psql
      port: 5432
      databaseName: orchestrator
      databaseSchema: create-ocp-namespace-swt

image:
  repository: ghcr.io/evanshortiss/create-ocp-namespace-swt
EOF

# Install with custom values
helm install create-ocp-namespace-swt orchestrator-workflows/create-ocp-namespace-swt -f my-values.yaml
```

### Configuration

The following environment variables must be configured:

| Variable | Description | Example |
|----------|-------------|---------|
| `backstageBackendUrl` | URL of your Red Hat Developer Hub instance | `https://rhdh.example.com` |
| `backstageBackendBearerToken` | Service account token for RHDH API access | `eyJhbGc...` |
| `gitlabUrl` | URL of your GitLab instance | `https://gitlab.example.com` |
| `gitlabToken` | GitLab access token with API permissions | `glpat-...` |
| `swtRef` | Software template reference | `template:default/orchestrator-namespace-request` |

## Repository Structure

- `create-ocp-namespace-swt/` - Main workflow implementation (SonataFlow definition)
- `scripts/` - Build and deployment scripts
- `resources/` - Docker build context and Dockerfile
- `charts/` - Helm chart for deployment
- `.github/workflows/` - CI/CD pipeline for automated builds

## Development

### Building Locally

The workflow is automatically built via GitHub Actions, but you can build locally:

```bash
# Set environment variables
export WORKFLOW_IMAGE_REGISTRY="quay.io"
export WORKFLOW_IMAGE_NAMESPACE="your-username"
export WORKFLOW_IMAGE_TAG="0.1.0"

# Run build script
./scripts/build-push.sh
```

### Versioning

The workflow version is managed in `create-ocp-namespace-swt/pom.xml`. Update the version there, and the CI/CD pipeline will automatically build and publish the new version.
