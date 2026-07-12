import 'package:flag_app/widget/app_swipe_detector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const targetKey = Key('swipe-target');

  Widget buildDetector({
    VoidCallback? onSwipeLeft,
    VoidCallback? onSwipeRight,
    VoidCallback? onSwipeDown,
    Widget child = const SizedBox.expand(),
  }) {
    return MaterialApp(
      home: Scaffold(
        body: AppSwipeDetector(
          key: targetKey,
          minimumHorizontalDistance: 50,
          minimumVerticalDistance: 50,
          onSwipeLeft: onSwipeLeft,
          onSwipeRight: onSwipeRight,
          onSwipeDown: onSwipeDown,
          child: child,
        ),
      ),
    );
  }

  testWidgets('a tap does not trigger a swipe callback', (tester) async {
    var callbackCount = 0;
    var childTapCount = 0;
    await tester.pumpWidget(
      buildDetector(
        onSwipeLeft: () => callbackCount++,
        onSwipeRight: () => callbackCount++,
        onSwipeDown: () => callbackCount++,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => childTapCount++,
          child: const SizedBox.expand(),
        ),
      ),
    );

    await tester.tap(find.byKey(targetKey));

    expect(callbackCount, 0);
    expect(childTapCount, 1);
  });

  testWidgets('movement below the minimum distance is ignored', (tester) async {
    var callbackCount = 0;
    await tester.pumpWidget(
      buildDetector(
        onSwipeLeft: () => callbackCount++,
        onSwipeDown: () => callbackCount++,
      ),
    );

    await tester.drag(find.byKey(targetKey), const Offset(-30, 0));
    await tester.drag(find.byKey(targetKey), const Offset(0, 30));

    expect(callbackCount, 0);
  });

  testWidgets('swipe up does not trigger swipe down', (tester) async {
    var swipeDownCount = 0;
    await tester.pumpWidget(
      buildDetector(onSwipeDown: () => swipeDownCount++),
    );

    await tester.drag(find.byKey(targetKey), const Offset(0, -80));

    expect(swipeDownCount, 0);
  });

  testWidgets('valid swipes trigger only their matching direction',
      (tester) async {
    var swipeLeftCount = 0;
    var swipeRightCount = 0;
    var swipeDownCount = 0;
    await tester.pumpWidget(
      buildDetector(
        onSwipeLeft: () => swipeLeftCount++,
        onSwipeRight: () => swipeRightCount++,
        onSwipeDown: () => swipeDownCount++,
      ),
    );

    await tester.drag(find.byKey(targetKey), const Offset(-80, 0));
    await tester.drag(find.byKey(targetKey), const Offset(80, 0));
    await tester.drag(find.byKey(targetKey), const Offset(0, 80));

    expect(swipeLeftCount, 1);
    expect(swipeRightCount, 1);
    expect(swipeDownCount, 1);
  });
}
