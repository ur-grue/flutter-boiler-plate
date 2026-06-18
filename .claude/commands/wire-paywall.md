# /wire-paywall — RevenueCat (entitlement "premium")

Design the money model with the **aso-skills** Revenue cluster FIRST, then implement:
- `monetization-strategy` → pricing model, tiers, trial length, free vs. premium split.
- `paywall-optimization` → paywall placement, the 7-element audit, value framing.
- `subscription-lifecycle` → trial→paid, renewal, churn/win-back messaging.
- `rating-prompt-strategy` → when to ask for a review (after a value moment, not on launch).
Ground pricing in real comps from `mcp-appstore` `get_pricing_details` on competitors — don't
pull price points from memory.

Implementation: PURCHASES_ENABLED is already true. Gate premium features by the "premium"
entitlement (check entitlement, never product IDs). Show the paywall via
`RevenueCatUI.presentPaywallIfNeeded("premium")` after onboarding. Add Restore.
Manual reminder: create products + the "premium" entitlement in App Store Connect,
Play Console, and the RevenueCat dashboard.
