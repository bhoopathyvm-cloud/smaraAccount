#!/bin/sh
# Runs the ACCEPTANCE tier: integration_test/acceptance/*_test.dart, driving
# a real launched build of the app (real database, real OS keychain)
# through its GUI. Manual-only, per acceptance-test-suite design.md
# Decision 4 - no CI workflow invokes this script or any file under
# integration_test/acceptance/.
#
# Usage:
#   tool/run_acceptance_tests.sh -d <device-id> [group]
#
#   -d <device-id>   Required. The target to run against - a macOS build,
#                    a booted iOS Simulator, or a running Android
#                    emulator/device. One target per invocation - this
#                    never runs against more than one platform at a time
#                    (spec: "Target Device Is Selectable Per Run").
#   [group]          Optional. A substring matched against test file names
#                    under integration_test/acceptance/ (e.g. "core_ledger",
#                    "currency", "csv_import"). Omit to run the full suite.
#
# Examples:
#   tool/run_acceptance_tests.sh -d macos
#   tool/run_acceptance_tests.sh -d 00008030-000A5D8C3403802E csv_import
#   tool/run_acceptance_tests.sh -d emulator-5554 currency
#
# Discovering a device id (flutter devices lists every currently
# reachable target - run it after the step below for each platform):
#   macOS:            already listed as "macos" whenever this Mac can run
#                      Flutter desktop builds - no extra step needed.
#   iOS Simulator:     open -a Simulator (boots the last-used simulator,
#                      or pick one in Xcode > Open Developer Tool >
#                      Simulator), then `flutter devices`.
#   Android emulator:  start it first - via Android Studio's Device
#                      Manager, or `emulator -avd <avd-name>` - then
#                      `flutter devices`; its id looks like emulator-5554.
#
# Pre-run cleanup happens automatically: every acceptance test file's
# own setUpAll calls resetToFreshDevice() (acceptance_harness.dart)
# before anything else runs, so a prior crashed run's leftover database
# file and keychain entries never contaminate this one
# (spec: "Acceptance Runs Leave No Residual Host State").

set -eu

usage() {
  echo "Usage: $0 -d <device-id> [group]" >&2
  echo "Run '$0 --help' style comments at the top of this script for device-id discovery." >&2
}

device_id=""
while getopts "d:" opt; do
  case "$opt" in
    d) device_id="$OPTARG" ;;
    *) usage; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

if [ -z "$device_id" ]; then
  echo "Error: no device specified. Pass -d <device-id> (see 'flutter devices')." >&2
  usage
  exit 1
fi

group="${1:-}"

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
acceptance_dir="$repo_root/integration_test/acceptance"

if [ -n "$group" ]; then
  test_files=$(find "$acceptance_dir" -maxdepth 1 -name "*${group}*_test.dart" | sort)
  if [ -z "$test_files" ]; then
    echo "Error: no acceptance test file under integration_test/acceptance/ matches '*${group}*_test.dart'." >&2
    exit 1
  fi
else
  test_files=$(find "$acceptance_dir" -maxdepth 1 -name "*_test.dart" | sort)
fi

echo "Running acceptance tests on device '$device_id':"
echo "$test_files" | sed "s#^#  #"
echo

# shellcheck disable=SC2086
if flutter test $test_files -d "$device_id"; then
  status=0
else
  status=$?
fi

if [ "$status" -eq 0 ]; then
  echo "Acceptance suite passed."
else
  echo "Acceptance suite failed (exit $status)." >&2
fi
exit "$status"
