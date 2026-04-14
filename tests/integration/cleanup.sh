#!/bin/sh

set -eu

PROJECT_ROOT=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)

docker stop xbackbone || true
docker rm xbackbone || true
docker volume rm xbb_storage xbb_database xbb_logs xbb_config || true
(cd "${PROJECT_ROOT}" && docker compose down -v) || true
rm -rf \
	"${PROJECT_ROOT}/xbackbone_uploader_admin.sh" \
	"${PROJECT_ROOT}/file.txt" \
	"${PROJECT_ROOT}/cookie.txt" \
	"${PROJECT_ROOT}/script.sh" || true