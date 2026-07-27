import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as timezone;

import 'daily_challenge_reminder.dart';
import 'local_timezone.dart';

class PlatformDailyChallengeReminder implements DailyChallengeReminder {
  static const int _notificationId = 2707;
  static const int _reminderHour = 19;
  static const String _payload = 'daily-challenge';

  final FlutterLocalNotificationsPlugin plugin;

  PlatformDailyChallengeReminder({
    FlutterLocalNotificationsPlugin? plugin,
  }) : plugin = plugin ?? FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized || !_isSupportedPlatform) return;

    final localTimezone = await FlutterTimezone.getLocalTimezone();
    initializeLocalTimezone(localTimezone.identifier);

    await plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_daily_challenge'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _initialized = true;
  }

  @override
  Future<bool> enable({
    required String title,
    required String body,
  }) async {
    if (!_isSupportedPlatform) return false;
    await initialize();
    final permissionGranted = await _requestPermission();
    if (!permissionGranted) return false;

    final current = timezone.TZDateTime.now(timezone.local);
    var nextReminder = timezone.TZDateTime(
      timezone.local,
      current.year,
      current.month,
      current.day,
      _reminderHour,
    );
    if (!nextReminder.isAfter(current)) {
      nextReminder = nextReminder.add(const Duration(days: 1));
    }

    await plugin.zonedSchedule(
      id: _notificationId,
      title: title,
      body: body,
      scheduledDate: nextReminder,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_challenge_reminder',
          'Daily challenge',
          channelDescription: 'Daily reminder for the Flags Game challenge',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBanner: true,
          presentList: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: _payload,
    );
    return true;
  }

  @override
  Future<void> disable() async {
    if (!_isSupportedPlatform) return;
    await initialize();
    await plugin.cancel(id: _notificationId);
  }

  Future<bool> _requestPermission() async {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return await plugin
                .resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin>()
                ?.requestNotificationsPermission() ??
            false;
      case TargetPlatform.iOS:
        return await plugin
                .resolvePlatformSpecificImplementation<
                    IOSFlutterLocalNotificationsPlugin>()
                ?.requestPermissions(
                  alert: true,
                  badge: true,
                  sound: true,
                ) ??
            false;
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return false;
    }
  }

  bool get _isSupportedPlatform {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }
}
