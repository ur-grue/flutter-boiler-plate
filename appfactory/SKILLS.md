# SKILLS — External Skill Manifest (single source of truth)

This file is the **contract** for what "a fresh clone has everything after `./setup.zsh`"
means. It lists every external skill/plugin the App Factory relies on, where it comes
from (pinned), how it installs, whether it needs a key, what it does, and which
command/agent consumes it.

`setup.zsh` (Phase 3) installs + verifies all of these; `scripts/doctor.sh` re-checks them.

---

## Trust posture

**Pinned + keyless by default.** Every skill below installs without an API key and runs
on general frameworks out of the box. The only optional key is **Appeeky** (used by
`aso-skills` for live App Store data) — it is **AUTHOR-TIME ONLY** and is **never shipped
in the app** and never goes into `dart_define`.

---

## Skills

### superpowers
- **Source:** `obra/superpowers-marketplace` (Claude plugin / marketplace) — pin to the
  marketplace ref recorded at install time.
- **Install:** `claude plugin marketplace add obra/superpowers-marketplace` then
  `claude plugin install superpowers@superpowers-marketplace --scope project`
- **Keyless?** Yes — no key, no optional key.
- **Purpose:** TDD discipline + subagent infrastructure.
- **Consumed by:** used across **/mvp**.

### marketing-skills
- **Source:** `coreyhaines31/marketingskills` (Claude plugin / marketplace) — pin to the
  marketplace ref recorded at install time.
- **Install:** `claude plugin marketplace add coreyhaines31/marketingskills` then
  `claude plugin install marketing-skills@marketingskills --scope project`
- **Keyless?** Yes.
- **Purpose:** brand voice, launch & growth copy.
- **Consumed by:** feeds **/aso** (positioning / copy).

### ui-ux-pro-max
- **Source:** `nextlevelbuilder/ui-ux-pro-max-skill` (Claude plugin / marketplace; MIT) —
  pin to the marketplace ref recorded at install time.
- **Install:** `claude plugin marketplace add nextlevelbuilder/ui-ux-pro-max-skill` then
  `claude plugin install ui-ux-pro-max@ui-ux-pro-max-skill --scope project`
- **Keyless?** Yes — no API key.
- **Purpose:** UI/UX design intelligence — generates a design SYSTEM (style, palette,
  typography, UX rules) for the product category.
- **Consumed by:** **/theme** (design intent). ⚠ Defaults to web (HTML/Tailwind) — use its
  palette/typography/UX *intent* only; map to Flutter Material 3, ignore any web code.

### gstack
- **Source:** `garrytan/gstack` (git clone + `./setup` into `~/.claude/skills/gstack`) —
  pin to the cloned commit recorded at install time.
- **Install:** `git clone --depth 1 https://github.com/garrytan/gstack.git
  ~/.claude/skills/gstack && (cd ~/.claude/skills/gstack && ./setup)`
- **Keyless?** Yes.
- **Purpose:** QA / review / design-review / health / ios-qa and related quality skills.
- **Consumed by:** **/mvp** polish + quality gate.

### impeccable
- **Source:** `pbakaus/impeccable` (`skills` CLI) — pin via the version recorded at
  install time.
- **Install:** `npx -y skills add pbakaus/impeccable --agent claude-code`
- **Keyless?** Yes.
- **Purpose:** design polish / anti-slop pass.
- **Consumed by:** **/mvp** polish pass.

### mcp-appstore  (the KEYLESS LIVE-DATA engine)
- **Source:** `appreply-co/mcp-appstore` (MCP server; Node) — pin the cloned commit.
- **Install:** `git clone --depth 1 https://github.com/appreply-co/mcp-appstore.git
  ~/.appfactory/mcp-appstore && npm install --prefix ~/.appfactory/mcp-appstore`, then
  `claude mcp add --scope user --transport stdio mcp-appstore -- node ~/.appfactory/mcp-appstore/server.js`.
  (No npx one-liner exists; needs Node 18+.)
- **Keyless?** Yes — scrapes the public App Store + Play Store; no key, no paid account.
- **Purpose:** the **live data source**. 17 tools incl. `get_keyword_scores` (real difficulty +
  traffic), `analyze_top_keywords`, `suggest_keywords_by_competition/_by_search/_by_similarity`,
  `search_app`, `get_similar_apps`, `get_pricing_details`, `analyze_reviews` — iOS + Android.
- **Consumed by:** **/aso** + **/validate** (real keyword + competitor data).

### aso-skills  (ASO METHOD / ROUTING)
- **Source:** `eronred/aso-skills` (`skills` CLI; MIT) — pin via the version recorded at
  install time (see "Pinning" below).
- **Install:** `npx -y skills add eronred/aso-skills --agent claude-code`
- **Keyless?** Yes, but keyless = **methodology only**. Its live-data mode needs a paid
  **Appeeky** key (`APPEEKY_API_KEY`, https://appeeky.com); **without it the skill falls back to
  the model's own knowledge** — which is why we pair it with `mcp-appstore` for real data.
  Appeeky is author-time only; never shipped.
- **Purpose:** ASO frameworks + routing — ~40 skills incl. `aso-router`, `keyword-research`,
  `metadata-optimization`, `competitor-analysis`, `aso-audit`, `monetization-strategy`,
  `paywall-optimization`, `screenshot-optimization`, `app-icon-optimization`,
  `app-analytics`, `category-positioning`, `app-rejection-recovery`.
- **Consumed by:** **/aso** (interprets mcp-appstore data), **/validate** + **/spec** (market
  intel), **/wire-paywall** (monetization).

---

## Division of labor

- **mcp-appstore** owns **live data** — real keyword difficulty/traffic, competitor listings,
  pricing, reviews. This is where every keyword number must come from.
- **aso-skills** owns ASO **method / routing** — how to interpret the data into keyword
  strategy, metadata, audits, monetization mechanics (keyless = method only, no live data).
- **marketing-skills** owns **brand voice / launch copy** — positioning and growth copy.

Keep these lanes separate: pull data with `mcp-appstore`, interpret it with `aso-skills`,
write voice/launch copy with `marketing-skills`. Never source keyword numbers from model memory.

**Design lane (decide → refine → QA):** `ui-ux-pro-max` *decides* the design system up
front (/theme); `impeccable` *refines* the built UI (polish / anti-slop); gstack
`design-review` + the `design-critic` agent *QA* the result. Don't blur these.

---

## Pinning

The `skills` CLI may not accept a git ref on `add`, so we do not hard-pin in the install
command. Instead: **pin via this manifest** — record the resolved version of each skill
here (or in `appfactory/.skills.lock` if/when added) after a successful install. Keep it
simple; do not over-engineer the lock mechanism.

---

setup.zsh installs + verifies all of these; doctor.sh re-checks; this file is the contract
for "a fresh clone has everything after ./setup.zsh."
