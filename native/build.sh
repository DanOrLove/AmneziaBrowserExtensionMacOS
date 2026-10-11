#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if ! command -v go >/dev/null 2>&1; then
  echo "Go 1.25 or later is required. Install it from https://go.dev/dl/" >&2
  exit 1
fi

GO_VERSION="$(go version | awk '{print $3}')"
VERSION="${GO_VERSION#go}"
GO_MAJOR="${VERSION%%.*}"
GO_MINOR="${VERSION#*.}"
GO_MINOR="${GO_MINOR%%.*}"
if (( GO_MAJOR < 1 || (GO_MAJOR == 1 && GO_MINOR < 25) )); then
  echo "Go 1.25 or later is required; found ${GO_VERSION}." >&2
  exit 1
fi

cd "$SCRIPT_DIR"
go build -trimpath -o "$SCRIPT_DIR/AmneziaBrowserVpnHost" .
chmod 700 "$SCRIPT_DIR/AmneziaBrowserVpnHost"
echo "Built macOS Native Messaging host: $SCRIPT_DIR/AmneziaBrowserVpnHost"
