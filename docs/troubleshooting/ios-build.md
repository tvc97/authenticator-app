# Troubleshooting — iOS build

Read the **first** meaningful error, not the last line. Classify before changing anything:

```
source | dependency | Xcode configuration | signing | environment
```

Then fix only that cause. Do not edit `project.pbxproj` or signing settings to make an
error disappear.

| Symptom | Likely cause | Action |
|---|---|---|
| `scheme not found` | manifest drifted from the project | `./.ai/adapter/setup` |
| `device busy` from an adapter verb | another worktree holds the lock | wait, or remove `.ai/run/.device.lock` if stale |
| Simulator not found | runtime removed by an Xcode update | `xcrun simctl list devices available`, update manifest |
| Keychain test fails on simulator only | simulator Keychain is not a real Keychain | move the assertion to a device scenario |
| Concurrency errors after a Swift update | strict concurrency tightened | fix the isolation; do not add `@unchecked Sendable` |
| Warnings-as-errors failure in `static` | new compiler diagnostic | fix it; do not lower the setting |

Record anything that happens twice in `.ai/ledger/` and increment `occurrences`.
