enum AppRuntimeMode {
  production,
  screenshots,
}

abstract final class AppRuntime {
  static AppRuntimeMode _mode = AppRuntimeMode.production;

  static AppRuntimeMode get mode => _mode;

  static bool get isScreenshotMode => _mode == AppRuntimeMode.screenshots;

  static bool get externalServicesEnabled => !isScreenshotMode;

  static bool get adsEnabled => !isScreenshotMode;

  static void configure(AppRuntimeMode mode) {
    _mode = mode;
  }
}
