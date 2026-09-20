#!/bin/sh
# PreToolUse guard. Exit 2 blocks the call and shows the reason to Claude.
# Deny-list, not a warn-list. An authenticator's secrets are the product.
input=$(cat)
tool=$(printf '%s' "$input" | jq -r '.tool_name // empty')
path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')
cmd=$(printf '%s' "$input"  | jq -r '.tool_input.command  // empty')

block() { printf 'BLOCKED by pre-tool-safety: %s\n' "$1" >&2; exit 2; }

case "$path" in
  *.p8|*.p12|*.mobileprovision|*.cer|*/.env|*/.env.*)
      block "credential file '$path' is never edited by an agent." ;;
  *.entitlements)
      block "entitlements are a security boundary. Requires an ADR and a human edit." ;;
  */Info.plist)
      block "Info.plist capability changes require human review (see CLAUDE.md)." ;;
esac

case "$cmd" in
  *"security add-generic-password"*|*"security import"*|*"security unlock-keychain"*|*"security delete"*)
      block "keychain mutation from an agent is not permitted." ;;
  *"git push --force"*|*"git push -f"*)
      block "force push is not permitted." ;;
  *"rm -rf /"*|*"rm -rf ~"*)
      block "destructive filesystem operation." ;;
  *"altool --upload"*|*"xcrun notarytool submit"*|*"fastlane pilot"*|*"fastlane deliver"*)
      block "publishing must go through ./.ai/adapter/publish, which enforces the human gate." ;;
  *"codesign"*"--force"*)
      block "re-signing artifacts by hand is not permitted." ;;
esac
exit 0
