# Release Checklist

```
[ ] All milestone issues closed; no open blocking issue
[ ] On main, clean tree, up to date with origin
[ ] Version + build number incremented and correct
[ ] CHANGELOG updated
[ ] static / unit / integration / security all PASS on the release commit
[ ] S1 S2 S3 S4 from docs/testing/security-matrix.md executed ON A PHYSICAL DEVICE
[ ] Device model + iOS version recorded in the release report
[ ] Runtime log audit clean (no otpauth://, no base32, no sharedSecret)
[ ] Signing identity + profile match manifest project.team_id
[ ] Archive validates
[ ] Artifacts preserved under build/<version>/
[ ] Release report written and ends with READY FOR HUMAN APPROVAL
[ ] Label gate:release-approved applied by a human
```

Publishing runs only through `./.ai/adapter/publish <version>`, which re-checks the gate
and requires the version typed at the prompt.

## Rollback

1. Expire the TestFlight build / remove from sale.
2. Open a `fix/` issue against the same milestone.
3. Write a postmortem in `.ai/ledger/` answering: **why did the system let this ship?**
