# Create OCP Namespace SWT Workflow

This repository contains the `create-ocp-namespace-swt` serverless workflow that creates a namespace on behalf of an OpenShift user using a software template.

## Overview

The workflow is built as a container image and deployed using Kubernetes manifests. It integrates with:
- Backstage for notifications and scaffolder services
- GitLab for repository operations

## Repository Structure

- `create-ocp-namespace-swt/` - The main workflow implementation
- `scripts/` - Build and deployment scripts
- `resources/` - Docker build context
- `charts/` - Helm chart for deployment
- `.github/workflows/` - CI/CD pipeline

## Building and Deploying

The workflow is automatically built and deployed via GitHub Actions when changes are pushed to the main branch. Manual builds can be triggered via the Actions tab.

## Usage

The workflow can be triggered through the Backstage scaffolder interface to create new OpenShift namespaces for users.