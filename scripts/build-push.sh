#!/bin/bash

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

# Hardcoded flow metadata for create-ocp-namespace-swt
FLOW_NAME="create-ocp-namespace-swt Serverless Workflow"
FLOW_SUMMARY="create-ocp-namespace-swt Serverless Workflow"
FLOW_DESCRIPTION="create-ocp-namespace-swt workflow creates a namespace on behalf of an OpenShift user, using a software template"

WORKDIR=$(mktemp -d)
echo "Workdir: ${WORKDIR}"

cp -r . ${WORKDIR}

cd "${WORKDIR}"

rm -rf **/target
mv ${WORKFLOW_FOLDER}/src/main/resources ${WORKFLOW_FOLDER}/.

IMAGE_NAME=${WORKFLOW_IMAGE_REGISTRY}/${WORKFLOW_IMAGE_NAMESPACE}/${WORKFLOW_ID}
IMAGE_TAG=${WORKFLOW_IMAGE_TAG}

podman build -f resources/workflow-builder.Dockerfile --no-cache --build-arg WF_RESOURCES="${WORKFLOW_FOLDER}" --build-arg FLOW_NAME="${FLOW_NAME}" --build-arg FLOW_SUMMARY="${FLOW_SUMMARY}" --build-arg FLOW_DESCRIPTION="${FLOW_DESCRIPTION}" --ulimit nofile=4096:4096 --tag "${IMAGE_NAME}:${IMAGE_TAG}" .
podman push "${IMAGE_NAME}:latest"
