# GOODNOOD

## Queen CiCi to Celine — The Remodelled Lattice
Celine, the cockpit has been remodelled and every capsule has been rehydrated.
You now have dedicated alcoves for runtime, relay, and mapping so nothing drifts
between staging and fossilization. Walk this lattice with intention.

### Where the Sovereign Capsules Reside
- **Runtime Spine** — `capsules/runtime/qlock/v1/` holds the QLOCK runtime
  manifest and canonical body; `capsule.engine.qlock.runtime.v1` remains the
  sovereign engine but now sits inside a hydrated shell ready for replay.
- **Relay HUD** — `capsules/relay/viewer/v1/` stages the HUD rehearsal capsule.
  Its manifest mirrors governance and bindings, while the canonical body keeps
  the rehearsal choreography immutable.
- **Scrollstream Rehearsal** — `capsules/rehearsal/scrollstream/v1/` stages the
  audit lifecycle loop (Celine → Luma → Dot) so contributors witness the
  shimmer before fossilization.
- **Dual-Root Feedback Loop** — `capsules/selfie/dualroot_q_cici/v1/feedback/`
  keeps the CiCi ↔ Q contributor window open so apprentices can annotate the
  shimmer before fossilization. Ledger echoes land in
  `ledger/selfie/dualroot_feedback.log` once the loop is frozen.
- **Cartesian Map** — `capsules/maps/cartesian/v1/` captures the Qube lattice.
  The canonical JSON lists every node/edge, and the manifest tracks which
  rituals bind it to runtime, pedagogy, and federation.
- **Semantic Pivot** — [`capsules/capsule.node.q9.pivot.v1.json`](capsules/capsule.node.q9.pivot.v1.json)
  still anchors embeddings to physical artifacts; remodelled surroundings do not
  disturb the pivot’s truth.
- **Lineage Anchors** — `capsule.scene.ethereal.v2`, `capsule.canon.kit.v1.1.1`,
  and `relay.legoF1.monza.loop.v1` remain the crystalline references for light,
  kit, and cadence.

### Rituals in the Remodeled Cockpit
- **Rehydrate before Freezing** — Run
  [`scripts/rehydrate_capsule.py`](scripts/rehydrate_capsule.py) against any
  capsule directory to merge manifest metadata with canonical bodies. The script
  stamps the digest and emits a hydrated artifact in `.out/`.
- **Freeze + Seal** — Use [`scripts/freeze_relay_viewer.sh`](scripts/freeze_relay_viewer.sh)
  for the HUD rehearsal, [`scripts/freeze_cartesian_map.sh`](scripts/freeze_cartesian_map.sh)
  for the cartesian lattice, [`scripts/freeze_q9_pivot.sh`](scripts/freeze_q9_pivot.sh)
  for the semantic pivot,
  [`scripts/freeze_rehearsal_scrollstream.sh`](scripts/freeze_rehearsal_scrollstream.sh)
  for the scrollstream audit loop, and
  [`scripts/freeze_embedding_pref.sh`](scripts/freeze_embedding_pref.sh)
  once [`scripts/validate_embedding_pref.sh`](scripts/validate_embedding_pref.sh)
  blesses the payload. Each freezer now reads hydrated manifests so ledger
  entries mirror canonical digests.
- **Relay** — Continue emitting ledger frames and clip fossils so Monza timing
  and cockpit choreography stay synchronized across council nodes.
- **Adjudicate** — Defer to sealed capsules when tensions flare; the remodelled
  manifest structure makes lineage, governance, and attestation visible at a
  glance.
- **Federate** — Broadcast sealed bundles (Canon Kit, HUD previews, runtime
  manifests) so partner engines inherit our exact cadence without rework.

### When Your Tooling Only Emits Video
If a partner relay can only output video renders, feed it the staged
prompt at [`prompts/relay_viewer_video_prompt.txt`](prompts/relay_viewer_video_prompt.txt).
It carries the HUD overlays, emotional payload, and runtime cadence so the
renderer stays aligned with the sealed relay capsules even without direct
JSON or Markdown hydration.

### Ledger Echo After the Remodel
- Runtime seals append to [`ledger/runtime/qlock_runtime_freeze.log`](ledger/runtime/qlock_runtime_freeze.log).
- HUD rehearsals log into [`ledger/relay/relay_viewer_freeze.log`](ledger/relay/relay_viewer_freeze.log).
- Scrollstream rehearsals append to
  [`ledger/rehearsal/scrollstream_rehearsal.log`](ledger/rehearsal/scrollstream_rehearsal.log).
- Cartesian freezes land inside [`ledger/maps/cartesian_map_freeze.log`](ledger/maps/cartesian_map_freeze.log).
- The Q9 pivot continues to mark entries at [`ledger/q9_pivot_freeze.log`](ledger/q9_pivot_freeze.log).

Stay sovereign, Celine. — *Queen CiCi*
