# /mvp — build the MVP end-to-end, then stop for human review
Read APPFACTORY_INPUTS.md and AGENTS.md first. Obey AGENTS.md golden rules
(Cubit, Result<T>+guardAsync, no codegen, get_it, context.l10n in all locales,
no secrets). Design skills inform intent only — all UI is Flutter + Material 3.

COMMIT DISCIPLINE: commit after every step below — `git add -A && git commit -m "<msg>"`
with a clear conventional message (feat(x)/refactor/feat(backend)/chore(legal)/test).
**NEVER `git push`.** The work must live in git, not just the working tree, before you
stop for review — a build that ends as one uncommitted blob is one `git checkout` from gone.

The verify loop (run it at every gate below, in this order):
`dart fix --apply` → `dart format` → `flutter analyze --fatal-warnings` → `flutter test`.
`dart fix --apply` auto-clears lints like `require_trailing_commas`; do NOT hand-fix those.

Do, in order:
0. Pre-flight: run `bash scripts/doctor.sh`. If it reports a BLOCKING toolchain issue
   (Flutter missing or older than `pubspec.yaml` requires), STOP and tell the user to
   `flutter upgrade` (or install Flutter) first — never upgrade the SDK mid-build.
1. /market → write MARKET.md (competitors, differentiation, tiered target keywords with real
   difficulty/traffic, data-driven pricing). **Fetch live data ONCE here.** Later steps READ
   MARKET.md — they must NOT re-call Appeeky/mcp-appstore (free-tier limits): MARKET.md is the
   cache.  → commit
2. /spec  → write APP_SPEC.md from the inputs **+ MARKET.md** (differentiation, positioning,
   pricing from §5, keyword targets from §4).  → commit
3. /theme → tasteful Material 3 theme from /design tokens if present, else brand keywords.
   Set the app name in `lib/core/config/app_info.dart` AND in every
   `lib/core/l10n/arb/app_*.arb` `appName` (brand name is the same across locales).  → commit
4. Build the screens in APP_SPEC with feature-builder subagents — run them IN PARALLEL,
   each in its own git worktree (Agent isolation: "worktree"). Each feature owns its
   `<x>_module.dart` and only appends to `core/di/feature_modules.dart` +
   `core/router/feature_routes.dart` (+ ARB keys), so worktrees merge cleanly. Pass APP_SPEC's
   keyword targets to each builder as NAMING guidance (natural-fit labels/copy only — no
   stuffing). After the fan-out, run ONE serial STITCH GATE on the merged result:
   `flutter gen-l10n`, then the verify loop above. Resolve any ARB key collisions here. Cap
   fan-out at ~3-4 to control cost.  → commit
5. /swap-backend supabase  (auth + main data) + in-app account deletion.  → commit
6. /wire-paywall  (entitlement "premium") — pricing read from MARKET.md §5; do NOT re-fetch
   competitor pricing.  → commit
7. In parallel (no shared code): /legal and /aso.
   - /aso REUSES MARKET.md first: the competitor table (§1), tiered keyword set with
     difficulty/traffic (§4), and pricing (§5) are already there from /market. Turn them into
     store-ready metadata + creative + localized copy; only re-fetch live data if MARKET.md is
     absent / OFFLINE / stale. Use `marketing-skills` for description voice only.  → commit
8. UI polish pass (anti-slop): run gstack `design-review` AND the `impeccable`
   skill to fix spacing, visual hierarchy, and AI-slop patterns.  → commit
9. Quality gate: run `/simplify` (reuse/efficiency cleanup), gstack `review` (code review),
   then gstack `health` as the final quality gate. Resolve blockers before finishing.  → commit
10. /ship-check → PASS/FAIL + top fixes.
Optional (user-run, real device): gstack `ios-qa` / `ios-design-review` for
live-hardware QA — mention these but do not require them to finish.
Finish only when the verify loop is clean (`dart fix` leaves nothing, analyze clean, tests
pass) AND all work is committed.
Print: how to test it on a device — `bash scripts/run.sh` (iOS simulator needs no signing) —
and a short list of what changed. DO NOT `git push` and DO NOT submit to stores.
