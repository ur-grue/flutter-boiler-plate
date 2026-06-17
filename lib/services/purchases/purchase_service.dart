import 'package:equatable/equatable.dart';
import 'package:flutter_boilerplate/core/error/result.dart';

/// A purchasable subscription/product.
class IapPackage extends Equatable {
  const IapPackage({
    required this.id,
    required this.title,
    required this.priceString,
  });

  final String id;
  final String title;
  final String priceString;

  @override
  List<Object?> get props => [id, title, priceString];
}

/// Subscription/IAP abstraction. The keyless default ([MockPurchaseService])
/// simulates a premium toggle so the paywall is fully testable offline.
abstract interface class PurchaseService {
  Future<void> init();

  /// Emits the current premium entitlement and every change.
  Stream<bool> get isPremium;

  /// Latest known premium value (for synchronous reads).
  bool get isPremiumNow;

  Future<Result<List<IapPackage>>> packages();

  Future<Result<bool>> purchase(IapPackage package);

  Future<Result<bool>> restore();

  Future<void> dispose();
}
