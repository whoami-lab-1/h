#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

DARKLUA_BIN=""
if command -v darklua >/dev/null 2>&1; then
    DARKLUA_BIN="darklua"
elif command -v rokit >/dev/null 2>&1; then
    DARKLUA_BIN="rokit run darklua"
else
    echo "[ERROR] Darklua is not installed or not on PATH." >&2
    echo "Install: https://darklua.com/docs/getting-started/" >&2
    exit 1
fi

mkdir -p dist
echo "[Harkening UI] Bundling source with Darklua..."
# shellcheck disable=SC2086
$DARKLUA_BIN process "Harkening/init.lua" "dist/Harkening.lua" --config "build/darklua.config.json"
echo "[OK] Generated dist/Harkening.lua"
