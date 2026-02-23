#!/usr/bin/env bash

set -euo pipefail

if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    compose_cmd=(docker compose)
elif command -v docker-compose >/dev/null 2>&1; then
    compose_cmd=(docker-compose)
else
    echo "Neither a working 'docker compose' nor 'docker-compose' is available." >&2
    exit 1
fi

wsc_version="${WSC_VERSION:-}"

if [ -z "$wsc_version" ] && [ -f ".env" ]; then
    wsc_version="$(grep -E '^[[:space:]]*WSC_VERSION=' .env | tail -n 1 | sed -E 's/^[[:space:]]*WSC_VERSION=//; s/[[:space:]]+$//')"
fi

wsc_version="${wsc_version:-6.1}"
wsc_version_normalized="$(printf '%s' "$wsc_version" | grep -Eo '^[0-9]+(\.[0-9]+){1,2}' || true)"

version_lt() {
    local a="$1"
    local b="$2"
    local i
    local IFS=.
    local -a va=($a)
    local -a vb=($b)

    for i in 0 1 2; do
        local ai="${va[$i]:-0}"
        local bi="${vb[$i]:-0}"
        if ((10#$ai < 10#$bi)); then
            return 0
        fi
        if ((10#$ai > 10#$bi)); then
            return 1
        fi
    done

    return 1
}

compose_files=(-f docker-compose.yml)
if [ -z "$wsc_version_normalized" ] || version_lt "$wsc_version_normalized" "6.3"; then
    compose_files+=(-f docker-compose.redis.yml)
fi

exec "${compose_cmd[@]}" "${compose_files[@]}" "$@"
