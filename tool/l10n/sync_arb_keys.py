#!/usr/bin/env python3
"""Copy missing keys from app_en.arb into every locale ARB, then apply overlays."""

from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from overlays import OVERLAYS

L10N = Path(__file__).resolve().parents[2] / "lib" / "l10n"


def parse_arb(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def dump_arb(data: dict) -> str:
    return json.dumps(data, ensure_ascii=False, indent=2) + "\n"


def main() -> None:
    en = parse_arb(L10N / "app_en.arb")
    en_keys = [k for k in en if not k.startswith("@") and k != "@@locale"]

    locale_files = [
        path
        for path in sorted(L10N.glob("app_*.arb"))
        if path.name != "app_en.arb"
    ]
    for path in locale_files:
        data = parse_arb(path)
        locale = data.get("@@locale") or path.stem.split("_", 1)[1]
        loc_overlay = OVERLAYS.get(locale, {})
        out = {"@@locale": locale}
        for key, value in en.items():
            if key == "@@locale":
                continue
            if key.startswith("@"):
                out[key] = value
                continue
            if key in loc_overlay:
                out[key] = loc_overlay[key]
            elif key in data:
                out[key] = data[key]
            else:
                out[key] = value
        path.write_text(dump_arb(out), encoding="utf-8")
        missing = [k for k in en_keys if k not in out]
        if missing:
            raise SystemExit(f"{path.name} missing keys: {missing}")
    print(f"Synced {len(locale_files)} locale ARB files")


if __name__ == "__main__":
    main()
