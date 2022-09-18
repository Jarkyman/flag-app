import 'package:get/get.dart';
import '../repos/hint_repo.dart';

class HintController extends GetxController implements GetxService {
  final HintRepo hintRepo;

  HintController({
    required this.hintRepo,
  });

  int _hints = 0;
  int get getHints => _hints;

  Future<void> readHints() async {
    _hints = await hintRepo.readHints();
  }

  Future<void> saveHints(int hints) async {
    _hints = hints;
    hintRepo.saveHints(hints);
  }

  void addHint(int hints) {
    if (hints > 5) {
    } else {
      _hints += hints;
      saveHints(_hints);
      update();
    }
  }

  void useHint(int hints) {
    _hints -= hints;
    saveHints(_hints);
    update();
  }

  bool getCorrect() {
    if (_hints >= 3) {
      return true;
    } else {
      Get.snackbar('No hints', 'Buy more hints');
      return false;
    }
  }

  bool getFiftyFifty() {
    if (_hints >= 1) {
      return true;
    } else {
      Get.snackbar('No hints', 'Buy more hints');
      return false;
    }
  }
}
