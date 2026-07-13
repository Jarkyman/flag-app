import 'package:flag_app/widget/menu_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  testWidgets('dotted map does not overflow on a 360 dp Android screen',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 804));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(
          body: MenuBackground(child: SizedBox.expand()),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
