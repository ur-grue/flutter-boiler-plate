# /aso — store metadata, backed by REAL live data (never invented from memory)

Two engines, separate lanes:
- **Live data → `mcp-appstore` MCP tools** (keyless; scrapes the real App Store + Play Store).
- **Method/routing → `aso-skills`** via `aso-router`, which dispatches to: `keyword-research`,
  `metadata-optimization`, `competitor-analysis`, `android-aso` (Play Store specifics — we ship
  Android too), `seasonal-aso` (timing), `screenshot-optimization`, `localization` (de/es/ar
  store metadata, matching the app's locales), `category-positioning`.
- **Copy/voice → `marketing-skills`** only — never for the keyword data itself.

## Get the data FIRST (mcp-appstore tools) — do not skip this
1. `search_app` + `get_similar_apps` → identify the 5–8 real competitors for this niche.
2. `get_app_details` + `get_pricing_details` on each → positioning + monetization (real).
3. `analyze_top_keywords` + `suggest_keywords_by_competition` / `_by_search` / `_by_similarity`
   → candidate keywords drawn from live listings, not memory.
4. `get_keyword_scores` on the candidates → real **difficulty + traffic** to pick the winners.
5. (Optional) `analyze_reviews` on top competitors → unmet-need gaps to target in copy.

If `mcp-appstore` is unavailable: use `APPEEKY_API_KEY` (aso-skills live mode) if set; else fall
back to `WebSearch` of real competitor listings and **mark the output LOW-CONFIDENCE (no live
data)**. Never fabricate keyword volumes/difficulty from training knowledge.

## Output (every keyword tagged with its source: tool + competitor/term)
1. **Competitor gap table** — competitors, their primary keywords, the gaps we can own.
2. **Tiered keyword list** — high-traffic / mid / long-tail, each with its `get_keyword_scores`
   difficulty + traffic and source tag.
3. **Copy-paste metadata** — iOS (name 30 / subtitle 30 / keywords 100) and Google Play
   (title 30 / short 80 / long 4000), localized `de` / `es` / `ar`.
4. **Screenshot captions** (OCR-indexed) to build in Claude Design.
