#!/usr/bin/env python3
"""Perform repository-level packaging checks on the authoritative SLX file."""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
import zipfile
from pathlib import Path


MODEL_PATH = Path("model/Vataleni_PMSG_SSO_Final.slx")
REQUIRED_MEMBERS = {"[Content_Types].xml", "_rels/.rels", "simulink/blockdiagram.xml"}
RETIRED_SFUNCTIONS = (
    "dc_link_sfunc",
    "gsc_control_sfunc",
    "grid_current_sfunc",
    "msc_control_sfunc",
    "measurements_sfunc",
    "pcc_interface_sfunc",
    "pll_sfunc",
)


def tracked_paths(root: Path) -> list[str]:
    output = subprocess.check_output(
        ["git", "ls-files", "-z"], cwd=root, text=False
    )
    return [item.decode() for item in output.split(b"\0") if item]


def audit(root: Path) -> dict[str, int]:
    model = root / MODEL_PATH
    if not model.is_file():
        raise RuntimeError(f"{MODEL_PATH} is not one regular file")

    paths = tracked_paths(root)
    extracted = [
        path
        for path in paths
        if re.search(r"(^|/)(\[Content_Types\](?:\.xml)?|_rels|metadata|simulink)(/|$)", path)
    ]

    try:
        with zipfile.ZipFile(model) as archive:
            bad_member = archive.testzip()
            names = set(archive.namelist())
            missing_members = REQUIRED_MEMBERS - names
            payload = b"\n".join(
                archive.read(name)
                for name in names
                if name.endswith((".xml", ".rels"))
            ).lower()
    except zipfile.BadZipFile as exc:
        raise RuntimeError("authoritative model is not a valid SLX package") from exc

    if bad_member:
        raise RuntimeError(f"corrupt SLX member: {bad_member}")
    if missing_members:
        raise RuntimeError(f"missing required SLX members: {sorted(missing_members)}")

    retired_hits = sum(payload.count(name.encode()) for name in RETIRED_SFUNCTIONS)
    model_reference_blocks = len(
        re.findall(rb'<Block\s+BlockType="ModelReference"\b', payload)
    )
    result = {
        "file_size_bytes": model.stat().st_size,
        "tracked_extracted_internal_count": len(extracted),
        "retired_sfunction_reference_count": retired_hits,
        "model_reference_block_count": model_reference_blocks,
    }
    if any(result[key] for key in result if key != "file_size_bytes"):
        raise RuntimeError(f"SLX audit failed: {result}")
    return result


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    args = parser.parse_args()
    try:
        result = audit(args.root.resolve())
    except (RuntimeError, subprocess.CalledProcessError) as exc:
        print(f"SLX_AUDIT: FAIL: {exc}", file=sys.stderr)
        return 1
    for key, value in result.items():
        print(f"{key}={value}")
    print("SLX_AUDIT: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
