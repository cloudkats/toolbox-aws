#!/bin/bash

set -ex

: "${IMAGE}"

echo "++++++++++++++++++++++++++++"
echo "RUN tests for image ${IMAGE}"
echo "++++++++++++++++++++++++++++"

docker run --rm --entrypoint="/bin/bash" "${IMAGE}" -c "kubectl version --client=true --short=true"
docker run --rm --entrypoint="/bin/bash" "${IMAGE}" -c "git --version"
docker run --rm --entrypoint="/bin/bash" "${IMAGE}" -c "aws --version"
docker run --rm --entrypoint="/bin/bash" "${IMAGE}" -c "yq --version"
docker run --rm --entrypoint="/bin/bash" "${IMAGE}" -c "helm version"
docker run --rm --entrypoint="/bin/bash" "${IMAGE}" -c "helm plugin list diff | grep diff"
docker run --rm --entrypoint="/bin/bash" "${IMAGE}" -c "terraform --version"
docker run --rm --entrypoint="/bin/bash" "${IMAGE}" -c "terragrunt --version"
