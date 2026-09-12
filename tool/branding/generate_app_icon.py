#!/usr/bin/env python3
"""Regenerate launcher assets for all five platforms from the approved Smara artwork.

The source is the navy-and-ivory folded S with a calculator. Keep it separate
from the normalized 1024px master so regeneration never resamples a thumbnail.
Run from any directory after `flutter pub get`.
"""

from pathlib import Path
import shutil
import subprocess


def main() -> None:
    root = Path(__file__).resolve().parents[2]
    branding = root / "assets" / "branding"
    shutil.copyfile(branding / "app_icon_source.png", branding / "app_icon.png")
    subprocess.run(["dart", "run", "flutter_launcher_icons"], cwd=root, check=True)
    ios_icons = root / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    shutil.copyfile(ios_icons / "Icon-App-1024x1024@1x.png", branding / "app_icon.png")
    shutil.copyfile(ios_icons / "Icon-App-20x20@1x.png", branding / "app_icon_20.png")
    print("Updated iOS, macOS, Android, Windows, and the shared Linux/master icon.")


if __name__ == "__main__":
    main()
