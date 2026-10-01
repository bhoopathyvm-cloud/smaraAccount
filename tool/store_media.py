#!/usr/bin/env python3
"""Store screenshots and preview videos from a real running build.

Host controller for integration_test/store_screenshots_test.dart and
integration_test/store_previews_test.dart. It runs the test with
`flutter test -d <device>` and watches its output for markers the test
prints (`STORE_MEDIA shot|rec_start|rec_stop <name>`), taking device
screenshots and screen recordings at exactly those moments:

- iOS Simulator: `xcrun simctl io <udid> screenshot|recordVideo`
- Android emulator/device: `adb screencap` / `adb shell screenrecord`

Then, for previews, it composes with ffmpeg:
- App Store previews (iOS size classes): tour_02_record, tour_04_fix,
  tour_07_invest, each fitted to 15-30 s, 30 fps, Apple's exact
  resolution, with a silent stereo AAC track.
- A captioned landscape tour of every chapter (1920x1080) for the Google
  Play promo video (YouTube) and the project website.

Requirements: Flutter, ffmpeg (brew install ffmpeg), Pillow
(pip install pillow). WARNING: the tests reset the target's app data and
signing keys - use a Simulator/emulator, never a device with real books.

Usage (normally via tool/capture_store_screenshots.sh and
tool/record_store_previews.sh):
  tool/store_media.py shots    -d <device-id> -c <size-class> [-o <dir>]
  tool/store_media.py previews -d <device-id> -c <size-class> [-o <dir>]
  tool/store_media.py compose  -c <size-class> -o <dir>   # re-compose only
"""

import argparse
import json
import os
import re
import shutil
import signal
import subprocess
import sys
import textwrap
import time
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
SIZE_CLASSES = {
    # class: (platform, App Store preview size or None)
    "iphone-6.9in": ("ios", (886, 1920)),
    "iphone-6.5in": ("ios", (886, 1920)),
    "ipad-13in": ("ios", (1200, 1600)),
    "android-phone": ("android", None),
    "android-tablet-10in": ("android", None),
}
APPLE_PREVIEWS = ["tour_02_record", "tour_04_fix", "tour_07_invest"]
def _find_adb():
    found = shutil.which("adb")
    if found:
        return found
    for base in (os.environ.get("ANDROID_HOME"), os.environ.get("ANDROID_SDK_ROOT"),
                 str(Path.home() / "Library/Android/sdk")):
        if base and (Path(base) / "platform-tools/adb").exists():
            return str(Path(base) / "platform-tools/adb")
    return "adb"


ADB = _find_adb()
NAVY = (26, 58, 107)
IVORY = (244, 239, 227)
WHITE = (255, 255, 255)

CHAPTERS = {
    "intro": ("Smara Account",
              "Household books on your device, with a history that can't "
              "quietly rewrite itself."),
    "tour_01_setup": ("Start in under a minute",
                      "Pick your language and currency, name your account, "
                      "record your first entry. No sign-up, no cloud."),
    "tour_02_record": ("Record what you spend",
                       "Amount, category, a note. Your balance and this "
                       "month's totals update instantly."),
    "tour_03_split": ("Split one purchase",
                      "Divide a shop across categories. Save stays locked "
                      "until it adds up."),
    "tour_04_fix": ("Fix mistakes, keep history",
                    "A correction is added next to the original line, so "
                    "your books never quietly change."),
    "tour_05_limits": ("Monthly spending guides",
                       "Set a limit per category and watch progress on Home. "
                       "It informs, it never blocks."),
    "tour_06_transfer": ("Move money between accounts",
                         "Transfers post in one step, with optional fees and "
                         "currencies."),
    "tour_07_invest": ("Track investments",
                       "Cash plus holdings: buys, sells, dividends and a "
                       "clearly labeled market estimate."),
    "tour_08_search_summary": ("Find anything, see where it went",
                               "Search the register and summarize income and "
                               "spending by category."),
    "tour_09_recurring": ("Bills that repeat",
                          "Due bills appear on Home and record with one tap, "
                          "never automatically."),
    "tour_10_import": ("Import bank statements",
                       "OFX and CSV files, with duplicate checks and saved "
                       "category rules."),
    "tour_11_settings": ("Your data stays yours",
                         "Everything stays on your device: encrypted backups, "
                         "optional app lock, signed tamper-evident history."),
    "outro": ("Smara Account",
              "No account. No cloud. No ads.\nsmara-ai.ch"),
}


def run(cmd, **kw):
    return subprocess.run(cmd, check=True, **kw)


def ffprobe_duration(path):
    out = subprocess.run(
        ["ffprobe", "-v", "error", "-show_entries", "format=duration",
         "-of", "json", str(path)],
        check=True, capture_output=True, text=True).stdout
    return float(json.loads(out)["format"]["duration"])


class Device:
    def __init__(self, device_id, platform):
        self.id = device_id
        self.platform = platform
        self._rec = None
        self._rec_name = None

    def clean_status_bar(self):
        if self.platform == "ios":
            run(["xcrun", "simctl", "status_bar", self.id, "override",
                 "--time", "9:41", "--dataNetwork", "wifi", "--wifiMode",
                 "active", "--wifiBars", "3", "--cellularMode", "active",
                 "--cellularBars", "4", "--batteryState", "charged",
                 "--batteryLevel", "100"])
        else:
            adb = [ADB, "-s", self.id, "shell"]
            run(adb + ["settings", "put", "global", "sysui_demo_allowed", "1"])
            demo = adb + ["am", "broadcast", "-a", "com.android.systemui.demo",
                          "-e", "command"]
            run(demo + ["enter"], capture_output=True)
            run(demo + ["clock", "-e", "hhmm", "0941"], capture_output=True)
            run(demo + ["battery", "-e", "level", "100", "-e", "plugged",
                        "false"], capture_output=True)
            run(demo + ["network", "-e", "wifi", "show", "-e", "level", "4"],
                capture_output=True)
            run(demo + ["notifications", "-e", "visible", "false"],
                capture_output=True)

    def restore_status_bar(self):
        if self.platform == "ios":
            subprocess.run(["xcrun", "simctl", "status_bar", self.id,
                            "clear"])
        else:
            subprocess.run([ADB, "-s", self.id, "shell", "am", "broadcast",
                            "-a", "com.android.systemui.demo", "-e",
                            "command", "exit"], capture_output=True)

    def screenshot(self, path):
        if self.platform == "ios":
            run(["xcrun", "simctl", "io", self.id, "screenshot", str(path)],
                capture_output=True)
        else:
            with open(path, "wb") as fh:
                run([ADB, "-s", self.id, "exec-out", "screencap", "-p"],
                    stdout=fh)

    def start_recording(self, name, raw_dir):
        self._rec_name = name
        if self.platform == "ios":
            self._rec = subprocess.Popen(
                ["xcrun", "simctl", "io", self.id, "recordVideo",
                 "--codec=h264", "--force", str(raw_dir / f"{name}.mp4")],
                stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        else:
            self._rec = subprocess.Popen(
                [ADB, "-s", self.id, "shell", "screenrecord",
                 "--bit-rate", "12000000", f"/sdcard/sm_{name}.mp4"])
        time.sleep(0.8)

    def stop_recording(self, raw_dir):
        if not self._rec:
            return
        if self.platform == "ios":
            self._rec.send_signal(signal.SIGINT)
            self._rec.wait(timeout=30)
        else:
            subprocess.run([ADB, "-s", self.id, "shell", "pkill", "-INT",
                            "screenrecord"])
            self._rec.wait(timeout=30)
            time.sleep(1.0)
            remote = f"/sdcard/sm_{self._rec_name}.mp4"
            run([ADB, "-s", self.id, "pull", remote,
                 str(raw_dir / f"{self._rec_name}.mp4")], capture_output=True)
            subprocess.run([ADB, "-s", self.id, "shell", "rm", remote])
        self._rec = None


def run_test(test_file, device, on_marker):
    cmd = ["flutter", "test", test_file, "-d", device.id,
           "--dart-define=HIDE_DEBUG_BANNER=true"]
    print("$ " + " ".join(cmd), flush=True)
    proc = subprocess.Popen(cmd, cwd=REPO, stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT, text=True, bufsize=1)
    marker = re.compile(r"STORE_MEDIA (\w+) (\S+)")
    for line in proc.stdout:
        sys.stdout.write(line)
        m = marker.search(line)
        if m:
            on_marker(m.group(1), m.group(2))
    return proc.wait()


def cmd_shots(args, device):
    out = Path(args.out or REPO / "docs/release/store-listing/screenshots"
               / args.size_class)
    out.mkdir(parents=True, exist_ok=True)

    def on_marker(kind, name):
        if kind == "shot":
            path = out / f"{name}.png"
            device.screenshot(path)
            print(f"[store_media] wrote {path}", flush=True)

    return run_test("integration_test/store_screenshots_test.dart", device,
                    on_marker)


def cmd_previews(args, device):
    out = Path(args.out or REPO / "build/store_media" / args.size_class)
    raw = out / "raw"
    raw.mkdir(parents=True, exist_ok=True)

    def on_marker(kind, name):
        if kind == "rec_start":
            device.start_recording(name, raw)
            print(f"[store_media] recording {name}", flush=True)
        elif kind == "rec_stop":
            device.stop_recording(raw)
            print(f"[store_media] saved {raw / (name + '.mp4')}", flush=True)

    status = run_test("integration_test/store_previews_test.dart", device,
                      on_marker)
    device.stop_recording(raw)
    if status != 0:
        return status
    compose(args.size_class, out)
    return 0


# ---------------------------------------------------------------- compose

def _font(size, bold=False):
    candidates = [
        "/System/Library/Fonts/SFNS.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
        "/Library/Fonts/Arial.ttf",
    ]
    from PIL import ImageFont
    for c in candidates:
        if os.path.exists(c):
            try:
                font = ImageFont.truetype(c, size)
                if bold:
                    try:
                        font.set_variation_by_name("Bold")
                    except Exception:
                        pass
                return font
            except OSError:
                continue
    return ImageFont.load_default()


def chapter_card(key, path, with_phone_slot):
    """1920x1080 navy card: title + text on the left (or centered when the
    card is a full-screen intro/outro)."""
    from PIL import Image, ImageDraw
    title, body = CHAPTERS[key]
    img = Image.new("RGB", (1920, 1080), NAVY)
    d = ImageDraw.Draw(img)
    title_font, body_font = _font(76, bold=True), _font(42)
    if with_phone_slot:
        # Text column stays left of the phone (which starts near x=1250).
        x, max_width = 140, 1000
        title_lines = _wrap_px(d, title, title_font, max_width)
        body_lines = [l for para in body.split("\n")
                      for l in _wrap_px(d, para, body_font, max_width - 120)]
        height = len(title_lines) * 96 + 40 + len(body_lines) * 62
        y = (1080 - height) / 2
        for line in title_lines:
            d.text((x, y), line, font=title_font, fill=WHITE)
            y += 96
        y += 40
        for line in body_lines:
            d.text((x, y), line, font=body_font, fill=IVORY)
            y += 62
    else:
        tw = d.textlength(title, font=title_font)
        d.text(((1920 - tw) / 2, 400), title, font=title_font, fill=WHITE)
        y = 540
        for para in body.split("\n"):
            for line in textwrap.wrap(para, 52):
                lw = d.textlength(line, font=body_font)
                d.text(((1920 - lw) / 2, y), line, font=body_font, fill=IVORY)
                y += 62
    img.save(path)


def _wrap_px(draw, text, font, max_width):
    words, lines, line = text.split(), [], ""
    for w in words:
        trial = f"{line} {w}".strip()
        if draw.textlength(trial, font=font) <= max_width or not line:
            line = trial
        else:
            lines.append(line)
            line = w
    if line:
        lines.append(line)
    return lines


# Fraction of the recording to crop at (top, bottom) to drop the system
# status bar and home indicator / gesture bar, per platform.
SYSTEM_BAR_CROP = {"ios": (0.057, 0.036), "android": (0.042, 0.022)}


def _x264(dst_args):
    return ["-c:v", "libx264", "-profile:v", "high", "-pix_fmt", "yuv420p",
            "-r", "30"] + dst_args


def apple_preview(src, dst, size):
    w, h = size
    d = ffprobe_duration(src)
    vf = [f"scale={w}:{h}:force_original_aspect_ratio=decrease",
          f"pad={w}:{h}:(ow-iw)/2:(oh-ih)/2:color=black", "fps=30"]
    if d > 29.5:
        vf.insert(0, f"setpts=PTS*{29.5 / d:.4f}")
        d = 29.5
    if d < 15.5:
        vf.append(f"tpad=stop_mode=clone:stop_duration={15.5 - d:.2f}")
        d = 15.5
    run(["ffmpeg", "-y", "-loglevel", "error", "-i", str(src),
         "-f", "lavfi", "-i", "anullsrc=channel_layout=stereo:sample_rate=44100",
         "-vf", ",".join(vf), "-t", f"{d:.2f}", "-map", "0:v", "-map", "1:a"]
        + _x264(["-c:a", "aac", "-b:a", "256k", "-shortest",
                 "-movflags", "+faststart", str(dst)]))


def tour_segment_card(key, work, seconds=3.5):
    card = work / f"{key}.png"
    chapter_card(key, card, with_phone_slot=False)
    seg = work / f"seg_{key}.mp4"
    run(["ffmpeg", "-y", "-loglevel", "error", "-loop", "1", "-i", str(card),
         "-t", str(seconds), "-vf", "fps=30"] + _x264([str(seg)]))
    return seg


def tour_segment_clip(key, clip, work, platform):
    card = work / f"{key}.png"
    chapter_card(key, card, with_phone_slot=True)
    seg = work / f"seg_{key}.mp4"
    # Crop status/navigation bars so the tour is platform-neutral, frame the
    # app in ivory (its navy bars would otherwise merge into the navy card),
    # then place it on the right of the chapter card.
    top, bottom = SYSTEM_BAR_CROP[platform]
    fc = (f"[1:v]crop=iw:ih*{1 - top - bottom:.3f}:0:ih*{top:.3f},"
          "scale=-2:944,pad=iw+16:ih+16:8:8:color=0xF4EFE3[app];"
          "[0:v][app]overlay=x=W-w-190:y=(H-h)/2:shortest=1,fps=30[v]")
    run(["ffmpeg", "-y", "-loglevel", "error", "-loop", "1", "-i", str(card),
         "-i", str(clip), "-filter_complex", fc, "-map", "[v]"]
        + _x264([str(seg)]))
    return seg


def compose(size_class, out):
    if not shutil.which("ffmpeg"):
        sys.exit("ffmpeg not found - brew install ffmpeg")
    try:
        import PIL  # noqa: F401
    except ImportError:
        sys.exit("Pillow not found - pip install pillow")
    raw = out / "raw"
    work = out / "work"
    work.mkdir(parents=True, exist_ok=True)
    platform, apple_size = SIZE_CLASSES[size_class]

    if apple_size:
        for i, key in enumerate(APPLE_PREVIEWS, start=1):
            src = raw / f"{key}.mp4"
            if src.exists():
                dst = out / f"app_preview_{i}_{key.split('_', 2)[2]}.mp4"
                apple_preview(src, dst, apple_size)
                print(f"[store_media] App Store preview {dst} "
                      f"({ffprobe_duration(dst):.1f}s)", flush=True)

    segments = [tour_segment_card("intro", work)]
    for key in CHAPTERS:
        clip = raw / f"{key}.mp4"
        if key.startswith("tour_") and clip.exists():
            segments.append(tour_segment_clip(key, clip, work, platform))
    segments.append(tour_segment_card("outro", work))
    listing = work / "segments.txt"
    listing.write_text("".join(f"file '{s}'\n" for s in segments))
    tour = out / "tour_1920x1080.mp4"
    run(["ffmpeg", "-y", "-loglevel", "error", "-f", "concat", "-safe", "0",
         "-i", str(listing), "-f", "lavfi", "-i",
         "anullsrc=channel_layout=stereo:sample_rate=44100",
         "-map", "0:v", "-map", "1:a", "-c:v", "copy", "-c:a", "aac",
         "-b:a", "128k", "-shortest", "-movflags", "+faststart", str(tour)])
    print(f"[store_media] tour {tour} ({ffprobe_duration(tour):.0f}s)",
          flush=True)


def detect_platform(device_id):
    sims = subprocess.run(["xcrun", "simctl", "list", "devices", "booted"],
                          capture_output=True, text=True).stdout
    if device_id in sims:
        return "ios"
    adb = subprocess.run([ADB, "devices"], capture_output=True,
                         text=True).stdout
    if re.search(rf"^{re.escape(device_id)}\s+device$", adb, re.M):
        return "android"
    sys.exit(f"{device_id} is neither a booted iOS Simulator nor an adb "
             "device (real iPhones are not supported: they can't be "
             "screen-recorded from here, and the test wipes app data).")


def main():
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("command", choices=["shots", "previews", "compose"])
    p.add_argument("-d", dest="device")
    p.add_argument("-c", dest="size_class", required=True,
                   choices=sorted(SIZE_CLASSES))
    p.add_argument("-o", dest="out")
    args = p.parse_args()

    if args.command == "compose":
        compose(args.size_class,
                Path(args.out or REPO / "build/store_media" / args.size_class))
        return 0
    if not args.device:
        p.error("-d <device-id> is required")
    platform = detect_platform(args.device)
    if platform != SIZE_CLASSES[args.size_class][0]:
        p.error(f"{args.size_class} needs an {SIZE_CLASSES[args.size_class][0]}"
                f" device, got {platform}")
    device = Device(args.device, platform)
    device.clean_status_bar()
    try:
        if args.command == "shots":
            return cmd_shots(args, device)
        return cmd_previews(args, device)
    finally:
        device.restore_status_bar()


if __name__ == "__main__":
    sys.exit(main())
