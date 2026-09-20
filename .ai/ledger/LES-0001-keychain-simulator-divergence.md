---
id: LES-0001
type: lesson
title: Simulator Keychain does not enforce real accessibility or Secure Enclave semantics
tags: [keychain, secure-enclave, biometrics, simulator, verification]
severity: high
occurrences: 0
status: recorded
prevention: "docs/testing/security-matrix.md S2 (device-required)"
links: [adr:001]
first_seen: 2026-09-20
last_seen: 2026-09-20
---
## Symptom
Keychain tests pass on the simulator; items behave differently on a real device —
accessibility classes, `kSecAccessControl` biometric constraints and Secure Enclave-backed
keys are not faithfully enforced by the simulator.

## Root cause
The simulator's Keychain is a host-side stand-in. It does not model device lock state,
passcode removal, or enclave attestation.

## Detection
A green `unit` and `integration` tier that includes any assertion about accessibility,
biometric constraint, or enclave-backed key material.

## Resolution
Move every such assertion into a device scenario. Keep the simulator for generation math
and UI only.

## Prevention
`manifest.yml: device_required_for` lists `keychain-accessibility`, `secure-enclave` and
`biometrics`. Any issue touching those must record `runtime.target: device`.
