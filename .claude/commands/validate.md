# /validate — go/no-go for an idea
Validate this idea: $ARGUMENTS
1. LIVE competitor + demand data via `mcp-appstore` tools: `search_app` / `get_similar_apps`
   (top 5 competitors), `get_pricing_details` (monetization), `get_keyword_scores` +
   `suggest_keywords_by_competition` (demand + gaps). If unavailable: `APPEEKY_API_KEY` else
   `WebSearch` real listings — never from memory.
2. Use `aso-skills` (`aso-router`) to interpret that data into keyword demand + gaps.
3. Output: target user, problem statement (vetted format), monetization angle,
   differentiation vs competitors (Apple 4.3 check), complexity.
End with GO or NO-GO + one-line reason.
