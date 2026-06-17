import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/services/ads/ads_service.dart';

/// Renders a banner from [AdsService], or nothing when ads are unavailable
/// (no-op impl) or the user is premium ([show] == false).
class BannerAdView extends StatefulWidget {
  const BannerAdView({required this.adsService, this.show = true, super.key});

  final AdsService adsService;
  final bool show;

  @override
  State<BannerAdView> createState() => _BannerAdViewState();
}

class _BannerAdViewState extends State<BannerAdView> {
  BannerAdHandle? _handle;

  @override
  void initState() {
    super.initState();
    if (widget.show) _handle = widget.adsService.createBanner();
  }

  @override
  void dispose() {
    _handle?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final handle = _handle;
    if (!widget.show || handle == null) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.bottomCenter,
      child: handle.build(context),
    );
  }
}
