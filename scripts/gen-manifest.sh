#!/bin/bash

# always exit if a command fails
set -o errexit

# Hardcoded values for create-ocp-namespace-swt workflow
WORKFLOW_ID="create-ocp-namespace-swt"
WORKFLOW_FOLDER="create-ocp-namespace-swt"

# Validate required environment variables
if [[ -z "${WORKFLOW_IMAGE_REGISTRY}" ]]; then
  echo 'Error: WORKFLOW_IMAGE_REGISTRY env variable must be set with the image registry name; e.g: ghcr.io'
  exit 1
fi

if [[ -z "${WORKFLOW_IMAGE_NAMESPACE}" ]]; then
  echo "Error: WORKFLOW_IMAGE_NAMESPACE env variable must be set with the name of the namespace's registry in which store the image; e.g: username"
  exit 1
fi

if [[ -z "${WORKFLOW_IMAGE_TAG}" ]]; then
  echo "Error: WORKFLOW_IMAGE_TAG env variable must be set with the image tag"
  exit 1
fi

WORKFLOW_IMAGE_REPO="${WORKFLOW_IMAGE_REPO:-${WORKFLOW_ID}}"
ENABLE_PERSISTENCE="${ENABLE_PERSISTENCE:-true}"
# helper binaries should be either on the developer machine or in the helper
# image quay.io/orchestrator/ubi9-pipeline from setup/Dockerfile, which we use
# to exeute this script. See the Makefile gen-manifests target.

# Work directly in the project directory instead of temp directory
WORKDIR=$(pwd)
echo "Working in: ${WORKDIR}"


command -v kn-workflow
command -v kubectl

cd "${WORKFLOW_FOLDER}"/src/main/resources

MANIFEST_DIR="${WORKDIR}/${WORKFLOW_FOLDER}/src/main/resources/manifests"
mkdir -p "${MANIFEST_DIR}"
kn-workflow gen-manifest --image "${WORKFLOW_IMAGE_REGISTRY}/${WORKFLOW_IMAGE_NAMESPACE}/${WORKFLOW_IMAGE_REPO}:${WORKFLOW_IMAGE_TAG}" --profile gitops --skip-namespace --custom-generated-manifests-dir="${MANIFEST_DIR}" 

# Enable bash's extended blobing for better pattern matching
shopt -s extglob
# Find the workflow file with .sw.yaml suffix since kn-cli uses the ID to generate resource names
workflow_file=$(printf '%s\n' ./*.sw.y?(a)ml 2>/dev/null | head -n 1)
# Disable bash's extended globing
shopt -u extglob

# Check if the workflow_file was found
if [ -z "$workflow_file" ]; then
  echo "No workflow file with .sw.yaml or .sw.yml suffix found."
  exit 1
fi

# Extract the 'id' property from the YAML file and convert to lowercase
workflow_id=$(grep '^id:' "$workflow_file" | awk '{print $2}' | tr '[:upper:]' '[:lower:]')

# Check if the 'id' property was found
if [ -z "$workflow_id" ]; then
  echo "No 'id' property found in the workflow file."
  exit 1
fi


# Note: Secret and SonataFlow CR generation are now handled by Helm chart
# The SonataFlow CR will be managed by the Helm template

# Note: Persistence configuration is now handled by Helm chart

echo "Manifests generated in ${MANIFEST_DIR}"