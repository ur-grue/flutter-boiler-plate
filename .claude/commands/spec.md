# /spec — single source of truth
From APPFACTORY_INPUTS.md **and MARKET.md** (ask at most 3 follow-ups), write APP_SPEC.md.
MARKET.md (written by /market) is the research input — read it and pull through:
- **Differentiation + positioning** ← MARKET §2/§3.
- **Pricing** ← MARKET §5 (real comps). Do NOT hardcode generic numbers — use §5's data-driven
  monthly/yearly(-50%)/lifetime + trial; if MARKET.md is OFFLINE/absent, fall back to the generic
  monthly/yearly -50%/lifetime template and note it.
- **Keyword targets** ← MARKET §4 (tiered head/mid/long-tail, with difficulty/traffic).

Use the **aso-skills** strategy skills to REFINE that research (method, not re-fetch):
`app-marketing-context`, `category-positioning`, `monetization-strategy`,
`onboarding-optimization` + `retention-optimization` (shape onboarding + core loop).

Write: problem (vetted format), niche, core loop (trigger→input→processing→output), screen list,
monetization (from MARKET §5; trial, paywall after onboarding, entitlement "premium"),
a `## Keyword targets` section (the §4 tiers), and a `## Naming candidates` section (app name +
subtitle ideas that naturally contain head/mid terms only where they fit the real product).
Guardrail: keywords INFORM names/copy where they describe the real feature — never invent a
feature to chase a keyword, never stuff. Differentiation (§2) beats keyword density (Apple 4.3).
If it's an AI app, also output the edge-function system prompt + strict JSON schema
(runs server-side, never in the client). Follow AGENTS.md.
