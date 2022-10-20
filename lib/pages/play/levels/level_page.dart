import 'package:flag_app/controllers/level_controller.dart';
import 'package:flag_app/helper/app_colors.dart';
import 'package:flag_app/helper/app_constants.dart';
import 'package:flag_app/helper/route_helper.dart';
import 'package:flag_app/models/level_model.dart';
import 'package:flag_app/widget/background_image.dart';
import 'package:flag_app/widget/level_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../controllers/country_controller.dart';
import '../../../controllers/sound_controller.dart';
import '../../../helper/ad_helper.dart';
import '../../../helper/dimensions.dart';
import '../../../widget/ads/ad_banner_widget.dart';

class LevelPage extends StatefulWidget {
  const LevelPage({Key? key}) : super(key: key);

  @override
  State<LevelPage> createState() => _LevelPageState();
}

class _LevelPageState extends State<LevelPage> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(Get.locale!);
    print(Get.find<CountryController>().getCountries[1].currencyName);
    print(Get.find<LevelController>().getList(Get.arguments[0])![1].country);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.find<SoundController>().clickSound();
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios_new),
        ),
        title: Text('Level'.tr + ' ${Get.arguments[1]}'),
        backgroundColor: AppColors.mainColor,
      ),
      body: BackgroundImage(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: Dimensions.width10,
                    right: Dimensions.width10,
                    top: Dimensions.height30,
                  ),
                  child: GetBuilder<LevelController>(
                    builder: (levelController) {
                      print('Type = ' + Get.arguments[0].toString());
                      print('Level = ' + Get.arguments[1].toString());
                      List<LevelModel> levels = levelController.getLevelList(
                          Get.arguments[1], Get.arguments[0]);
                      return GridView.count(
                        childAspectRatio: 6 / 5,
                        mainAxisSpacing: Dimensions.height20,
                        crossAxisSpacing: Dimensions.height20,
                        crossAxisCount: 4,
                        children: List.generate(levels.length, (index) {
                          print(
                              '${Get.find<CountryController>().getCountryCode(levels[index].country!).toLowerCase()}');
                          print(levels[index].country!);
                          String countryCodeImg =
                              '${Get.find<CountryController>().getCountryCode(levels[index].country!).toLowerCase()}';
                          if ((countryCodeImg == 'ni' ||
                                  countryCodeImg == 'py' ||
                                  countryCodeImg == 'sv') &&
                              levels[index].guessed! &&
                              Get.arguments[0] == AppConstants.FLAGS) {
                            countryCodeImg =
                                '${Get.find<CountryController>().getCountryCode(levels[index].country!).toLowerCase()}-full';
                          }
                          return GestureDetector(
                            onTap: () {
                              Get.find<SoundController>().windSound();
                              Get.toNamed(RouteHelper.getGuessPage(),
                                  arguments: [
                                    //Get.arguments[0][index],
                                    Get.arguments[0],
                                    Get.arguments[1],
                                    index
                                  ]);
                            },
                            child: Hero(
                              tag: '${countryCodeImg.toLowerCase()}',
                              child: LevelCard(
                                guessed: levels[index].guessed!,
                                image:
                                    'assets/image/${Get.arguments[0].toString().toLowerCase()}/${countryCodeImg.toLowerCase()}.png',
                                option: Get.arguments[0],
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
              ),
              if (_bannerAd != null) adBannerWidget(bannerAd: _bannerAd),
            ],
          ),
        ),
      ),
    );
  }
}
