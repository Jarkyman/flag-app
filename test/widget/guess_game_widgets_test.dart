import 'package:flag_app/helper/app_colors.dart';
import 'package:flag_app/widget/play/guess_game_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  testWidgets('shows all three South African capitals without clipping',
      (tester) async {
    const capitals = 'Pretória\nCidade do Cabo\nBloemfontein';

    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(
          body: Center(
            child: GuessFactsCard(
              accentColor: AppColors.coralColor,
              facts: [
                GuessFactData(
                  icon: Icons.location_city_rounded,
                  label: 'Capital',
                  value: capitals,
                  maxLines: 3,
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final textFinder = find.text(capitals);
    expect(textFinder, findsOneWidget);
    expect(tester.widget<Text>(textFinder).maxLines, 3);
    expect(tester.widget<Text>(textFinder).textAlign, TextAlign.left);

    final richTextFinder = find.descendant(
      of: textFinder,
      matching: find.byType(RichText),
    );
    final paragraph = tester.renderObject<RenderParagraph>(richTextFinder);

    expect(paragraph.didExceedMaxLines, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('long playable fact values render without clipping',
      (tester) async {
    const continent = 'América del Norte';
    const country = 'Saint Vincent and the Grenadines';
    const currency = 'Marco conversível da Bósnia e Herzegovina (BAM)';

    await tester.binding.setSurfaceSize(const Size(360, 804));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(
          body: Center(
            child: GuessFactsCard(
              accentColor: AppColors.coralColor,
              facts: [
                GuessFactData(
                  icon: Icons.public_rounded,
                  label: 'Continent',
                  value: continent,
                ),
                GuessFactData(
                  icon: Icons.flag_rounded,
                  label: 'Country',
                  value: country,
                  maxLines: 2,
                  textAlign: TextAlign.left,
                ),
                GuessFactData(
                  icon: Icons.payments_rounded,
                  label: 'Currency',
                  value: currency,
                  maxLines: 3,
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    for (final value in [continent, country, currency]) {
      final textFinder = find.text(value);
      final richTextFinder = find.descendant(
        of: textFinder,
        matching: find.byType(RichText),
      );
      final paragraph = tester.renderObject<RenderParagraph>(richTextFinder);

      expect(
        paragraph.didExceedMaxLines,
        isFalse,
        reason: '$value; size=${paragraph.size}; '
            'constraints=${paragraph.constraints}; '
            'fontSize=${paragraph.text.style?.fontSize}',
      );
    }
    expect(tester.takeException(), isNull);
  });
}
