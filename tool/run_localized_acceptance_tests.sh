#!/bin/sh
# Runs the full ACCEPTANCE tier once per curated locale (see
# integration_test/acceptance/support/locale_fixtures.dart's
# kCuratedAcceptanceLocales), against a single device, in one command.
# Manual-only, like tool/run_acceptance_tests.sh itself - no CI workflow
# invokes this script (spec: "The curated multi-locale suite is never
# invoked by CI").
#
# This multiplies tool/run_acceptance_tests.sh's own runtime by the number
# of curated locales (9 as of writing) - a single English run already takes
# several hours, so a full pass here is a long-running, deliberate exercise
# (a periodic health check, or after a change likely to affect localized
# text/layout), not something to reach for after every change. Use
# tool/run_acceptance_tests.sh -l <tag> directly to spot-check one locale
# instead.
#
# Usage:
#   tool/run_localized_acceptance_tests.sh -d <device-id> [group]
#
#   -d <device-id>   Required. Same target argument as
#                    tool/run_acceptance_tests.sh; one target for the whole
#                    run (every locale runs against the same device
#                    sequentially, never in parallel).
#   [group]          Optional. Same plain-text group filter as
#                    tool/run_acceptance_tests.sh, applied to every
#                    locale's run.
#
# One locale's failure does not stop the rest (spec: "One locale's failure
# does not hide another's result") - every curated locale runs regardless,
# and a final per-locale summary is printed with a non-zero exit if any
# locale failed.
#
# Example:
#   tool/run_localized_acceptance_tests.sh -d macos

set -eu

usage() {
  echo "Usage: $0 -d <device-id> [group]" >&2
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

# Mirrors integration_test/acceptance/support/locale_fixtures.dart's
# kCuratedAcceptanceLocales exactly - keep in sync if that list changes.
curated_locale_tags="ar ur hi ja zh ko fr de as"

echo "Running the acceptance suite once per curated locale on device '$device_id':"
echo "Locales: $curated_locale_tags"
echo

overall_status=0
results=""
for tag in $curated_locale_tags; do
  echo "=== Locale: $tag ==="
  status=0
  "$repo_root/tool/run_acceptance_tests.sh" -d "$device_id" -l "$tag" $group || status=$?
  if [ "$status" -eq 0 ]; then
    results="$results\n  $tag: PASSED"
  else
    results="$results\n  $tag: FAILED"
    overall_status=1
  fi
  echo
done

echo "=== Curated multi-locale summary ==="
printf '%b\n' "$results"

if [ "$overall_status" -eq 0 ]; then
  echo "All curated locales passed."
else
  echo "One or more curated locales failed - see the summary above." >&2
fi
exit "$overall_status"
