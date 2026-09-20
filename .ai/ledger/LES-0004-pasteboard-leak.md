---
id: LES-0004
type: lesson
title: Copied codes persist and can sync to other devices
tags: [pasteboard, handoff, ui, secrets]
severity: medium
occurrences: 0
status: recorded
prevention: ".ai/adapter/security pasteboard check"
links: [adr:001]
first_seen: 2026-09-20
last_seen: 2026-09-20
---
## Symptom
A copied code remains on the pasteboard long after its 30-second validity, and may appear
on other Apple devices through Universal Clipboard.

## Root cause
`UIPasteboard.general.string = code` with no `expirationDate` and no local-only flag.

## Detection
Static check for `UIPasteboard` use without `expirationDate`; manual check that the entry
is gone after expiry.

## Resolution
Use `setItems(_:options:)` with `.expirationDate` set to the code's remaining validity, and
`.localOnly` true.

## Prevention
Covered by the `security` tier. Scenario S4 confirms expiry behaviour by hand.
