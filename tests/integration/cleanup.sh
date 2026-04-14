#!/bin/sh

set -eu

PROJECT_ROOT=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)

docker stop xbackbone || true
docker rm xbackbone || true
docker volume rm xbb_storage xbb_database xbb_logs xbb_config || true
(cd "${PROJECT_ROOT}" && docker compose down -v) || true
if [ -d "${PROJECT_ROOT}/xbb" ]; then
	docker run --rm \
		-v "${PROJECT_ROOT}/xbb:/target" \
		alpine:3.20 \
		chown -R "$(id -u):$(id -g)" /target || true
fi
rm -rf \
	"${PROJECT_ROOT}/xbackbone_uploader_admin.sh" \
	"${PROJECT_ROOT}/file.txt" \
	"${PROJECT_ROOT}/cookie.txt" \
	"${PROJECT_ROOT}/script.sh" || true