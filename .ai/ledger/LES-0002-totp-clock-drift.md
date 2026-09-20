---
id: LES-0002
type: lesson
title: TOTP correctness depends on a clock the app does not control
tags: [totp, time, drift, verification, hotp]
severity: high
occurrences: 0
status: recorded
prevention: "docs/testing/security-matrix.md S3"
links: [adr:001]
first_seen: 2026-09-20
last_seen: 2026-09-20
---
## Symptom
Codes are rejected by the service although the app shows them as valid. Reproduces only on
devices with automatic time disabled, or after timezone/DST transitions, or after long
background suspension.

## Root cause
The generator trusts the device clock. TOTP is a function of time; an unvalidated clock is
an unvalidated input.

## Detection
Only by running with a deliberately skewed clock. No static check finds this.

## Resolution
Treat the clock as untrusted input: keep a measured offset, surface drift in the UI, and
say "this code may be rejected" rather than showing a confident wrong code.

## Prevention
Clock-skew scenarios (+30s, +90s, −90s) are required verification for any change to
generation, counters or drift handling.
