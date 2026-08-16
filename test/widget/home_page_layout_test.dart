import 'package:flag_app/controllers/hint_controller.dart';
import 'package:flag_app/helper/app_runtime.dart';
import 'package:flag_app/pages/home/home_page.dart';
import 'package:flag_app/repos/hint_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    AppRuntime.configure(AppRuntimeMode.production);
    Get.reset();
  });

  testWidgets('phone home layout shows complete first and last menu cards',
      (tester) async {
    const screenSize = Size(402, 874);
    const systemPadding = EdgeInsets.only(top: 59, bottom: 34);
    await tester.binding.setSurfaceSize(screenSize);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    Get.put(
      HintController(
        hintRepo: HintRepo(sharedPreferences: preferences),
      ),
    );
    AppRuntime.configure(AppRuntimeMode.screenshots);

    await tester.pumpWidget(
      GetMaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: screenSize,
            padding: systemPadding,
          ),
          child: const HomePage(),
        ),
      ),
    );
    await tester.pump();

    final dailyCard = tester.getRect(find.text('Daily challenge'));
    final shopCard = tester.getRect(
      find.byKey(const ValueKey('home-shop-menu-button')),
    );

    expect(dailyCard.top, greaterThan(systemPadding.top));
    expect(
      shopCard.bottom,
      lessThanOrEqualTo(screenSize.height - systemPadding.bottom),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('small phone keeps readable spacing and scrolls to the shop',
      (tester) async {
    const screenSize = Size(320, 568);
    const systemPadding = EdgeInsets.only(top: 20, bottom: 16);
    await tester.binding.setSurfaceSize(screenSize);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    Get.put(
      HintController(
        hintRepo: HintRepo(sharedPreferences: preferences),
      ),
    );
    AppRuntime.configure(AppRuntimeMode.screenshots);

    await tester.pumpWidget(
      GetMaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: screenSize,
            padding: systemPadding,
          ),
          child: const HomePage(),
        ),
      ),
    );
    await tester.pump();

    final shopFinder = find.byKey(
      const ValueKey('home-shop-menu-button'),
    );
    expect(
      tester.getRect(shopFinder).bottom,
      greaterThan(screenSize.height - systemPadding.bottom),
    );

    await tester.scrollUntilVisible(
      shopFinder,
      160,
      scrollable: find.byType(Scrollable),
    );
    await tester.pump(const Duration(milliseconds: 300));

    final shopRect = tester.getRect(shopFinder);
    expect(shopRect.top, greaterThanOrEqualTo(systemPadding.top));
    expect(
      shopRect.bottom,
      lessThanOrEqualTo(screenSize.height - systemPadding.bottom),
    );
    expect(tester.takeException(), isNull);
  });
}
