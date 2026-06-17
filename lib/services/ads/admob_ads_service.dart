import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_boilerplate/core/utils/logger.dart';
import 'package:flutter_boilerplate/services/ads/ad_ids.dart';
import 'package:flutter_boilerplate/services/ads/ads_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Real AdMob-backed ads. Only registered when `AppConfig.useRealAds` is true.
///
/// Requires the AdMob app id in AndroidManifest.xml / Info.plist — see
/// `docs/SECURITY.md`. Until then keep ads disabled (the default).
class AdMobAdsService implements AdsService {
  AdMobAdsService();

  bool _ready = false;
  InterstitialAd? _interstitial;

  @override
  Future<void> init() async {
    await MobileAds.instance.initialize();
    _ready = true;
    unawaited(_preloadInterstitial());
  }

  @override
  bool get isAvailable => _ready;

  Future<void> _preloadInterstitial() async {
    await InterstitialAd.load(
      adUnitId: AdIds.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (e) {
          AppLogger.error('Interstitial failed to load', error: e, name: 'ads');
          _interstitial = null;
        },
      ),
    );
  }

  @override
  Future<bool> showInterstitial() async {
    final ad = _interstitial;
    if (ad == null) return false;
    _interstitial = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        unawaited(_preloadInterstitial());
      },
    );
    await ad.show();
    return true;
  }

  @override
  BannerAdHandle? createBanner() {
    if (!_ready) return null;
    return _AdMobBanner();
  }
}

class _AdMobBanner implements BannerAdHandle {
  _AdMobBanner() {
    _ad = BannerAd(
      adUnitId: AdIds.banner,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, e) {
          AppLogger.error('Banner failed to load', error: e, name: 'ads');
          ad.dispose();
        },
      ),
    )..load();
  }

  late final BannerAd _ad;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _ad.size.width.toDouble(),
      height: _ad.size.height.toDouble(),
      child: AdWidget(ad: _ad),
    );
  }

  @override
  void dispose() => _ad.dispose();
}
