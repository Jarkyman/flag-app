import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../controllers/country_controller.dart';
import '../../../controllers/level_controller.dart';
import '../../../controllers/sound_controller.dart';
import '../../../helper/ad_helper.dart';
import '../../../helper/app_constants.dart';
import '../../../helper/dimensions.dart';
import '../../../helper/route_helper.dart';
import '../../../models/level_model.dart';
import '../../../widget/ads/ad_banner_widget.dart';
import '../../../widget/level_card.dart';
import '../../../widget/menu_background.dart';
import '../../../widget/menu_page_header.dart';

class LevelPage extends StatefulWidget {
  const LevelPage({super.key});

  @override
  State<LevelPage> createState() => _LevelPageState();
}

class _LevelPageState extends State<LevelPage> {
  BannerAd? _bannerAd;
  late String argType;
  late int argLevel;

  @override
  void initState() {
    super.initState();
    argType = Get.arguments[0];
    argLevel = Get.arguments[1];
    createBannerAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void createBannerAd() {
    if (!AdHelper.forcedAdsEnabled) return;

    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() => _bannerAd = ad as BannerAd);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Failed to load a banner ad: ${error.message}');
          ad.dispose();
        },
      ),
    ).load();
  }

  String countryImageCode(LevelModel level) {
    var countryCode = Get.find<CountryController>()
        .getCountryCode(level.country!)
        .toLowerCase();
    final usesFullFlag =
        countryCode == 'ni' || countryCode == 'py' || countryCode == 'sv';

    if (usesFullFlag && level.guessed! && argType == AppConstants.FLAGS) {
      countryCode = '$countryCode-full';
    }
    return countryCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MenuBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              MenuPageHeader(title: '${'Level'.tr} $argLevel'),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    Dimensions.width15,
                    Dimensions.height15,
                    Dimensions.width15,
                    Dimensions.height10,
                  ),
                  child: GetBuilder<LevelController>(
                    builder: (levelController) {
                      final levels =
                          levelController.getLevelList(argLevel, argType);

                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1,
                          mainAxisSpacing: Dimensions.height15,
                          crossAxisSpacing: Dimensions.width15,
                        ),
                        itemCount: levels.length,
                        itemBuilder: (context, index) {
                          final level = levels[index];
                          final imageCode = countryImageCode(level);

                          return GestureDetector(
                            onTap: () {
                              Get.find<SoundController>().windSound();
                              Get.toNamed(
                                RouteHelper.getGuessPage(),
                                arguments: [argType, argLevel, index],
                              );
                            },
                            child: Hero(
                              tag: imageCode.toLowerCase(),
                              child: LevelCard(
                                guessed: level.guessed!,
                                image:
                                    'assets/image/${argType.toLowerCase()}/${imageCode.toLowerCase()}.png',
                                option: argType,
                                number: index + 1,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              if (_bannerAd != null) AdBannerWidget(bannerAd: _bannerAd),
            ],
          ),
        ),
      ),
    );
  }
}
