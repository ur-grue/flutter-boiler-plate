#!/usr/bin/env zsh
# ──────────────────────────────────────────────────────────────────────────────
# collect-run-data.zsh — APP FACTORY // post-build telemetry harvester
#
#   cd <your-generated-app> && ./scripts/collect-run-data.zsh
#
# After the App Factory (./setup.zsh → /mvp) generates a mobile app, this script
# gathers everything needed to LEARN FROM and IMPROVE the generation:
#   • the Claude Code transcript of the /mvp run
#   • the spec + the interview inputs
#   • static analysis + test results
#   • git history, toolchain report, project file tree
# …then REDACTS anything secret-looking and writes a manifest. By default it
# DOES NOT spawn Claude: instead it writes an ANALYZE.md prompt and hands the
# synthesis of LEARNINGS.md to YOUR CURRENT interactive Claude session (lighter,
# faster, no model-access surprises). Pass --analyze to opt into the old behavior
# (a spawned `claude -p` pass with three parallel subagents). Finally it tars the
# lot for sharing.
#
# Run it from the ROOT of a generated app repo.
#
# Options:
#   --analyze      opt in: spawn `claude -p` with 3 parallel subagents to write
#                  LEARNINGS.md (heavier; needs model access)
#   --no-analyze   collect only (this is the default; harmless alias)
#   --out <dir>    output base dir (default: ./debug)
#   --model <id>   model for the spawned analysis pass (e.g. claude-opus-4-8)
#   -h | --help    this screen
#
# Safe by design: every collection step is non-fatal, and secrets are scrubbed
# before anything is archived. Still — skim the output before you share it.
# ──────────────────────────────────────────────────────────────────────────────
set -uo pipefail   # NOT -e: individual collection steps are allowed to fail.

# ── args ────────────────────────────────────────────────────────────────────────
# Default: collect only and hand synthesis to the user's current Claude session.
DO_ANALYZE=0
OUT="./debug"
MODEL=""
HELP=0
while (( $# )); do
  case "$1" in
    --analyze)    DO_ANALYZE=1 ;;
    --no-analyze) DO_ANALYZE=0 ;;
    --out)        shift; OUT="${1:-./debug}" ;;
    --model)      shift; MODEL="${1:-}" ;;
    -h|--help)    HELP=1 ;;
    *)            print -u2 "unknown option: $1"; exit 1 ;;
  esac
  shift
done

# ── aesthetic (gum if present; plain print otherwise) ────────────────────────────
PINK="212"; CYAN="51"; GREEN="82"; AMBER="214"; PURP="99"; GREY="245"
HAS_GUM=0; command -v gum >/dev/null 2>&1 && HAS_GUM=1

step() { (( HAS_GUM )) && gum log --level debug "$1" || print -P "%F{cyan}▸ $1%f"; }
ok()   { (( HAS_GUM )) && gum log --level info  "$1" || print -P "%F{green}✓ $1%f"; }
warn() { (( HAS_GUM )) && gum log --level warn  "$1" || print -P "%F{yellow}! $1%f"; }

section() {
  echo
  if (( HAS_GUM )); then
    gum style --foreground "$PURP" --bold \
      --border-foreground "$PURP" --border normal --padding "0 1" "[ $1 ]  $2"
  else
    print -P "%F{magenta}── [ $1 ]  $2 ──%f"
  fi
}

panel() {
  if (( HAS_GUM )); then
    gum style --foreground "$GREEN" --bold --border-foreground "$PURP" \
      --border double --align left --width 72 --padding "1 3" "$@"
  else
    echo; for line in "$@"; do print -P "%F{green}$line%f"; done; echo
  fi
}

usage() {
  if (( HAS_GUM )); then
    gum style --foreground "$PINK" --border-foreground "$PURP" \
      --border double --align center --width 60 --padding "1 3" \
      "APP FACTORY  //  collect-run-data" "harvest → redact → learn"
    echo
    gum style --foreground "$CYAN" --bold "USAGE"
    gum style --foreground "$GREY"  "  ./scripts/collect-run-data.zsh [options]"
    echo
    gum style --foreground "$CYAN" --bold "OPTIONS"
    gum style --foreground "$GREY" \
      "  (default)      collect only; hand synthesis to your current Claude session" \
      "  --analyze      opt in: spawn 'claude -p' with 3 parallel subagents" \
      "  --no-analyze   collect only (default; harmless alias)" \
      "  --out <dir>    output base dir (default: ./debug)" \
      "  --model <id>   model for the spawned analysis pass (e.g. claude-opus-4-8)" \
      "  -h --help      this screen"
  else
    print -r -- "APP FACTORY // collect-run-data — harvest, redact, learn"
    print -r -- "USAGE:   ./scripts/collect-run-data.zsh [options]"
    print -r -- "  (default)      collect only; hand synthesis to your current Claude session"
    print -r -- "  --analyze      opt in: spawn 'claude -p' with 3 parallel subagents"
    print -r -- "  --no-analyze   collect only (default; harmless alias)"
    print -r -- "  --out <dir>    output base dir (default: ./debug)"
    print -r -- "  --model <id>   model for the spawned analysis pass (e.g. claude-opus-4-8)"
    print -r -- "  -h --help      this screen"
  fi
  exit 0
}
(( HELP )) && usage

# ── output dir ───────────────────────────────────────────────────────────────────
STAMP="$(date +%Y%m%d-%H%M%S)"
OUTDIR="${OUT}/run-${STAMP}"
mkdir -p "$OUTDIR" || { print -u2 "could not create $OUTDIR"; exit 1; }
# Absolute path so Claude (run later) can read artifacts regardless of cwd.
OUTDIR_ABS="${OUTDIR:A}"

# ── project-root guard (non-fatal but unmissable) ─────────────────────────────────
if [[ ! -f pubspec.yaml && ! -d lib ]]; then
  warn "This doesn't look like a Flutter app root (no pubspec.yaml or lib/)."
  warn "cd into your generated app before running, or the harvest will be mostly empty."
fi

# ──────────────────────────────────────────────────────────────────────────────
# PHASE 1 — COLLECT (each step non-fatal)
# ──────────────────────────────────────────────────────────────────────────────
section "01" "HARVESTING ARTIFACTS"

# Append a footer recording an exit code, so the manifest can parse pass/fail.
record_exit() { print "\n----\nexit_code: $1" >> "$2"; }

collect_transcript() {
  step "locating Claude Code transcript"
  local note="$OUTDIR_ABS/transcript.MISSING.txt"
  local projdir="$HOME/.claude/projects"
  local session_id="" transcript=""

  # 1. Exact match via .appfactory_session, if present.
  if [[ -f .appfactory_session ]]; then
    session_id="$(cat .appfactory_session 2>/dev/null | tr -d '[:space:]')"
    [[ -n "$session_id" ]] \
      && transcript="$(find "$projdir" -name "${session_id}.jsonl" 2>/dev/null | head -1)"
  fi

  # 2. Fallback (no session file, or no match): newest transcript for THIS project.
  #    Claude Code names the project folder after the cwd path, so the repo's
  #    basename appears in it — prefer that folder, else the newest jsonl anywhere.
  if [[ -z "$transcript" ]]; then
    local projfolder
    projfolder="$(find "$projdir" -maxdepth 1 -type d -name "*${PWD:t}*" 2>/dev/null | head -1)"
    [[ -n "$projfolder" ]] \
      && transcript="$(find "$projfolder" -name '*.jsonl' 2>/dev/null | xargs -r ls -t 2>/dev/null | head -1)"
    [[ -z "$transcript" ]] \
      && transcript="$(find "$projdir" -name '*.jsonl' 2>/dev/null | xargs -r ls -t 2>/dev/null | head -1)"
    [[ -n "$transcript" ]] \
      && warn "no session id — using newest transcript for this project (verify it's the right run)"
  fi

  if [[ -n "$transcript" && -f "$transcript" ]]; then
    cp "$transcript" "$OUTDIR_ABS/transcript.jsonl" && ok "transcript → transcript.jsonl"
  else
    print -r -- "No transcript found: no .appfactory_session and no .jsonl under ~/.claude/projects." > "$note"
    warn "transcript not located"
  fi
}

collect_spec_and_inputs() {
  step "copying spec + interview inputs"
  local f
  for f in APP_SPEC.md APPFACTORY_INPUTS.md; do
    if [[ -f "$f" ]]; then cp "$f" "$OUTDIR_ABS/$f" && ok "$f"; else warn "$f not present"; fi
  done
}

collect_flutter_checks() {
  if ! command -v flutter >/dev/null 2>&1; then
    print "flutter not on PATH — analyze + test skipped." > "$OUTDIR_ABS/flutter.MISSING.txt"
    warn "flutter missing — analyze/test skipped"
    return 0
  fi
  step "flutter analyze --fatal-warnings"
  local analyze="$OUTDIR_ABS/analyze.txt"
  flutter analyze --fatal-warnings > "$analyze" 2>&1
  record_exit "$?" "$analyze"; ok "analyze.txt"

  step "flutter test"
  local test_out="$OUTDIR_ABS/test.txt"
  flutter test > "$test_out" 2>&1
  record_exit "$?" "$test_out"; ok "test.txt"
}

collect_git() {
  if ! command -v git >/dev/null 2>&1 || [[ ! -d .git ]]; then
    print "git unavailable or not a repo — git history skipped." > "$OUTDIR_ABS/git.MISSING.txt"
    warn "git unavailable — history skipped"
    return 0
  fi
  step "capturing git history"
  git log --oneline -30 > "$OUTDIR_ABS/git-log.txt" 2>&1 && ok "git-log.txt"
  git diff --stat HEAD~30..HEAD > "$OUTDIR_ABS/git-diffstat.txt" 2>/dev/null \
    || git diff --stat > "$OUTDIR_ABS/git-diffstat.txt" 2>&1
  ok "git-diffstat.txt"
}

collect_toolchain() {
  if ! command -v flutter >/dev/null 2>&1; then
    print "flutter not on PATH — flutter doctor skipped." > "$OUTDIR_ABS/flutter-doctor.MISSING.txt"
    warn "flutter missing — doctor skipped"
    return 0
  fi
  step "flutter doctor -v"
  flutter doctor -v > "$OUTDIR_ABS/flutter-doctor.txt" 2>&1 && ok "flutter-doctor.txt"
}

collect_project_shape() {
  step "capturing project shape"
  [[ -f pubspec.yaml ]] && { cp pubspec.yaml "$OUTDIR_ABS/pubspec.yaml"; ok "pubspec.yaml"; } \
    || warn "pubspec.yaml not present"
  if [[ -d lib ]]; then
    find lib -type f | sort > "$OUTDIR_ABS/file-tree.txt" && ok "file-tree.txt"
  else
    print "No lib/ directory found." > "$OUTDIR_ABS/file-tree.txt"
    warn "lib/ missing — empty file-tree"
  fi
}

collect_dart_define() {
  if [[ -f dart_define.dev.json ]]; then
    step "copying dart_define.dev.json (will be redacted)"
    cp dart_define.dev.json "$OUTDIR_ABS/dart_define.dev.json" && ok "dart_define.dev.json"
  else
    warn "dart_define.dev.json not present"
  fi
}

# Probe common SDK locations so analyze/test/doctor run even when Flutter is
# installed but not exported on PATH (mirrors setup.zsh / scripts/doctor.sh).
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
      step "found Flutter at $cand"
      return 0
    fi
  done
  return 1
}
locate_flutter

collect_transcript
collect_spec_and_inputs
collect_flutter_checks
collect_git
collect_toolchain
collect_project_shape
collect_dart_define

# ──────────────────────────────────────────────────────────────────────────────
# PHASE 2 — REDACT (critical: this data may be shared)
# ──────────────────────────────────────────────────────────────────────────────
section "02" "SCRUBBING SECRETS"

SECRETS_ENV="$HOME/.appfactory/secrets.env"

redact_with_python() {
  step "redacting via python3"
  SECRETS_ENV="$SECRETS_ENV" python3 - "$OUTDIR_ABS" <<'PY'
import os, re, sys, glob

outdir = sys.argv[1]
MASK = "***REDACTED***"
SENSITIVE = re.compile(r"KEY|TOKEN|SECRET|PASSWORD|SUPABASE|REVENUECAT|ADMOB|API", re.I)

# Long opaque tokens and JWT-like blobs anywhere in a file.
JWT = re.compile(r"eyJ[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+")
OPAQUE = re.compile(r"[A-Za-z0-9_\-]{24,}")

# JSON-ish:  "KEY": "value"
JSON_KV = re.compile(r'("([^"]*)"\s*:\s*)"([^"]*)"')
# env-ish:   KEY="value" | KEY=value
ENV_KV = re.compile(r'^(\s*([A-Za-z0-9_]+)\s*=\s*)(.*)$')

def mask_structurally(text):
    def json_sub(m):
        prefix, key, _val = m.group(1), m.group(2), m.group(3)
        return f'{prefix}"{MASK}"' if SENSITIVE.search(key) else m.group(0)
    text = JSON_KV.sub(json_sub, text)

    lines = []
    for line in text.split("\n"):
        m = ENV_KV.match(line)
        if m and SENSITIVE.search(m.group(2)):
            lines.append(f"{m.group(1)}{MASK}")
        else:
            lines.append(line)
    return "\n".join(lines)

def mask_opaque(text):
    text = JWT.sub(MASK, text)
    text = OPAQUE.sub(MASK, text)
    return text

# Exact values leaked from the central vault — scrub them everywhere.
leaked = []
secrets_path = os.environ.get("SECRETS_ENV", "")
if secrets_path and os.path.isfile(secrets_path):
    for raw in open(secrets_path, encoding="utf-8", errors="replace"):
        raw = raw.strip()
        if not raw or raw.startswith("#") or "=" not in raw:
            continue
        val = raw.split("=", 1)[1].strip().strip('"').strip("'")
        if val:
            leaked.append(val)
leaked.sort(key=len, reverse=True)  # longest first to avoid partial overlaps

def scrub_leaked(text):
    for val in leaked:
        if val and val in text:
            text = text.replace(val, MASK)
    return text

for path in glob.glob(os.path.join(outdir, "*")):
    if not os.path.isfile(path):
        continue
    base = os.path.basename(path)
    try:
        with open(path, encoding="utf-8", errors="replace") as f:
            text = f.read()
    except Exception:
        continue

    text = mask_structurally(text)
    if base == "transcript.jsonl":
        text = mask_opaque(text)
    text = scrub_leaked(text)

    with open(path, "w", encoding="utf-8") as f:
        f.write(text)
print("redaction complete")
PY
}

redact_with_fallback() {
  step "redacting via sed/perl (python3 unavailable)"
  local file
  for file in "$OUTDIR_ABS"/*(.N); do
    # Structural masking: any KEY=value / "KEY":"value" with a sensitive name.
    if command -v perl >/dev/null 2>&1; then
      perl -i -pe '
        s/("[^"]*(?i:KEY|TOKEN|SECRET|PASSWORD|SUPABASE|REVENUECAT|ADMOB|API)[^"]*"\s*:\s*)"[^"]*"/$1"***REDACTED***"/g;
        s/^(\s*[A-Za-z0-9_]*(?i:KEY|TOKEN|SECRET|PASSWORD|SUPABASE|REVENUECAT|ADMOB|API)[A-Za-z0-9_]*\s*=\s*).*$/$1***REDACTED***/g;
      ' "$file" 2>/dev/null
      if [[ "${file:t}" == "transcript.jsonl" ]]; then
        perl -i -pe '
          s/eyJ[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+/***REDACTED***/g;
          s/[A-Za-z0-9_\-]{24,}/***REDACTED***/g;
        ' "$file" 2>/dev/null
      fi
    else
      sed -i.bak -E \
        -e 's/("[^"]*([Kk][Ee][Yy]|TOKEN|SECRET|PASSWORD|SUPABASE|REVENUECAT|ADMOB|API)[^"]*"[[:space:]]*:[[:space:]]*)"[^"]*"/\1"***REDACTED***"/g' \
        "$file" 2>/dev/null
      rm -f "${file}.bak" 2>/dev/null
    fi
  done

  # Scrub exact leaked vault values everywhere.
  if [[ -f "$SECRETS_ENV" ]]; then
    while IFS= read -r raw; do
      [[ -z "$raw" || "$raw" == \#* || "$raw" != *=* ]] && continue
      local val="${raw#*=}"
      val="${val#\"}"; val="${val%\"}"; val="${val#\'}"; val="${val%\'}"
      [[ -z "$val" ]] && continue
      for file in "$OUTDIR_ABS"/*(.N); do
        if command -v perl >/dev/null 2>&1; then
          VAL="$val" perl -i -pe 'BEGIN{$v=quotemeta($ENV{VAL})} s/$v/***REDACTED***/g' "$file" 2>/dev/null
        fi
      done
    done < "$SECRETS_ENV"
  fi
}

if command -v python3 >/dev/null 2>&1; then
  redact_with_python && ok "secrets scrubbed"
else
  redact_with_fallback && ok "secrets scrubbed (fallback)"
fi
warn "redaction is best-effort — always skim before sharing"

# ──────────────────────────────────────────────────────────────────────────────
# PHASE 3 — MANIFEST
# ──────────────────────────────────────────────────────────────────────────────
section "03" "WRITING MANIFEST"

# Parse "exit_code: N" footer → human pass/fail.
exit_summary() {
  local file="$1"
  [[ -f "$file" ]] || { print "not collected"; return; }
  local code
  code="$(grep -E '^exit_code: ' "$file" 2>/dev/null | tail -1 | grep -oE '[0-9]+' | head -1)"
  [[ -z "$code" ]] && { print "no exit code recorded"; return; }
  (( code == 0 )) && print "PASS (exit 0)" || print "FAIL (exit $code)"
}

describe() {
  local base="$1"
  case "$base" in
    transcript.jsonl)        print "Claude Code transcript of the /mvp build (redacted)" ;;
    transcript.MISSING.txt)  print "note: transcript could not be located" ;;
    APP_SPEC.md)             print "the generated app spec" ;;
    APPFACTORY_INPUTS.md)    print "the interview inputs that seeded the build" ;;
    analyze.txt)             print "flutter analyze --fatal-warnings — $(exit_summary "$OUTDIR_ABS/analyze.txt")" ;;
    test.txt)                print "flutter test — $(exit_summary "$OUTDIR_ABS/test.txt")" ;;
    git-log.txt)             print "last 30 commits (oneline)" ;;
    git-diffstat.txt)        print "diffstat across the build's commits" ;;
    flutter-doctor.txt)      print "flutter doctor -v toolchain report" ;;
    pubspec.yaml)            print "project manifest / dependencies" ;;
    file-tree.txt)           print "sorted list of files under lib/" ;;
    dart_define.dev.json)    print "client config (redacted)" ;;
    ANALYZE.md)              print "ready-to-use prompt for an interactive Claude session → LEARNINGS.md" ;;
    LEARNINGS.md)            print "synthesised App Factory improvements (from the --analyze pass)" ;;
    flutter.MISSING.txt|flutter-doctor.MISSING.txt) print "note: flutter not on PATH" ;;
    git.MISSING.txt)         print "note: git unavailable" ;;
    *)                       print "collected artifact" ;;
  esac
}

MANIFEST="$OUTDIR_ABS/manifest.md"
{
  print -r -- "# Run data manifest"
  print
  print -r -- "- Collected: $(date)"
  print -r -- "- Output dir: $OUTDIR_ABS"
  print
  print -r -- "| File | What it is |"
  print -r -- "|------|------------|"
} > "$MANIFEST"

for f in "$OUTDIR_ABS"/*(.N); do
  base="${f:t}"
  [[ "$base" == "manifest.md" ]] && continue
  print "| \`$base\` | $(describe "$base") |" >> "$MANIFEST"
done
ok "manifest.md"

# ──────────────────────────────────────────────────────────────────────────────
# PHASE 4 — SYNTHESIS HANDOFF (default) / OPTIONAL SPAWNED CLAUDE PASS (--analyze)
# ──────────────────────────────────────────────────────────────────────────────

# Build the synthesis prompt once and write it to ANALYZE.md, so the interactive
# handoff and the spawned --analyze pass use byte-for-byte the same instructions.
ANALYZE_PROMPT="You are reviewing the artifacts of an automated 'App Factory' build that
generated a Flutter mobile app. All artifacts are in this directory. Read them:
manifest.md, transcript.jsonl, analyze.txt, test.txt, file-tree.txt,
git-diffstat.txt, APP_SPEC.md, APPFACTORY_INPUTS.md, flutter-doctor.txt.

LAUNCH THREE SUBAGENTS IN PARALLEL using your Task tool — run all three at once,
do not run them sequentially. Each subagent reads files from this directory:

  (a) a 'code-quality' subagent → reads analyze.txt + test.txt + file-tree.txt →
      lists concrete lint, test, and architecture debt the generator left behind.
  (b) a 'process' subagent → reads transcript.jsonl → finds wasted turns,
      mis-ordered or repeated steps, and where the orchestrator stalled.
  (c) a 'fidelity' subagent → reads APP_SPEC.md + APPFACTORY_INPUTS.md +
      git-diffstat.txt + file-tree.txt → judges how faithfully the build matched
      the spec and what was missed.

When all three subagents return, synthesise their findings into a file named
LEARNINGS.md in this directory. LEARNINGS.md must contain a prioritized,
actionable list of improvements to the App Factory itself — specifically to
setup.zsh, mvp.md, and the agent/skill definitions. Lead with the highest-impact
fixes. Be concrete; cite the artifact that motivated each recommendation."

write_analyze_prompt() {
  print -r -- "$ANALYZE_PROMPT" > "$OUTDIR_ABS/ANALYZE.md"
  ok "ANALYZE.md (synthesis prompt for an interactive Claude session)"
}

run_spawned_analysis() {
  if ! command -v claude >/dev/null 2>&1; then
    warn "claude CLI not found — skipping spawned analysis (collection is complete)"
    return 0
  fi
  step "launching Claude with 3 parallel subagents (non-fatal)"
  local model_arg=()
  [[ -n "$MODEL" ]] && model_arg=(--model "$MODEL")
  if ( cd "$OUTDIR_ABS" && claude -p "$ANALYZE_PROMPT" --permission-mode acceptEdits "${model_arg[@]}" ); then
    ok "LEARNINGS.md written"
  else
    warn "Claude analysis failed (artifacts still intact). If it's a model-access error,"
    warn "re-run with a model you can use, e.g.: ./scripts/collect-run-data.zsh --analyze --model claude-opus-4-8"
    warn "(or run 'claude' then '/model' to set a default)."
  fi
}

handoff_to_current_session() {
  ok "Synthesis handed off to your current Claude session."
  step "In that session say:"
  step "  'Read the run data in $OUTDIR_ABS (start with manifest.md + ANALYZE.md) and write LEARNINGS.md.'"
  step "ANALYZE.md holds the full synthesis prompt (the 3-angle review)."
}

run_analysis() {
  section "04" "SYNTHESISING LEARNINGS"
  write_analyze_prompt
  if (( DO_ANALYZE )); then
    run_spawned_analysis
  else
    handoff_to_current_session
  fi
}
run_analysis

# ──────────────────────────────────────────────────────────────────────────────
# PHASE 5 — ARCHIVE + FINISH
# ──────────────────────────────────────────────────────────────────────────────
section "05" "ARCHIVING"

PARENT="${OUTDIR_ABS:h}"
RUN_BASE="${OUTDIR_ABS:t}"
TARBALL="${OUTDIR_ABS}.tar.gz"
if tar -czf "$TARBALL" -C "$PARENT" "$RUN_BASE" 2>/dev/null; then
  ok "archive → $TARBALL"
else
  warn "tar failed — the run dir is still available"
  TARBALL="(not created)"
fi

panel \
  "◢◤  RUN DATA COLLECTED  ◥◣" \
  "" \
  "dir:     $OUTDIR_ABS" \
  "tarball: $TARBALL" \
  "" \
  "⚠ skim for secrets before sharing — redaction is best-effort."
echo
