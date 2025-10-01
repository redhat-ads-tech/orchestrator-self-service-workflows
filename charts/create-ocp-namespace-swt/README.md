# Create OCP Namespace SWT Helm Chart

This Helm chart deploys the `create-ocp-namespace-swt` serverless workflow.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- SonataFlow Operator installed

## Installation

1. Copy the example values file:
   ```bash
   cp values-example.yaml my-values.yaml
   ```

2. Update the values in `my-values.yaml` with your environment-specific configuration:
   - Set the correct image repository and tag
   - Configure the environment variables (Backstage URL, tokens, etc.)
   - Update persistence configuration if needed

3. Install the chart:
   ```bash
   helm install create-ocp-namespace-swt . -f my-values.yaml
   ```

## Configuration

### Environment Variables

The following environment variables are required and will be injected as secrets:

- `backstageBackendUrl`: URL of your Backstage instance
- `backstageBackendBearerToken`: Bearer token for Backstage API access
- `gitlabUrl`: URL of your GitLab instance
- `gitlabToken`: GitLab access token
- `swtRef`: Software template reference (default: "template:default/orchestrator-namespace-request")

### Persistence

The workflow supports PostgreSQL persistence. Configure the following in your values:

- `persistence.postgresql.secretRef`: Secret containing database credentials
- `persistence.postgresql.serviceRef`: Database service configuration

## Usage

Once deployed, the workflow can be triggered through the Backstage scaffolder interface to create new OpenShift namespaces for users.
