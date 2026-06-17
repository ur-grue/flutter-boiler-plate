#!/usr/bin/env zsh
# App Factory — one-shot MVP builder. Run from inside a freshly cloned boilerplate repo.
# Usage:  ./new-app.sh            (interactive)
#         ./new-app.sh --reinstall-skills
set -e -u -o pipefail

CFG_DIR="$HOME/.appfactory"
SECRETS="$CFG_DIR/secrets.env"
SKILLS_MARK="$CFG_DIR/.skills_installed"
KIT_DIR="${0:A:h}"

note() { print -P "%F{cyan}▸ $1%f"; }
ok()   { print -P "%F{green}✓ $1%f"; }
die()  { print -P "%F{red}✗ $1%f"; exit 1; }

# 1) Central secrets — entered ONCE, never again --------------------------------
mkdir -p "$CFG_DIR"
if [[ ! -f "$SECRETS" ]]; then
  cp "$KIT_DIR/appfactory/secrets.env.example" "$SECRETS"
  chmod 600 "$SECRETS"
  die "First run: fill in your keys once → $SECRETS  then re-run."
fi
source "$SECRETS"
ok "Loaded central secrets from $SECRETS"

# 2) Prereqs --------------------------------------------------------------------
for bin in flutter claude; do command -v $bin >/dev/null || die "$bin not found in PATH"; done
command -v jq >/dev/null || note "jq not found (optional, used for session tracking)"

# 3) Skills/plugins — install once, idempotent ----------------------------------
if [[ ! -f "$SKILLS_MARK" || "${1:-}" == "--reinstall-skills" ]]; then
  note "Installing Claude Code skills (one-time)…"
  [[ -d "$HOME/.claude/skills/aso-optimizer" ]] || {
    tmp=$(mktemp -d); git clone --depth 1 https://github.com/dock-aso/aso-optimizer-skill.git "$tmp" >/dev/null 2>&1 \
      && mkdir -p "$HOME/.claude/skills" && cp -r "$tmp/aso-optimizer" "$HOME/.claude/skills/aso-optimizer"; rm -rf "$tmp"; }
  npx -y skills add ceorkm/mobile-app-ui-design --agent claude-code 2>/dev/null || note "ceorkm skill add skipped"
  npx -y skills add pbakaus/impeccable          --agent claude-code 2>/dev/null || note "impeccable skill add skipped"
  touch "$SKILLS_MARK"; ok "Skills ready"
  [[ "${1:-}" == "--reinstall-skills" ]] && exit 0
fi

# 4) Interview — a few questions ------------------------------------------------
print -P "%F{magenta}— New app —%f"
read "APP_NAME?App display name: "
read "BUNDLE_ID?Bundle id (com.brand.app): "
read "IDEA?One-line idea / problem: "
read "CATEGORY?App Store category: "
: "${APP_NAME:?}" "${BUNDLE_ID:?}" "${IDEA:?}" "${CATEGORY:?}"

# 5) Scaffold (deterministic, no AI needed) -------------------------------------
note "Scaffolding…"
flutter create . >/dev/null
if [[ -f scripts/rename.sh ]]; then bash scripts/rename.sh "$APP_NAME" "$BUNDLE_ID";
elif [[ -f tool/rename.dart ]]; then dart run tool/rename.dart "$APP_NAME" "$BUNDLE_ID"; fi

# dart_define from central secrets + app values (client-safe keys only)
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
flutter pub get >/dev/null && flutter gen-l10n >/dev/null
ok "Project scaffolded for $APP_NAME ($BUNDLE_ID)"

# Hand the answers to Claude
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

# 6) Build the MVP (headless, single resumable session) -------------------------
note "Claude is building the MVP… (this runs unattended; review after)"
OUT=$(claude -p "/mvp" --permission-mode acceptEdits --output-format json 2>/dev/null || true)
if command -v jq >/dev/null && [[ -n "$OUT" ]]; then
  echo "$OUT" | jq -r '.session_id' > .appfactory_session 2>/dev/null || true
fi

ok "MVP build finished."
print -P "%F{yellow}Test it:%f flutter run --dart-define-from-file=dart_define.dev.json"
print -P "%F{yellow}Approve & continue to release:%f ./ship.sh"
