#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="$ROOT_DIR/dist"
OUT_WASM="$OUT_DIR/sqlc-dts.wasm"
OUT_SHA="$OUT_DIR/sqlc-dts.wasm.sha256"

mkdir -p "$OUT_DIR"
GOOS=wasip1 GOARCH=wasm go build -trimpath -ldflags "-s -w" -o "$OUT_WASM" .
SHA256="$(shasum -a 256 "$OUT_WASM" | awk '{print $1}')"
printf '%s\n' "$SHA256" > "$OUT_SHA"

echo "Built: $OUT_WASM"
echo "sha256: $SHA256"
echo "sha file: $OUT_SHA"
