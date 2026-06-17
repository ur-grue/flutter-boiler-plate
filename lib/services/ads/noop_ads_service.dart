import 'package:flutter_boilerplate/services/ads/ads_service.dart';

/// Default ads impl: does nothing. Used unless `AppConfig.useRealAds` is true,
/// so the template never touches native AdMob without explicit opt-in.
class NoOpAdsService implements AdsService {
  const NoOpAdsService();

  @override
  Future<void> init() async {}

  @override
  bool get isAvailable => false;

  @override
  Future<bool> showInterstitial() async => false;

  @override
  BannerAdHandle? createBanner() => null;
}
