#!/bin/sh

set -eu

PROJECT_ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
IMAGE_TAG=${IMAGE_TAG:-xbackbone-docker:test}

cleanup_container() {
    docker stop xbackbone >/dev/null 2>&1 || true
    docker rm xbackbone >/dev/null 2>&1 || true
}

cleanup_volumes() {
    docker volume rm xbb_storage xbb_database xbb_logs xbb_config >/dev/null 2>&1 || true
}

cleanup_compose() {
    (cd "${PROJECT_ROOT}" && docker compose down -v) >/dev/null 2>&1 || true
}

cleanup_artifacts() {
    rm -rf "${PROJECT_ROOT}/xbb"
    rm -f \
        "${PROJECT_ROOT}/cookie.txt" \
        "${PROJECT_ROOT}/file.txt" \
        "${PROJECT_ROOT}/script.sh" \
        "${PROJECT_ROOT}/xbackbone_uploader_admin.sh"
}

cleanup() {
    cleanup_container
    cleanup_volumes
    cleanup_compose
    cleanup_artifacts
}

trap cleanup EXIT

smoke_test() {
    (cd "${PROJECT_ROOT}" && bash tests/integration/login.sh)
}

full_test() {
    (cd "${PROJECT_ROOT}" && bash tests/integration/login.sh)
    (cd "${PROJECT_ROOT}" && bash tests/integration/upload.sh)
    (cd "${PROJECT_ROOT}" && bash tests/integration/cleanup.sh)
}

restart_container() {
    docker stop xbackbone
    docker start xbackbone
    docker logs xbackbone
}

prepare_bind_mounts() {
    mkdir -p \
        "${PROJECT_ROOT}/xbb/storage" \
        "${PROJECT_ROOT}/xbb/database" \
        "${PROJECT_ROOT}/xbb/logs" \
        "${PROJECT_ROOT}/xbb/config"

    docker run --rm \
        -v "${PROJECT_ROOT}/xbb:/target" \
        alpine:3.20 \
        chown -R 1000:1000 /target
}

run_bind_mount_suite() {
    prepare_bind_mounts

    docker run -d -p 80:80 \
        -v "${PROJECT_ROOT}/xbb/storage:/app/storage" \
        -v "${PROJECT_ROOT}/xbb/database:/app/resources/database" \
        -v "${PROJECT_ROOT}/xbb/logs:/app/logs" \
        -v "${PROJECT_ROOT}/xbb/config:/app/config" \
        -e PHP_UPLOAD_MAX_FILESIZE=1G \
        -e URL=http://127.0.0.1 \
        --name xbackbone \
        "${IMAGE_TAG}"

    smoke_test
    restart_container
    full_test
}

run_named_volume_suite() {
    docker volume create xbb_storage
    docker volume create xbb_database
    docker volume create xbb_logs
    docker volume create xbb_config

    docker run -d -p 80:80 \
        -v xbb_storage:/app/storage \
        -v xbb_database:/app/resources/database \
        -v xbb_logs:/app/logs \
        -v xbb_config:/app/config \
        -e PHP_UPLOAD_MAX_FILESIZE=1G \
        -e URL=http://127.0.0.1 \
        --name xbackbone \
        "${IMAGE_TAG}"

    smoke_test
    restart_container
    full_test
}

run_compose_suite() {
    (cd "${PROJECT_ROOT}" && XBACKBONE_IMAGE="${IMAGE_TAG}" docker compose up -d --no-build)
    (cd "${PROJECT_ROOT}" && docker compose ps)
    smoke_test
    (cd "${PROJECT_ROOT}" && docker compose stop)
    (cd "${PROJECT_ROOT}" && docker compose start)
    (cd "${PROJECT_ROOT}" && docker compose logs)
    full_test
}

cleanup
run_bind_mount_suite
cleanup
run_named_volume_suite
cleanup
run_compose_suite