import 'dart:math';

import 'package:flag_app/controllers/level_controller.dart';
import 'package:flag_app/models/level_model.dart';
import 'package:flag_app/widget/empty_tile.dart';
import 'package:flag_app/widget/letter_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_detector/flutter_swipe_detector.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../controllers/country_controller.dart';
import '../../../controllers/hint_controller.dart';
import '../../../helper/ad_helper.dart';
import '../../../helper/app_colors.dart';
import '../../../helper/dimensions.dart';
import '../../../helper/route_helper.dart';
import '../../../widget/ads/ad_banner_widget.dart';
import '../../../widget/hint_bar.dart';
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
  bool bombUsed = false;

  BannerAd? _bannerAd;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setInit();
    createBannerAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void createBannerAd() {
    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    ).load();
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
    bombUsed = false;
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
    int maxLetters = TILES_PR_ROW * tileRows;
    Random random = Random();

    for (int i = 0; i < result.length; i++) {
      if (result[i] == ' ' || result[i] == '-') {
        result.remove(result[i]);
      }
    }

    for (int i = result.length; i < maxLetters; i++) {
      int nextLetter = random.nextInt(25) + 65; //65 to 90
      result.add(String.fromCharCode(nextLetter).toUpperCase());
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

  void useFirstLetterHint(int hints) {
    if (Get.find<HintController>().getHints >= hints) {
      String letter = '';
      int index = 0;
      bool isDone = false;

      for (int i = 0; i < lettersListAnswer.length; i++) {
        for (int j = 0; j < lettersListAnswer[i].length; j++) {
          if (lettersListAnswer[i][j] == '') {
            isDone = true;
            letter = correctLettersList[i][j];
            j = lettersListAnswer[i].length;
          } else if (lettersListAnswer[i][j] != correctLettersList[i][j]) {
            for (int k = 0; k < allLetters.length; k++) {
              if (allLetters[k] == '') {
                removeLetter(lettersListAnswer[i][j], j, i);
                isDone = true;
                letter = correctLettersList[i][j];
                k = allLetters.length;
                j = lettersListAnswer[i].length;
              }
            }
          }
        }
        if (isDone) {
          i = lettersListAnswer.length;
        }
      }

      for (int i = 0; i < allLetters.length; i++) {
        if (allLetters[i] == letter) {
          index = i;
        }
      }
      putLetterInBox(letter, index);
      Get.find<HintController>().useHint(hints);
    } else {
      Get.toNamed(RouteHelper.getShopPage());
    }
  }

  void useBombHint(int hints) {
    if (Get.find<HintController>().getHints >= hints) {
      if (!bombUsed) {
        List<String> reducedLetters = [];
        List<String> tempAllList = [];
        List<String> correctList =
            country.country!.removeAllWhitespace.toUpperCase().split('');
        bool isDone = false;

        for (int i = 0; i < allLetters.length; i++) {
          tempAllList.add(allLetters[i]);
        }

        for (int i = 0; i < allLetters.length; i++) {
          reducedLetters.add('');
        }

        for (int j = 0; j < correctList.length; j++) {
          int index = tempAllList.indexOf(correctList[j]);
          tempAllList[index] = '';
          reducedLetters[index] = correctList[j];
        }

        setState(() {
          allLetters = reducedLetters;
          bombUsed = true;
        });
        Get.find<HintController>().useHint(hints);
      }
    } else {
      Get.toNamed(RouteHelper.getShopPage());
    }
  }

  void useFinishHint(int hints) {
    if (Get.find<HintController>().getHints >= hints) {
      setState(() {
        Get.find<LevelController>().guessed(Get.arguments[0], country);
      });
      Get.find<HintController>().useHint(hints);
    } else {
      Get.toNamed(RouteHelper.getShopPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('${Get.arguments[0]}'),
          backgroundColor: AppColors.mainColor,
        ),
        bottomNavigationBar:
            country.guessed! ? finishInfoBox() : BottomAppBar(),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      country.guessed!
                          ? Container()
                          : HintBar(
                              tapHintOne: () {
                                useFinishHint(5);
                              },
                              iconOne: Icon(
                                Icons.check,
                                color: AppColors.mainColor,
                              ),
                              hintPriceOne: '5',
                              tapHintTwo: () {
                                useBombHint(2);
                              },
                              iconTwo: ImageIcon(
                                AssetImage('assets/icon/bomb.png'),
                                color: AppColors.mainColor,
                                size: Dimensions.iconSize24,
                              ),
                              hintPriceTwo: '2',
                              tapHintThree: () {
                                useFirstLetterHint(1);
                              },
                              iconThree: ImageIcon(
                                AssetImage('assets/icon/a.png'),
                                color: AppColors.mainColor,
                                size: Dimensions.iconSize24,
                              ),
                              hintPriceThree: '1',
                            ),
                      SizedBox(height: Dimensions.height10),
                      Hero(
                        tag:
                            '${Get.find<CountryController>().getCountryCode(country.country!).toLowerCase()}',
                        child: FittedBox(
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          child: Container(
                            //width: double.maxFinite,
                            height: Dimensions.height20 * 13,
                            margin: EdgeInsets.symmetric(
                                horizontal: Dimensions.height20),
                            decoration: BoxDecoration(),
                            child: Image.asset(
                              'assets/image/${Get.arguments[0].toString().toLowerCase()}/${Get.find<CountryController>().getCountryCode(country.country!).toLowerCase()}.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      country.guessed!
                          ? Expanded(
                              child: guessTiles(correctLettersList, true),
                            )
                          : Expanded(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  guessTiles(lettersListAnswer, false),
                                  tilesAtBottom(),
                                ],
                              ),
                            ),
                      if (_bannerAd != null)
                        adBannerWidget(bannerAd: _bannerAd),
                    ],
                  ),
                );
              },
            ),
          ),
        ));
  }

  Container finishInfoBox() {
    return Container(
      height: Dimensions.screenHeight / 4,
      color: Colors.grey,
    );
  }

  Padding tilesAtBottom() {
    return Padding(
      padding: EdgeInsets.all(Dimensions.width10),
      child: Column(
          children:
              List.generate(getAmountOfTileRows(TILES_PR_ROW), (rowIndex) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(TILES_PR_ROW, (tileIndex) {
            int index = tileIndex + (TILES_PR_ROW * rowIndex);

            return Padding(
              padding: EdgeInsets.only(bottom: Dimensions.height10 / 2),
              child: allLetters[index] == ''
                  ? EmptyTile()
                  : GestureDetector(
                      onTap: () {
                        putLetterInBox(allLetters[index], index);
                      },
                      child: LetterTile(letter: allLetters[index]),
                    ),
            );
          }),
        );
      })),
    );
  }

  Padding guessTiles(List<List<String>> identifier, bool isGuessed) {
    return Padding(
      padding: EdgeInsets.only(
          left: Dimensions.width5,
          right: Dimensions.width5,
          top: Dimensions.height10),
      child: Column(
        children: List.generate(lettersListAnswer.length, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: Dimensions.height10 / 1.5),
            child: tileList(
              correctLettersList[index],
              identifier[index],
              index,
              isGuessed,
            ),
          );
        }),
      ),
    );
  }

  Wrap tileList(
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
