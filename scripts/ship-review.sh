#!/usr/bin/env bash
#
# Ship-review: render EVERYTHING you'd otherwise open files to read — app icon, framed
# screenshots, store metadata per locale, and the market research — onto ONE local HTML page
# you open in the browser. No server, no copying: review it, then `./ship.sh` uploads.
#
#   bash scripts/ship-review.sh        # writes build/ship/index.html and opens it
#
# Reads the same files fastlane uploads, so the page IS the upload preview:
#   fastlane/metadata/{ios,android}/<locale>/*.txt   ·   fastlane/screenshots/<locale>/*.png
#   assets/icon/app_icon.png   ·   MARKET.md / APP_SPEC.md
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"; cd "$ROOT"

OUT="build/ship"; mkdir -p "$OUT"; HTML="$OUT/index.html"
esc() { sed -e 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'; }   # minimal HTML-escape for file text
rel() { printf '../../%s' "$1"; }                            # path relative to build/ship/

{
  cat <<'HEAD'
<!doctype html><html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Ship Review</title>
<style>
  :root { color-scheme: light dark; }
  body { font: 15px/1.5 -apple-system, system-ui, sans-serif; margin: 0; padding: 2rem; max-width: 1100px; margin-inline: auto; }
  h1 { margin: 0 0 .25rem; } h2 { margin-top: 2.5rem; border-bottom: 1px solid #8884; padding-bottom: .3rem; }
  .muted { opacity: .65; } .row { display: flex; gap: 1.5rem; flex-wrap: wrap; align-items: flex-start; }
  .icon { width: 96px; height: 96px; border-radius: 22px; box-shadow: 0 2px 12px #0003; }
  .shots img { height: 360px; border-radius: 12px; box-shadow: 0 2px 12px #0003; margin: .25rem; }
  .field { margin: .4rem 0; } .field b { display: inline-block; min-width: 130px; }
  pre { white-space: pre-wrap; background: #8881; padding: 1rem; border-radius: 10px; }
  .card { border: 1px solid #8884; border-radius: 12px; padding: 1rem 1.25rem; margin: .75rem 0; }
  button { font: inherit; padding: .2rem .6rem; border-radius: 8px; border: 1px solid #8886; cursor: pointer; background: transparent; }
  .warn { color: #c60; }
</style></head><body>
<h1>Ship Review</h1>
<p class="muted">Everything that goes to the stores, rendered. Review here, then run <code>./ship.sh</code>.
Nothing here is uploaded automatically.</p>
HEAD

  # App icon
  echo '<h2>App icon</h2><div class="row">'
  if [[ -f assets/icon/app_icon.png ]]; then
    printf '<img class="icon" src="%s" alt="app icon"><div class="muted">assets/icon/app_icon.png<br>(replace the placeholder via /theme)</div>' "$(rel assets/icon/app_icon.png)"
  else
    echo '<p class="warn">No assets/icon/app_icon.png yet — /theme generates it.</p>'
  fi
  echo '</div>'

  # Metadata per platform/locale
  echo '<h2>Store metadata</h2>'
  if compgen -G "fastlane/metadata/*/*" >/dev/null 2>&1; then
    for plat in ios android; do
      base="fastlane/metadata/$plat"; [[ -d "$base" ]] || continue
      echo "<h3>${plat}</h3>"
      for locdir in "$base"/*/; do
        [[ -d "$locdir" ]] || continue
        echo "<div class=\"card\"><b>$(basename "$locdir")</b>"
        for f in "$locdir"*.txt; do
          [[ -f "$f" ]] || continue
          val="$(cat "$f" | esc)"
          printf '<div class="field"><b>%s</b> <button onclick="navigator.clipboard.writeText(this.nextElementSibling.textContent)">copy</button> <span>%s</span></div>' "$(basename "$f" .txt)" "$val"
        done
        echo '</div>'
      done
    done
  else
    echo '<p class="warn">No fastlane/metadata yet — /aso writes it (name/subtitle/keywords/description per locale).</p>'
  fi

  # Screenshots per locale
  echo '<h2>Screenshots</h2>'
  if compgen -G "fastlane/screenshots/*/*.png" >/dev/null 2>&1; then
    for locdir in fastlane/screenshots/*/; do
      [[ -d "$locdir" ]] || continue
      echo "<h3>$(basename "$locdir")</h3><div class=\"shots\">"
      for img in "$locdir"*.png; do [[ -f "$img" ]] && printf '<img src="%s" alt="">' "$(rel "$img")"; done
      echo '</div>'
    done
  else
    echo '<p class="warn">No fastlane/screenshots yet — bash scripts/screenshots.sh generates them.</p>'
  fi

  # Research
  echo '<h2>Market research (MARKET.md)</h2>'
  if [[ -f MARKET.md ]]; then echo '<pre>'; cat MARKET.md | esc; echo '</pre>'
  else echo '<p class="warn">No MARKET.md yet — /market writes it.</p>'; fi

  echo '</body></html>'
} > "$HTML"

echo "▸ wrote $HTML"
command -v open >/dev/null 2>&1 && open "$HTML" >/dev/null 2>&1 || echo "  open it: $HTML"
