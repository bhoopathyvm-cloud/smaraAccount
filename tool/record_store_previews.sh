#!/bin/sh
# Records the store preview videos: three App Store previews and one captioned full tour
# from a real running build on an iOS Simulator or Android emulator.
# See tool/store_media.py for details and docs/release/store-release-runbook.md
# for when to run it.
#
# WARNING: resets the target's app data and signing keys first. Never run
# it against a device holding real books.
#
# Usage: tool/record_store_previews.sh -d <device-id> -c <size-class> [-o <dir>]
#   size classes: iphone-6.9in iphone-6.5in ipad-13in android-phone
#                 android-tablet-10in
#   The Mac App Store screenshot is captured by hand (see the runbook).
set -eu
repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
exec python3 "$repo_root/tool/store_media.py" previews "$@"
