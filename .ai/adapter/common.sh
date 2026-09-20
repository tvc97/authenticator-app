#!/bin/sh
# Shared helpers for adapter verbs. Source, do not execute.
set -eu

# Resolve the repo root robustly: git first, then the script location.
ROOT=$(git rev-parse --show-toplevel 2>/dev/null || true)
if [ -z "${ROOT:-}" ] || [ ! -f "$ROOT/.ai/adapter/manifest.yml" ]; then
  ROOT=$(cd "$(dirname "$0")" && while [ "$PWD" != "/" ] && [ ! -f "$PWD/.ai/adapter/manifest.yml" ]; do cd ..; done; pwd)
fi
[ -f "$ROOT/.ai/adapter/manifest.yml" ] || { echo "BLOCKED: cannot locate .ai/adapter/manifest.yml from $PWD" >&2; exit 1; }
ADAPTER="$ROOT/.ai/adapter"
MANIFEST="$ADAPTER/manifest.yml"
RUNDIR="$ROOT/.ai/run"
LOCK="$RUNDIR/.device.lock"

mkdir -p "$RUNDIR"

# mval a.b  -> value of nested key (2 levels max), empty if absent
mval() {
  awk -v path="$1" '
    BEGIN { split(path, p, "."); depth = (length(p) > 1) ? 2 : 1 }
    /^[[:space:]]*#/ { next }
    /^[^[:space:]-]/ { top = $1; sub(/:.*/, "", top) }
    {
      line = $0
      sub(/[[:space:]]*#.*$/, "", line)
      if (line ~ /^[[:space:]]*$/) next
      key = line; sub(/:.*/, "", key); gsub(/^[[:space:]]+|[[:space:]]+$/, "", key)
      val = line
      if (index(line, ":") == 0) next
      sub(/^[^:]*:[[:space:]]*/, "", val)
      gsub(/^"|"$/, "", val)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", val)
      if (depth == 1 && key == p[1]) { print val; exit }
      if (depth == 2 && top == p[1] && key == p[2] && line ~ /^[[:space:]]+/) { print val; exit }
    }
  ' "$MANIFEST"
}

# mlist key -> items of a top-level yaml list
mlist() {
  awk -v k="$1" '
    $0 ~ "^"k":" { inlist=1; next }
    inlist && /^[[:space:]]*-[[:space:]]*/ { line=$0; sub(/^[[:space:]]*-[[:space:]]*/, "", line); gsub(/"/,"",line); print line; next }
    inlist && /^[^[:space:]]/ { inlist=0 }
  ' "$MANIFEST"
}

say()  { printf '\033[1m==>\033[0m %s\n' "$*"; }
ok()   { printf '\033[32m  PASS\033[0m %s\n' "$*"; }
warn() { printf '\033[33m  WARN\033[0m %s\n' "$*"; }
die()  { printf '\033[31mBLOCKED\033[0m\nReason:\n  %s\n' "$*" >&2; exit 1; }

require_project() {
  if [ "$(mval project.status)" != "ready" ]; then
    die "manifest project.status is 'pending-discovery'.
  This repository has no Xcode project yet, or it was never recorded.
  Fix: create the app target, then run ./.ai/adapter/setup
  Do NOT guess the scheme or bundle id."
  fi
}

# Serialize everything that touches the simulator, a device, or DerivedData.
with_device_lock() {
  tries=0
  while ! mkdir "$LOCK" 2>/dev/null; do
    tries=$((tries + 1))
    [ "$tries" -gt 60 ] && die "device busy: $LOCK held for over 5 minutes.
  Another issue is building or running. Wait, or remove the lock if stale."
    sleep 5
  done
  trap 'rmdir "$LOCK" 2>/dev/null || true' EXIT INT TERM
  "$@"
}

destination() {
  printf 'platform=iOS Simulator,name=%s,OS=%s' \
    "$(mval simulator.name)" "$(mval simulator.runtime | sed 's/^iOS //')"
}

xcb() {
  if command -v xcbeautify >/dev/null 2>&1; then
    set -o pipefail
    xcodebuild "$@" | xcbeautify
  else
    xcodebuild "$@"
  fi
}

proj_flag() {
  kind=$(mval project.kind)
  case "$kind" in
    xcworkspace) printf -- '-workspace %s' "$(mval project.path)" ;;
    swiftpm)     printf '' ;;
    *)           printf -- '-project %s' "$(mval project.path)" ;;
  esac
}
