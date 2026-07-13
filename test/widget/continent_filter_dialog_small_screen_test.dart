import 'package:flag_app/helper/app_colors.dart';
import 'package:flag_app/models/training_continent.dart';
import 'package:flag_app/widget/popup/continent_filter_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  testWidgets('fits the continent grid on a small screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale('es', 'ES'),
        translations: _SpanishTranslations(),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => showContinentFilterDialog(
                  context: context,
                  selectedContinent: TrainingContinent.southAmerica,
                  accentColor: AppColors.purpleColor,
                  recordFor: (continent) => continent.index,
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    for (final continent in ['América del Norte', 'América del Sur']) {
      final textFinder = find.text(continent);
      expect(textFinder, findsOneWidget);
      expect(tester.widget<Text>(textFinder).maxLines, 2);

      final richTextFinder = find.descendant(
        of: textFinder,
        matching: find.byType(RichText),
      );
      final paragraph = tester.renderObject<RenderParagraph>(richTextFinder);
      expect(paragraph.didExceedMaxLines, isFalse, reason: continent);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('shrinks a long compound word before wrapping it',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale('de', 'DE'),
        translations: _GermanTranslations(),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => showContinentFilterDialog(
                  context: context,
                  selectedContinent: TrainingContinent.northAmerica,
                  accentColor: AppColors.skyColor,
                  recordFor: (continent) => continent.index,
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final textFinder = find.text('Nordamerika');
    expect(textFinder, findsOneWidget);

    final richTextFinder = find.descendant(
      of: textFinder,
      matching: find.byType(RichText),
    );
    final paragraph = tester.renderObject<RenderParagraph>(richTextFinder);
    final boxes = paragraph.getBoxesForSelection(
      const TextSelection(baseOffset: 0, extentOffset: 11),
    );

    expect(boxes, hasLength(1));
    expect(paragraph.didExceedMaxLines, isFalse);
    expect(tester.takeException(), isNull);
  });
}

class _SpanishTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'es_ES': {
          'All': 'Todos',
          'Africa': 'África',
          'Asia': 'Asia',
          'Europe': 'Europa',
          'North America': 'América del Norte',
          'Oceania': 'Oceanía',
          'South America': 'América del Sur',
          'Choose continent': 'Elegir continente',
        },
      };
}

class _GermanTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'de_DE': {
          'All': 'Alle',
          'Africa': 'Afrika',
          'Asia': 'Asien',
          'Europe': 'Europa',
          'North America': 'Nordamerika',
          'Oceania': 'Ozeanien',
          'South America': 'Südamerika',
          'Choose continent': 'Kontinent auswählen',
        },
      };
}
