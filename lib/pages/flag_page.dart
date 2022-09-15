import 'package:flag_app/controllers/country_controller.dart';
import 'package:flag_app/controllers/score_controller.dart';
import 'package:flag_app/helper/app_colors.dart';
import 'package:flag_app/models/country_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../helper/dimensions.dart';
import '../widget/guess_button.dart';

class FlagPage extends StatefulWidget {
  const FlagPage({Key? key}) : super(key: key);

  @override
  State<FlagPage> createState() => _FlagPageState();
}

class _FlagPageState extends State<FlagPage> {
  late CountryModel selectedCountry;
  late List<CountryModel> countryOptions;
  List<bool> correctColor = [false, false, false, false];
  List<bool> wrongColor = [false, false, false, false];
  bool isLoading = true;
  int score = 0;
  late int highScore;

  void generateCountries() {
    setState(() {
      Duration(milliseconds: 300).delay(() {
        selectedCountry = Get.find<CountryController>().getACountry();
        countryOptions = Get.find<CountryController>()
            .generateCountries(selectedCountry.countryName.toString(), 4);
        print(selectedCountry.countryName);
        correctColor = [false, false, false, false];
        isLoading = false;
      });
      isLoading = false;
    });
  }

  void checkWin(String country, int selected) {
    if (country == selectedCountry.countryName.toString()) {
      correctColor[selected] = true;
      setState(() {
        isLoading = true;
        score++;
        if (score > highScore) {
          highScore = score;
          Get.find<ScoreController>().saveFlagScore(highScore.toString());
        }
      });
      generateCountries();
    } else {
      setState(() {
        wrongColor[selected] = true;
        if (score > highScore) {
          highScore = score;
          Get.find<ScoreController>().saveFlagScore(highScore.toString());
        }
        score = 0;
      });
      Duration(milliseconds: 300).delay(() {
        setState(() {
          wrongColor[selected] = false;
        });
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
      highScore = Get.find<ScoreController>().getFlagScore;
      isLoading = false;
    });
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
          Text(
            'Score: $score \nHigh score: $highScore ',
            style: TextStyle(fontSize: Dimensions.font16),
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : GetBuilder<CountryController>(
              builder: (countryController) {
                return Column(
                  children: [
                    SizedBox(
                      height: Dimensions.height10,
                    ),
                    Container(
                      width: double.maxFinite,
                      height: Dimensions.height20 * 14,
                      margin:
                          EdgeInsets.symmetric(horizontal: Dimensions.height20),
                      decoration: BoxDecoration(),
                      child: Image.asset(
                        'assets/image/flags/${selectedCountry.countryCode.toString().toLowerCase()}.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(
                      height: Dimensions.height20,
                    ),
                    Expanded(
                      child: ListView.builder(
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
                                    countryOptions[index]
                                        .countryName
                                        .toString(),
                                    index);
                              },
                            );
                          }),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
