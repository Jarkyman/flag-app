import 'package:flag_app/helper/app_constants.dart';
import 'package:flag_app/widget/level_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  testWidgets('level grid decodes large thumbnails at card size',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 130,
            height: 130,
            child: LevelCard(
              guessed: true,
              image: 'assets/image/flags/ve.png',
              option: AppConstants.FLAGS,
              number: 1,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<ResizeImage>());
    final resizedImage = image.image as ResizeImage;
    expect(resizedImage.width, isNotNull);
    expect(resizedImage.width, lessThan(2560));
    expect(tester.takeException(), isNull);
  });
}
