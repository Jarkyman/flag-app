import 'package:flag_app/helper/dimensions.dart';
import 'package:flag_app/widget/menu_page_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  testWidgets('header keeps design spacing below the system safe area',
      (tester) async {
    const screenSize = Size(390, 844);
    const systemTopInset = 47.0;

    await tester.binding.setSurfaceSize(screenSize);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: MediaQuery(
            data: const MediaQueryData(
              size: screenSize,
              padding: EdgeInsets.only(top: systemTopInset),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  MenuPageHeader(
                    title: 'Play',
                    showHintBadge: false,
                    onLeadingTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final headerRect = tester.getRect(find.byType(MenuPageHeader));
    final titleRect = tester.getRect(find.text('Play'));
    final contentHeight = Dimensions.height20 * 3.2;

    expect(headerRect.top, systemTopInset);
    expect(
      headerRect.height,
      closeTo(Dimensions.headerTopSpacing + contentHeight, 0.1),
    );
    expect(
      titleRect.center.dy,
      closeTo(
        systemTopInset + Dimensions.headerTopSpacing + contentHeight / 2,
        0.5,
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
