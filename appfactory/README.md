# App Factory Kit

Drop these into your boilerplate's template repo. Then per new app:

```
gh repo create my-app --template ur-grue/flutter-boiler-plate --private --clone
cd my-app
~/path/to/new-app.sh          # answer 4 questions → Claude builds the MVP
flutter run --dart-define-from-file=dart_define.dev.json   # test
./ship.sh                     # after you approve → build + store checklist
```

## One-time setup (never repeated)
1. `./new-app.sh` once → it creates `~/.appfactory/secrets.env`. Fill in your keys there ONCE.
2. Re-run `./new-app.sh`. First run also installs the skills (ASO + ceorkm + impeccable) globally.

## What's in here
- `new-app.sh` — interview → scaffold → headless Claude build (`/mvp`) → stop for your test.
- `ship.sh` — after approval: `/release` (resumes the same session).
- `.claude/commands/` — the steps as `/`-commands (`/mvp` orchestrates the rest).
- `.claude/agents/` — feature-builder, design-critic, compliance-auditor (subagents).
- `appfactory/secrets.env.example` — central key store (copied to `~/.appfactory/`).

## Orchestration (how /mvp works)
`/mvp` runs: spec → theme → build screens (feature-builder, **serial** — they share
injector.dart + router) → swap-backend → wire-paywall → **legal + aso in parallel**
→ ship-check. Stops with a change summary. You test, then `./ship.sh`.

## Add the CLAUDE.md rule (once, in the template)
> Design skills inform intent and critique only. All UI is Flutter + Material 3 per
> AGENTS.md. Ignore web/CSS advice (hover, HTML, gradients); use the boilerplate theme.

## Notes
- Entitlement is **premium**. State management is **Cubit**. Both already match the boilerplate.
- Secrets live in `~/.appfactory/secrets.env` only; the script templates the client-safe
  ones into `dart_define.dev.json`. LLM key stays server-side (Supabase edge function).
- Friction knob: `new-app.sh` uses `--permission-mode acceptEdits`. For fully unattended
  runs swap to `--dangerously-skip-permissions` (only in a sandbox you trust).
