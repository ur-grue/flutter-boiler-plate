# /aso — store metadata, backed by REAL live data (never invented from memory)

Two engines, separate lanes:
- **Live data → `mcp-appstore` MCP tools** (keyless; scrapes the real App Store + Play Store).
- **Method/routing → `aso-skills`** via `aso-router`, which dispatches to: `keyword-research`,
  `metadata-optimization`, `competitor-analysis`, `android-aso` (Play Store specifics — we ship
  Android too), `seasonal-aso` (timing), `screenshot-optimization`, `localization` (de/es/ar
  store metadata, matching the app's locales), `category-positioning`.
- **Copy/voice → `marketing-skills`** only — never for the keyword data itself.

## REUSE MARKET.md first (don't re-fetch)
If MARKET.md exists (written by /market), it already holds the competitor table (§1), the tiered
keyword set with difficulty/traffic (§4), and pricing (§5). **Use it** — your job here is to turn
that research into store-ready metadata + localized copy. Only run the live-fetch path below if
MARKET.md is absent, marked OFFLINE/PARTIAL, or older than this build session.

## Live-fetch path (only when MARKET.md can't be reused) — mcp-appstore tools
1. `search_app` + `get_similar_apps` → identify the 5–8 real competitors for this niche.
2. `get_app_details` + `get_pricing_details` on each → positioning + monetization (real).
3. `analyze_top_keywords` + `suggest_keywords_by_competition` / `_by_search` / `_by_similarity`
   → candidate keywords drawn from live listings, not memory.
4. `get_keyword_scores` on the candidates → real **difficulty + traffic** to pick the winners.
5. (Optional) `analyze_reviews` on top competitors → unmet-need gaps to target in copy.

If the **Appeeky** MCP server is registered (author set `APPEEKY_API_KEY`), use its first-party
data too and cross-check it against `mcp-appstore`. If neither is available, fall back to
`WebSearch` of real competitor listings and **mark the output LOW-CONFIDENCE (no live data)**.
Never fabricate keyword volumes/difficulty from training knowledge.

## Output (every keyword tagged with its source: tool + competitor/term)
1. **Competitor gap table** — competitors, their primary keywords, the gaps we can own.
2. **Tiered keyword list** — high-traffic / mid / long-tail, each with its `get_keyword_scores`
   difficulty + traffic and source tag.
3. **Copy-paste metadata** — iOS (name 30 / subtitle 30 / keywords 100) and Google Play
   (title 30 / short 80 / long 4000), localized `de` / `es` / `ar`.
4. **Screenshot set** — use `screenshot-optimization` + the competitor screenshot analysis from
   MARKET.md §2 (their hook + palette): design our sequence so **screenshot 1 leads with a stronger
   hook** than the competitors, in our theme palette. Output OCR-indexed captions (keyword-aware)
   to build in Claude Design.
