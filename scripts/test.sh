#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

DATA_DIR="${DATA_DIR:-$(mktemp -d "${ROOT_DIR}/data-test.XXXXXX")}"
REPORT_DIR="${REPORT_DIR:-$(mktemp -d "${ROOT_DIR}/reports-test.XXXXXX")}"
KEEP_DIRS="${KEEP_TEST_DIRS:-0}"
LOG_FILE_TEMP="${REPORT_DIR}/events.log"

cleanup() {
  if [[ "${KEEP_DIRS}" -ne 1 ]]; then
    rm -rf "${DATA_DIR}" "${REPORT_DIR}"
  fi
}
trap cleanup EXIT

mkdir -p "${DATA_DIR}" "${REPORT_DIR}"

"${ROOT_DIR}/scripts/build.sh"

export DATA_DIR
export REPORT_DIR
export BANKFLOW_DATA_DIR="${DATA_DIR}"
export BANKFLOW_REPORT_DIR="${REPORT_DIR}"
export BANKFLOW_LOG_FILE="${LOG_FILE_TEMP}"
export BANKFLOW_VERBOSE="${BANKFLOW_VERBOSE:-N}"

"${ROOT_DIR}/scripts/reset-data.sh" >/dev/null

run_case() {
  local name="$1"
  local input="$2"
  local log="${REPORT_DIR}/${name}.log"
  printf "%b" "${input}" | "${ROOT_DIR}/build/bankflow" >"${log}"
  echo "${log}"
}

# Base scenario (customer, account, deposit, withdrawal, report)
BASE_INPUT=$'1\nJohn Smith\n12345678901\n123 Main Street\n\n2\n1\n\n3\n1\n250.00\n\n4\n1\n50.00\n\n5\n1\n\n7\n1\n\n8\n'
BASE_LOG="$(run_case "base" "${BASE_INPUT}")"
grep -q "Customer registered successfully" "${BASE_LOG}"
grep -q "Account created successfully" "${BASE_LOG}"
grep -q "Deposit completed successfully" "${BASE_LOG}"
grep -q "Withdrawal completed successfully" "${BASE_LOG}"
grep -q "Current balance" "${BASE_LOG}"
grep -q "Report generated successfully" "${BASE_LOG}"
grep -q "Account: 00000001" "${REPORT_DIR}/report.txt"

# Deposit into non-existing account
INVALID_DEPOSIT_INPUT=$'3\n99999999\n10.00\n\n8\n'
INVALID_DEPOSIT_LOG="$(run_case "deposit-invalid" "${INVALID_DEPOSIT_INPUT}")"
grep -q "Account not found" "${INVALID_DEPOSIT_LOG}"

# Withdrawal with insufficient funds
INSUFFICIENT_INPUT=$'4\n1\n9999.00\n\n8\n'
INSUFFICIENT_LOG="$(run_case "withdraw-insufficient" "${INSUFFICIENT_INPUT}")"
grep -q "Insufficient funds" "${INSUFFICIENT_LOG}"

# Second customer/account and report verification
MULTI_INPUT=$'1\nMary Johnson\n10987654321\n456 Second Avenue\n\n2\n2\n\n3\n2\n300.00\n\n7\n2\n\n8\n'
MULTI_LOG="$(run_case "multi-client" "${MULTI_INPUT}")"
grep -q "Customer registered successfully" "${MULTI_LOG}"
grep -q "Account created successfully! Number: 00000002" "${MULTI_LOG}"
grep -q "Deposit completed successfully" "${MULTI_LOG}"
grep -q "Report generated successfully" "${MULTI_LOG}"
grep -q "Account: 00000002" "${REPORT_DIR}/report.txt"
grep -q "Total customer balance" "${REPORT_DIR}/report.txt"

# Transfer between accounts
TRANSFER_INPUT=$'6\n1\n2\n75.00\n\n5\n1\n\n5\n2\n\n8\n'
TRANSFER_LOG="$(run_case "transfer" "${TRANSFER_INPUT}")"
grep -q "Transfer completed successfully" "${TRANSFER_LOG}"
grep -q "Current balance" "${TRANSFER_LOG}"

# Preserve final results in project directories
mkdir -p "${ROOT_DIR}/data" "${ROOT_DIR}/reports"
cp "${DATA_DIR}/clients.dat" "${ROOT_DIR}/data/clients.dat"
cp "${DATA_DIR}/accounts.dat" "${ROOT_DIR}/data/accounts.dat"
cp "${DATA_DIR}/transactions.dat" "${ROOT_DIR}/data/transactions.dat"
cp "${REPORT_DIR}/report.txt" "${ROOT_DIR}/reports/report.txt"
mkdir -p "${ROOT_DIR}/logs"
if [[ -f "${LOG_FILE_TEMP}" ]]; then
  cp "${LOG_FILE_TEMP}" "${ROOT_DIR}/logs/events.log"
fi
cat "${BASE_LOG}" \
    "${INVALID_DEPOSIT_LOG}" \
    "${INSUFFICIENT_LOG}" \
    "${MULTI_LOG}" \
    "${TRANSFER_LOG}" > "${ROOT_DIR}/reports/test-output.log"

echo "Functional tests OK"

