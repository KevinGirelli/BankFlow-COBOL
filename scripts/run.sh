#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATA_DIR="${DATA_DIR:-${ROOT_DIR}/data}"
REPORT_DIR="${REPORT_DIR:-${ROOT_DIR}/reports}"
LOG_DIR="${LOG_DIR:-${ROOT_DIR}/logs}"
LOG_FILE="${LOG_FILE:-${LOG_DIR}/events.log}"

mkdir -p "${DATA_DIR}" "${REPORT_DIR}" "${LOG_DIR}"

if [[ ! -x "${ROOT_DIR}/build/bankflow" ]]; then
  "${ROOT_DIR}/scripts/build.sh"
fi

export BANKFLOW_DATA_DIR="${DATA_DIR}"
export BANKFLOW_REPORT_DIR="${REPORT_DIR}"
export BANKFLOW_LOG_FILE="${LOG_FILE}"

if [[ -z "${BANKFLOW_VERBOSE:-}" && -n "${VERBOSE:-}" ]]; then
  export BANKFLOW_VERBOSE="${VERBOSE}"
fi

"${ROOT_DIR}/build/bankflow"

