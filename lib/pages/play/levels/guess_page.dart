import 'dart:math';

import 'package:flag_app/controllers/level_controller.dart';
import 'package:flag_app/models/level_model.dart';
import 'package:flag_app/widget/empty_tile.dart';
import 'package:flag_app/widget/letter_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_detector/flutter_swipe_detector.dart';
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
  late List<LevelModel> levels;
  late List<LevelModel> levelList;
  late LevelModel country;
  late List<List<String>> correctLettersList;
  late List<List<String>> lettersListAnswer;
  late List<String> allLetters;
  final int TILES_PR_ROW = 8;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setInit();
  }

  void setInit() {
    levels = Get.find<LevelController>().getList(Get.arguments[0])!;
    levelList =
        Get.find<LevelController>().getLevelList(Get.arguments[1], levels);
    country = levelList[Get.arguments[2]];
    correctLettersList = getCorrectLettersList(country.country!);
    lettersListAnswer = getLettersListEmpty(country.country!);
    allLetters =
        generateRandomLetters(country.country!.toUpperCase().split(''));
    print('\nLETTERS = ' +
        country.country!.removeAllWhitespace.length.toString());
  }

  void checkWin() {
    if (countryAnswer().removeAllWhitespace.toUpperCase() ==
        country.country!.removeAllWhitespace.toUpperCase()) {
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

    result = words.join(' ');

    List<String> temp = result.split('');
    for (int i = 0; i < temp.length; i++) {
      if (temp[i] == String.fromCharCode(8626)) {
        temp.remove(temp[i]);
      }
    }

    result = temp.join('');

    return result;
  }

  int getWordAmount(String word) {
    return word.split(' ').length;
  }

  List<List<String>> getCorrectLettersList(String word) {
    List<String> words = word.toUpperCase().split(' ');
    List<List<String>> lettersList = [];
    for (var word in words) {
      List<String> wordSplit = word.split('');
      if (wordSplit.length > 8) {
        List<String> temp = [];
        int maxLength = 6;
        for (int i = 0; i < wordSplit.length; i++) {
          if (temp.length == maxLength) {
            if (!wordSplit.contains('-')) {
              temp.add(String.fromCharCode(8626));
            }
            lettersList.add(temp);
            temp = [];
            temp.add(wordSplit[i]);
            maxLength += 2;
          } else {
            temp.add(wordSplit[i]);
          }
        }
        if (temp.isNotEmpty) {
          lettersList.add(temp);
        }
      } else {
        lettersList.add(word.split(''));
      }
    }

    return lettersList;
  }

  List<List<String>> getLettersListEmpty(String word) {
    List<List<String>> lettersList = getCorrectLettersList(word);

    lettersList.forEach((words) {
      for (int i = 0; i < words.length; i++) {
        if (words[i] == '-' || words[i] == String.fromCharCode(8626)) {
        } else {
          words[i] = '';
        }
      }
    });

    return lettersList;
  }

  int getAmountOfTileRows(int amount) {
    int tileRows =
        (country.country!.toUpperCase().split('').length / amount).ceil();
    if (tileRows < 2) {
      tileRows = 2;
    }
    return tileRows;
  }

  List<String> generateRandomLetters(List<String> correctLetters) {
    List<String> result = correctLetters;
    int tileRows = getAmountOfTileRows(TILES_PR_ROW);
    print('tileRows = $tileRows');
    print('tileRows = $tileRows');
    int maxLetters = TILES_PR_ROW * tileRows;
    Random random = Random();

    print('maxLetters = ' + maxLetters.toString());
    for (int i = 0; i < result.length; i++) {
      if (result[i] == ' ' || result[i] == '-') {
        result.remove(result[i]);
      }
    }

    for (int i = result.length; i < maxLetters; i++) {
      int nextLetter = random.nextInt(25) + 65; //65 to 90
      result.add(String.fromCharCode(nextLetter).toUpperCase());
    }

    print('All Letters : ' + result.toString());
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
        allLetters[index] = '';
      });
      checkWin();
    }
  }

  void removeLetter(String letter, int index, int wordIndex) {
    bool isDone = false;

    if (letter != '-') {
      for (int i = 0; i < allLetters.length; i++) {
        setState(() {
          if (allLetters[i] == '') {
            allLetters[i] = letter;
            i = allLetters.length;
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
        body: SwipeDetector(
          onSwipeRight: (value) {
            int nextPageIndex = Get.arguments[2];
            nextPageIndex = Get.arguments[2] - 1;

            if (nextPageIndex > -1) {
              setState(() {
                Get.arguments[2] = nextPageIndex;
                setInit();
              });
            }
          },
          onSwipeLeft: (value) {
            int nextPageIndex = Get.arguments[2];
            nextPageIndex = Get.arguments[2] + 1;
            if (nextPageIndex < levelList.length) {
              setState(() {
                Get.arguments[2] = nextPageIndex;
                setInit();
              });
            }
          },
          child: SafeArea(
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
                      country.guessed!
                          ? Container()
                          : Padding(
                              padding: EdgeInsets.only(
                                  left: Dimensions.width10,
                                  right: Dimensions.width10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                              AssetImage(
                                                  'assets/icon/bomb.png'),
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
                                  GetBuilder<HintController>(
                                      builder: (hintController) {
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
                                        lettersListAnswer.length, (index) {
                                      return Padding(
                                        padding: EdgeInsets.only(
                                            bottom: Dimensions.height10 / 1.5),
                                        child: TileList(
                                            correctLettersList[index],
                                            correctLettersList[index],
                                            index,
                                            true),
                                      );
                                    }),
                                  ),
                                ),
                              ),
                            )
                          : Expanded(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: Dimensions.width5,
                                        right: Dimensions.width5,
                                        top: Dimensions.height10),
                                    child: Column(
                                      children: List.generate(
                                          lettersListAnswer.length, (index) {
                                        return Padding(
                                          padding: EdgeInsets.only(
                                              bottom:
                                                  Dimensions.height10 / 1.5),
                                          child: TileList(
                                            correctLettersList[index],
                                            lettersListAnswer[index],
                                            index,
                                            false,
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(Dimensions.width10),
                                    child: Column(
                                        children: List.generate(
                                            getAmountOfTileRows(TILES_PR_ROW),
                                            (rowIndex) {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: List.generate(TILES_PR_ROW,
                                            (tileIndex) {
                                          int index = tileIndex +
                                              (TILES_PR_ROW * rowIndex);

                                          return Padding(
                                            padding: EdgeInsets.only(
                                                bottom:
                                                    Dimensions.height10 / 2),
                                            child: allLetters[index] == ''
                                                ? EmptyTile()
                                                : GestureDetector(
                                                    onTap: () {
                                                      putLetterInBox(
                                                          allLetters[index],
                                                          index);
                                                    },
                                                    child: LetterTile(
                                                        letter:
                                                            allLetters[index]),
                                                  ),
                                          );
                                        }),
                                      );
                                    })),
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                );
              },
            ),
          ),
        ));
  }

  Wrap TileList(
      List<String> words, List<String> answer, int wordIndex, bool isGuessed) {
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: List.generate(
        words.length,
        (index) => answer[index] == ''
            ? EmptyTile()
            : GestureDetector(
                onTap: () {
                  if (!isGuessed) {
                    removeLetter(answer[index], index, wordIndex);
                  }
                },
                child: LetterTile(letter: answer[index]),
              ),
      ),
    );
  }
}
/*
[
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: List.generate(
                                              8,
                                              (index) => allLetters[index] == ''
                                                  ? EmptyTile()
                                                  : GestureDetector(
                                                      onTap: () {
                                                        putLetterInBox(
                                                            allLetters[index],
                                                            index);
                                                      },
                                                      child: LetterTile(
                                                          letter: allLetters[
                                                              index]),
                                                    ),
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: List.generate(
                                              8,
                                              (index) => allLetters[index +
                                                          TILES_PR_ROW] ==
                                                      ''
                                                  ? EmptyTile()
                                                  : GestureDetector(
                                                      onTap: () {
                                                        putLetterInBox(
                                                            allLetters[index +
                                                                TILES_PR_ROW],
                                                            index +
                                                                TILES_PR_ROW);
                                                      },
                                                      child: LetterTile(
                                                          letter: allLetters[
                                                              index +
                                                                  TILES_PR_ROW])),
                                            ),
                                          ),
                                        ],
 */
