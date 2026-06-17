import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/theme/app_seed_colors.dart';

/// User-configurable app preferences.
class AppSettings extends Equatable {
  const AppSettings({
    required this.themeMode,
    required this.locale,
    required this.seedColor,
    required this.hapticsEnabled,
  });

  /// Sensible defaults used before anything is persisted.
  static const fallback = AppSettings(
    themeMode: ThemeMode.system,
    locale: null,
    seedColor: AppSeedColors.defaultSeed,
    hapticsEnabled: true,
  );

  final ThemeMode themeMode;

  /// `null` means "follow the system locale".
  final Locale? locale;
  final Color seedColor;
  final bool hapticsEnabled;

  AppSettings copyWith({
    ThemeMode? themeMode,
    Locale? Function()? locale,
    Color? seedColor,
    bool? hapticsEnabled,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale != null ? locale() : this.locale,
      seedColor: seedColor ?? this.seedColor,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    );
  }

  @override
  List<Object?> get props => [themeMode, locale, seedColor, hapticsEnabled];
}
