import 'package:flutter/services.dart';

/// Haptic feedback helpers gated by the user's settings flag.
///
/// Pass the current `hapticsEnabled` value (from `SettingsCubit`) so feedback
/// is suppressed when the user turns it off.
abstract final class Haptics {
  static Future<void> selection({required bool enabled}) async {
    if (!enabled) return;
    await HapticFeedback.selectionClick();
  }

  static Future<void> light({required bool enabled}) async {
    if (!enabled) return;
    await HapticFeedback.lightImpact();
  }

  static Future<void> medium({required bool enabled}) async {
    if (!enabled) return;
    await HapticFeedback.mediumImpact();
  }
}
