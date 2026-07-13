import 'package:flag_app/helper/image_decode_size.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('converts a Dimensions width to physical decode pixels', () {
    expect(
      imageDecodeWidth(
        logicalWidth: 390,
        devicePixelRatio: 3,
      ),
      1170,
    );
  });

  test('rounds fractional physical widths up', () {
    expect(
      imageDecodeWidth(
        logicalWidth: 175,
        devicePixelRatio: 2.625,
      ),
      460,
    );
  });
}
