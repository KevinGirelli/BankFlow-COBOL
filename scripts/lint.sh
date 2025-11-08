#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cobc -fsyntax-only -free \
  -Wall -Wextra \
  -Wno-terminator \
  -Wno-obsolete \
  -Wno-possible-overlap \
  -Wno-possible-truncate \
  -I"${ROOT_DIR}/src/copybooks" \
  -I"${ROOT_DIR}/src/sections" \
  "${ROOT_DIR}/src/app/BankFlow.cbl"

echo "Lint OK"

