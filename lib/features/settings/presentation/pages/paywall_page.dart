import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_spacing.dart';
import 'package:flutter_boilerplate/core/widgets/app_button.dart';
import 'package:flutter_boilerplate/features/settings/presentation/cubit/subscription_cubit.dart';
import 'package:flutter_boilerplate/services/purchases/purchase_service.dart';

class PaywallPage extends StatefulWidget {
  const PaywallPage({super.key});

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  late Future<List<IapPackage>> _packages;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _packages = context.read<SubscriptionCubit>().packages();
  }

  Future<void> _purchase(IapPackage package) async {
    setState(() => _busy = true);
    await context.read<SubscriptionCubit>().purchase(package);
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _restore() async {
    setState(() => _busy = true);
    await context.read<SubscriptionCubit>().restore();
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isPremium = context.watch<SubscriptionCubit>().state;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.paywallTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.workspace_premium, size: 72),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.paywallSubtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              if (isPremium)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: AppSpacing.sm),
                        Text(l10n.premiumActive),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: FutureBuilder<List<IapPackage>>(
                    future: _packages,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final packages = snapshot.data!;
                      return ListView.separated(
                        itemCount: packages.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, i) {
                          final pkg = packages[i];
                          return Card(
                            child: ListTile(
                              title: Text(pkg.title),
                              trailing: Text(pkg.priceString),
                              onTap: _busy ? null : () => _purchase(pkg),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              if (!isPremium)
                AppButton(
                  label: l10n.paywallRestore,
                  isLoading: _busy,
                  onPressed: _restore,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
