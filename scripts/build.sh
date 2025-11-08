#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "${ROOT_DIR}/build"

cobc -x -free \
  -I"${ROOT_DIR}/src/copybooks" \
  -I"${ROOT_DIR}/src/sections" \
  -o "${ROOT_DIR}/build/bankflow" \
  "${ROOT_DIR}/src/app/BankFlow.cbl"

echo "Binario gerado em ${ROOT_DIR}/build/bankflow"

