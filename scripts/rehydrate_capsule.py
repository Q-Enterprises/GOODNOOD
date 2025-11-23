#!/usr/bin/env python3
"""Utilities to rehydrate capsule manifests with canonical payloads."""
from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
import sys
from pathlib import Path
from typing import Any, Dict


def _timestamp() -> str:
    return dt.datetime.now(dt.timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def _sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(8192), b""):
            digest.update(chunk)
    return f"sha256:{digest.hexdigest()}"


def rehydrate_capsule(
    capsule_dir: Path,
    out_path: Path | None = None,
    *,
    timestamp: str | None = None,
    update_manifest: bool = True,
) -> Path:
    manifest_path = capsule_dir / "manifest.json"
    if not manifest_path.exists():
        raise FileNotFoundError(f"Manifest not found: {manifest_path}")

    with manifest_path.open("r", encoding="utf-8") as handle:
        manifest: Dict[str, Any] = json.load(handle)

    canonical_info = manifest.get("canonical", {})
    canonical_rel = canonical_info.get("path", "canonical.json")
    canonical_path = capsule_dir / canonical_rel
    if not canonical_path.exists():
        raise FileNotFoundError(f"Canonical payload not found: {canonical_path}")

    with canonical_path.open("r", encoding="utf-8") as handle:
        canonical_body = json.load(handle)

    digest = _sha256(canonical_path)
    stamp = timestamp or _timestamp()

    canonical_info["body_digest"] = digest
    canonical_info["last_hydrated"] = stamp
    manifest["canonical"] = canonical_info

    if update_manifest:
        with manifest_path.open("w", encoding="utf-8") as handle:
            json.dump(manifest, handle, indent=2, sort_keys=True)
            handle.write("\n")

    capsule_id = manifest.get("metadata", {}).get("capsule_id", capsule_dir.name)
    if out_path is None:
        out_dir = Path(".out")
        out_dir.mkdir(parents=True, exist_ok=True)
        sanitized = capsule_id.replace("/", "_")
        out_path = out_dir / f"{sanitized}.hydrated.json"
    else:
        out_path.parent.mkdir(parents=True, exist_ok=True)

    hydrated: Dict[str, Any] = {
        "metadata": manifest.get("metadata", {}),
        "attestation": manifest.get("attestation", {}),
        "ledger": manifest.get("ledger", {}),
        "canonical": manifest.get("canonical", {}),
        "body": canonical_body,
    }

    summary = manifest.get("summary")
    if summary:
        hydrated["summary"] = summary

    with out_path.open("w", encoding="utf-8") as handle:
        json.dump(hydrated, handle, indent=2, sort_keys=True)
        handle.write("\n")

    return out_path


def main(argv: list[str] | None = None) -> None:
    parser = argparse.ArgumentParser(
        description="Rehydrate a capsule manifest with its canonical payload.",
    )
    parser.add_argument(
        "capsule",
        help="Path to the capsule directory containing manifest.json and canonical payload.",
    )
    parser.add_argument("--out", help="Explicit path for the hydrated artifact.")
    parser.add_argument("--timestamp", help="Override the timestamp recorded in the manifest.")
    parser.add_argument(
        "--no-update-manifest",
        action="store_true",
        help="Do not persist canonical metadata back to the manifest.",
    )
    args = parser.parse_args(argv)

    capsule_dir = Path(args.capsule)
    out_path = Path(args.out) if args.out else None
    try:
        hydrated_path = rehydrate_capsule(
            capsule_dir,
            out_path,
            timestamp=args.timestamp,
            update_manifest=not args.no_update_manifest,
        )
    except FileNotFoundError as exc:
        print(f"error: {exc}", file=sys.stderr)
        sys.exit(1)

    print(str(hydrated_path))


if __name__ == "__main__":
    main()
