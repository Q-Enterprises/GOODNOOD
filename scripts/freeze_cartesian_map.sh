#!/usr/bin/env bash
set -euo pipefail

CAPSULE_PATH="capsules/capsule.map.qube.cartesian.v1.json"
LEDGER_DIR="ledger"
LEDGER_FILE="${LEDGER_DIR}/qube_cartesian_map_freeze.log"

if [[ ! -f "${CAPSULE_PATH}" ]]; then
  echo "\"${CAPSULE_PATH}\" not found. Stage the cartesian map capsule before freezing." >&2
  exit 1
fi

if ! command -v sha256sum >/dev/null 2>&1; then
  echo "sha256sum is required to freeze the cartesian map capsule." >&2
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
Cartesian map capsule frozen.
Timestamp : ${TIMESTAMP}
Hash      : ${HASH}
Ledger    : ${LEDGER_FILE}
MSG
