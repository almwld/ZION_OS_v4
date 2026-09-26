#!/usr/bin/env bash
set -euo pipefail

ARCH="${1:-aarch64}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
WORK="$ROOT/build/termux-packages"
OUT="$ROOT/build/termux-bootstrap"
mkdir -p "$ROOT/build"

if [[ ! -d "$WORK/.git" ]]; then
  git clone --depth=1 --branch infra-improvs https://github.com/agnostic-apollo/termux-packages.git "$WORK"
fi

export TERMUX_APP_PACKAGE=com.zion.os\nexport TERMUX_APP__PACKAGE_NAME=com.zion.os
export TERMUX_APP__PACKAGE_NAME=com.zion.os

cd "$WORK"
./scripts/run-docker.sh ./clean.sh || true
./scripts/run-docker.sh ./scripts/build-bootstraps.sh --architectures "$ARCH"

mkdir -p "$OUT"
cp -f bootstrap-"$ARCH".zip "$OUT/bootstrap-$ARCH.zip"
echo "Created $OUT/bootstrap-$ARCH.zip"
