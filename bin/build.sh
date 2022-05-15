#!/bin/bash

set -ex

: "${IMAGE}"
: "${CREATED}"
: "${BUILD_URL}"

echo "++++++++++++++++++++++++++++"
echo "Build image ${IMAGE}"
echo "++++++++++++++++++++++++++++"

docker build -t "${IMAGE}" . \
  --label "org.opencontainers.image.created=${CREATED}" \
  --label "org.opencontainers.image.build-url=${BUILD_URL}"
