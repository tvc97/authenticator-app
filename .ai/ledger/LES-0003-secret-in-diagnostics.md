---
id: LES-0003
type: lesson
title: Seeds leak through diagnostics, not through the storage layer
tags: [logging, crash-reports, analytics, secrets, security-tier]
severity: critical
occurrences: 0
status: automated
prevention: ".ai/adapter/security and .ai/adapter/run log audit"
links: [adr:001]
first_seen: 2026-09-20
last_seen: 2026-09-20
---
## Symptom
The Keychain layer is correct, yet a seed or an `otpauth://` URI appears in a log line, an
error message, a crash report breadcrumb, or an analytics payload.

## Root cause
Secrets reach diagnostics through paths nobody classifies as storage: `print` during
debugging, a struct with a synthesized `description`, an error carrying its input, or a
breadcrumb attached to a failure.

## Detection
Static scan of sources for secret-adjacent logging, plus a runtime log audit after an
actual app run.

## Resolution
Never pass secret material to anything that stringifies. Give secret-bearing types a custom
`CustomStringConvertible` that redacts.

## Prevention
`security` tier greps for it; `run` audits the live runtime log and fails hard on a match.
This is already automated — keep it that way.
