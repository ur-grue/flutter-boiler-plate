#!/usr/bin/env bash
#
# Publish the generated legal pages so the App Store / Play "privacy URL" exists
# WITHOUT manual hosting.
#
#   bash scripts/publish-legal.sh
#
# Expects /legal to have written:
#   docs/legal/privacy.html
#   docs/legal/terms.html
#
# Strategy: serve them straight from the `docs/` folder on the default branch via
# GitHub Pages (no gh-pages branch, no build step). If the GitHub CLI is present we
# best-effort enable Pages from the docs/ folder; either way we PRINT the resulting
# URL pattern so you can paste it into store metadata + app config.
#
# Everything here is NON-FATAL except a genuinely missing input — worst case it
# prints what to do next.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# Guard: be in the app root (same shape as scripts/run.sh).
if [[ ! -f pubspec.yaml || ! -f lib/main.dart ]]; then
  echo "✗ This isn't your app's root (need pubspec.yaml + lib/main.dart here)."
  echo "  cd into your app's project folder, then re-run."
  exit 1
fi

PRIVACY_HTML="docs/legal/privacy.html"
TERMS_HTML="docs/legal/terms.html"

# 1. Inputs must exist — they're produced by /legal.
missing=0
[[ -f "$PRIVACY_HTML" ]] || { echo "✗ Missing $PRIVACY_HTML"; missing=1; }
[[ -f "$TERMS_HTML"   ]] || { echo "✗ Missing $TERMS_HTML"; missing=1; }
if [[ "$missing" -ne 0 ]]; then
  echo
  echo "  Generate the legal pages first, then re-run this script:"
  echo "      run the /legal command (writes privacy.html + terms.html under docs/legal/)"
  exit 1
fi
echo "▸ Found legal pages under docs/legal/"

# 2. Derive owner/repo from the origin remote so we can print a real URL.
owner="<owner>"
repo="<repo>"
remote_url="$(git remote get-url origin 2>/dev/null || true)"
if [[ -n "$remote_url" ]]; then
  # Handles git@github.com:owner/repo.git and https://github.com/owner/repo(.git)
  slug="${remote_url#*github.com[:/]}"
  slug="${slug%.git}"
  if [[ "$slug" == */* ]]; then
    owner="${slug%%/*}"
    repo="${slug##*/}"
  fi
fi

# 3. Best-effort: enable GitHub Pages from the docs/ folder on the default branch.
#    Non-fatal — if gh is absent, unauthenticated, or Pages already exists, we move on.
if command -v gh >/dev/null 2>&1 && [[ "$owner" != "<owner>" ]]; then
  echo "▸ Enabling GitHub Pages from /docs on the default branch (best-effort)…"
  pages_out="$(gh api -X POST "repos/${owner}/${repo}/pages" \
    -f 'source[branch]=main' -f 'source[path]=/docs' 2>&1)" || true
  if echo "$pages_out" | grep -qiE 'already exists|409'; then
    echo "  ✓ GitHub Pages already enabled — leaving it as-is."
  elif echo "$pages_out" | grep -qiE '"html_url"|201|created'; then
    echo "  ✓ GitHub Pages enabled."
  else
    echo "  ! Could not enable Pages automatically (this is fine — enable it once in"
    echo "    Settings ▸ Pages ▸ Source = 'Deploy from a branch', branch = default, /docs)."
  fi
else
  echo "▸ Skipping auto-enable of GitHub Pages (gh CLI not available or remote unknown)."
  echo "  Enable it once in Settings ▸ Pages ▸ Source = 'Deploy from a branch', /docs folder."
fi

# 4. Print the resulting URLs to paste into store metadata + app config.
base="https://${owner}.github.io/${repo}/legal"
echo
echo "▸ Your legal URLs (once Pages is live, may take ~1 min on first publish):"
echo "      Privacy: ${base}/privacy.html"
echo "      Terms:   ${base}/terms.html"
echo

# 5. Honest reminders.
echo "▸ Next:"
echo "  • Commit + push docs/legal/ so GitHub Pages can serve it:"
echo "        git add docs/legal && git commit -m 'Add legal pages' && git push"
echo "  • A PRIVATE repo needs GitHub Pages on a PAID plan. If your repo is private and"
echo "    you're on the free plan, either make the repo public, or host the two static"
echo "    files (docs/legal/privacy.html + terms.html) anywhere (Netlify, Vercel, S3,"
echo "    your own site) and use THAT URL instead."
echo "  • Put the privacy URL into the store metadata + app config (the /legal command"
echo "    writes them into fastlane/metadata/{ios,android} and dart_define for you)."
