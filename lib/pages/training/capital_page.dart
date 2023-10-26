import 'dart:math';

import 'package:flag_app/controllers/country_controller.dart';
import 'package:flag_app/controllers/score_controller.dart';
import 'package:flag_app/helper/app_colors.dart';
import 'package:flag_app/models/country_model.dart';
import 'package:flag_app/widget/background_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/hint_controller.dart';
import '../../controllers/sound_controller.dart';
import '../../helper/dimensions.dart';
import '../../widget/Top bar/hint_bar.dart';
import '../../widget/buttons/guess_button.dart';

class CapitalPage extends StatefulWidget {
  const CapitalPage({Key? key}) : super(key: key);

  @override
  State<CapitalPage> createState() => _CapitalPageState();
}

class _CapitalPageState extends State<CapitalPage> {
  late CountryModel selectedCountry;
  late List<CountryModel> countryOptions;
  List<bool> correctColor = [false, false, false, false];
  List<bool> wrongColor = [false, false, false, false];
  bool isLoading = true;
  bool fiftyFiftyUsed = false;
  bool checkUsed = false;
  int score = 0;
  late int highScore;

  void generateCountries() {
    setState(() {
      const Duration(milliseconds: 500).delay(() {
        selectedCountry = Get.find<CountryController>().getACountry();
        countryOptions = Get.find<CountryController>()
            .generateCountries(selectedCountry.countryName.toString(), 4);
        print(selectedCountry.countryName);
        correctColor = [false, false, false, false];
        wrongColor = [false, false, false, false];
        isLoading = false;
        checkUsed = false;
        fiftyFiftyUsed = false;
      });
      isLoading = false;
    });
  }

  void checkWin(String country, int selected) {
    if (country == selectedCountry.countryName.toString()) {
      Get.find<SoundController>().correctSound();
      correctColor[selected] = true;
      setState(() {
        checkUsed = true;
        isLoading = true;
        score++;
        if (score > highScore) {
          highScore = score;
          Get.find<ScoreController>().saveCapitalScore(highScore);
        }
      });
      generateCountries();
    } else {
      Get.find<SoundController>().wrongSound();
      setState(() {
        correctColor[getCorrect()] = true;
        wrongColor[selected] = true;
        if (score > highScore) {
          highScore = score;
          Get.find<ScoreController>().saveCapitalScore(highScore);
        }
        generateCountries();
        score = 0;
      });
    }
  }

  int getCorrect() {
    return countryOptions.indexOf(selectedCountry);
  }

  void useCorrectHint(hints) {
    if (Get.find<HintController>().checkIfEnoughHints(hints) && !checkUsed) {
      Get.find<HintController>().useHint(hints);
      checkWin(selectedCountry.countryName!, getCorrect());
    }
  }

  void useFiftyFiftyHint(int hints) {
    if (Get.find<HintController>().checkIfEnoughHints(hints) &&
        !fiftyFiftyUsed) {
      Get.find<HintController>().useHint(hints);
      int correct = getCorrect();
      wrongColor = [false, false, false, false];
      Random ran = Random();
      int ran1 = ran.nextInt(4);
      int ran2 = ran.nextInt(4);
      while (ran1 == correct || ran1 == ran2 || ran2 == correct) {
        ran1 = ran.nextInt(4);
        ran2 = ran.nextInt(4);
      }
      setState(() {
        wrongColor[ran1] = true;
        wrongColor[ran2] = true;
        fiftyFiftyUsed = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      selectedCountry = Get.find<CountryController>().getACountry();
      countryOptions = Get.find<CountryController>()
          .generateCountries(selectedCountry.countryName.toString(), 4);
      highScore = Get.find<ScoreController>().getCapitalScore;
      isLoading = false;
    });
    print(Get.find<ScoreController>().getCapitalScore);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.find<SoundController>().clickSound();
            Get.back();
          },
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: Text(
          'Capitals'.tr,
          style: TextStyle(
              fontSize: Dimensions.font26, color: AppColors.titleColor),
        ),
        backgroundColor: AppColors.mainColor,
        actions: [
          GetBuilder<ScoreController>(builder: (scoreController) {
            return Text(
              '${'Score'.tr}: $score \n${'Record'.tr}: $highScore ',
              style: TextStyle(fontSize: Dimensions.font16),
            );
          }),
        ],
      ),
      body: BackgroundImage(
        child: SafeArea(
          child: GetBuilder<CountryController>(
            builder: (countryController) {
              return Column(
                children: [
                  HintBar(
                      tapHintOne: () {
                        useCorrectHint(3);
                      },
                      tapHintTwo: () {
                        useFiftyFiftyHint(1);
                      },
                      iconOne: const Icon(
                        Icons.check,
                        color: AppColors.mainColor,
                      ),
                      iconTwo: ImageIcon(
                        const AssetImage('assets/icon/fifty_fifty.png'),
                        color: AppColors.mainColor,
                        size: Dimensions.iconSize24 * 1.4,
                      ),
                      hintPriceOne: '3',
                      hintPriceTwo: '1'),
                  SizedBox(
                    height: Dimensions.height30 * 2,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.width10),
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            selectedCountry.capital.toString(),
                            style: TextStyle(
                              fontSize: Dimensions.font26 * 2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Divider(
                    height: 20,
                    thickness: 2,
                    indent: 20,
                    endIndent: 20,
                    color: Colors.grey,
                  ),
                  SizedBox(
                    height: Dimensions.height20 * 2,
                  ),
                  Expanded(
                    child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          return GuessButton(
                            color: correctColor[index]
                                ? AppColors.correctColor
                                : wrongColor[index]
                                    ? Colors.red
                                    : Colors.white,
                            textColor: correctColor[index]
                                ? Colors.white
                                : wrongColor[index]
                                    ? Colors.white
                                    : AppColors.mainColor,
                            borderColor: correctColor[index]
                                ? Colors.white
                                : wrongColor[index]
                                    ? Colors.white
                                    : AppColors.mainColor,
                            country:
                                countryOptions[index].countryName.toString(),
                            onTap: () {
                              checkWin(
                                  countryOptions[index].countryName.toString(),
                                  index);
                            },
                          );
                        }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
