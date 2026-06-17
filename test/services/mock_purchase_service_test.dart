import 'package:flutter_boilerplate/services/purchases/mock_purchase_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockPurchaseService service;

  setUp(() => service = MockPurchaseService());
  tearDown(() => service.dispose());

  test('starts not premium', () {
    expect(service.isPremiumNow, isFalse);
  });

  test('purchase flips premium and emits true', () async {
    final emissions = <bool>[];
    final sub = service.isPremium.listen(emissions.add);

    final packages = (await service.packages()).valueOrNull!;
    final result = await service.purchase(packages.first);

    expect(result.valueOrNull, isTrue);
    expect(service.isPremiumNow, isTrue);
    expect(emissions, contains(true));

    await sub.cancel();
  });
}
