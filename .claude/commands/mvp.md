# /mvp — build the MVP end-to-end, then stop for human review
Read APPFACTORY_INPUTS.md and AGENTS.md first. Obey AGENTS.md golden rules
(Cubit, Result<T>+guardAsync, no codegen, get_it, context.l10n in all locales,
no secrets). Design skills inform intent only — all UI is Flutter + Material 3.

Do, in order:
1. /spec  → write APP_SPEC.md from the inputs.
2. /theme → tasteful Material 3 theme from /design tokens if present, else brand keywords.
3. Build each screen in APP_SPEC with the feature-builder subagent, ONE AT A TIME
   (shared files injector.dart + router are edited serially, never in parallel):
   onboarding, home/input, output/detail, settings.
4. /swap-backend supabase  (auth + main data) + in-app account deletion.
5. /wire-paywall  (entitlement "premium").
6. In parallel (no shared code): /legal and /aso.
   - Strengthen /aso with the `marketing-skills` plugin (coreyhaines31/marketingskills):
     store keywords, description copy, and positioning.
7. UI polish pass (anti-slop): run gstack `design-review` AND the `impeccable`
   skill to fix spacing, visual hierarchy, and AI-slop patterns before ship-check.
8. Quality gate: run gstack `review` for a code-review pass, then gstack `health`
   as the final quality gate. Resolve blockers before finishing.
9. /ship-check → PASS/FAIL + top fixes.
Optional (user-run, real device): gstack `ios-qa` / `ios-design-review` for
live-hardware QA — mention these but do not require them to finish.
Finish only when `flutter analyze` is clean and `flutter test` passes.
Print: how to run the app, and a short list of what you changed. DO NOT submit to stores.
