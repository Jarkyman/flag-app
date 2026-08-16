import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('iOS advertises every locale supported by the Flutter app', () {
    final infoPlist = File('ios/Runner/Info.plist').readAsStringSync();
    final project = File(
      'ios/Runner.xcodeproj/project.pbxproj',
    ).readAsStringSync();
    const expectedLocalizations = {
      'da',
      'de',
      'en',
      'es',
      'fr',
      'nb',
      'pt-BR',
      'pt-PT',
      'sv',
    };

    expect(infoPlist, contains('<key>CFBundleLocalizations</key>'));
    for (final localization in expectedLocalizations) {
      expect(
        infoPlist,
        contains('<string>$localization</string>'),
        reason: 'Missing iOS localization $localization',
      );
      expect(
        File(
          'ios/Runner/$localization.lproj/InfoPlist.strings',
        ).existsSync(),
        isTrue,
        reason: 'Missing bundled iOS resource for $localization',
      );
      expect(
        project,
        contains('$localization.lproj/InfoPlist.strings'),
        reason: 'iOS project does not bundle $localization',
      );
    }
    expect(project, contains('InfoPlist.strings in Resources'));
    expect(
      infoPlist,
      contains(
        '<key>ITSAppUsesNonExemptEncryption</key>\n\t\t<false/>',
      ),
    );
  });
}
