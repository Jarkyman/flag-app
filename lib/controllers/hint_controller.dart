import 'package:flag_app/helper/route_helper.dart';
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
    if (_hints >= hints) {
      _hints -= hints;
      saveHints(_hints);
      update();
    }
  }

  bool checkIfEnoughHints(int hints) {
    if (_hints >= hints) {
      return true;
    } else {
      Get.toNamed(RouteHelper.getShopPage());
      return false;
    }
  }
}
