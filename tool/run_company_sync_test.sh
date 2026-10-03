#!/usr/bin/env bash
# Company sync multi-instance acceptance runner (tasks 7.3–7.5 / 8.x).
#
# Usage:
#   tool/run_company_sync_test.sh [--employees N] [--dry] [--ios-only]
#
# --employees N   Claimant count (default 2; max 5). Full cast is 5.
# --dry           Two-role dry run (Owner macOS + one iOS Claimant) for 7.2.
# --ios-only      Skip Android emulators (also used when sudo for vmnet is declined).
#
# Artifacts land under build/company_sync/<timestamp>/.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

EMPLOYEES=2
DRY=0
IOS_ONLY=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --employees) EMPLOYEES="${2:?}"; shift 2 ;;
    --dry) DRY=1; shift ;;
    --ios-only) IOS_ONLY=1; shift ;;
    -h|--help)
      sed -n '2,14p' "$0"
      exit 0
      ;;
    *) echo "Unknown arg: $1" >&2; exit 64 ;;
  esac
done

TS="$(date -u +%Y%m%dT%H%M%SZ)"
REPORT_DIR="$ROOT/build/company_sync/$TS"
mkdir -p "$REPORT_DIR"/{owner,approver,claimant_0,claimant_1,claimant_2,claimant_3,claimant_4,conductor}

# Free-memory check (task 7.3).
free_gb() {
  if command -v vm_stat >/dev/null 2>&1; then
    python3 - <<'PY'
import re, subprocess
out = subprocess.check_output(["vm_stat"], text=True)
m = re.search(r"page size of (\d+)", out)
page = int(m.group(1)) if m else 16384
free = 0
for line in out.splitlines():
    if line.startswith(("Pages free", "Pages speculative", "Pages inactive", "Pages purgeable")):
        free += int(line.split(":")[1].strip().rstrip(".")) * page
print(int(free / (1024**3)))
PY
  else
    echo 0
  fi
}
NEED_GB=2
if [[ "$DRY" -eq 0 ]]; then NEED_GB=5; fi
if [[ "$EMPLOYEES" -ge 5 && "$DRY" -eq 0 ]]; then NEED_GB=10; fi
FREE="$(free_gb)"
echo "Free memory ~${FREE} GB (need >= ${NEED_GB})"
if [[ "$FREE" -lt "$NEED_GB" ]]; then
  echo "Not enough free memory for this cast; try --employees 2 or free RAM." >&2
  exit 1
fi

# --- Simulators (task 7.3) ---
# Prefer a light cast on 16 GB hosts: shut down sims we will not use.
IOS_BUNDLE_ID="com.smaraaccounting.smaraAccounting"
ANDROID_PACKAGE="com.smaraaccounting.smara_accounting"

latest_ios_runtime() {
  xcrun simctl list runtimes available | python3 -c '
import re,sys
best=None
for line in sys.stdin:
    # e.g. iOS 26.5 (26.5 - 23F77) - com.apple.CoreSimulator.SimRuntime.iOS-26-5
    m=re.search(r"(com\.apple\.CoreSimulator\.SimRuntime\.iOS-[\d-]+)", line)
    if m: best=m.group(1)
print(best or "")
'
}

find_sim_udid() {
  # Args: exact device name substrings to try in order.
  python3 - "$@" <<'PY'
import re, subprocess, sys
out = subprocess.check_output(["xcrun", "simctl", "list", "devices", "available"], text=True)
names = sys.argv[1:]
for name in names:
    for line in out.splitlines():
        if name not in line:
            continue
        # Prefer exact name match before the UUID paren.
        # "iPhone 17 (" must not match "iPhone 17 Pro" / "iPhone 17e".
        m = re.search(r"^\s*(.+?)\s+\(([A-F0-9-]{36})\)", line)
        if not m:
            continue
        device_name = m.group(1).strip()
        if name == "iPhone 17":
            if device_name != "iPhone 17":
                continue
        elif name not in device_name and device_name != name:
            continue
        print(m.group(2))
        sys.exit(0)
sys.exit(1)
PY
}

create_sim() {
  local name="$1"
  local device_type="$2"
  local runtime
  runtime="$(latest_ios_runtime)"
  if [[ -z "$runtime" ]]; then
    echo "No iOS simulator runtime available to create '$name'." >&2
    exit 1
  fi
  echo "Creating simulator '$name' ($device_type @ $runtime)..." >&2
  xcrun simctl create "$name" "$device_type" "$runtime"
}

ensure_sim() {
  local name="$1"
  local device_type="${2:-}"
  local udid=""
  if udid="$(find_sim_udid "$name")"; then
    :
  elif [[ -n "$device_type" ]]; then
    udid="$(create_sim "$name" "$device_type")"
  else
    echo "Simulator '$name' not found and no device type to create." >&2
    exit 1
  fi
  xcrun simctl boot "$udid" 2>/dev/null || true
  echo "$udid"
}

shutdown_unused_sims() {
  local keep=("$@")
  python3 - "$REPORT_DIR/conductor/shutdown_sims.log" "${keep[@]}" <<'PY'
import subprocess, sys
log_path = sys.argv[1]
keep = set(sys.argv[2:])
out = subprocess.check_output(["xcrun", "simctl", "list", "devices", "booted"], text=True)
import re
booted=[]
for line in out.splitlines():
    m=re.search(r"\(([A-F0-9-]{36})\)\s+\(Booted\)", line)
    if m: booted.append(m.group(1))
with open(log_path, "a") as log:
    for udid in booted:
        if udid in keep:
            continue
        log.write(f"shutdown {udid}\n")
        subprocess.run(["xcrun", "simctl", "shutdown", udid], check=False,
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
PY
}

IPAD_UDID=""
SE_UDID=""
IPHONE17_UDID=""
PROMAX_UDID=""

# SE: prefer a dedicated SE-test, else stock SE names, else create SE 3rd gen.
if udid="$(find_sim_udid 'SE-test' 'iPhone SE (3rd generation)' 'iPhone SE')"; then
  SE_UDID="$udid"
  xcrun simctl boot "$SE_UDID" 2>/dev/null || true
else
  SE_UDID="$(ensure_sim 'iPhone SE (3rd generation)' 'com.apple.CoreSimulator.SimDeviceType.iPhone-SE-3rd-generation')"
fi

if [[ "$DRY" -eq 0 ]]; then
  IPAD_UDID="$(ensure_sim 'iPad (A16)' 'com.apple.CoreSimulator.SimDeviceType.iPad-A16')"
  if udid="$(find_sim_udid 'iPhone 17')"; then
    IPHONE17_UDID="$udid"
    xcrun simctl boot "$IPHONE17_UDID" 2>/dev/null || true
  else
    IPHONE17_UDID="$(ensure_sim 'iPhone 17' 'com.apple.CoreSimulator.SimDeviceType.iPhone-17')"
  fi
  PROMAX_UDID="$(ensure_sim 'iPhone 17 Pro Max' 'com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro-Max')"
fi

KEEP_SIMS=("$SE_UDID")
if [[ "$DRY" -eq 0 ]]; then
  KEEP_SIMS+=("$IPAD_UDID" "$IPHONE17_UDID" "$PROMAX_UDID")
fi
shutdown_unused_sims "${KEEP_SIMS[@]}"

echo "Sims: iPad=$IPAD_UDID SE=$SE_UDID 17=$IPHONE17_UDID ProMax=$PROMAX_UDID"

# Clean app data on each booted simulator (task 7.3).
clean_sim() {
  local udid="$1"
  [[ -z "$udid" ]] && return 0
  xcrun simctl uninstall "$udid" "$IOS_BUNDLE_ID" 2>/dev/null || true
  xcrun simctl privacy "$udid" reset all "$IOS_BUNDLE_ID" 2>/dev/null || true
}
for udid in "$SE_UDID" "$IPAD_UDID" "$IPHONE17_UDID" "$PROMAX_UDID"; do
  clean_sim "$udid"
done

# Push receipt fixtures (task 7.4) — only to booted devices we will use.
MEDIA_UDIDS=("$SE_UDID")
if [[ "$DRY" -eq 0 ]]; then
  MEDIA_UDIDS+=("$IPAD_UDID" "$IPHONE17_UDID" "$PROMAX_UDID")
fi
for udid in "${MEDIA_UDIDS[@]}"; do
  [[ -z "$udid" ]] && continue
  xcrun simctl addmedia "$udid" \
    "$ROOT/test_fixtures/receipts/hotel_receipt.jpg" \
    "$ROOT/test_fixtures/receipts/meal_receipt.jpg" \
    "$ROOT/test_fixtures/receipts/unreadable_receipt.jpg" \
    "$ROOT/test_fixtures/receipts/train_receipt.pdf" 2>/dev/null || true
done

# Android emulators (optional)
ANDROID_OK=0
if [[ "$IOS_ONLY" -eq 0 && "$DRY" -eq 0 ]]; then
  if command -v emulator >/dev/null 2>&1; then
    echo "Starting Android emulators with -vmnet-shared (may prompt for sudo)..."
    if sudo -n true 2>/dev/null || sudo -v; then
      for avd in smara_store_phone smara_kiosk_pixel; do
        if emulator -list-avds 2>/dev/null | grep -qx "$avd"; then
          emulator -avd "$avd" -vmnet-shared -no-snapshot-save \
            >"$REPORT_DIR/conductor/${avd}.log" 2>&1 &
          ANDROID_OK=1
        fi
      done
      if [[ "$ANDROID_OK" -eq 1 ]]; then
        adb wait-for-device || true
        for serial in $(adb devices | awk '/emulator/{print $1}'); do
          adb -s "$serial" push \
            "$ROOT/test_fixtures/receipts/hotel_receipt.jpg" /sdcard/Download/ 2>/dev/null || true
          adb -s "$serial" push \
            "$ROOT/test_fixtures/receipts/meal_receipt.jpg" /sdcard/Download/ 2>/dev/null || true
          adb -s "$serial" push \
            "$ROOT/test_fixtures/receipts/train_receipt.pdf" /sdcard/Download/ 2>/dev/null || true
        done
      fi
    else
      echo "sudo declined — falling back to --ios-only"
      IOS_ONLY=1
    fi
  else
    echo "No Android emulator binary; continuing iOS-only"
    IOS_ONLY=1
  fi
fi

# --- Conductor ---
CONDUCTOR_ARGS=("$REPORT_DIR/conductor")
if [[ "$DRY" -eq 1 ]]; then
  CONDUCTOR_ARGS+=(--dry)
else
  CONDUCTOR_ARGS+=(--employees "$EMPLOYEES")
fi
( cd "$ROOT/tool/company_sync" && dart run_conductor.dart "${CONDUCTOR_ARGS[@]}" ) \
  >"$REPORT_DIR/conductor/stdout.log" 2>&1 &
CONDUCTOR_PID=$!

kill_role_processes() {
  for pidfile in "$REPORT_DIR"/*/pid; do
    [[ -f "$pidfile" ]] || continue
    pid="$(cat "$pidfile" 2>/dev/null || true)"
    [[ -n "${pid:-}" ]] || continue
    # Kill flutter test and its children; never wait here (fail-fast).
    kill -TERM "$pid" 2>/dev/null || true
    pkill -TERM -P "$pid" 2>/dev/null || true
  done
  # Also sweep any leftover role runners for this report dir.
  pkill -TERM -f "COMPANY_SYNC_ARTIFACTS=$REPORT_DIR" 2>/dev/null || true
}

cleanup() {
  kill_role_processes
  kill "$CONDUCTOR_PID" 2>/dev/null || true
}
trap cleanup EXIT

# Wait for CONDUCTOR_PORT=
for _ in $(seq 1 60); do
  if grep -q '^CONDUCTOR_PORT=' "$REPORT_DIR/conductor/stdout.log" 2>/dev/null; then
    break
  fi
  sleep 0.25
done
PORT="$(grep '^CONDUCTOR_PORT=' "$REPORT_DIR/conductor/stdout.log" | tail -1 | cut -d= -f2)"
if [[ -z "${PORT:-}" ]]; then
  echo "Conductor failed to start; see $REPORT_DIR/conductor/stdout.log" >&2
  exit 1
fi
CONDUCTOR_URL="http://127.0.0.1:$PORT"
echo "Conductor at $CONDUCTOR_URL"

DEFINES=(
  --dart-define=COMPANY_SYNC_TEST=true
  --dart-define=COMPANY_SYNC_CONDUCTOR="$CONDUCTOR_URL"
  --dart-define=COMPANY_SYNC_ARTIFACTS="$REPORT_DIR"
  --dart-define=COMPANY_SYNC_EMPLOYEES="$EMPLOYEES"
)
if [[ "$DRY" -eq 1 ]]; then
  DEFINES+=(--dart-define=COMPANY_SYNC_DRY_RUN=true)
fi

launch_role() {
  local role="$1"
  local device="$2"
  echo "Launching $role on $device"
  mkdir -p "$REPORT_DIR/$role"
  flutter test integration_test/company_sync/company_sync_test.dart \
    -d "$device" \
    "${DEFINES[@]}" \
    --dart-define=COMPANY_SYNC_ROLE="$role" \
    >"$REPORT_DIR/$role/flutter.log" 2>&1 &
  echo $! >"$REPORT_DIR/$role/pid"
}

# Concurrent iOS `flutter test` builds share build/ios and last-writer-wins
# dart-defines (approver was once compiled as claimant_0). Wait until the
# role's log shows the correct compiled role name before starting the next.
wait_role_compiled() {
  local role="$1"
  local log="$REPORT_DIR/$role/flutter.log"
  local needle="company_sync role runner ($role)"
  for _ in $(seq 1 240); do
    if [[ -f "$log" ]] && grep -qF "$needle" "$log" 2>/dev/null; then
      echo "$role compiled/started"
      return 0
    fi
    # Fail fast if the process died before printing the role line.
    local pid
    pid="$(cat "$REPORT_DIR/$role/pid" 2>/dev/null || true)"
    if [[ -n "${pid:-}" ]] && ! kill -0 "$pid" 2>/dev/null; then
      echo "$role process exited before compile marker; see $log" >&2
      return 1
    fi
    sleep 1
  done
  echo "Timed out waiting for $role compile marker in $log" >&2
  return 1
}

# Build once per platform (task 7.3) — flutter test builds on first launch;
# we still warm the macos and first iOS target sequentially.
echo "Warming macOS build..."
flutter build macos --debug \
  --dart-define=COMPANY_SYNC_TEST=true \
  >"$REPORT_DIR/conductor/build_macos.log" 2>&1 || true

if [[ "$DRY" -eq 1 ]]; then
  launch_role owner macos
  wait_role_compiled owner || exit 1
  launch_role claimant_0 "$SE_UDID"
  wait_role_compiled claimant_0 || exit 1
else
  launch_role owner macos
  wait_role_compiled owner || exit 1
  launch_role approver "$IPAD_UDID"
  wait_role_compiled approver || exit 1
  # Assign claimants: prefer iOS then Android when available
  CLAIMANTS=()
  CLAIMANTS+=("$SE_UDID")
  CLAIMANTS+=("$IPHONE17_UDID")
  CLAIMANTS+=("$PROMAX_UDID")
  if [[ "$ANDROID_OK" -eq 1 ]]; then
    while IFS= read -r serial; do
      CLAIMANTS+=("$serial")
    done < <(adb devices | awk '/emulator/{print $1}')
  fi
  for ((i=0; i<EMPLOYEES; i++)); do
    dev="${CLAIMANTS[$i]:-}"
    if [[ -z "$dev" ]]; then
      echo "No device for claimant_$i" >&2
      exit 1
    fi
    launch_role "claimant_$i" "$dev"
    wait_role_compiled "claimant_$i" || exit 1
  done
fi

# Wait for report.json with all done or failed — fail-fast kills roles.
echo "Waiting for scenario to finish..."
TIMEOUT=900
if [[ "$DRY" -eq 0 ]]; then TIMEOUT=1800; fi
DEADLINE=$((SECONDS + TIMEOUT))
FAILED_FAST=0
while (( SECONDS < DEADLINE )); do
  if [[ -f "$REPORT_DIR/conductor/report.json" ]]; then
    if python3 - <<PY
import json,sys
r=json.load(open("$REPORT_DIR/conductor/report.json"))
sys.exit(0 if r.get("failed") or r.get("stopped") else 1)
PY
    then
      FAILED_FAST=1
      break
    fi
  fi
  # Also check if all role pids exited
  alive=0
  for pidfile in "$REPORT_DIR"/*/pid; do
    [[ -f "$pidfile" ]] || continue
    pid="$(cat "$pidfile")"
    if kill -0 "$pid" 2>/dev/null; then alive=1; fi
  done
  if [[ "$alive" -eq 0 && -f "$REPORT_DIR/conductor/report.json" ]]; then
    break
  fi
  sleep 2
done

if [[ "$FAILED_FAST" -eq 1 ]]; then
  echo "Conductor reported failure/stop — killing role processes..."
  kill_role_processes
fi

# Force conductor to write final report, then reap without hanging.
kill -INT "$CONDUCTOR_PID" 2>/dev/null || true
for _ in $(seq 1 20); do
  if ! kill -0 "$CONDUCTOR_PID" 2>/dev/null; then break; fi
  sleep 0.25
done
kill -KILL "$CONDUCTOR_PID" 2>/dev/null || true
kill_role_processes
# Best-effort reap of any remaining flutter test children.
pkill -KILL -f "integration_test/company_sync/company_sync_test.dart" 2>/dev/null || true
trap - EXIT

echo "Report: $REPORT_DIR/conductor/report.json"
if [[ -f "$REPORT_DIR/conductor/report.json" ]]; then
  python3 - <<PY
import json,sys
r=json.load(open("$REPORT_DIR/conductor/report.json"))
print("done:", r.get("done"))
print("failed:", r.get("failed"))
timeline=r.get("timeline") or []
ready=[e for e in timeline if e.get("event")=="ready"]
print("ready_roles:", sorted({e.get("role") for e in ready}))
if r.get("failed"):
  sys.exit(1)
if not ready:
  print("No ready events in report", file=sys.stderr)
  sys.exit(1)
# Dry run / successful Acme: every step done, none failed.
print("OK")
PY
else
  echo "No report written" >&2
  exit 1
fi
