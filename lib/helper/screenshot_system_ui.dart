import 'dart:io';

import 'package:flutter/services.dart';

abstract final class ScreenshotSystemUi {
  static const MethodChannel _androidChannel = MethodChannel(
    'com.hartvig_solutions.flags/screenshot',
  );

  static Future<void> hideSystemBars() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: const [],
    );

    if (!Platform.isAndroid) return;

    try {
      await _androidChannel.invokeMethod<void>('hideSystemBars');
    } on MissingPluginException {
      // The Flutter fallback above still works on older Android versions.
    }
  }
}
