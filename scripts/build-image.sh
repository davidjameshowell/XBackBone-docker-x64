#!/bin/sh

set -eu

PROJECT_ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
IMAGE_TAG=${IMAGE_TAG:-xbackbone-docker:local}
XBACKBONE_VERSION=${XBACKBONE_VERSION:-3.8.1}

docker build \
    --pull \
    --build-arg "XBACKBONE_VERSION=${XBACKBONE_VERSION}" \
    --tag "${IMAGE_TAG}" \
    "${PROJECT_ROOT}/docker/xbackbone"

if [ "${RUN_TESTS:-true}" = "true" ]; then
    IMAGE_TAG="${IMAGE_TAG}" bash "${PROJECT_ROOT}/scripts/test-integration.sh"
fi