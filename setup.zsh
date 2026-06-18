#!/usr/bin/env zsh
# ──────────────────────────────────────────────────────────────────────────────
# setup.zsh — APP FACTORY // one-script cyberpunk bootstrap
#
#   git clone <your-app> && cd <your-app> && ./setup.zsh
#
# Does everything, in order:
#   0. Prereqs + auto-install (Homebrew): gum · Flutter · Claude CLI
#   1. Central secrets  (~/.appfactory/secrets.env — entered ONCE)
#   2. Claude Code config (.claude/settings*.json, docs/clean-code.md) — never
#      clobbers this repo's Flutter CLAUDE.md / AGENTS.md
#   3. Claude skills (superpowers · marketing-skills · ui-ux-pro-max · gstack · impeccable · aso-skills · mcp-appstore)
#   4. Interview (app name · bundle id · idea · category)
#   5. Scaffold (flutter create → rename → postcreate → dart_define → pub get)
#   6. AI MVP build  (claude -p /mvp)
#   7. SYSTEM ONLINE
#
# Options:
#   --no-build        scaffold + configure, but skip the AI /mvp build
#   --no-plugins      skip Claude plugin install
#   --force           overwrite existing .claude config files (default: skip)
#   --reinstall       re-run plugin install even if already marked done
#   -h | --help       this screen
#
# Requires: macOS + zsh. Auto-installs gum/Flutter/Claude via Homebrew (asks first).
# ──────────────────────────────────────────────────────────────────────────────
set -euo pipefail

CFG_DIR="$HOME/.appfactory"
SECRETS="$CFG_DIR/secrets.env"
PLUGINS_MARK="$CFG_DIR/.plugins_installed"
KIT_DIR="${0:A:h}"

# ── args ───────────────────────────────────────────────────────────────────────
DO_BUILD=1; DO_PLUGINS=1; FORCE=0; REINSTALL=0; HELP=0
while (( $# )); do
  case "$1" in
    --no-build)   DO_BUILD=0 ;;
    --no-plugins) DO_PLUGINS=0 ;;
    --force)      FORCE=1 ;;
    --reinstall)  REINSTALL=1 ;;
    -h|--help)    HELP=1 ;;
    *)            echo "unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

# ──────────────────────────────────────────────────────────────────────────────
# PHASE 0a — pre-gum bootstrap (plain text; gum doesn't exist yet)
# ──────────────────────────────────────────────────────────────────────────────
plain_die() { print -P "%F{red}✗ $1%f"; exit 1; }

[[ "$(uname -s)" == "Darwin" ]] || plain_die \
  "This script targets macOS (zsh + Homebrew). On other platforms, install Flutter + Claude manually, then run new-app.sh."

ensure_brew() {
  command -v brew >/dev/null 2>&1 && return 0
  print -P "%F{yellow}▸ Homebrew is required and not installed.%f"
  print -P "  It powers the auto-install of gum, Flutter, and the Claude CLI."
  printf "  Install Homebrew now? [y/N] "
  read -r reply
  if [[ "$reply" == [yY]* ]]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Make brew available on Apple Silicon + Intel for the rest of this run.
    [[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
    [[ -x /usr/local/bin/brew ]]   && eval "$(/usr/local/bin/brew shellenv)"
    command -v brew >/dev/null 2>&1 || plain_die "Homebrew install did not complete — see https://brew.sh"
  else
    plain_die "Install Homebrew (https://brew.sh) then re-run ./setup.zsh"
  fi
}

ensure_gum() {
  command -v gum >/dev/null 2>&1 && return 0
  print -P "%F{cyan}▸ Installing gum (the cyberpunk UI)…%f"
  brew install gum || plain_die "Could not install gum — run: brew install gum"
}

ensure_brew
ensure_gum

# ──────────────────────────────────────────────────────────────────────────────
# From here on the gum UI is live.
# ──────────────────────────────────────────────────────────────────────────────
PINK="212"; CYAN="51"; GREEN="82"; AMBER="214"; PURP="99"; GREY="245"

ok()    { gum log --level info  "$1"; }
warn()  { gum log --level warn  "$1"; }
err()   { gum log --level error "$1"; }
info()  { gum log --level debug "$1"; }
wrote() { gum log --level info  "wrote: $1"; }
die()   { gum log --level error "$1"; exit 1; }

section() {
  echo
  gum style --foreground "$PURP" --bold \
    --border-foreground "$PURP" --border normal --padding "0 1" \
    "[ $1 ]  $2"
}

confirm() { gum confirm "$1"; }   # returns nonzero on "no"

safe_write() {
  local dest="$1"
  if [[ -e "$dest" && $FORCE -eq 0 ]]; then
    warn "skip (exists): $dest  — use --force to overwrite"
    cat > /dev/null
    return 0
  fi
  mkdir -p "${dest:h}"
  cat > "$dest"
  wrote "$dest"
}

usage() {
  gum style --foreground "$PINK" --border-foreground "$PURP" \
    --border double --align center --width 56 --padding "1 3" \
    "APP FACTORY  //  setup" "clone → one script → tested MVP"
  echo
  gum style --foreground "$CYAN" --bold "USAGE"
  gum style --foreground "$GREY"  "  ./setup.zsh [options]"
  echo
  gum style --foreground "$CYAN" --bold "OPTIONS"
  gum style --foreground "$GREY" \
    "  --no-build     scaffold + configure, skip the AI /mvp build" \
    "  --no-plugins   skip Claude plugin install" \
    "  --force        overwrite existing .claude config files" \
    "  --reinstall    re-run plugin install" \
    "  -h --help      this screen"
  echo
  exit 0
}
(( HELP )) && usage

# ── banner ──────────────────────────────────────────────────────────────────────
echo
gum style --foreground "$PINK" \
  ' █████╗ ██████╗ ██████╗     ███████╗ █████╗  ██████╗████████╗ ██████╗ ██████╗ ██╗   ██╗' \
  '██╔══██╗██╔══██╗██╔══██╗    ██╔════╝██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗╚██╗ ██╔╝' \
  '███████║██████╔╝██████╔╝    █████╗  ███████║██║        ██║   ██║   ██║██████╔╝ ╚████╔╝ ' \
  '██╔══██║██╔═══╝ ██╔═══╝     ██╔══╝  ██╔══██║██║        ██║   ██║   ██║██╔══██╗  ╚██╔╝  ' \
  '██║  ██║██║     ██║         ██║     ██║  ██║╚██████╗   ██║   ╚██████╔╝██║  ██║   ██║   ' \
  '╚═╝  ╚═╝╚═╝     ╚═╝         ╚═╝     ╚═╝  ╚═╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝   ╚═╝   '
gum style --foreground "$CYAN" --bold \
  --border-foreground "$PURP" --border normal --align center --width 86 --padding "0 2" \
  "V I B E - D E C K  //  idea → tested MVP, one script" \
  "project: ${KIT_DIR:t}"
echo

# ──────────────────────────────────────────────────────────────────────────────
# PHASE 0b — toolchain (Flutter locator + auto-install; Claude CLI)
# ──────────────────────────────────────────────────────────────────────────────
section "00" "PROVISIONING TOOLCHAIN"

# Probe common SDK locations for a present-but-unexported Flutter, add to PATH.
locate_flutter() {
  command -v flutter >/dev/null 2>&1 && return 0
  local cand
  for cand in \
    "$HOME/development/flutter/bin" \
    "$HOME/flutter/bin" \
    "$HOME/fvm/default/bin" \
    "$PWD/.fvm/flutter_sdk/bin" \
    "$HOME/.puro/envs/default/flutter/bin" \
    "/opt/homebrew/bin" \
    "/usr/local/bin"; do
    if [[ -x "$cand/flutter" ]]; then
      export PATH="$cand:$PATH"
      info "found Flutter at $cand (added to PATH for this run)"
      return 0
    fi
  done
  return 1
}

ensure_flutter() {
  if locate_flutter; then ok "Flutter present"; return 0; fi
  warn "Flutter not found on PATH or in common SDK locations."
  if confirm "Install Flutter via Homebrew (brew install --cask flutter)?"; then
    gum spin --spinner moon --title "installing Flutter (multi-GB, be patient)…" \
      -- brew install --cask flutter || die "Flutter install failed — see https://docs.flutter.dev/get-started/install/macos"
    locate_flutter || die "Flutter installed but not on PATH — open a new terminal and re-run."
    ok "Flutter installed"
  else
    die "Install Flutter (https://docs.flutter.dev/get-started/install/macos), open a new terminal, then re-run."
  fi
}

ensure_claude() {
  command -v claude >/dev/null 2>&1 && { ok "Claude CLI present"; return 0; }
  warn "Claude Code CLI not found."
  if confirm "Install the Claude Code CLI now (official installer)?"; then
    gum spin --spinner pulse --title "installing Claude Code…" \
      -- /bin/bash -c 'curl -fsSL https://claude.ai/install.sh | bash' \
      || warn "Claude install returned nonzero — install manually: https://docs.claude.com/claude-code"
    # The installer drops the binary in ~/.local/bin on most setups.
    [[ -x "$HOME/.local/bin/claude" ]] && export PATH="$HOME/.local/bin:$PATH"
    command -v claude >/dev/null 2>&1 && ok "Claude CLI installed" || warn "claude still not on PATH (needed for the build step)"
  else
    warn "Skipping Claude install — the AI /mvp build step will be skipped."
  fi
}

ensure_gh() {
  command -v gh >/dev/null 2>&1 && { ok "GitHub CLI present"; return 0; }
  warn "GitHub CLI (gh) not found — used to create your PRIVATE app repo automatically."
  if confirm "Install GitHub CLI via Homebrew (brew install gh)?"; then
    gum spin --spinner dot --title "installing gh…" -- brew install gh \
      || warn "gh install failed — install manually: https://cli.github.com"
    command -v gh >/dev/null 2>&1 && ok "gh installed" || warn "gh still missing — you'll create the repo by hand."
  else
    warn "Skipping gh — you'll create the private repo manually (instructions shown later)."
  fi
}

ensure_flutter
ensure_claude
ensure_gh
command -v git >/dev/null 2>&1 || die "git not found — install Xcode Command Line Tools: xcode-select --install"
command -v jq  >/dev/null 2>&1 || info "jq not found (optional, used for session tracking)"

# ──────────────────────────────────────────────────────────────────────────────
# PHASE 1 — central secrets (entered ONCE)
# ──────────────────────────────────────────────────────────────────────────────
section "01" "LOADING SECRET VAULT"

mkdir -p "$CFG_DIR"
if [[ ! -f "$SECRETS" ]]; then
  cp "$KIT_DIR/appfactory/secrets.env.example" "$SECRETS"
  chmod 600 "$SECRETS"
  warn "First run: fill in your keys once, then re-run ./setup.zsh"
  gum style --foreground "$AMBER" "  vault: $SECRETS"
  exit 0
fi
set -a; source "$SECRETS"; set +a
ok "Loaded central secrets from $SECRETS"

# ──────────────────────────────────────────────────────────────────────────────
# PHASE 2 — Claude Code config (idempotent; preserves Flutter CLAUDE.md/AGENTS.md)
# ──────────────────────────────────────────────────────────────────────────────
section "02" "FORGING CONFIG MATRIX"

safe_write "docs/clean-code.md" <<'EOF'
# Clean Code Rules
*Distilled from Robert C. Martin's "Clean Code." Apply at all times, not just on request.*

## Naming
- Use intention-revealing names. `daysSinceCreation`, not `d`.
- Avoid disinformation and false encodings (`userList` for a non-List is a lie).
- Use pronounceable, searchable names. Single-letter vars only in tiny local scope.
- Functions are verbs (`getUserById`). Classes are nouns (`UserRepository`).
- Booleans are predicates (`isActive`, `hasPermission`).
- Drop redundant context (`user.userName` → `user.name`).
- One word per concept — don't mix `fetch`, `retrieve`, and `get` for the same idea.

## Functions
- Do one thing. If you can extract a sub-function with a non-redundant name, it did more than one thing.
- Keep them small — ideally < 20 lines, almost never > 40.
- Arguments: 0–2 ideal, 3 borderline, 4+ is a design smell (pass an object).
- No hidden side effects beyond what the name implies.
- Command/query separation: a function either does something or answers something, not both.
- Prefer exceptions to error codes. Don't return `null`; don't pass `null`.

## Comments
- Good code is mostly self-documenting; comments compensate for failures to express intent in code.
- Explain *why*, not *what*.
- Never leave commented-out code — that's what git is for.
- Delete noise comments (`// default constructor`).
- TODO/FIXME are fine if tracked.

## Formatting
- Vertical: related code stays together; blank lines separate concepts.
- Declare variables close to their use.
- Newspaper structure: high-level functions on top, details below (caller above callee).
- Keep lines reasonable (≤ 120 chars).
- Defer to the project's formatter/linter — don't hand-fight it.

## Error Handling
- Use exceptions, not error codes.
- Provide context in messages: the operation that failed and why.
- Don't swallow exceptions silently.
- Don't return or pass `null` — use empty collections, Option/Result types, or throw.
- Wrap third-party errors at the boundary so callers see one consistent type.

## Objects & Data Structures
- Small, single-responsibility classes; few instance variables (high cohesion).
- Hide internals — expose behavior, not raw data.
- Prefer composition over inheritance.
- Law of Demeter: a method talks only to itself, its arguments, objects it creates,
  and its direct components. Avoid train wrecks (`a.getB().getC().doThing()`).

## Tests (F.I.R.S.T.)
- **Fast** — run in milliseconds so you run them often.
- **Independent** — no test depends on another's state or order.
- **Repeatable** — same result on any machine, offline.
- **Self-validating** — a boolean pass/fail, no manual log-reading.
- **Timely** — write them with (ideally just before) the production code.
- One assert *concept* per test. Test boundary conditions explicitly.
- Keep test code as clean as production code — don't let it rot.

## The Boy Scout Rule
*Leave the code cleaner than you found it.* Each session: rename one unclear variable,
split one over-long function, delete one comment that states the obvious.
EOF

safe_write ".claude/settings.json" <<'EOF'
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",

  "permissions": {
    "allow": [
      "Bash(flutter *)",
      "Bash(dart *)",
      "Bash(git status)",
      "Bash(git diff *)",
      "Bash(git add *)",
      "Bash(git commit *)",
      "Bash(git log *)",
      "Bash(git branch *)",
      "Bash(git checkout *)",
      "Bash(ls *)",
      "Bash(cat *)",
      "Bash(rg *)",
      "Bash(grep *)",
      "Bash(bash scripts/*.sh)"
    ],
    "ask": [
      "Bash(rm *)",
      "Bash(mv *)",
      "Bash(git push *)",
      "Bash(git merge *)",
      "Bash(git rebase *)",
      "Bash(supabase db *)"
    ],
    "deny": [
      "Bash(git push --force *)",
      "Bash(rm -rf /*)",
      "Bash(rm -rf ~*)",
      "Bash(curl * | sh)",
      "Bash(curl * | bash)",
      "Bash(eval *)",
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./**/secrets/**)",
      "Read(./**/*.pem)",
      "Read(./**/*.key)"
    ],
    "defaultMode": "acceptEdits"
  },

  "attribution": {
    "commits": false,
    "pullRequests": true
  },

  "cleanupPeriodDays": 30,
  "spinnerTipsEnabled": false,
  "enableAllProjectMcpServers": false,

  "enabledPlugins": {}
}
EOF

safe_write ".claude/settings.local.json" <<'EOF'
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "//": "Personal overrides — gitignored. Machine-specific or experimental settings.",
  "permissions": { "allow": [], "ask": [], "deny": [] }
}
EOF

# Point this repo's Flutter CLAUDE.md at the clean-code rules (append once; never clobber).
if [[ -f CLAUDE.md ]] && ! grep -q 'docs/clean-code.md' CLAUDE.md; then
  cat >> CLAUDE.md <<'EOF'

## Clean Code
Apply the project's Clean Code rules at all times: @docs/clean-code.md
EOF
  ok "CLAUDE.md → linked docs/clean-code.md"
fi

# Seal .gitignore (append only missing entries).
GITIGNORE_LINES=(
  "# Claude Code"
  ".claude/settings.local.json"
  "CLAUDE.md.bak"
)
if [[ -e .gitignore ]]; then
  for line in "${GITIGNORE_LINES[@]}"; do
    grep -qxF "$line" .gitignore || echo "$line" >> .gitignore
  done
  ok "updated .gitignore"
else
  printf '%s\n' "${GITIGNORE_LINES[@]}" > .gitignore
  wrote ".gitignore"
fi

# ──────────────────────────────────────────────────────────────────────────────
# PHASE 3 — Claude plugins (idempotent, non-fatal)
# ──────────────────────────────────────────────────────────────────────────────
section "03" "DEPLOYING SKILLMATRIX"

patch_enabled_plugin() {
  local key="$1" file=".claude/settings.json"
  grep -q "\"$key\"" "$file" 2>/dev/null && return 0
  command -v python3 >/dev/null 2>&1 || return 1
  python3 - "$file" "$key" <<'PY'
import json, sys
path, key = sys.argv[1], sys.argv[2]
with open(path) as f: data = json.load(f)
data.setdefault("enabledPlugins", {})[key] = True
with open(path, "w") as f: json.dump(data, f, indent=2); f.write("\n")
PY
}

install_plugin() {
  local repo="$1" market="$2" name="$3"
  local key="${name}@${market}"
  gum spin --spinner globe --title "transmitting $key ..." \
    -- claude plugin marketplace add "$repo" \
    || warn "$name: marketplace add returned nonzero (may already exist)"
  if gum spin --spinner pulse --title "installing $key ..." \
      -- claude plugin install "$key" --scope project; then
    ok "linked $key"
  else
    warn "install failed for $key"
  fi
  grep -q "\"$key\"" .claude/settings.json 2>/dev/null \
    && info "verified in settings.json" \
    || { patch_enabled_plugin "$key" && warn "patched enabledPlugins manually" || true; }
}

# Garry Tan's gstack skill suite (git clone + ./setup). Idempotent, non-fatal.
install_gstack() {
  local dest="$HOME/.claude/skills/gstack"
  if [[ -d "$dest" ]]; then
    info "gstack already present at $dest"
    return 0
  fi
  if gum spin --spinner globe --title "cloning gstack ..." \
      -- git clone --depth 1 https://github.com/garrytan/gstack.git "$dest"; then
    if gum spin --spinner pulse --title "running gstack setup ..." \
        -- zsh -c "cd \"$dest\" && ./setup"; then
      ok "installed gstack"
    else
      warn "gstack setup returned nonzero — run manually: (cd $dest && ./setup)"
    fi
  else
    warn "gstack clone failed — install manually: git clone --depth 1 https://github.com/garrytan/gstack.git $dest"
  fi
}

# Paul Bakaus' impeccable design-polish skill (skills CLI). Non-fatal.
install_impeccable() {
  if [[ -d "$HOME/.claude/skills/impeccable" ]]; then
    info "impeccable already present"
    return 0
  fi
  if gum spin --spinner pulse --title "installing impeccable ..." \
      -- npx -y skills add pbakaus/impeccable --agent claude-code; then
    ok "installed impeccable"
  else
    warn "impeccable install failed — run manually: npx -y skills add pbakaus/impeccable --agent claude-code"
  fi
}

# eronred/aso-skills — the ASO data engine (skills CLI; MIT). Keyless by default;
# Appeeky is an OPTIONAL author-time key (never shipped). Non-fatal.
# Pin via the manifest (appfactory/SKILLS.md): record the resolved version there —
# the skills CLI may not accept a ref on add, so we don't over-engineer a lock here.
install_aso_skills() {
  if [[ -d "$HOME/.claude/skills/aso-skills" ]]; then
    info "aso-skills already present"
    return 0
  fi
  if gum spin --spinner pulse --title "installing aso-skills ..." \
      -- npx -y skills add eronred/aso-skills --agent claude-code; then
    ok "installed aso-skills"
  else
    warn "aso-skills install failed — run manually: npx -y skills add eronred/aso-skills --agent claude-code"
  fi
}

# appreply-co/mcp-appstore — the KEYLESS live App Store + Play Store data engine.
# aso-skills only returns LIVE data with a paid Appeeky key (else it falls back to model
# knowledge); this MCP server scrapes the public stores for free and gives real keyword
# difficulty/traffic scores + competitor data. No npx one-liner exists → clone + npm install
# + register by absolute path. Needs Node. Non-fatal throughout.
MCP_APPSTORE_DIR="$HOME/.appfactory/mcp-appstore"
install_mcp_appstore() {
  command -v node >/dev/null 2>&1 || { warn "node missing — skipping mcp-appstore (live ASO data). Install Node 18+ and re-run."; return 0; }
  if [[ ! -d "$MCP_APPSTORE_DIR/.git" ]]; then
    gum spin --spinner dot --title "cloning mcp-appstore (live store data)" -- \
      git clone --depth 1 https://github.com/appreply-co/mcp-appstore.git "$MCP_APPSTORE_DIR" \
      || { warn "mcp-appstore clone failed — install manually: https://github.com/appreply-co/mcp-appstore"; return 0; }
  fi
  gum spin --spinner dot --title "npm install (mcp-appstore)" -- \
    npm install --prefix "$MCP_APPSTORE_DIR" --silent || warn "npm install for mcp-appstore failed"
  # Register at user scope so the headless /mvp build picks it up. Idempotent: a second
  # run errors because it already exists — that's fine.
  claude mcp add --scope user --transport stdio mcp-appstore -- node "$MCP_APPSTORE_DIR/server.js" >/dev/null 2>&1 \
    && ok "registered mcp-appstore MCP server (keyless live store data)" \
    || info "mcp-appstore already registered (or 'claude mcp add' unavailable)"
}

# Confirm every skill/plugin landed so a missing one fails loudly, not silently.
verify_skills() {
  info "verifying skill matrix ..."
  [[ -d "$HOME/.claude/skills/gstack" ]] \
    && ok "gstack present" \
    || warn "gstack MISSING — install: git clone --depth 1 https://github.com/garrytan/gstack.git $HOME/.claude/skills/gstack"
  [[ -d "$HOME/.claude/skills/impeccable" ]] \
    && ok "impeccable present" \
    || warn "impeccable MISSING — install: npx -y skills add pbakaus/impeccable --agent claude-code"
  [[ -d "$HOME/.claude/skills/aso-skills" ]] \
    && ok "aso-skills present" \
    || warn "aso-skills MISSING — install: npx -y skills add eronred/aso-skills --agent claude-code"
  if claude mcp list 2>/dev/null | grep -q mcp-appstore; then
    ok "mcp-appstore MCP server registered (keyless live ASO data)"
  else
    warn "mcp-appstore MISSING — live ASO data engine. Re-run setup, or see https://github.com/appreply-co/mcp-appstore"
  fi
  grep -q '"superpowers@superpowers-marketplace"' .claude/settings.json 2>/dev/null \
    && ok "superpowers enabled in settings.json" \
    || warn "superpowers not found in settings.json enabledPlugins"
  grep -q '"marketing-skills@marketingskills"' .claude/settings.json 2>/dev/null \
    && ok "marketing-skills enabled in settings.json" \
    || warn "marketing-skills not found in settings.json enabledPlugins"
  grep -q '"ui-ux-pro-max@ui-ux-pro-max-skill"' .claude/settings.json 2>/dev/null \
    && ok "ui-ux-pro-max enabled in settings.json" \
    || warn "ui-ux-pro-max not found in settings.json enabledPlugins"
}

# Optional Appeeky upgrade: if APPEEKY_API_KEY is in the vault, register Appeeky's MCP server
# so aso-skills gets live FIRST-PARTY App Store data on top of keyless mcp-appstore. Additive,
# idempotent, non-fatal. The key is read from the env (sourced from the vault) — NEVER hardcoded
# and never written into the repo. Runs every time (the key may be added after first install).
register_appeeky_mcp() {
  if [[ -z "${APPEEKY_API_KEY:-}" ]]; then
    info "no APPEEKY_API_KEY in vault — keyless mcp-appstore still gives live data (fine)"
    return 0
  fi
  command -v claude >/dev/null 2>&1 || return 0
  claude mcp add --scope user --transport http appeeky https://mcp.appeeky.com/mcp \
    --header "Authorization: Bearer ${APPEEKY_API_KEY}" >/dev/null 2>&1 \
    && ok "registered Appeeky MCP server (live first-party ASO data)" \
    || info "appeeky MCP already registered (or 'claude mcp add' unavailable)"
}

if (( DO_PLUGINS )) && command -v claude >/dev/null 2>&1; then
  if [[ ! -f "$PLUGINS_MARK" || $REINSTALL -eq 1 ]]; then
    install_plugin "obra/superpowers-marketplace"  "superpowers-marketplace" "superpowers"
    install_plugin "coreyhaines31/marketingskills" "marketingskills"         "marketing-skills"
    install_plugin "nextlevelbuilder/ui-ux-pro-max-skill" "ui-ux-pro-max-skill" "ui-ux-pro-max"
    install_gstack
    install_impeccable
    install_aso_skills
    install_mcp_appstore
    touch "$PLUGINS_MARK"
  else
    info "plugins already installed (--reinstall to redo)"
  fi
  verify_skills
  register_appeeky_mcp
elif (( DO_PLUGINS )); then
  warn "claude CLI not found — skipping plugin install"
else
  info "--no-plugins set, skipping"
fi

# ──────────────────────────────────────────────────────────────────────────────
# PHASE 4 — interview
# ──────────────────────────────────────────────────────────────────────────────
section "04" "INTAKE INTERVIEW"

APP_NAME="$(gum input --prompt "App display name › " --placeholder "My App")"
BUNDLE_ID="$(gum input --prompt "Bundle id › "        --placeholder "com.brand.app")"
IDEA="$(gum input --prompt "One-line idea › "         --placeholder "the problem you solve")"
CATEGORY="$(gum input --prompt "App Store category › " --placeholder "Productivity")"
: "${APP_NAME:?app name required}" "${BUNDLE_ID:?bundle id required}" \
  "${IDEA:?idea required}" "${CATEGORY:?category required}"

# ──────────────────────────────────────────────────────────────────────────────
# PHASE 5 — scaffold (deterministic, no AI)
# ──────────────────────────────────────────────────────────────────────────────
section "05" "SCAFFOLDING PROJECT"

gum spin --spinner dot --title "flutter create (iOS + Android)" -- flutter create --platforms=android,ios .
if [[ -f scripts/rename.sh ]]; then
  bash scripts/rename.sh "$APP_NAME" "$BUNDLE_ID"
elif [[ -f tool/rename.dart ]]; then
  dart run tool/rename.dart "$APP_NAME" "$BUNDLE_ID"
fi
[[ -f scripts/postcreate.sh ]] && bash scripts/postcreate.sh

# Client-safe keys only → dart_define (secrets stay in the vault).
cat > dart_define.dev.json <<JSON
{
  "APP_ENV": "dev",
  "API_BASE_URL": "${API_BASE_URL:-https://example.com}",
  "ADS_ENABLED": "${ADS_ENABLED:-false}",
  "ADMOB_APP_ID_ANDROID": "${ADMOB_APP_ID_ANDROID:-}",
  "ADMOB_APP_ID_IOS": "${ADMOB_APP_ID_IOS:-}",
  "PURCHASES_ENABLED": "true",
  "REVENUECAT_API_KEY": "${REVENUECAT_API_KEY:-}"
}
JSON

gum spin --spinner dot --title "flutter pub get"  -- flutter pub get
gum spin --spinner dot --title "flutter gen-l10n" -- flutter gen-l10n
ok "Project scaffolded for $APP_NAME ($BUNDLE_ID)"

cat > APPFACTORY_INPUTS.md <<MD
# App inputs
- Name: $APP_NAME
- Bundle id: $BUNDLE_ID
- Idea / problem: $IDEA
- Category: $CATEGORY
- RevenueCat entitlement: premium
- Backend: Supabase (SUPABASE_URL/ANON in central secrets; LLM key stays server-side)
- ASO data source: ${ASO_DATA_SOURCE:-web_search + aso-optimizer skill}
MD

# ──────────────────────────────────────────────────────────────────────────────
# PHASE 5b — isolate the app's git repo (PRIVATE), detach from the factory
# ──────────────────────────────────────────────────────────────────────────────
section "5b" "ISOLATING APP REPO"

# GitHub-safe slug from the app name ("My App" → "my-app"); fall back to bundle tail.
REPO_SLUG="$(printf '%s' "$APP_NAME" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-' | sed 's/^-*//; s/-*$//')"
[[ -n "$REPO_SLUG" ]] || REPO_SLUG="${BUNDLE_ID##*.}"

# 1. Detach from the factory. If origin still points at the template, a push would
#    overwrite the FACTORY with your app — sever it and start a fresh history.
ORIGIN_URL="$(git remote get-url origin 2>/dev/null || true)"
if [[ "$ORIGIN_URL" == *flutter-boiler-plate* ]]; then
  warn "origin points at the FACTORY template — detaching (fresh git history) so app code can never land there"
  rm -rf .git
fi

# 2. Your repo describes YOUR app, not the template. Replace the factory README.
cat > README.md <<MD
# $APP_NAME

> $IDEA

A $CATEGORY app for iOS & Android, built with Flutter.

## Develop

\`\`\`bash
bash scripts/run.sh        # boots a simulator and runs (mock data, no keys needed)
flutter analyze && flutter test
\`\`\`

Build-time config is injected via \`dart_define.dev.json\` (\`--dart-define\`); secrets never
live in source. See \`AGENTS.md\` for the architecture and the add-a-feature recipe.

---
*Bundle id: \`$BUNDLE_ID\` · scaffolded with the Flutter App Factory.*
MD
ok "Wrote an app-specific README for $APP_NAME"

# 3. Fresh repo + base commit (so the new private remote has content to receive).
if [[ ! -d .git ]]; then
  git init -q
  git add -A
  git -c user.name="App Factory" -c user.email="setup@appfactory.local" \
      -c commit.gpgsign=false commit -qm "Initial commit: $APP_NAME" 2>/dev/null \
    || warn "couldn't make the base commit (set git user.name/email) — commit before pushing"
fi

# 4. Create a PRIVATE GitHub repo and point origin at it. Idempotent, non-fatal.
if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  if git remote get-url origin >/dev/null 2>&1; then
    # Already has its own remote (e.g. "Use this template"). Enforce private.
    VIS="$(gh repo view --json visibility -q .visibility 2>/dev/null || echo UNKNOWN)"
    if [[ "$VIS" == "PUBLIC" ]]; then
      warn "your app repo is PUBLIC — app code/secrets should not be."
      if confirm "Make it PRIVATE now?"; then
        gh repo edit --visibility private --accept-visibility-change-consequences >/dev/null 2>&1 \
          && ok "repo set to private" || warn "couldn't change visibility — set it private in the GitHub UI"
      fi
    else
      ok "app repo is already non-public ($VIS)"
    fi
  elif confirm "Create PRIVATE GitHub repo '$REPO_SLUG' and set it as origin?"; then
    gum spin --spinner dot --title "gh repo create $REPO_SLUG (private)" -- \
      gh repo create "$REPO_SLUG" --private --source=. --remote=origin --description "$IDEA" \
      && ok "Private repo created: $REPO_SLUG" \
      || warn "gh repo create failed — make one and run: git remote add origin <url>"
  fi
else
  warn "gh not authenticated — leaving origin UNSET so nothing can be pushed to the factory."
  info "Create your private repo with:"
  echo "    gh repo create $REPO_SLUG --private --source=. --remote=origin --description \"$IDEA\""
  echo "    (or run 'gh auth login' and re-run, or 'git remote add origin <url>')"
fi

# 5. Defense in depth: refuse ANY push to the factory, whatever origin says.
mkdir -p .git/hooks
cat > .git/hooks/pre-push <<'HOOK'
#!/bin/sh
# Installed by App Factory setup.zsh — never push app code to the template repo.
remote_url="$2"
case "$remote_url" in
  *flutter-boiler-plate*)
    echo "✖ Refusing to push to the App Factory template ($remote_url)." >&2
    echo "  Re-home to your own PRIVATE repo first:" >&2
    echo "    gh repo create <app> --private --source=. --remote=origin" >&2
    exit 1 ;;
esac
exit 0
HOOK
chmod +x .git/hooks/pre-push
ok "Installed pre-push guard (blocks any push to the factory)"

# ──────────────────────────────────────────────────────────────────────────────
# PHASE 6 — AI MVP build
# ──────────────────────────────────────────────────────────────────────────────
if (( DO_BUILD )) && command -v claude >/dev/null 2>&1; then
  section "06" "BUILDING MVP (AI)"
  info "Claude is building the MVP unattended; review the diff after."
  OUT="$(claude -p "/mvp" --permission-mode acceptEdits --output-format json 2>/dev/null || true)"
  if command -v jq >/dev/null 2>&1 && [[ -n "$OUT" ]]; then
    echo "$OUT" | jq -r '.session_id' > .appfactory_session 2>/dev/null || true
  fi
  ok "MVP build finished."
else
  section "06" "BUILDING MVP (AI)"
  (( DO_BUILD )) || info "--no-build set, skipping the AI build."
  command -v claude >/dev/null 2>&1 || warn "claude CLI missing — skipped the AI build."
fi

# ──────────────────────────────────────────────────────────────────────────────
# PHASE 7 — SYSTEM ONLINE
# ──────────────────────────────────────────────────────────────────────────────
echo
gum style --foreground "$GREEN" --bold \
  --border-foreground "$PURP" --border double \
  --align center --width 64 --padding "1 3" \
  "◢◤  SYSTEM ONLINE  ◥◣" \
  "" \
  "$APP_NAME  ·  $BUNDLE_ID" \
  "repo: ${REPO_SLUG:-<unset>} (private)" \
  "" \
  "next:" \
  "  1. test:     bash scripts/run.sh" \
  "  2. verify:   flutter analyze && flutter test" \
  "  3. push:     git push -u origin main   (your private repo; factory is blocked)" \
  "  4. ship:     ./ship.sh"
echo

# ── idea → ship journey (verbose, for first-time users) ──────────────────────────
gum style --foreground "$CYAN" --bold \
  --border-foreground "$PURP" --border normal \
  --align left --width 78 --padding "1 2" \
  "◢◤  IDEA → SHIP  //  what to do now  ◥◣" \
  "" \
  "TEST    run the app on a device/simulator:" \
  "          flutter run --dart-define-from-file=dart_define.dev.json" \
  "" \
  "ITERATE inside  claude  — add to the MVP with slash commands:" \
  "          /feature       add a screen (11-step recipe)" \
  "          /theme         tune the Material 3 theme" \
  "          /wire-paywall  RevenueCat (entitlement \"premium\")" \
  "          /aso           keywords + metadata (aso-skills data; marketing-skills copy)" \
  "          /legal         privacy/terms pages + in-app links" \
  "          /ship-check    pre-submit gate → PASS/FAIL" \
  "" \
  "VERIFY  keep it green:" \
  "          flutter analyze && flutter test" \
  "" \
  "SHIP    pre-flight + release build, then submit by hand:" \
  "          ./ship.sh      (runs /release: pre-flight + release build)" \
  "          then upload via App Store Connect / Play Console"
echo
