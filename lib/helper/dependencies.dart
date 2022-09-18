import 'package:flag_app/controllers/country_continent_controller.dart';
import 'package:flag_app/controllers/country_controller.dart';
import 'package:flag_app/controllers/hint_controller.dart';
import 'package:flag_app/controllers/score_controller.dart';
import 'package:flag_app/repos/country_continent_repo.dart';
import 'package:flag_app/repos/country_repo.dart';
import 'package:flag_app/repos/hint_repo.dart';
import 'package:flag_app/repos/score_repo.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  //Repo
  Get.lazyPut(() => CountryRepo());
  Get.lazyPut(() => CountryContinentRepo());
  Get.lazyPut(() => ScoreRepo(sharedPreferences: sharedPreferences));
  Get.lazyPut(() => HintRepo(sharedPreferences: sharedPreferences));

  //Controller
  Get.lazyPut(() => CountryController(countryRepo: Get.find()));
  Get.lazyPut(() => CountryContinentController(continentRepo: Get.find()));
  Get.lazyPut(() => ScoreController(scoreRepo: Get.find()));
  Get.lazyPut(() => HintController(hintRepo: Get.find()));
}
