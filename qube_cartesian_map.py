"""Utilities for constructing the Qube's sovereign cartesian map.

This module defines a light-weight schema that describes how the Qube's
sovereign capsules relate to one another in a cartesian lattice.  It is
intended to be imported by pipeline steps that need a deterministic view of
layer positions and edges, while also being runnable as a CLI that can emit a
JSON payload for inspection or downstream jobs.

The data encoded here mirrors the lineage described in the README and mirrors
existing capsules.  Each node references a capsule or ledger artifact and is
assigned to a logical layer (SSOT, motion, runtime, marketing, etc.).
"""
from __future__ import annotations

from dataclasses import asdict, dataclass
from typing import Dict, Iterable, List, Tuple
import argparse
import json


@dataclass(frozen=True)
class QubeNode:
    """A single position inside the cartesian map."""

    node_id: str
    capsule_ref: str
    description: str
    layer: str
    position: Tuple[int, int]


@dataclass(frozen=True)
class QubeEdge:
    """A directional edge connecting two cartesian nodes."""

    source: str
    target: str
    rationale: str


@dataclass(frozen=True)
class QubeCartesianMap:
    """Represents the entire lattice with nodes and edges."""

    nodes: List[QubeNode]
    edges: List[QubeEdge]

    def to_dict(self) -> Dict[str, List[Dict[str, object]]]:
        """Serialize the map to a JSON-compatible dictionary."""

        return {
            "nodes": [asdict(node) for node in self.nodes],
            "edges": [asdict(edge) for edge in self.edges],
        }

    def layer_index(self) -> Dict[str, List[str]]:
        """Return a lookup of layer name to node identifiers."""

        index: Dict[str, List[str]] = {}
        for node in self.nodes:
            index.setdefault(node.layer, []).append(node.node_id)
        return index


QUBE_CARTESIAN_NODES: Tuple[QubeNode, ...] = (
    QubeNode(
        node_id="ssot",
        capsule_ref="capsule.scene.ethereal.v2",
        description="Single source of truth scene capsule",
        layer="lineage",
        position=(0, 2),
    ),
    QubeNode(
        node_id="canon_kit",
        capsule_ref="capsule.canon.kit.v1.1.1",
        description="Canonical kit freeze binding runtime props",
        layer="lineage",
        position=(1, 2),
    ),
    QubeNode(
        node_id="motion_loop",
        capsule_ref="relay.legoF1.monza.loop.v1",
        description="240-frame stop-motion relay ledger",
        layer="motion",
        position=(0, 1),
    ),
    QubeNode(
        node_id="qulock",
        capsule_ref="capsule.engine.qlock.runtime.v1",
        description="QLOCK runtime engine attestation",
        layer="runtime",
        position=(1, 1),
    ),
    QubeNode(
        node_id="pivot",
        capsule_ref="capsule.node.q9.pivot.v1",
        description="Q9 pivot node bridging semantics and artifacts",
        layer="graph",
        position=(0, 0),
    ),
    QubeNode(
        node_id="cartesian_map",
        capsule_ref="capsule.map.qube.cartesian.v1",
        description="Canonical cartesian lattice map sealed for runtime",
        layer="graph",
        position=(1, 0),
    ),
    QubeNode(
        node_id="pedagogy",
        capsule_ref="capsule.relay.pedagogy.queenboo.v1",
        description="Contributor descent capsule binding training loops",
        layer="training",
        position=(2, 1),
    ),
    QubeNode(
        node_id="marketing",
        capsule_ref="relay.trailer.legoF1.plan.v1",
        description="Public relay plan for Lego F1 25 trailer",
        layer="broadcast",
        position=(2, 0),
    ),
    QubeNode(
        node_id="federation",
        capsule_ref="capsule.federate.v1",
        description="Broadcast frame for distributing sealed bundles",
        layer="broadcast",
        position=(3, 0),
    ),
)

QUBE_CARTESIAN_EDGES: Tuple[QubeEdge, ...] = (
    QubeEdge(
        source="ssot",
        target="motion_loop",
        rationale="Motion ledger derives from SSOT lineage",
    ),
    QubeEdge(
        source="canon_kit",
        target="qulock",
        rationale="Canonical kit is rendered through QLOCK",
    ),
    QubeEdge(
        source="qulock",
        target="cartesian_map",
        rationale="Runtime engine feeds the cockpit map",
    ),
    QubeEdge(
        source="motion_loop",
        target="pivot",
        rationale="Pivot node consumes motion embeddings",
    ),
    QubeEdge(
        source="cartesian_map",
        target="pedagogy",
        rationale="Map anchors contributor descent rituals",
    ),
    QubeEdge(
        source="cartesian_map",
        target="marketing",
        rationale="Cockpit map informs marketing relay broadcast",
    ),
    QubeEdge(
        source="cartesian_map",
        target="federation",
        rationale="Sealed map is broadcast across the federation mesh",
    ),
)


def build_default_map() -> QubeCartesianMap:
    """Construct the canonical cartesian map."""

    return QubeCartesianMap(
        nodes=list(QUBE_CARTESIAN_NODES),
        edges=list(QUBE_CARTESIAN_EDGES),
    )


def emit_json(map_: QubeCartesianMap) -> str:
    """Return a pretty-printed JSON representation."""

    return json.dumps(map_.to_dict(), indent=2, sort_keys=True)


def emit_markdown(map_: QubeCartesianMap) -> str:
    """Render the map as a simple markdown table."""

    header = "| Node | Capsule | Layer | Position | Description |\n|---|---|---|---|---|"
    rows = [
        "| {node.node_id} | {node.capsule_ref} | {node.layer} | ({x}, {y}) | {desc} |".format(
            node=node,
            x=node.position[0],
            y=node.position[1],
            desc=node.description,
        )
        for node in map_.nodes
    ]
    return "\n".join([header, *rows])


def parse_args(argv: Iterable[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Emit the Qube cartesian map for downstream jobs.",
    )
    parser.add_argument(
        "--format",
        choices=("json", "markdown"),
        default="json",
        help="Output format to emit (default: json).",
    )
    return parser.parse_args(argv)


def main(argv: Iterable[str] | None = None) -> None:
    args = parse_args(argv)
    map_ = build_default_map()
    if args.format == "json":
        print(emit_json(map_))
    else:
        print(emit_markdown(map_))


if __name__ == "__main__":
    main()
