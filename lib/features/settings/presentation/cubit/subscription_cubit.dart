import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_boilerplate/services/purchases/purchase_service.dart';

/// Global premium-entitlement state, sourced from [PurchaseService]. Consumed
/// by the paywall, settings, and ad gating (premium users see no ads).
class SubscriptionCubit extends Cubit<bool> {
  SubscriptionCubit(this._purchases) : super(_purchases.isPremiumNow) {
    _sub = _purchases.isPremium.listen(emit);
  }

  final PurchaseService _purchases;
  late final StreamSubscription<bool> _sub;

  Future<bool> purchase(IapPackage package) async {
    final result = await _purchases.purchase(package);
    return result.fold((ok) => ok, (_) => false);
  }

  Future<bool> restore() async {
    final result = await _purchases.restore();
    return result.fold((ok) => ok, (_) => false);
  }

  Future<List<IapPackage>> packages() async {
    final result = await _purchases.packages();
    return result.fold((list) => list, (_) => const []);
  }

  @override
  Future<void> close() async {
    await _sub.cancel();
    return super.close();
  }
}
