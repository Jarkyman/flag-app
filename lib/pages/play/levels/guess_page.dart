import 'dart:math';

import 'package:flag_app/controllers/level_controller.dart';
import 'package:flag_app/models/level_model.dart';
import 'package:flag_app/widget/empty_tile.dart';
import 'package:flag_app/widget/letter_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/country_controller.dart';
import '../../../controllers/hint_controller.dart';
import '../../../helper/app_colors.dart';
import '../../../helper/dimensions.dart';
import '../../../helper/route_helper.dart';
import '../../../widget/hint_widget.dart';

class GuessPage extends StatefulWidget {
  const GuessPage({Key? key}) : super(key: key);

  @override
  State<GuessPage> createState() => _GuessPageState();
}

class _GuessPageState extends State<GuessPage> {
  late LevelModel country;
  late List<List<String>> lettersList;
  late List<List<String>> lettersListAnswer;
  late List<String> letters;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    List<LevelModel> levels =
        Get.find<LevelController>().getList(Get.arguments[0])!;
    country = Get.find<LevelController>()
        .getLevelList(Get.arguments[1], levels)[Get.arguments[2]];
    lettersList = getLettersList(country.country!);
    lettersListAnswer = getLettersListEmpty(country.country!);
    letters = generateRandomLetters(country.country!.toUpperCase().split(''));
  }

  void checkWin() {
    if (countryAnswer().toUpperCase() == country.country!.toUpperCase()) {
      Get.find<LevelController>().guessed(Get.arguments[0], country);
    } else {
      print('Wrong');
    }
  }

  String countryAnswer() {
    int wordAmount = lettersListAnswer.length;
    List<String> words = [];
    String result = '';
    for (int i = 0; i < wordAmount; i++) {
      words.add(lettersListAnswer[i].join(''));
    }

    for (int i = 0; i < words.length; i++) {
      result = words.join(' ');
    }

    return result;
  }

  int getWordAmount(String word) {
    return word.split(' ').length;
  }

  List<List<String>> getLettersList(String word) {
    List<String> words = word.toUpperCase().split(' ');
    List<List<String>> lettersList = [];
    words.forEach((element) {
      lettersList.add(element.split(''));
    });

    return lettersList;
  }

  List<List<String>> getLettersListEmpty(String word) {
    List<String> words = word.toUpperCase().split(' ');
    List<List<String>> lettersList = [];
    words.forEach((element) {
      lettersList.add(element.split(''));
    });

    lettersList.forEach((words) {
      for (int i = 0; i < words.length; i++) {
        words[i] = '';
      }
    });

    return lettersList;
  }

  List<String> generateRandomLetters(List<String> correctLetters) {
    List<String> result = correctLetters;
    int maxLetters = 16;
    Random random = Random();

    for (int i = result.length; i < maxLetters; i++) {
      int nextLetter = random.nextInt(25) + 65; //65 to 90
      result.add(String.fromCharCode(nextLetter).toUpperCase());
    }

    for (int i = 0; i < result.length; i++) {
      if (result[i] == ' ') {
        //TODO: || result[i] == '-'
        int nextLetter = random.nextInt(25) + 65; //65 to 90
        result[i] = String.fromCharCode(nextLetter).toUpperCase();
      }
    }

    result.shuffle();
    result.shuffle();
    result.shuffle();

    return result;
  }

  int getAnswerLetterAmount() {
    int amount = 0;
    for (int i = 0; i < lettersListAnswer.length; i++) {
      amount += lettersListAnswer[i].length;
    }
    return amount;
  }

  int getInputLetterAmount() {
    int amount = 0;
    for (int i = 0; i < lettersListAnswer.length; i++) {
      for (int j = 0; j < lettersListAnswer[i].length; j++) {
        if (lettersListAnswer[i][j] == '' || lettersListAnswer[i][j] == ' ') {
        } else {
          amount++;
        }
      }
    }
    return amount;
  }

  bool isAnswerFull() {
    if (getAnswerLetterAmount() == getInputLetterAmount()) {
      return true;
    }
    return false;
  }

  void putLetterInBox(String letter, int index) {
    if (isAnswerFull()) {
    } else {
      bool isDone = false;
      for (int j = 0; j < lettersListAnswer.length; j++) {
        for (int i = 0; i < lettersListAnswer[j].length; i++) {
          setState(() {
            if (lettersListAnswer[j][i] == '') {
              lettersListAnswer[j][i] = letter;
              i = lettersListAnswer[j].length;
              isDone = true;
            }
          });
        }
        if (isDone) {
          j = lettersListAnswer.length;
        }
      }

      setState(() {
        letters[index] = '';
      });
      checkWin();
    }
  }

  void removeLetter(String letter, int index, int wordIndex) {
    bool isDone = false;

    for (int i = 0; i < letters.length; i++) {
      setState(() {
        if (letters[i] == '') {
          letters[i] = letter;
          i = letters.length;
        }
      });
    }

    for (int i = 0; i < lettersListAnswer[wordIndex].length; i++) {
      setState(() {
        if (lettersListAnswer[wordIndex][index] == letter) {
          lettersListAnswer[wordIndex][index] = '';
          i = lettersListAnswer[wordIndex].length;
          isDone = true;
        }
      });
    }
  }

  void useFirstLetterHint() {}

  void useBombHint() {}

  void useFinishHint() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Guess'),
        ),
        bottomNavigationBar: country.guessed!
            ? Container(
                height: Dimensions.screenHeight / 3,
                color: Colors.grey,
              )
            : BottomAppBar(),
        body: SafeArea(
          child: GetBuilder<LevelController>(
            builder: (levelController) {
              print('Type = ' + Get.arguments[0].toString());
              print('Level = ' + Get.arguments[1].toString());
              print('Flag index = ' + Get.arguments[2].toString());

              return Padding(
                padding: EdgeInsets.only(
                    top: Dimensions.height10, bottom: Dimensions.height10),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          left: Dimensions.width10, right: Dimensions.width10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                GetBuilder<HintController>(
                                    builder: (hintController) {
                                  return HintWidget(
                                    onTap: () {
                                      useFinishHint();
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
                                GetBuilder<HintController>(
                                    builder: (hintController) {
                                  return HintWidget(
                                    onTap: () {
                                      useBombHint();
                                    },
                                    icon: ImageIcon(
                                      AssetImage('assets/icon/bomb.png'),
                                      color: AppColors.mainColor,
                                      size: Dimensions.iconSize24,
                                    ),
                                    num: '1',
                                  );
                                }),
                                SizedBox(
                                  width: Dimensions.width10,
                                ),
                                GetBuilder<HintController>(
                                    builder: (hintController) {
                                  return HintWidget(
                                    onTap: () {
                                      useFirstLetterHint();
                                    },
                                    icon: ImageIcon(
                                      AssetImage('assets/icon/a.png'),
                                      color: AppColors.mainColor,
                                      size: Dimensions.iconSize24,
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
                    SizedBox(height: Dimensions.height10),
                    Hero(
                      tag:
                          '${Get.find<CountryController>().getCountryCode(country.country!).toLowerCase()}',
                      child: Container(
                        width: double.maxFinite,
                        height: Dimensions.height20 * 14,
                        margin: EdgeInsets.symmetric(
                            horizontal: Dimensions.height20),
                        decoration: BoxDecoration(),
                        child: Image.asset(
                          'assets/image/flags/${Get.find<CountryController>().getCountryCode(country.country!).toLowerCase()}.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    country.guessed!
                        ? Expanded(
                            child: Container(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: Dimensions.width5,
                                    right: Dimensions.width5,
                                    top: Dimensions.height10),
                                child: Column(
                                  children: List.generate(
                                      getWordAmount(country.country!), (index) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                          bottom: Dimensions.height10 / 1.5),
                                      child: TileListGuessed(
                                          lettersList[index],
                                          country.country!
                                              .toUpperCase()
                                              .split(' ')[index]
                                              .split(''),
                                          index),
                                    );
                                  }),
                                ),
                              ),
                            ),
                          )
                        : Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: Dimensions.width5,
                                      right: Dimensions.width5,
                                      top: Dimensions.height10),
                                  child: Column(
                                    children: List.generate(
                                        getWordAmount(country.country!),
                                        (index) {
                                      return Padding(
                                        padding: EdgeInsets.only(
                                            bottom: Dimensions.height10 / 1.5),
                                        child: TileList(lettersList[index],
                                            lettersListAnswer[index], index, 0),
                                      );
                                    }),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(Dimensions.width10),
                                  child: Container(
                                    height:
                                        MediaQuery.of(context).size.width / 4,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: List.generate(
                                            8,
                                            (index) => letters[index] == ''
                                                ? EmptyTile()
                                                : GestureDetector(
                                                    onTap: () {
                                                      putLetterInBox(
                                                          letters[index],
                                                          index);
                                                    },
                                                    child: LetterTile(
                                                        letter: letters[index]),
                                                  ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: List.generate(
                                            8,
                                            (index) => letters[index + 8] == ''
                                                ? EmptyTile()
                                                : GestureDetector(
                                                    onTap: () {
                                                      putLetterInBox(
                                                          letters[index + 8],
                                                          index + 8);
                                                    },
                                                    child: LetterTile(
                                                        letter: letters[
                                                            index + 8])),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              );
            },
          ),
        ));
  }

  Wrap TileList(
      List<String> words, List<String> answer, int wordIndex, int splitIndex) {
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: List.generate(
        words.length,
        (index) => answer[index] == ''
            ? EmptyTile()
            : GestureDetector(
                onTap: () {
                  removeLetter(answer[index], index, wordIndex);
                },
                child: LetterTile(letter: answer[index]),
              ),
      ),
    );
  }

  Wrap TileListGuessed(List<String> words, List<String> answer, int wordIndex) {
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: List.generate(
        words.length,
        (index) => answer[index] == ''
            ? EmptyTile()
            : LetterTile(letter: answer[index]),
      ),
    );
  }
}
