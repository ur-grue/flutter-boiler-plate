import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:flutter_boilerplate/core/theme/app_seed_colors.dart';
import 'package:flutter_boilerplate/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_boilerplate/features/settings/domain/app_settings.dart';
import 'package:flutter_boilerplate/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter_boilerplate/features/settings/presentation/cubit/settings_state.dart';
import 'package:flutter_boilerplate/features/settings/presentation/cubit/subscription_cubit.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const _locales = <Locale?>[
    null,
    Locale('en'),
    Locale('de'),
    Locale('es'),
    Locale('ar')
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          if (state is! SettingsReady) {
            return const Center(child: CircularProgressIndicator());
          }
          final settings = state.settings;
          final cubit = context.read<SettingsCubit>();

          return ListView(
            children: [
              _SectionHeader(l10n.settingsAppearance),
              ListTile(
                leading: const Icon(Icons.brightness_6_outlined),
                title: Text(l10n.settingsThemeMode),
                trailing: DropdownButton<ThemeMode>(
                  value: settings.themeMode,
                  underline: const SizedBox.shrink(),
                  onChanged: (m) => m == null ? null : cubit.setThemeMode(m),
                  items: [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text(l10n.themeSystem),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text(l10n.themeLight),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text(l10n.themeDark),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: Text(l10n.settingsSeedColor),
                subtitle: _SeedColorPicker(
                  selected: settings.seedColor,
                  onSelected: cubit.setSeedColor,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.language_outlined),
                title: Text(l10n.settingsLanguage),
                trailing: DropdownButton<Locale?>(
                  value: settings.locale,
                  underline: const SizedBox.shrink(),
                  onChanged: cubit.setLocale,
                  items: [
                    for (final locale in _locales)
                      DropdownMenuItem(
                        value: locale,
                        child: Text(
                          locale?.languageCode.toUpperCase() ??
                              l10n.languageSystem,
                        ),
                      ),
                  ],
                ),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.vibration_outlined),
                title: Text(l10n.settingsHaptics),
                value: settings.hapticsEnabled,
                onChanged: (v) => cubit.setHaptics(enabled: v),
              ),
              const Divider(),
              _SectionHeader(l10n.settingsPremium),
              BlocBuilder<SubscriptionCubit, bool>(
                builder: (context, isPremium) {
                  return ListTile(
                    leading: const Icon(Icons.workspace_premium_outlined),
                    title: Text(l10n.settingsPremium),
                    subtitle: Text(
                      isPremium ? l10n.premiumActive : l10n.premiumInactive,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.pushNamed(Routes.paywall),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: Text(l10n.settingsNotifications),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.pushNamed(Routes.notifications),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text(l10n.signOut),
                onTap: () => context.read<AuthCubit>().signOut(),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 1,
            ),
      ),
    );
  }
}

class _SeedColorPicker extends StatelessWidget {
  const _SeedColorPicker({required this.selected, required this.onSelected});

  final Color selected;
  final ValueChanged<Color> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 12,
        children: [
          for (final color in AppSeedColors.all)
            GestureDetector(
              onTap: () => onSelected(color),
              child: CircleAvatar(
                backgroundColor: color,
                radius: 16,
                child: color == selected
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}
