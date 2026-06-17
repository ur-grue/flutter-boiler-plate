import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_boilerplate/core/error/failure.dart';
import 'package:flutter_boilerplate/core/error/result.dart';
import 'package:flutter_boilerplate/core/utils/logger.dart';
import 'package:flutter_boilerplate/services/purchases/purchase_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Real RevenueCat-backed purchases. Only registered when
/// `AppConfig.useRealPurchases` is true (flag on + non-empty API key).
///
/// Configure your entitlement id and products in the RevenueCat dashboard.
class RevenueCatPurchaseService implements PurchaseService {
  RevenueCatPurchaseService(this._apiKey, {this.entitlementId = 'premium'});

  final String _apiKey;
  final String entitlementId;

  final _controller = StreamController<bool>.broadcast();
  bool _isPremium = false;

  @override
  Future<void> init() async {
    await Purchases.configure(PurchasesConfiguration(_apiKey));
    Purchases.addCustomerInfoUpdateListener(_onCustomerInfo);
    try {
      _onCustomerInfo(await Purchases.getCustomerInfo());
    } on PlatformException catch (e) {
      AppLogger.error('RevenueCat init failed', error: e, name: 'iap');
    }
  }

  void _onCustomerInfo(CustomerInfo info) {
    _isPremium = info.entitlements.active.containsKey(entitlementId);
    _controller.add(_isPremium);
  }

  @override
  Stream<bool> get isPremium => _controller.stream;

  @override
  bool get isPremiumNow => _isPremium;

  @override
  Future<Result<List<IapPackage>>> packages() async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null) return const Ok([]);
      return Ok([
        for (final p in current.availablePackages)
          IapPackage(
            id: p.identifier,
            title: p.storeProduct.title,
            priceString: p.storeProduct.priceString,
          ),
      ]);
    } on PlatformException catch (e) {
      return Err(ServerFailureFromPlatform(e).toFailure());
    }
  }

  @override
  Future<Result<bool>> purchase(IapPackage package) async {
    try {
      final offerings = await Purchases.getOfferings();
      Package? pkg;
      for (final p in offerings.current?.availablePackages ?? const []) {
        if (p.identifier == package.id) {
          pkg = p;
          break;
        }
      }
      if (pkg == null) return const Ok(false);
      await Purchases.purchasePackage(pkg);
      return Ok(_isPremium);
    } on PlatformException catch (e) {
      if (PurchasesErrorHelper.getErrorCode(e) ==
          PurchasesErrorCode.purchaseCancelledError) {
        return const Ok(false);
      }
      return Err(ServerFailureFromPlatform(e).toFailure());
    }
  }

  @override
  Future<Result<bool>> restore() async {
    try {
      _onCustomerInfo(await Purchases.restorePurchases());
      return Ok(_isPremium);
    } on PlatformException catch (e) {
      return Err(ServerFailureFromPlatform(e).toFailure());
    }
  }

  @override
  Future<void> dispose() async {
    await _controller.close();
  }
}

/// Small adapter so we don't leak PlatformException details to the UI.
class ServerFailureFromPlatform {
  const ServerFailureFromPlatform(this.exception);
  final PlatformException exception;

  Failure toFailure() =>
      ServerFailure(exception.message ?? 'Purchase failed.');
}
