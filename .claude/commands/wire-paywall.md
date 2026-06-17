# /wire-paywall — RevenueCat (entitlement "premium")
PURCHASES_ENABLED is already true. Gate premium features by the "premium"
entitlement (check entitlement, never product IDs). Show the paywall via
RevenueCatUI.presentPaywallIfNeeded("premium") after onboarding. Add Restore.
Manual reminder: create products + the "premium" entitlement in App Store
Connect, Play Console, and the RevenueCat dashboard.
