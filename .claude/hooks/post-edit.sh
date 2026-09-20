#!/bin/sh
# PostToolUse: format the file that was just edited. Fast only — no builds here.
input=$(cat)
path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')
case "$path" in
  *.swift) [ -f "$path" ] && xcrun swift-format format -i "$path" 2>/dev/null || true ;;
esac
exit 0
