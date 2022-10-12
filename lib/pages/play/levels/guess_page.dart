import 'dart:convert';
import 'dart:math';

import 'package:animated_widgets/widgets/rotation_animated.dart';
import 'package:animated_widgets/widgets/shake_animated_widget.dart';
import 'package:flag_app/controllers/country_continent_controller.dart';
import 'package:flag_app/controllers/level_controller.dart';
import 'package:flag_app/models/level_model.dart';
import 'package:flag_app/widget/background_image.dart';
import 'package:flag_app/widget/tiles/empty_tile.dart';
import 'package:flag_app/widget/tiles/letter_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_detector/flutter_swipe_detector.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../controllers/country_controller.dart';
import '../../../controllers/hint_controller.dart';
import '../../../controllers/sound_controller.dart';
import '../../../helper/ad_helper.dart';
import '../../../helper/app_colors.dart';
import '../../../helper/dimensions.dart';
import '../../../helper/route_helper.dart';
import '../../../models/country_model.dart';
import '../../../widget/Top bar/hint_bar.dart';
import '../../../widget/ads/ad_banner_widget.dart';
import '../../../widget/info_column.dart';

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
  final int TILES_PR_ROW = 9;
  bool bombUsed = false;
  bool shakeTile = false;

  Random random = Random();

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;

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
    _interstitialAd?.dispose();
    super.dispose();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              Get.find<SoundController>().windSound();
              Get.back();
            },
          );

          setState(() {
            _interstitialAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          print('Failed to load an interstitial ad: ${err.message}');
        },
      ),
    );
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
    _loadInterstitialAd();
    levels = Get.find<LevelController>().getList(Get.arguments[0])!;
    levelList = Get.find<LevelController>()
        .getLevelList(Get.arguments[1], Get.arguments[0]);
    country = levelList[Get.arguments[2]];
    correctLettersList = getCorrectLettersList(country.country!);
    lettersListAnswer = getLettersListEmpty(country.country!);
    allLetters =
        generateRandomLetters(country.country!.toUpperCase().split(''));
    bombUsed = false;
    print(jsonEncode(country));
  }

  void checkWin() {
    if (countryAnswer().removeAllWhitespace.toUpperCase() ==
        country.country!.removeAllWhitespace.toUpperCase()) {
      Get.find<SoundController>().completeSound();
      Get.find<LevelController>().guessed(Get.arguments[0], country);
    } else {
      bool done = false;
      for (int i = 0; i < lettersListAnswer.length; i++) {
        if (!lettersListAnswer[i].contains('')) {
          done = true;
        }
      }
      if (done) {
        shakeTile = true;
        Get.find<SoundController>().wrongSound();
        Duration(milliseconds: 500).delay(() {
          setState(() {
            shakeTile = false;
          });
        });
      }
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
      if (temp[i] == String.fromCharCode(8626) || temp[i] == '/') {
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
      if (wordSplit.length > TILES_PR_ROW) {
        List<String> temp = [];
        int maxLength = TILES_PR_ROW - 2;
        if (wordSplit.contains('-') &&
            wordSplit.indexOf('-') + 1 <= TILES_PR_ROW) {
          maxLength = wordSplit.indexOf('-') + 1;
        }
        for (int i = 0; i < wordSplit.length; i++) {
          if (temp.length == maxLength || temp.contains('-')) {
            if (!wordSplit.contains('-')) {
              temp.add(String.fromCharCode(8626));
            }
            lettersList.add(temp);
            temp = [];
            temp.add(wordSplit[i]);
            if (temp.length >= TILES_PR_ROW) {
              maxLength += 2;
            }
          } else {
            temp.add(wordSplit[i]);
          }
        }
        if (temp.isNotEmpty) {
          if (temp.length <= 2) {
            if (lettersList.last.contains(String.fromCharCode(8626))) {
              lettersList.last.remove(String.fromCharCode(8626));
            }
            lettersList.last.addAll(temp);
          } else {
            lettersList.add(temp);
          }
        }
      } else {
        lettersList.add(word.split(''));
      }
    }

    if (lettersList.length > 1) {
      for (int i = 0; i < lettersList.length - 1; i++) {
        if ((lettersList[i].length + lettersList[i + 1].length) <=
            TILES_PR_ROW - 1) {
          lettersList[i].add('/');
          lettersList[i].addAll(lettersList[i + 1]);
          lettersList.removeAt(i + 1);
        }
      }
    }

    print(lettersList);

    return lettersList;
  }

  List<List<String>> getLettersListEmpty(String word) {
    List<List<String>> lettersList = getCorrectLettersList(word);

    lettersList.forEach((words) {
      for (int i = 0; i < words.length; i++) {
        if (words[i] == '-' ||
            words[i] == String.fromCharCode(8626) ||
            words[i] == '/') {
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

  String firstLetterUpperCase(String word) {
    List<String> wordList = word.split('');
    while (wordList[0] == ' ') {
      wordList.removeAt(0);
    }
    wordList[0] = wordList[0].toUpperCase();
    return wordList.join('');
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
      Get.find<SoundController>().completeSound();
    } else {
      Get.toNamed(RouteHelper.getShopPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              int randomInt = random.nextInt(4);
              if (_interstitialAd != null && randomInt == 3) {
                _interstitialAd?.show();
              } else {
                Get.find<SoundController>().windSound();
                Get.back();
              }
            },
            icon: Icon(Icons.arrow_back_ios_new),
          ),
          title: Text('${Get.arguments[0]}'.tr),
          backgroundColor: AppColors.mainColor,
          /*actions: [
            GestureDetector(
              onTap: () {
                Get.find<LevelController>()
                    .guessedRemove(Get.arguments[0], country);
              },
              child: Icon(Icons.refresh),
            ),
          ],*/ //Reset level
        ),
        body: BackgroundImage(
          child: SwipeDetector(
            onSwipeRight: (value) {
              int nextPageIndex = Get.arguments[2];
              nextPageIndex = Get.arguments[2] - 1;

              if (nextPageIndex > -1) {
                Get.find<SoundController>().windSound();
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
                Get.find<SoundController>().windSound();
                setState(() {
                  Get.arguments[2] = nextPageIndex;
                  setInit();
                });
              }
            },
            child: GetBuilder<LevelController>(
              builder: (levelController) {
                print('Type = ' + Get.arguments[0].toString());
                print('Level = ' + Get.arguments[1].toString());
                print('Flag index = ' + Get.arguments[2].toString());

                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    country.guessed!
                        ? Container(
                            height: Dimensions.height20 * 2,
                          )
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
                      child: Container(
                        height: Dimensions.height20 * 10,
                        margin: EdgeInsets.symmetric(
                            horizontal: Dimensions.height20),
                        decoration: BoxDecoration(),
                        child: Image.asset(
                          'assets/image/${Get.arguments[0].toString().toLowerCase()}/${Get.find<CountryController>().getCountryCode(country.country!).toLowerCase()}.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    country.guessed!
                        ? Expanded(
                            child: guessTiles(correctLettersList, true),
                          )
                        : Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                guessTiles(lettersListAnswer, false),
                                tilesAtBottom(),
                              ],
                            ),
                          ),
                    finishInfoBox(
                        Get.find<CountryController>()
                            .getCountryByName(country.country!),
                        !country.guessed!),
                  ],
                );
              },
            ),
          ),
        ));
  }

  finishInfoBox(CountryModel country, bool isGuessed) {
    var ad = adBannerWidget(bannerAd: _bannerAd);
    return Stack(
      alignment: Alignment.center,
      children: [
        !isGuessed
            ? Container(
                height: country.countryCode!.toLowerCase() == 'vc'
                    ? Dimensions.screenHeight / 4.5
                    : Dimensions.screenHeight / 3.4,
                decoration: BoxDecoration(
                  color: AppColors.mainColor.withOpacity(0.4),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(Dimensions.radius30),
                    topRight: Radius.circular(Dimensions.radius30),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                      left: Dimensions.width20,
                      right: Dimensions.width20,
                      top: Dimensions.width20),
                  child: Column(
                    children: [
                      InfoColumn(
                        header: 'Continent'.tr,
                        info: firstLetterUpperCase(
                            Get.find<CountryContinentController>()
                                .getContinentNameByCountryModel(country)),
                      ),
                      InfoColumn(
                        header: 'Country'.tr,
                        info: firstLetterUpperCase(country.countryName!),
                      ),
                      InfoColumn(
                        header: 'Capital'.tr,
                        info: firstLetterUpperCase(country.capital!),
                      ),
                      InfoColumn(
                        header: 'Currency'.tr,
                        info:
                            '${firstLetterUpperCase(country.currencyName!)} (${country.currencyCode!})',
                        divider: false,
                      ),
                    ],
                  ),
                ),
              )
            : _bannerAd != null && getAmountOfTileRows(TILES_PR_ROW) < 4
                ? Container(
                    height: _bannerAd!.size.height.toDouble(),
                  )
                : Container(),
        if (_bannerAd != null && getAmountOfTileRows(TILES_PR_ROW) < 4)
          Positioned(
            bottom: 0,
            child: adBannerWidget(bannerAd: _bannerAd),
          ),
      ],
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
            : answer[index] == '/'
                ? Container(
                    width: Dimensions.screenWidth / 10,
                  )
                : ShakeAnimatedWidget(
                    enabled: shakeTile,
                    duration: Duration(milliseconds: 500),
                    shakeAngle: Rotation.deg(z: 40),
                    curve: Curves.linear,
                    child: GestureDetector(
                      onTap: () {
                        if (!isGuessed) {
                          removeLetter(answer[index], index, wordIndex);
                        }
                      },
                      child: LetterTile(letter: answer[index]),
                    ),
                  ),
      ),
    );
  }
}
