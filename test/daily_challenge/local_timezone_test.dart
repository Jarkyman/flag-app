import 'package:flag_app/daily_challenge/local_timezone.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('supports the local timezone identifier returned by iOS in Denmark', () {
    final location = initializeLocalTimezone('Europe/Copenhagen');

    expect(location.name, 'Europe/Copenhagen');
  });
}
