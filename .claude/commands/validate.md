# /validate — go/no-go for an idea (thin wrapper over /market)
Validate this idea: $ARGUMENTS

1. Run the **/market** research routine on this idea (same engines: `mcp-appstore` live data +
   `aso-skills` via `aso-router`). If MARKET.md already exists and is fresh (DATA MODE LIVE, recent),
   READ it instead of re-fetching; if invoked standalone (not inside /mvp) you MAY write MARKET.md
   so a follow-on /mvp reuses it.
2. On top of that research, judge: target user, problem statement (vetted format), monetization
   angle, differentiation vs competitors (Apple 4.3 check), complexity.

End with **GO** or **NO-GO** + one-line reason. (The verdict is ephemeral — the research lives in
MARKET.md.)
