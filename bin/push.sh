#!/bin/bash

set -e

: "${IMAGE}"
: "${DOCKER_USERNAME}"
: "${DOCKER_PASSWORD}"
: "${IMAGE_ID}"
: "${TAG_VERSION_DATE}"
: "${TAG_VERSION_SHA}"
: "${IMAGE_VERSION:-latest}"

echo "++++++++++++++++++++++++++++"
echo "Login and Push Image ${IMAGE}"
echo "++++++++++++++++++++++++++++"

echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin

echo "Push Version ${IMAGE_ID}:latest"
docker tag "${IMAGE}" "${IMAGE_ID}:latest"
docker push "${IMAGE_ID}:latest"

if [ "$IMAGE_VERSION" != "latest" ]; then
  echo "push version ${IMAGE_ID}:${IMAGE_VERSION}.${TAG_VERSION_DATE}"
  docker tag "${IMAGE}" "${IMAGE_ID}:${IMAGE_VERSION}.${TAG_VERSION_DATE}"
  docker push "${IMAGE_ID}:${IMAGE_VERSION}.${TAG_VERSION_DATE}"

  echo "push version ${IMAGE_ID}:${IMAGE_VERSION}.${TAG_VERSION_SHA}"
  docker tag "${IMAGE}" "${IMAGE_ID}:${IMAGE_VERSION}.${TAG_VERSION_SHA}"
  docker push "${IMAGE_ID}:${IMAGE_VERSION}.${TAG_VERSION_SHA}"

  echo "push version ${IMAGE_ID}:${IMAGE_VERSION}"
  docker tag "${IMAGE}" "${IMAGE_ID}:${IMAGE_VERSION}"
  docker push "${IMAGE_ID}:${IMAGE_VERSION}"
else
  echo "push version ${IMAGE_ID}:${TAG_VERSION_DATE}"
  docker tag "${IMAGE}" "${IMAGE_ID}:${TAG_VERSION_DATE}"
  docker push "${IMAGE_ID}:${TAG_VERSION_DATE}"

  echo "push version ${IMAGE_ID}:${TAG_VERSION_SHA}"
  docker tag "${IMAGE}" "${IMAGE_ID}:${TAG_VERSION_SHA}"
  docker push "${IMAGE_ID}:${TAG_VERSION_SHA}"
fi
