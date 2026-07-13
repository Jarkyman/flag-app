import 'package:flag_app/controllers/shop_controller.dart';
import 'package:flag_app/helper/app_constants.dart';
import 'package:flag_app/repos/shop_repo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads direct Android products as non-subscriptions', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    List<String>? requestedIdentifiers;
    ProductCategory? requestedCategory;
    final controller = ShopController(
      shopRepo: ShopRepo(sharedPreferences: preferences),
      productsLoader: (
        identifiers, {
        required productCategory,
      }) async {
        requestedIdentifiers = identifiers;
        requestedCategory = productCategory;
        return const [];
      },
    );

    final products = await controller.getProducts;

    expect(products, isEmpty);
    expect(requestedCategory, ProductCategory.nonSubscription);
    expect(requestedIdentifiers, [
      AppConstants.TEN_HINTS_ID,
      AppConstants.TWENTYFIVE_HINTS_ID,
      AppConstants.SIXTY_HINTS_ID,
      AppConstants.REMOVE_ADS_ID,
      AppConstants.UNLOCK_LEVELS_ID,
    ]);
  });

  for (final testCase in [
    (
      name: 'nothing',
      removeAds: false,
      unlockLevels: false,
      expected: <RestoredPurchase>{},
    ),
    (
      name: 'remove ads',
      removeAds: true,
      unlockLevels: false,
      expected: {RestoredPurchase.removeAds},
    ),
    (
      name: 'all levels',
      removeAds: false,
      unlockLevels: true,
      expected: {RestoredPurchase.unlockLevels},
    ),
    (
      name: 'both permanent purchases',
      removeAds: true,
      unlockLevels: true,
      expected: {
        RestoredPurchase.removeAds,
        RestoredPurchase.unlockLevels,
      },
    ),
  ]) {
    test('restores ${testCase.name} and persists the resulting access',
        () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.ADS_REMOVE: !testCase.removeAds,
        AppConstants.UNLOCK_LEVELS: !testCase.unlockLevels,
      });
      final preferences = await SharedPreferences.getInstance();
      final controller = ShopController(
        shopRepo: ShopRepo(sharedPreferences: preferences),
        purchasesRestorer: () async => _customerInfo(
          removeAds: testCase.removeAds,
          unlockLevels: testCase.unlockLevels,
        ),
      );
      await controller.removeAdsRead();
      await controller.levelsUnlockRead();

      final restored = await controller.restorePurchases();

      expect(restored, unorderedEquals(testCase.expected));
      expect(controller.isAdsRemoved, testCase.removeAds);
      expect(controller.isLevelsUnlocked, testCase.unlockLevels);
      expect(
        preferences.getBool(AppConstants.ADS_REMOVE),
        testCase.removeAds,
      );
      expect(
        preferences.getBool(AppConstants.UNLOCK_LEVELS),
        testCase.unlockLevels,
      );
    });
  }
}

CustomerInfo _customerInfo({
  required bool removeAds,
  required bool unlockLevels,
}) {
  final entitlements = <String, EntitlementInfo>{
    if (removeAds)
      AppConstants.REMOVE_ADS_ID_ENT: _entitlement(
        identifier: AppConstants.REMOVE_ADS_ID_ENT,
        productIdentifier: AppConstants.REMOVE_ADS_ID,
      ),
    if (unlockLevels)
      AppConstants.UNLOCK_LEVELS_ID_ENT: _entitlement(
        identifier: AppConstants.UNLOCK_LEVELS_ID_ENT,
        productIdentifier: AppConstants.UNLOCK_LEVELS_ID,
      ),
  };

  return CustomerInfo(
    EntitlementInfos(entitlements, entitlements),
    const {},
    const [],
    const [],
    const [],
    '2026-07-14T00:00:00Z',
    r'$RCAnonymousID:test',
    const {},
    '2026-07-14T00:00:00Z',
  );
}

EntitlementInfo _entitlement({
  required String identifier,
  required String productIdentifier,
}) {
  return EntitlementInfo(
    identifier,
    true,
    false,
    '2026-07-14T00:00:00Z',
    '2026-07-14T00:00:00Z',
    productIdentifier,
    true,
  );
}
