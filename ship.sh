#!/usr/bin/env zsh
# Run AFTER you tested & approved the MVP. Resumes the same Claude session.
set -e -u -o pipefail
RESUME=""
[[ -f .appfactory_session ]] && RESUME="--resume $(cat .appfactory_session)"
print -P "%F{cyan}▸ Pre-flight + release build…%f"
claude -p "/release" --permission-mode acceptEdits ${=RESUME} || true
print -P "%F{green}✓ Build done. Finish store steps in App Store Connect / Play Console (see /release output).%f"
