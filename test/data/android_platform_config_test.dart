import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android compiles against and targets API level 36', () {
    final gradle = File('android/app/build.gradle').readAsStringSync();

    expect(gradle, contains('compileSdkVersion 36'));
    expect(gradle, contains('targetSdkVersion 36'));
  });
}
