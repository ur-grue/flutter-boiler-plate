# /ship-check — pre-submit gate → PASS/FAIL
Run the verify loop first: `dart fix --apply`, `dart format --set-exit-if-changed .`,
`flutter analyze --fatal-warnings` (clean), `flutter test` (green).

Then check: account deletion present; legal links open; ATT prompt iff tracking;
privacy-label/data-safety answers ready; paywall shows price + restore.

Stale-identity gate (FAIL if any hit): `grep -rn "Flutter Boilerplate" lib/` returns
nothing, and `appName` is the real app name in ALL `lib/core/l10n/arb/app_*.arb`. Also
confirm there is no leftover `example_notes/` and no uncommitted MVP work (`git status`
clean or only intended changes).

Security gate: run `/security-review` on the diff (secrets, unsafe deps, network
hardening) — complements the compliance-auditor's store-policy checks.

Then run the design-critic subagent on the latest screenshots and list the top 5 fixes.
Output PASS or FAIL.
