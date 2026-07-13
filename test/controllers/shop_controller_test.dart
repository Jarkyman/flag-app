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
}
