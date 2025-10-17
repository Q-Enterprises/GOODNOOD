#!/usr/bin/env bash
# freeze_embedding_pref.sh
# deps: jq, sha256sum
set -euo pipefail
CAP="${1:?capsule json required}"
LEDGER="${2:-ledger.embedding.pref.jsonl}"
SEALED_BY="${3:-Council}"

ts(){ date -u +%Y-%m-%dT%H:%M:%SZ; }

# 0) validate
"$(dirname "$0")/validate_embedding_pref.sh" "$CAP"

# 1) canonical BODY_ONLY
CANON="$(mktemp)"
jq -S 'del(.attestation,.seal,.signatures)' "$CAP" > "$CANON"
DIG="sha256:$(sha256sum "$CANON" | awk '{print $1}')"
STAMP="$(ts)"

# 2) seal (flip UNSEALED→SEALED, set attestation)
OUT=".out/$(basename "$CAP" .json).sealed.json"; mkdir -p .out
jq -S --arg dig "$DIG" --arg ts "$STAMP" --arg by "$SEALED_BY" '
  .seal = {state:"SEALED", sealed_at:$ts, content_hash:$dig, sealed_by:$by} |
  .attestation = {status:"SEALED", sealed_at:$ts, sealed_by:$by, content_hash:$dig}
' "$CAP" > "$OUT"

CID="$(jq -r .capsule_id "$OUT")"

# 3) ledger frames
{
  echo "{\"t\":\"$STAMP\",\"event\":\"capsule.commit.v1\",\"capsule\":\"$CID\",\"digest\":\"$DIG\"}"
  echo "{\"t\":\"$STAMP\",\"event\":\"capsule.review.v1\",\"capsule\":\"$CID\",\"reviewer\":\"$SEALED_BY\",\"status\":\"APPROVED\"}"
  echo "{\"t\":\"$STAMP\",\"event\":\"capsule.seal.v1\",\"capsule\":\"$CID\",\"sealed_by\":\"$SEALED_BY\",\"digest\":\"$DIG\"}"
} >> "$LEDGER"

echo "✅ SEALED $CID → $DIG"
echo "🧾 $OUT"
echo "📒 ledger → $LEDGER"
