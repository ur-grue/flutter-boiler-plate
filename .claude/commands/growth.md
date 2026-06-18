# /growth — post-launch growth, analytics & UA (run AFTER the app is live)

These aso-skills need a **published app** and **real data/budget**, so they are NOT part of
`/mvp` (build time). Use this once the app is in the stores. State which goal you're after and
route through `aso-router` to the right skill(s):

**Launch & UA:** `app-launch`, `apple-search-ads`, `ua-campaign`, `press-and-pr`,
`creator-ugc-marketing`, `referral-program`, `web-to-app-funnel`, `app-store-featured`.

**Store experiments & creative:** `ab-test-store-listing`, `custom-product-pages`,
`app-preview-video`, `review-management`, `in-app-events`, `app-clips`.

**Analytics & attribution:** `app-analytics`, `attribution-setup`, `asc-metrics`,
`crash-analytics`.

**Retention & revenue (ongoing):** `retention-optimization`, `subscription-lifecycle`,
`rating-prompt-strategy`, `onboarding-optimization`, `seasonal-aso`.

**Market tracking:** `market-pulse`, `market-movers`, `competitor-tracking` — pair with
`mcp-appstore` (`get_keyword_scores`, `analyze_top_keywords`, `get_similar_apps`) for live data.

Pull every number from `mcp-appstore` or your real analytics — never from model memory.
