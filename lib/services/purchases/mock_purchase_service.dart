import 'dart:async';

import 'package:flutter_boilerplate/core/error/result.dart';
import 'package:flutter_boilerplate/services/purchases/purchase_service.dart';

/// Default purchases impl: an in-memory premium toggle. Lets you build and test
/// the paywall + premium gating without a RevenueCat account.
class MockPurchaseService implements PurchaseService {
  final _controller = StreamController<bool>.broadcast();
  bool _isPremium = false;

  static const _packages = [
    IapPackage(id: 'monthly', title: 'Monthly', priceString: r'$4.99'),
    IapPackage(id: 'annual', title: 'Annual', priceString: r'$39.99'),
  ];

  @override
  Future<void> init() async {
    _controller.add(_isPremium);
  }

  @override
  Stream<bool> get isPremium => _controller.stream;

  @override
  bool get isPremiumNow => _isPremium;

  @override
  Future<Result<List<IapPackage>>> packages() async => const Ok(_packages);

  @override
  Future<Result<bool>> purchase(IapPackage package) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _setPremium(true);
    return const Ok(true);
  }

  @override
  Future<Result<bool>> restore() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _controller.add(_isPremium);
    return Ok(_isPremium);
  }

  void _setPremium(bool value) {
    _isPremium = value;
    _controller.add(value);
  }

  @override
  Future<void> dispose() async => _controller.close();
}
