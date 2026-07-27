import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android declares notification scheduling requirements', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(
      manifest,
      contains('android.permission.POST_NOTIFICATIONS'),
    );
    expect(
      manifest,
      contains('android.permission.RECEIVE_BOOT_COMPLETED'),
    );
    expect(
      manifest,
      contains(
        'com.dexterous.flutterlocalnotifications.'
        'ScheduledNotificationReceiver',
      ),
    );
    expect(
      manifest,
      contains(
        'com.dexterous.flutterlocalnotifications.'
        'ScheduledNotificationBootReceiver',
      ),
    );

    final reminder = File(
      'lib/daily_challenge/platform_daily_challenge_reminder.dart',
    ).readAsStringSync();
    final notificationIcon = File(
      'android/app/src/main/res/drawable/ic_stat_daily_challenge.xml',
    );
    final resourceKeepRules = File(
      'android/app/src/main/res/raw/keep.xml',
    ).readAsStringSync();

    expect(
      reminder,
      contains("AndroidInitializationSettings('ic_stat_daily_challenge')"),
    );
    expect(notificationIcon.existsSync(), isTrue);
    expect(resourceKeepRules, contains('@drawable/ic_stat_daily_challenge'));
  });

  test('iOS forwards foreground notifications through FlutterAppDelegate', () {
    final appDelegate = File(
      'ios/Runner/AppDelegate.swift',
    ).readAsStringSync();

    expect(
      appDelegate,
      contains('UNUserNotificationCenter.current().delegate = self'),
    );
  });
}
