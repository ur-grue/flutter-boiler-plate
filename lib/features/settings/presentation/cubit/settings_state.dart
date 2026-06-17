import 'package:equatable/equatable.dart';
import 'package:flutter_boilerplate/features/settings/domain/app_settings.dart';

sealed class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

final class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

final class SettingsReady extends SettingsState {
  const SettingsReady(this.settings);
  final AppSettings settings;

  @override
  List<Object?> get props => [settings];
}
