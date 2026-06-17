import 'package:flutter/widgets.dart';

/// Opaque handle to a created banner ad, rendered by `BannerAdView`.
abstract interface class BannerAdHandle {
  Widget build(BuildContext context);
  void dispose();
}

/// Cross-cutting ads abstraction. The keyless default ([NoOpAdsService]) makes
/// every method a safe no-op so the app runs without an AdMob account.
abstract interface class AdsService {
  Future<void> init();

  /// `false` for the no-op impl; UI hides ad surfaces accordingly.
  bool get isAvailable;

  /// Returns `false` when no ad was shown (e.g. ads disabled).
  Future<bool> showInterstitial();

  /// `null` when ads are unavailable, so `BannerAdView` collapses to nothing.
  BannerAdHandle? createBanner();
}
