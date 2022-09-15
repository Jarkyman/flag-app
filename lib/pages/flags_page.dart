import 'package:flutter/material.dart';

import '../controllers/country_controller.dart';
import '../controllers/score_controller.dart';
import '../helper/app_colors.dart';
import '../helper/dimensions.dart';
import '../models/country_model.dart';
import 'package:get/get.dart';

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
  int score = 0;
  late int highScore;

  void generateCountries() {
    setState(() {
      Duration(milliseconds: 300).delay(() {
        selectedCountry = Get.find<CountryController>().getACountry();
        countryOptions = Get.find<CountryController>()
            .generateCountries(selectedCountry.countryName.toString(), 6);
        print(selectedCountry.countryName);
        correctColor = [false, false, false, false, false, false];
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
          Get.find<ScoreController>().saveFlagsScore(highScore.toString());
        }
      });
      generateCountries();
    } else {
      setState(() {
        wrongColor[selected] = true;
        if (score > highScore) {
          highScore = score;
          Get.find<ScoreController>().saveFlagsScore(highScore.toString());
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
          .generateCountries(selectedCountry.countryName.toString(), 6);
      highScore = Get.find<ScoreController>().getFlagsScore;
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
      body: GetBuilder<CountryController>(builder: (countryController) {
        return Column(
          children: [
            SizedBox(
              height: Dimensions.height30,
            ),
            Container(
              height: Dimensions.height30 * 2,
              child: Center(
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
            const Divider(
              height: 20,
              thickness: 2,
              indent: 20,
              endIndent: 20,
              color: Colors.grey,
            ),
            Expanded(
              child: GridView.count(
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
                        horizontal: Dimensions.height20,
                        vertical: Dimensions.width20 * 2,
                      ),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.contain,
                          colorFilter: new ColorFilter.mode(
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
