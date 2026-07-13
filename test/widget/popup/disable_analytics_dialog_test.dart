import 'package:flag_app/widget/popup/disable_analytics_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(Get.reset);

  testWidgets('keeps analytics enabled when the primary action is selected',
      (tester) async {
    bool? result;
    await tester.pumpWidget(
      _TestApp(
        onResult: (value) => result = value,
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Turn off anonymous analytics?'), findsOneWidget);
    expect(find.text('Analytics disable description'), findsOneWidget);

    await tester.tap(find.text('Keep analytics on'));
    await tester.pumpAndSettle();

    expect(result, isFalse);
    expect(find.text('Turn off anonymous analytics?'), findsNothing);
  });

  testWidgets('confirms that analytics should be disabled', (tester) async {
    bool? result;
    await tester.pumpWidget(
      _TestApp(
        onResult: (value) => result = value,
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Turn off analytics'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
    expect(find.text('Turn off anonymous analytics?'), findsNothing);
  });
}

class _TestApp extends StatelessWidget {
  final ValueChanged<bool> onResult;

  const _TestApp({required this.onResult});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
                onResult(await showDisableAnalyticsDialog());
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );
  }
}
