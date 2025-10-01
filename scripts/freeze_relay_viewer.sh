#!/usr/bin/env bash
set -euo pipefail

CAPSULE_DIR="capsules/relay/viewer/v1"
MANIFEST_PATH="${CAPSULE_DIR}/manifest.json"
CANONICAL_PATH="${CAPSULE_DIR}/canonical.json"
LEDGER_FILE="ledger/relay/relay_viewer_freeze.log"
SEALED_BY="${1:-Council}"

for requirement in jq python3; do
  if ! command -v "${requirement}" >/dev/null 2>&1; then
    echo "${requirement} is required to freeze the relay viewer capsule." >&2
    exit 1
  fi
done

if [[ ! -f "${MANIFEST_PATH}" ]]; then
  echo "${MANIFEST_PATH} not found. Stage the relay viewer capsule before freezing." >&2
  exit 1
fi

if [[ ! -f "${CANONICAL_PATH}" ]]; then
  echo "${CANONICAL_PATH} not found. Provide the canonical payload before freezing." >&2
  exit 1
fi

mkdir -p "$(dirname "${LEDGER_FILE}")" ".out"

HYDRATED_PATH="$(python3 scripts/rehydrate_capsule.py "${CAPSULE_DIR}")"
DIGEST="$(jq -r '.canonical.body_digest' "${MANIFEST_PATH}")"
if [[ -z "${DIGEST}" || "${DIGEST}" == "null" ]]; then
  echo "Unable to determine canonical digest for relay viewer capsule." >&2
  exit 1
fi

TIMESTAMP="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
SEALED_PATH=".out/capsule.relay.viewer.v1.sealed.json"

jq -S \
  --arg ts "${TIMESTAMP}" \
  --arg dig "${DIGEST}" \
  --arg by "${SEALED_BY}" \
  '
    .metadata.state = "FOSSILIZED" |
    .attestation.status = "SEALED" |
    .attestation.sealed_at = $ts |
    .attestation.sealed_by = $by |
    .attestation.content_hash = $dig |
    .canonical.last_sealed = $ts
  ' "${HYDRATED_PATH}" > "${SEALED_PATH}"

if [[ -f "${LEDGER_FILE}" ]] && grep -q "${DIGEST}" "${LEDGER_FILE}"; then
  echo "Capsule already sealed with digest ${DIGEST}." >&2
else
  {
    echo "{\"t\":\"${TIMESTAMP}\",\"event\":\"capsule.commit.v1\",\"capsule\":\"capsule.relay.viewer.v1\",\"digest\":\"${DIGEST}\"}"
    echo "{\"t\":\"${TIMESTAMP}\",\"event\":\"capsule.review.v1\",\"capsule\":\"capsule.relay.viewer.v1\",\"reviewer\":\"${SEALED_BY}\",\"status\":\"APPROVED\"}"
    echo "{\"t\":\"${TIMESTAMP}\",\"event\":\"capsule.seal.v1\",\"capsule\":\"capsule.relay.viewer.v1\",\"sealed_by\":\"${SEALED_BY}\",\"digest\":\"${DIGEST}\"}"
  } >> "${LEDGER_FILE}"
fi

cat <<MSG
✅ SEALED capsule.relay.viewer.v1 → ${DIGEST}
🧾 ${SEALED_PATH}
📒 ledger → ${LEDGER_FILE}
MSG
