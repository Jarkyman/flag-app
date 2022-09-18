import 'dart:math';

import 'package:flag_app/helper/route_helper.dart';
import 'package:flutter/material.dart';

import '../controllers/country_controller.dart';
import '../controllers/hint_controller.dart';
import '../controllers/score_controller.dart';
import '../helper/app_colors.dart';
import '../helper/dimensions.dart';
import '../models/country_model.dart';
import 'package:get/get.dart';

import '../widget/hint_widget.dart';

class FlagsPage extends StatefulWidget {
  const FlagsPage({Key? key}) : super(key: key);

  @override
  State<FlagsPage> createState() => _FlagsPageState();
}

class _FlagsPageState extends State<FlagsPage> {
  late CountryModel selectedCountry;
  late List<CountryModel> countryOptions;
  List<bool> correctColor = [false, false, false, false, false, false];
  List<bool> wrongColor = [false, false, false, false, false, false];
  bool isLoading = true;
  bool fiftyFiftyUsed = false;
  bool checkUsed = false;
  int score = 0;
  late int highScore;

  void generateCountries() {
    setState(() {
      Duration(milliseconds: 500).delay(() {
        selectedCountry = Get.find<CountryController>().getACountry();
        countryOptions = Get.find<CountryController>()
            .generateCountries(selectedCountry.countryName.toString(), 6);
        print(getCorrect() + 1);
        correctColor = [false, false, false, false, false, false];
        wrongColor = [false, false, false, false, false, false];
        isLoading = false;
        fiftyFiftyUsed = false;
        checkUsed = false;
      });
      isLoading = false;
    });
  }

  void checkWin(String country, int selected) {
    if (country == selectedCountry.countryName.toString()) {
      correctColor[selected] = true;
      setState(() {
        checkUsed = true;
        isLoading = true;
        score++;
        if (score > highScore) {
          highScore = score;
          Get.find<ScoreController>().saveFlagsScore(highScore);
        }
        generateCountries();
      });
    } else {
      setState(() {
        correctColor[getCorrect()] = true;
        wrongColor[selected] = true;
        if (score > highScore) {
          highScore = score;
          Get.find<ScoreController>().saveFlagsScore(highScore);
        }
        generateCountries();
        score = 0;
      });
    }
  }

  int getCorrect() {
    return countryOptions.indexOf(selectedCountry);
  }

  void getFiftyFifty() {
    int correct = getCorrect();
    wrongColor = [false, false, false, false, false, false];
    Random ran = Random();
    int ran1 = ran.nextInt(6);
    int ran2 = ran.nextInt(6);
    int ran3 = ran.nextInt(6);
    while (ran1 == correct ||
        ran1 == ran2 ||
        ran2 == correct ||
        ran1 == ran3 ||
        ran2 == ran3 ||
        ran3 == correct) {
      ran1 = ran.nextInt(6);
      ran2 = ran.nextInt(6);
      ran3 = ran.nextInt(6);
    }
    setState(() {
      wrongColor[ran1] = true;
      wrongColor[ran2] = true;
      wrongColor[ran3] = true;
      fiftyFiftyUsed = true;
    });

    print(ran1.toString() + " / " + ran2.toString());
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      selectedCountry = Get.find<CountryController>().getACountry();
      countryOptions = Get.find<CountryController>()
          .generateCountries(selectedCountry.countryName.toString(), 6);
      highScore = Get.find<ScoreController>().getFlagsScore;
      isLoading = false;
    });
    print(Get.find<ScoreController>().getFlagsScore);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Flags',
          style: TextStyle(
              fontSize: Dimensions.font26, color: AppColors.titleColor),
        ),
        backgroundColor: AppColors.mainColor,
        actions: [
          GetBuilder<ScoreController>(builder: (scoreController) {
            return Text(
              'Score: $score \nHigh score: $highScore ',
              style: TextStyle(fontSize: Dimensions.font16),
            );
          }),
        ],
      ),
      body: GetBuilder<CountryController>(builder: (countryController) {
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  top: Dimensions.height10, bottom: Dimensions.height10),
              child: Padding(
                padding: EdgeInsets.only(
                    left: Dimensions.width10, right: Dimensions.width10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GetBuilder<HintController>(builder: (hintController) {
                            return HintWidget(
                              onTap: () {
                                if (hintController.getCorrect() && !checkUsed) {
                                  hintController.useHint(3);
                                  checkWin(selectedCountry.countryName!,
                                      getCorrect());
                                }
                              },
                              icon: Icon(
                                Icons.check,
                                color: AppColors.mainColor,
                              ),
                              num: '3',
                            );
                          }),
                          SizedBox(
                            width: Dimensions.width10,
                          ),
                          GetBuilder<HintController>(builder: (hintController) {
                            return HintWidget(
                              onTap: () {
                                if (hintController.getFiftyFifty() &&
                                    !fiftyFiftyUsed) {
                                  hintController.useHint(1);
                                  getFiftyFifty();
                                }
                              },
                              icon: ImageIcon(
                                AssetImage('assets/icon/fifty_fifty.png'),
                                color: AppColors.mainColor,
                                size: Dimensions.iconSize24 * 1.4,
                              ),
                              num: '1',
                            );
                          }),
                        ],
                      ),
                    ),
                    GetBuilder<HintController>(builder: (hintController) {
                      return HintWidget(
                        onTap: () {
                          Get.toNamed(RouteHelper.getShopPage());
                        },
                        icon: Icon(
                          Icons.lightbulb_outline,
                          color: AppColors.mainColor,
                        ),
                        num: hintController.getHints.toString(),
                      );
                    }),
                  ],
                ),
              ),
            ),
            Container(
              height: Dimensions.height30 * 2,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.width10),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      selectedCountry.countryName.toString(),
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
            Expanded(
              child: GridView.count(
                physics: NeverScrollableScrollPhysics(),
                childAspectRatio: 3 / 2,
                mainAxisSpacing: Dimensions.height20,
                // Create a grid with 2 columns. If you change the scrollDirection to
                // horizontal, this produces 2 rows.
                crossAxisCount: 2,
                // Generate 100 widgets that display their index in the List.
                children: List.generate(6, (index) {
                  return GestureDetector(
                    onTap: () {
                      checkWin(
                          countryOptions[index].countryName.toString(), index);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width / 2 -
                          Dimensions.width20,
                      margin: EdgeInsets.symmetric(
                        horizontal: Dimensions.height10,
                      ),
                      decoration: BoxDecoration(),
                      child: Stack(
                        children: [
                          Center(
                            child: Image.asset(
                              'assets/image/flags/${countryOptions[index].countryCode.toString().toLowerCase()}.png',
                            ),
                          ),
                          Center(
                            child: Container(
                              height: Dimensions.height20 * 3.5,
                              width: Dimensions.height20 * 3.5,
                              decoration: BoxDecoration(
                                color: correctColor[index]
                                    ? AppColors.correctColor
                                    : wrongColor[index]
                                        ? AppColors.wrongColor
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radius20 * 3.5,
                                ),
                                border: Border.all(
                                  width: 2,
                                  color: correctColor[index]
                                      ? Colors.black
                                      : wrongColor[index]
                                          ? Colors.black
                                          : Colors.transparent,
                                ),
                              ),
                              child: correctColor[index]
                                  ? Icon(
                                      Icons.check,
                                      size: Dimensions.iconSize16 * 2.5,
                                    )
                                  : wrongColor[index]
                                      ? Icon(
                                          Icons.close,
                                          size: Dimensions.iconSize16 * 2.5,
                                        )
                                      : Container(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      }),
    );
  }
}
/*
image: DecorationImage(
                          fit: BoxFit.contain,
                          colorFilter: ColorFilter.mode(
                            correctColor[index]
                                ? AppColors.correctColor
                                : wrongColor[index]
                                    ? AppColors.wrongColor
                                    : Colors.transparent,
                            BlendMode.color,
                          ),
                          image: AssetImage(
                            'assets/image/flags/${countryOptions[index].countryCode.toString().toLowerCase()}.png',
                          ),
                        ),
 */
