import 'package:flag_app/controllers/hint_controller.dart';
import 'package:flag_app/controllers/level_controller.dart';
import 'package:flag_app/helper/app_constants.dart';
import 'package:flag_app/pages/play/play_page.dart';
import 'package:flag_app/repos/hint_repo.dart';
import 'package:flag_app/repos/level_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  testWidgets('category progress updates while the play page stays mounted',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final levelController = _FakeLevelController(
      levelRepo: LevelRepo(sharedPreferences: preferences),
    );
    final hintController = HintController(
      hintRepo: HintRepo(sharedPreferences: preferences),
    );
    await hintController.readHints();
    Get.put<LevelController>(levelController);
    Get.put(hintController);

    await tester.pumpWidget(const GetMaterialApp(home: PlayPage()));
    await tester.pump();

    expect(find.text('159/197'), findsOneWidget);

    levelController.completeAnotherFlag();
    await tester.pump();

    expect(find.text('159/197'), findsNothing);
    expect(find.text('160/197'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _FakeLevelController extends LevelController {
  var completedFlags = 159;

  _FakeLevelController({required super.levelRepo});

  void completeAnotherFlag() {
    completedFlags++;
    update();
  }

  @override
  int getFinishedLevelsTotal(String playOption) {
    return playOption == AppConstants.FLAGS ? completedFlags : 0;
  }

  @override
  int getAmountOfLevelsTotal(String playOption) => 197;
}
