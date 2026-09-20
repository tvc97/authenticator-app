#!/bin/sh
# Stop hook: refuse a silent "done" when the branch has no fresh evidence.
root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
branch=$(git -C "$root" rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)
[ "$branch" = "main" ] && exit 0

issue=$(printf '%s' "$branch" | sed -n 's|^[a-z]*/\([0-9]\{1,\}\)-.*|\1|p')
[ -z "$issue" ] && exit 0

git -C "$root" diff --quiet HEAD 2>/dev/null && clean=1 || clean=0
f="$root/.ai/run/$issue/evidence.yml"
head=$(git -C "$root" rev-parse --short HEAD)

if [ ! -f "$f" ]; then
  printf 'No evidence for issue #%s. Before reporting completion run:\n  ./scripts/ai/flow verify %s\nIf you are mid-implementation, say so explicitly instead of DONE.\n' "$issue" "$issue" >&2
  exit 2
fi

c=$(awk -F': *' '/^commit:/{print $2}' "$f" | tr -d ' ')
if [ "$c" != "$head" ]; then
  printf 'Evidence for #%s is STALE (evidence=%s HEAD=%s). Re-run:\n  ./scripts/ai/flow verify %s\n' "$issue" "$c" "$head" "$issue" >&2
  exit 2
fi
[ "$clean" -eq 1 ] || printf 'Note: uncommitted changes present; evidence covers HEAD only.\n' >&2
exit 0
