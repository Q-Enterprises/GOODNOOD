#!/usr/bin/env bash
set -euo pipefail

CAPSULE_PATH="capsules/capsule.relay.viewer.v1.json"
CANONICAL_PATH="capsules/capsule.relay.viewer.v1.canon.json"
LEDGER_DIR="ledger"
LEDGER_FILE="${LEDGER_DIR}/relay_viewer_freeze.log"
SEALED_BY="${1:-Council}"

if [[ ! -f "${CAPSULE_PATH}" ]]; then
  echo "\"${CAPSULE_PATH}\" not found. Stage the relay viewer capsule before freezing." >&2
  exit 1
fi

if [[ ! -f "${CANONICAL_PATH}" ]]; then
  echo "\"${CANONICAL_PATH}\" not found. Provide the canonical payload before freezing." >&2
  exit 1
fi

for cmd in jq sha256sum; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "${cmd} is required to freeze the relay viewer capsule." >&2
    exit 1
  fi
done

mkdir -p "${LEDGER_DIR}" ".out"

BODY_ONLY="$(mktemp)"
jq -S . "${CANONICAL_PATH}" > "${BODY_ONLY}"
DIGEST="sha256:$(sha256sum "${BODY_ONLY}" | awk '{print $1}')"
TIMESTAMP="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
OUT_FILE=".out/capsule.relay.viewer.v1.sealed.json"

jq -S \
  --arg ts "${TIMESTAMP}" \
  --arg dig "${DIGEST}" \
  --arg by "${SEALED_BY}" \
  '
    .status = "FOSSILIZED" |
    .attestation.status = "SEALED" |
    .attestation.sealed_at = $ts |
    .attestation.sealed_by = $by |
    .attestation.content_hash = $dig
  ' "${CAPSULE_PATH}" > "${OUT_FILE}"

{
  echo "{\"t\":\"${TIMESTAMP}\",\"event\":\"capsule.commit.v1\",\"capsule\":\"capsule.relay.viewer.v1\",\"digest\":\"${DIGEST}\"}"
  echo "{\"t\":\"${TIMESTAMP}\",\"event\":\"capsule.review.v1\",\"capsule\":\"capsule.relay.viewer.v1\",\"reviewer\":\"${SEALED_BY}\",\"status\":\"APPROVED\"}"
  echo "{\"t\":\"${TIMESTAMP}\",\"event\":\"capsule.seal.v1\",\"capsule\":\"capsule.relay.viewer.v1\",\"sealed_by\":\"${SEALED_BY}\",\"digest\":\"${DIGEST}\"}"
} >> "${LEDGER_FILE}"

cat <<MSG
✅ SEALED capsule.relay.viewer.v1 → ${DIGEST}
🧾 ${OUT_FILE}
📒 ledger → ${LEDGER_FILE}
MSG
