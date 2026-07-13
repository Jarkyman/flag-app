import 'package:flag_app/helper/app_colors.dart';
import 'package:flag_app/widget/training/training_game_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  testWidgets('large flag assets request a display-sized decode',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 390 / 2,
            height: 200,
            child: TrainingFlagAnswerCard(
              image: 'assets/image/flags/ve.png',
              accentColor: AppColors.purpleColor,
              state: TrainingAnswerState.idle,
              onTap: () {},
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

  testWidgets('metadata-cleaned Serbia flag decodes successfully',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 390 / 2,
            height: 200,
            child: TrainingFlagAnswerCard(
              image: 'assets/image/flags/rs.png',
              accentColor: AppColors.purpleColor,
              state: TrainingAnswerState.idle,
              onTap: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
