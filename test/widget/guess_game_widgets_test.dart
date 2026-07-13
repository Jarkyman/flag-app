import 'package:flag_app/controllers/hint_controller.dart';
import 'package:flag_app/helper/app_colors.dart';
import 'package:flag_app/helper/app_constants.dart';
import 'package:flag_app/repos/hint_repo.dart';
import 'package:flag_app/widget/play/guess_game_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  testWidgets('header stays centered with a large hint balance',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 804));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    SharedPreferences.setMockInitialValues({AppConstants.HINTS: 9000});
    final preferences = await SharedPreferences.getInstance();
    final hintController = HintController(
      hintRepo: HintRepo(sharedPreferences: preferences),
    );
    await hintController.readHints();
    Get.put(hintController);

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: GuessGameHeader(
            title: 'Level 10',
            subtitle: 'Coat of arms • 20/20',
            onBack: () {},
            onHelp: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('999+'), findsOneWidget);
    expect(find.text('9000'), findsNothing);

    final titleRect = tester.getRect(find.text('Level 10'));
    final helpRect = tester.getRect(find.byIcon(Icons.question_mark_rounded));
    final hintRect = tester.getRect(find.text('999+'));

    expect(titleRect.center.dx, closeTo(180, 0.5));
    expect(helpRect.right, lessThan(titleRect.left));
    expect(titleRect.right, lessThan(hintRect.left));
    expect(tester.takeException(), isNull);
  });

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
    const continentLabel = 'Continente';
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
                  label: continentLabel,
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

    final labelFinder = find.text(continentLabel);
    final labelRichTextFinder = find.descendant(
      of: labelFinder,
      matching: find.byType(RichText),
    );
    final labelParagraph =
        tester.renderObject<RenderParagraph>(labelRichTextFinder);
    expect(
      labelParagraph.didExceedMaxLines,
      isFalse,
      reason: 'size=${labelParagraph.size}; '
          'constraints=${labelParagraph.constraints}; '
          'fontSize=${labelParagraph.text.style?.fontSize}',
    );

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
