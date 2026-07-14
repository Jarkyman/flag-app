import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:flag_app/helper/app_constants.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../helper/app_runtime.dart';
import '../repos/shop_repo.dart';

typedef StoreProductsLoader = Future<List<StoreProduct>> Function(
  List<String> productIdentifiers, {
  required ProductCategory productCategory,
});

typedef PurchasesRestorer = Future<CustomerInfo> Function();

enum RestoredPurchase {
  removeAds,
  unlockLevels,
}

class ShopController extends GetxController implements GetxService {
  final ShopRepo shopRepo;
  final StoreProductsLoader productsLoader;
  final PurchasesRestorer purchasesRestorer;

  ShopController({
    required this.shopRepo,
    StoreProductsLoader? productsLoader,
    PurchasesRestorer? purchasesRestorer,
  })  : productsLoader = productsLoader ??
            ((productIdentifiers, {required productCategory}) =>
                Purchases.getProducts(
                  productIdentifiers,
                  productCategory: productCategory,
                )),
        purchasesRestorer = purchasesRestorer ?? Purchases.restorePurchases;

  bool _levelsUnlocked = false;

  bool get isLevelsUnlocked => _levelsUnlocked;

  bool _adsRemoved = false;

  bool get isAdsRemoved => _adsRemoved;

  final List<String> _productsIds = [
    AppConstants.TEN_HINTS_ID,
    AppConstants.TWENTYFIVE_HINTS_ID,
    AppConstants.SIXTY_HINTS_ID,
    AppConstants.REMOVE_ADS_ID,
    AppConstants.UNLOCK_LEVELS_ID,
  ];

  List<StoreProduct> _products = [];

  Future<List<StoreProduct>> get getProducts async {
    if (!AppRuntime.externalServicesEnabled) return const [];
    _products = await _loadProducts();
    return _products;
  }

  Future<List<StoreProduct>> _loadProducts() {
    return productsLoader(
      _productsIds,
      productCategory: ProductCategory.nonSubscription,
    );
  }

  Future<void> loadShopSettings() async {
    if (!AppRuntime.externalServicesEnabled) {
      await Future.wait([
        levelsUnlockRead(),
        removeAdsRead(),
      ]);
      _products = [];
      update();
      return;
    }

    await initPlatformState();
    await Future.wait([
      levelsUnlockRead(),
      removeAdsRead(),
    ]);
    Purchases.addCustomerInfoUpdateListener(
      (_) => updateCustomerStatus(),
    );
    try {
      _products = await _loadProducts();
    } catch (e) {
      debugPrint(e.toString());
      _products = [];
    }

    debugPrint(_products.toString());
    update();
  }

  Future<void> initPlatformState() async {
    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration? configuration;
    if (Platform.isAndroid) {
      configuration =
          PurchasesConfiguration("goog_aFvMfMgfGuwqMGeaReDwwGbqbTE");
    } else if (Platform.isIOS) {
      configuration =
          PurchasesConfiguration("appl_eEHKYOTQjTUkCIilqUeqEzETXQj");
    }
    await Purchases.configure(configuration!);
  }

  Future updateCustomerStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      await _savePermanentPurchases(_activePermanentPurchases(customerInfo));
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<Set<RestoredPurchase>> restorePurchases() async {
    if (!AppRuntime.externalServicesEnabled) return {};
    final customerInfo = await purchasesRestorer();
    final restoredPurchases = _activePermanentPurchases(customerInfo);
    await _savePermanentPurchases(restoredPurchases);
    return restoredPurchases;
  }

  Set<RestoredPurchase> _activePermanentPurchases(
    CustomerInfo customerInfo,
  ) {
    final restoredPurchases = <RestoredPurchase>{};

    if (customerInfo
            .entitlements.all[AppConstants.REMOVE_ADS_ID_ENT]?.isActive ==
        true) {
      restoredPurchases.add(RestoredPurchase.removeAds);
    }
    if (customerInfo
            .entitlements.all[AppConstants.UNLOCK_LEVELS_ID_ENT]?.isActive ==
        true) {
      restoredPurchases.add(RestoredPurchase.unlockLevels);
    }

    return restoredPurchases;
  }

  Future<void> _savePermanentPurchases(
    Set<RestoredPurchase> purchases,
  ) async {
    await Future.wait([
      removeAdsSave(purchases.contains(RestoredPurchase.removeAds)),
      levelsUnlockSave(purchases.contains(RestoredPurchase.unlockLevels)),
    ]);
  }

  Future<void> levelsUnlockRead() async {
    _levelsUnlocked = await shopRepo.levelsUnlockRead();
  }

  Future<void> levelsUnlockSave(bool unlock) async {
    _levelsUnlocked = unlock;
    await shopRepo.levelsUnlockSave(unlock);
    update();
  }

  Future<void> removeAdsRead() async {
    _adsRemoved = await shopRepo.removeAdsRead();
  }

  Future<void> removeAdsSave(bool removeAds) async {
    _adsRemoved = removeAds;
    await shopRepo.removeAdsSave(removeAds);
    update();
  }
}
