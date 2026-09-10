#!/bin/sh
# Runs the ACCEPTANCE tier: integration_test/acceptance/acceptance_test.dart,
# driving a real launched build of the app (real database, real OS keychain)
# through its GUI. Manual-only, per acceptance-test-suite design.md
# Decision 4 - no CI workflow invokes this script or any file under
# integration_test/acceptance/.
#
# One file, one `flutter test` invocation, one install: the suite used to
# be 13 separate files, each its own `flutter test <file> -d <device>`
# invocation - meaning 13 full app rebuild+reinstall+relaunch cycles per
# full run. Every former file is now a `group('name', () { ... })` inside
# a single shared `main()` (app-store-launch-readiness), so a full run
# needs only one install. This especially matters on a real iOS device,
# where Xcode's own automation-driven launch step is intermittently flaky
# - one launch attempt per full run instead of 13 means one chance to hit
# that flakiness instead of thirteen.
#
# Usage:
#   tool/run_acceptance_tests.sh -d <device-id> [-l <locale-tag>] [group]
#
#   -d <device-id>   Required. The target to run against - a macOS build,
#                    a booted iOS Simulator, or a running Android
#                    emulator/device. One target per invocation - this
#                    never runs against more than one platform at a time
#                    (spec: "Target Device Is Selectable Per Run").
#   -l <locale-tag>  Optional. Drives onboarding's language screen to this
#                    locale instead of "Same as device", and resolves every
#                    UI-text assertion and typed-in fixture string against
#                    it for the rest of the run (acceptance-tests-multi-
#                    locale spec: "Locale Is Selectable Per Run"). Must be
#                    one of the tags in lib/l10n/supported_locales.dart's
#                    kSupportedLocaleTags. Defaults to "en", reproducing
#                    this script's original, single-locale behavior exactly
#                    when omitted. Only the curated locale set (see
#                    integration_test/acceptance/support/locale_fixtures.dart)
#                    has translated fixture strings; any other supported tag
#                    still runs, just with English fixture text alongside
#                    that locale's own app chrome.
#   [group]          Optional. A plain-text substring matched against
#                    `group()`/`testWidgets()` names in
#                    acceptance_test.dart (e.g. "core_ledger", "currency",
#                    "csv_import" - the former per-file names, now group
#                    names) via `flutter test --plain-name`. Omit to run
#                    every group.
#
# Examples:
#   tool/run_acceptance_tests.sh -d macos
#   tool/run_acceptance_tests.sh -d 00008030-000A5D8C3403802E csv_import
#   tool/run_acceptance_tests.sh -d emulator-5554 currency
#   tool/run_acceptance_tests.sh -d macos -l ja
#   tool/run_acceptance_tests.sh -d macos -l ar onboarding
#
# To run the full suite once per curated locale in one command, see
# tool/run_localized_acceptance_tests.sh instead.
#
# Discovering a device id (flutter devices lists every currently
# reachable target - run it after the step below for each platform):
#   macOS:            already listed as "macos" whenever this Mac can run
#                      Flutter desktop builds - no extra step needed.
#   iOS Simulator:     open -a Simulator (boots the last-used simulator,
#                      or pick one in Xcode > Open Developer Tool >
#                      Simulator), then `flutter devices`.
#   iOS real device:   must be connected by USB cable, not just wireless -
#                      `flutter test` cannot launch a debug session on a
#                      wirelessly-tethered iOS device ("Cannot start app
#                      on wirelessly tethered iOS device").
#   Android emulator:  start it first - via Android Studio's Device
#                      Manager, or `emulator -avd <avd-name>` - then
#                      `flutter devices`; its id looks like emulator-5554.
#
# Pre-run cleanup happens automatically: every group's own setUpAll calls
# resetToFreshDevice() (acceptance_harness.dart) before its tests run, so
# a prior crashed run's leftover database file and keychain entries never
# contaminate this one (spec: "Acceptance Runs Leave No Residual Host
# State").

set -eu

usage() {
  echo "Usage: $0 -d <device-id> [-l <locale-tag>] [group]" >&2
  echo "Run '$0 --help' style comments at the top of this script for device-id discovery and locale tags." >&2
}

# Mirrors lib/l10n/supported_locales.dart's kSupportedLocaleTags exactly -
# duplicated here so an unsupported tag fails fast, before launching
# anything, rather than only once the app throws deep inside a run (spec:
# "An unsupported locale tag is rejected"). Keep in sync if that list
# changes.
supported_locale_tags="en ta te ml kn hi ur pa ne sa doi ks mai mr gu kok sd bn as or mni brx sat de fr es it pt hu ro ja zh ko ar ru id tr vi th ms uk pl nl"

device_id=""
locale_tag="en"
while getopts "d:l:" opt; do
  case "$opt" in
    d) device_id="$OPTARG" ;;
    l) locale_tag="$OPTARG" ;;
    *) usage; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

if [ -z "$device_id" ]; then
  echo "Error: no device specified. Pass -d <device-id> (see 'flutter devices')." >&2
  usage
  exit 1
fi

is_supported=0
for tag in $supported_locale_tags; do
  if [ "$tag" = "$locale_tag" ]; then
    is_supported=1
    break
  fi
done
if [ "$is_supported" -ne 1 ]; then
  echo "Error: unsupported locale tag '$locale_tag'. Must be one of: $supported_locale_tags" >&2
  usage
  exit 1
fi

group="${1:-}"

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
test_file="$repo_root/integration_test/acceptance/acceptance_test.dart"

if [ -n "$group" ]; then
  echo "Running acceptance tests on device '$device_id' (locale: '$locale_tag', group: '$group'):"
else
  echo "Running acceptance tests on device '$device_id' (locale: '$locale_tag'):"
fi
echo

status=0
if [ -n "$group" ]; then
  flutter test "$test_file" -d "$device_id" --dart-define=ACCEPTANCE_LOCALE="$locale_tag" --plain-name "$group" || status=$?
else
  flutter test "$test_file" -d "$device_id" --dart-define=ACCEPTANCE_LOCALE="$locale_tag" || status=$?
fi

if [ "$status" -eq 0 ]; then
  echo "Acceptance suite passed."
else
  echo "Acceptance suite failed." >&2
fi
exit "$status"
