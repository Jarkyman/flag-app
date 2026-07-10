import 'package:flag_app/helper/app_colors.dart';
import 'package:flag_app/models/training_continent.dart';
import 'package:flag_app/widget/popup/continent_filter_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  testWidgets('shows every continent and returns the selected filter',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(402, 874));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    TrainingContinent? result;

    await tester.pumpWidget(
      GetMaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () async {
                  result = await showContinentFilterDialog(
                    context: context,
                    selectedContinent: TrainingContinent.all,
                    accentColor: AppColors.coralColor,
                    recordFor: (continent) => continent.index,
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Choose continent'), findsOneWidget);
    for (final continent in TrainingContinent.values) {
      expect(find.text(continent.translationKey), findsOneWidget);
    }
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Europe'));
    await tester.pumpAndSettle();

    expect(result, TrainingContinent.europe);
  });

  testWidgets('fits long translated continent names without overflow',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(402, 874));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale('fr', 'FR'),
        translations: _FrenchTranslations(),
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

    expect(find.text('Amérique du Nord'), findsOneWidget);
    expect(find.text('Amérique du Sud'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _FrenchTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'fr_FR': {
          'All': 'Tous',
          'Africa': 'Afrique',
          'Asia': 'Asie',
          'Europe': 'Europe',
          'North America': 'Amérique du Nord',
          'Oceania': 'Océanie',
          'South America': 'Amérique du Sud',
          'Choose continent': 'Choisir un continent',
        },
      };
}
