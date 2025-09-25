#!/usr/bin/env bash
set -euo pipefail

CAPSULE_PATH="capsules/capsule.node.q9.pivot.v1.json"
LEDGER_DIR="ledger"
LEDGER_FILE="${LEDGER_DIR}/q9_pivot_freeze.log"

if [[ ! -f "${CAPSULE_PATH}" ]]; then
  echo "\"${CAPSULE_PATH}\" not found. Ensure the capsule is staged before freezing." >&2
  exit 1
fi

if ! command -v sha256sum >/dev/null 2>&1; then
  echo "sha256sum is required to freeze the Q9 pivot capsule." >&2
  exit 1
fi

mkdir -p "${LEDGER_DIR}"

HASH=$(sha256sum "${CAPSULE_PATH}" | awk '{print $1}')
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
ENTRY="${TIMESTAMP} ${HASH} ${CAPSULE_PATH}"

if [[ -f "${LEDGER_FILE}" ]] && grep -q "${HASH}" "${LEDGER_FILE}"; then
  echo "Capsule already frozen with hash ${HASH}." >&2
  exit 0
fi

echo "${ENTRY}" >> "${LEDGER_FILE}"

cat <<MSG
Q9 pivot capsule frozen.
Timestamp : ${TIMESTAMP}
Hash      : ${HASH}
Ledger    : ${LEDGER_FILE}
MSG
