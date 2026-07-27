import 'dart:convert';
import 'dart:io';

import 'package:flag_app/controllers/daily_challenge_controller.dart';
import 'package:flag_app/daily_challenge/daily_challenge_reminder.dart';
import 'package:flag_app/daily_challenge/daily_challenge_repository.dart';
import 'package:flag_app/models/country_model.dart';
import 'package:flag_app/pages/daily_challenge/daily_challenge_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  testWidgets('starts the challenge without overflowing on a small screen',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final countries = (jsonDecode(
      File('assets/json/us/countries.json').readAsStringSync(),
    ) as List<dynamic>)
        .take(30)
        .map(
          (value) => CountryModel.fromJson(
            value as Map<String, dynamic>,
          ),
        )
        .toList();
    final controller = DailyChallengeController(
      repository: DailyChallengeRepository(
        sharedPreferences: preferences,
      ),
      reminder: const _Reminder(),
      countriesProvider: () => countries,
      submitScore: ({
        required int scoreMilliseconds,
        required String dayKey,
      }) async {},
      now: () => DateTime.utc(2026, 7, 27, 12),
      answerTransitionDuration: Duration.zero,
    );
    Get.put(controller);

    await tester.pumpWidget(
      const GetMaterialApp(home: DailyChallengePage()),
    );
    await tester.pump();

    expect(find.text('Start challenge'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Start challenge'));
    await tester.pump();

    expect(find.text('Identify the country'), findsOneWidget);
    expect(find.text('1/10'), findsOneWidget);
    expect(tester.takeException(), isNull);

    Get.delete<DailyChallengeController>(force: true);
    await tester.pump();
  });
}

class _Reminder implements DailyChallengeReminder {
  const _Reminder();

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> enable({
    required String title,
    required String body,
  }) async {
    return true;
  }

  @override
  Future<void> disable() async {}
}
