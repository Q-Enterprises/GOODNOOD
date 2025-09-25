#!/usr/bin/env bash
# validate_embedding_pref.sh
set -euo pipefail
CAP="${1:?capsule json required}"

jq -e '
  .capsule_id=="capsule.lora.embedding.pref.v1" and
  .type=="PreferenceCapsule" and
  (.positive_features|type=="array" and length>0) and
  (.negative_features|type=="array" and length>0) and
  (.scripture_prompt|type=="string" and (.|length)>40) and
  (.artifact.name|type=="string") and
  (.provenance.ssot_ref|type=="string")
' "$CAP" >/dev/null || { echo "❌ schema/required fields failed"; exit 1; }

echo "✅ embedding.pref capsule passes guards"
