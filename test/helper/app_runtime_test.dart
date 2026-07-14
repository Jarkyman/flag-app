import 'package:flag_app/helper/ad_helper.dart';
import 'package:flag_app/helper/app_runtime.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => AppRuntime.configure(AppRuntimeMode.production));

  test('screenshot mode disables ads and external services', () {
    AppRuntime.configure(AppRuntimeMode.screenshots);

    expect(AppRuntime.isScreenshotMode, isTrue);
    expect(AppRuntime.externalServicesEnabled, isFalse);
    expect(AdHelper.adsEnabled, isFalse);
  });

  test('production mode keeps ads and external services available', () {
    AppRuntime.configure(AppRuntimeMode.production);

    expect(AppRuntime.isScreenshotMode, isFalse);
    expect(AppRuntime.externalServicesEnabled, isTrue);
    expect(AdHelper.adsEnabled, isTrue);
  });
}
