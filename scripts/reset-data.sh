#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATA_DIR="${DATA_DIR:-${ROOT_DIR}/data}"
REPORT_DIR="${REPORT_DIR:-${ROOT_DIR}/reports}"

mkdir -p "${DATA_DIR}" "${REPORT_DIR}"

rm -f "${DATA_DIR}/clients.dat" \
      "${DATA_DIR}/accounts.dat" \
      "${DATA_DIR}/transactions.dat" \
      "${DATA_DIR}/clientes.dat" \
      "${DATA_DIR}/contas.dat" \
      "${DATA_DIR}/transacoes.dat"

rm -f "${REPORT_DIR}/report.txt" \
      "${REPORT_DIR}/relatorio.txt"

echo "Data and report files cleared:"
echo "  DATA_DIR=${DATA_DIR}"
echo "  REPORT_DIR=${REPORT_DIR}"

