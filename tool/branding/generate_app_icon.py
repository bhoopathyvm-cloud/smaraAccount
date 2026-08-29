#!/usr/bin/env python3
"""Generate the 1024×1024 SMARA Account master launcher icon.

A navy field (AppColors.primary) with a white ledger page and a small
seal — simple enough to stay readable at iOS notification size (20×20).
"""

from __future__ import annotations

import struct
import zlib
from pathlib import Path

SIZE = 1024
PRIMARY = (0x1A, 0x3A, 0x6B, 255)
WHITE = (255, 255, 255, 255)


def _in_round_rect(x: int, y: int, l: int, t: int, r: int, b: int, rad: int) -> bool:
    if x < l or x >= r or y < t or y >= b:
        return False
    # Corner circles
    if x < l + rad and y < t + rad:
        return (x - (l + rad)) ** 2 + (y - (t + rad)) ** 2 <= rad * rad
    if x >= r - rad and y < t + rad:
        return (x - (r - 1 - rad)) ** 2 + (y - (t + rad)) ** 2 <= rad * rad
    if x < l + rad and y >= b - rad:
        return (x - (l + rad)) ** 2 + (y - (b - 1 - rad)) ** 2 <= rad * rad
    if x >= r - rad and y >= b - rad:
        return (x - (r - 1 - rad)) ** 2 + (y - (b - 1 - rad)) ** 2 <= rad * rad
    return True


def _in_circle(x: int, y: int, cx: int, cy: int, rad: int) -> bool:
    return (x - cx) ** 2 + (y - cy) ** 2 <= rad * rad


def pixel(x: int, y: int) -> tuple[int, int, int, int]:
    # Generous padding so the page remains a clear rectangle at 20px.
    page_l, page_t, page_r, page_b = 236, 180, 788, 844
    page_rad = 48
    if _in_round_rect(x, y, page_l, page_t, page_r, page_b, page_rad):
        # Three ledger rules, thick enough to survive downscaling.
        for rule_y in (420, 600):
            if abs(y - rule_y) <= 28 and page_l + 90 <= x <= page_r - 90:
                return PRIMARY
        # Remembrance seal in the lower-right of the page.
        if _in_circle(x, y, 680, 740, 56):
            return PRIMARY
        return WHITE
    return PRIMARY


def write_png(path: Path, width: int, height: int) -> None:
    def chunk(tag: bytes, data: bytes) -> bytes:
        crc = zlib.crc32(tag + data) & 0xFFFFFFFF
        return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", crc)

    raw = bytearray()
    for y in range(height):
        raw.append(0)
        for x in range(width):
            raw.extend(pixel(x, y) if width == SIZE else pixel(x * SIZE // width, y * SIZE // height))
    ihdr = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)
    png = (
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", ihdr)
        + chunk(b"IDAT", zlib.compress(bytes(raw), 9))
        + chunk(b"IEND", b"")
    )
    path.write_bytes(png)


def main() -> None:
    out_dir = Path(__file__).resolve().parents[2] / "assets" / "branding"
    out_dir.mkdir(parents=True, exist_ok=True)
    write_png(out_dir / "app_icon.png", SIZE, SIZE)
    write_png(out_dir / "app_icon_20.png", 20, 20)
    print(f"Wrote {out_dir / 'app_icon.png'}")


if __name__ == "__main__":
    main()
