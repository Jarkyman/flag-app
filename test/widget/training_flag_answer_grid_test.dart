import 'package:flag_app/widget/training/training_game_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  testWidgets('six flag choices fit inside an iPad 13 height', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1024, 1366));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _gridHarness(width: 960, height: 650),
    );
    await tester.pump();

    final gridRect = tester.getRect(find.byType(TrainingFlagAnswerGrid));
    for (var index = 0; index < 6; index++) {
      final itemRect = tester.getRect(find.byKey(ValueKey('flag-$index')));
      expect(itemRect.bottom, lessThanOrEqualTo(gridRect.bottom + 0.1));
    }

    final firstItem = tester.getRect(find.byKey(const ValueKey('flag-0')));
    expect(firstItem.width / firstItem.height, greaterThan(1.45));
    expect(
      tester.widget<GridView>(find.byType(GridView)).physics,
      isA<NeverScrollableScrollPhysics>(),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('flag choices keep their natural proportions on a phone',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _gridHarness(width: 360, height: 500),
    );
    await tester.pump();

    final firstItem = tester.getRect(find.byKey(const ValueKey('flag-0')));
    expect(firstItem.width / firstItem.height, closeTo(1.45, 0.01));

    final gridRect = tester.getRect(find.byType(TrainingFlagAnswerGrid));
    final lastItem = tester.getRect(find.byKey(const ValueKey('flag-5')));
    expect(lastItem.bottom, lessThanOrEqualTo(gridRect.bottom + 0.1));
    expect(tester.takeException(), isNull);
  });
}

Widget _gridHarness({required double width, required double height}) {
  return GetMaterialApp(
    home: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: width,
          height: height,
          child: TrainingFlagAnswerGrid(
            itemCount: 6,
            itemBuilder: (context, index) => ColoredBox(
              key: ValueKey('flag-$index'),
              color: Colors.white,
            ),
          ),
        ),
      ),
    ),
  );
}
