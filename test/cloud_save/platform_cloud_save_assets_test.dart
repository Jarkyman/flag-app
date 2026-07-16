import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Play Games cover image stays within the guaranteed 800 KB limit',
      () async {
    final coverImage =
        await rootBundle.load('assets/image/flag_ball_cloud_save.png');

    expect(coverImage.lengthInBytes, lessThanOrEqualTo(800 * 1024));
  });
}
