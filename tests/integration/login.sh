#!/bin/sh

set -eu

attempts=${ATTEMPTS:-30}

while [ "${attempts}" -gt 0 ]; do
	if curl --silent --show-error --fail http://127.0.0.1/login >/dev/null; then
		exit 0
	fi

	attempts=$((attempts - 1))
	sleep 2
done

curl --silent --show-error --fail http://127.0.0.1/login >/dev/null