import 'package:flag_app/widget/menu_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  testWidgets('dotted map can be hidden on active game screens',
      (tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(
          body: MenuBackground(
            showDottedWorldMap: false,
            child: SizedBox.expand(),
          ),
        ),
      ),
    );

    expect(find.byType(SvgPicture), findsNothing);
  });

  test('dotted map timeline wraps without resetting its cycle', () {
    expect(
      DottedWorldMapTimeline.phaseAt(const Duration(seconds: 12)),
      closeTo(0.25, 0.0001),
    );
    expect(
      DottedWorldMapTimeline.phaseAt(const Duration(seconds: 60)),
      closeTo(0.25, 0.0001),
    );
  });

  testWidgets('dotted map keeps its timeline across push and pop',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 804));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      GetMaterialApp(
        navigatorKey: navigatorKey,
        home: const Scaffold(
          body: MenuBackground(child: SizedBox.expand()),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 12));
    final beforePush = _visibleMapOffset(tester);

    navigatorKey.currentState!.push(
      MaterialPageRoute<void>(
        builder: (context) => const Scaffold(
          body: MenuBackground(child: SizedBox.expand()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final afterPush = _visibleMapOffset(tester);

    expect(afterPush.abs(), greaterThan(beforePush.abs()));

    navigatorKey.currentState!.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final afterPop = _visibleMapOffset(tester);

    expect(afterPop.abs(), greaterThan(afterPush.abs()));
    expect(tester.takeException(), isNull);
  });
}

double _visibleMapOffset(WidgetTester tester) {
  final transforms = tester.widgetList<Transform>(
    find.byKey(const ValueKey('dotted-world-map-translation')),
  );

  expect(transforms, isNotEmpty);
  return transforms.last.transform.storage[12];
}
