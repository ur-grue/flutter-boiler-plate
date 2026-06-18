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

### aso-skills  (the ASO DATA ENGINE)
- **Source:** `eronred/aso-skills` (`skills` CLI; MIT) — pin via the version recorded at
  install time (see "Pinning" below).
- **Install:** `npx -y skills add eronred/aso-skills --agent claude-code`
- **Keyless?** Yes by default (general ASO frameworks). **Optional key:** `APPEEKY_API_KEY`
  (https://appeeky.com) unlocks live App Store data. Author-time only; never shipped.
- **Purpose:** the ASO data engine — ~40 skills including `aso-router`, `keyword-research`,
  `metadata-optimization`, `competitor-analysis`, `aso-audit`, `monetization-strategy`,
  `paywall-optimization`, `screenshot-optimization`, `app-icon-optimization`,
  `app-analytics`, `category-positioning`, `app-rejection-recovery`.
- **Consumed by:** **/aso** (engine), **/validate** + **/spec** (market intel),
  **/wire-paywall** (monetization).

---

## Division of labor

- **aso-skills** owns ASO **mechanics / data + routing** — keyword research, metadata,
  competitor and market intel, monetization/paywall mechanics, audits.
- **marketing-skills** owns **brand voice / launch copy** — positioning and growth copy.

Keep these lanes separate to avoid overlap: route ASO mechanics through `aso-skills`,
route voice/launch copy through `marketing-skills`.

---

## Pinning

The `skills` CLI may not accept a git ref on `add`, so we do not hard-pin in the install
command. Instead: **pin via this manifest** — record the resolved version of each skill
here (or in `appfactory/.skills.lock` if/when added) after a successful install. Keep it
simple; do not over-engineer the lock mechanism.

---

setup.zsh installs + verifies all of these; doctor.sh re-checks; this file is the contract
for "a fresh clone has everything after ./setup.zsh."
