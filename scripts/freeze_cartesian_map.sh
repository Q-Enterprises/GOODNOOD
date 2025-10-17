#!/usr/bin/env bash
set -euo pipefail

CAPSULE_DIR="capsules/maps/cartesian/v1"
MANIFEST_PATH="${CAPSULE_DIR}/manifest.json"
CANONICAL_PATH="${CAPSULE_DIR}/canonical.json"
LEDGER_FILE="ledger/maps/cartesian_map_freeze.log"

for requirement in jq python3; do
  if ! command -v "${requirement}" >/dev/null 2>&1; then
    echo "${requirement} is required to freeze the cartesian map capsule." >&2
    exit 1
  fi
done

if [[ ! -f "${MANIFEST_PATH}" ]]; then
  echo "${MANIFEST_PATH} not found. Stage the cartesian map capsule before freezing." >&2
  exit 1
fi

if [[ ! -f "${CANONICAL_PATH}" ]]; then
  echo "${CANONICAL_PATH} not found. Provide the canonical payload before freezing." >&2
  exit 1
fi

mkdir -p "$(dirname "${LEDGER_FILE}")"

HYDRATED_PATH="$(python3 scripts/rehydrate_capsule.py "${CAPSULE_DIR}")"
DIGEST="$(jq -r '.canonical.body_digest' "${MANIFEST_PATH}")"
if [[ -z "${DIGEST}" || "${DIGEST}" == "null" ]]; then
  echo "Unable to determine canonical digest for cartesian map capsule." >&2
  exit 1
fi

TIMESTAMP="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
ENTRY="${TIMESTAMP} ${DIGEST} ${CANONICAL_PATH}"

if [[ -f "${LEDGER_FILE}" ]] && grep -q "${DIGEST}" "${LEDGER_FILE}"; then
  echo "Capsule already frozen with digest ${DIGEST}." >&2
else
  echo "${ENTRY}" >> "${LEDGER_FILE}"
fi

cat <<MSG
Cartesian map capsule frozen.
Timestamp : ${TIMESTAMP}
Digest    : ${DIGEST}
Hydrated  : ${HYDRATED_PATH}
Ledger    : ${LEDGER_FILE}
MSG
