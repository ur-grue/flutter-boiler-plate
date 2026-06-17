import 'dart:io';

/// Ad unit ids. Defaults are Google's official **test** unit ids so you can
/// develop safely. Replace with your real unit ids (ideally via remote config)
/// before shipping — see `docs/SECURITY.md`.
abstract final class AdIds {
  static String get banner => Platform.isIOS
      ? 'ca-app-pub-3940256099942544/2934735716'
      : 'ca-app-pub-3940256099942544/6300978111';

  static String get interstitial => Platform.isIOS
      ? 'ca-app-pub-3940256099942544/4411468910'
      : 'ca-app-pub-3940256099942544/1033173712';
}
