import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helper/app_colors.dart';
import '../../helper/app_constants.dart';
import '../../helper/app_runtime.dart';
import '../../helper/dimensions.dart';
import '../../helper/image_decode_size.dart';
import '../../helper/route_helper.dart';
import '../../widget/buttons/menu_button.dart';
import '../../widget/menu_background.dart';
import '../../widget/menu_page_header.dart';
import '../../widget/show_consent_form.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    if (AppRuntime.adsEnabled) {
      unawaited(showConsentForm());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MenuBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  Dimensions.width10,
                  Dimensions.headerTopSpacing,
                  Dimensions.width10,
                  0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MenuRoundButton(
                      icon: Icons.settings_outlined,
                      semanticLabel: '_Settings'.tr,
                      onTap: () => Get.toNamed(RouteHelper.getSettingsPage()),
                    ),
                    const MenuHintBadge(),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final screenSize = MediaQuery.sizeOf(context);
                    final fitAllCardsLayout =
                        constraints.maxWidth < 600 && screenSize.height >= 780;
                    final heroSize =
                        Dimensions.height45 * (fitAllCardsLayout ? 2.55 : 3.1);
                    final menuHeight =
                        Dimensions.height20 * (fitAllCardsLayout ? 3.25 : 3.7);
                    final menuGap =
                        Dimensions.height10 * (fitAllCardsLayout ? 0.7 : 1);
                    final sectionGap =
                        Dimensions.height20 * (fitAllCardsLayout ? 0.75 : 1);

                    return SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        Dimensions.width20,
                        Dimensions.height10 * (fitAllCardsLayout ? 0.6 : 1),
                        Dimensions.width20,
                        Dimensions.height30 * (fitAllCardsLayout ? 0.35 : 1),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: heroSize,
                            height: heroSize,
                            padding: EdgeInsets.all(Dimensions.width10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.45),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.mainColor
                                      .withValues(alpha: 0.12),
                                  blurRadius: Dimensions.radius30,
                                  offset: Offset(0, Dimensions.height10),
                                ),
                              ],
                            ),
                            child: Hero(
                              tag: AppConstants.FLAG_BALL_HERO,
                              createRectTween: (begin, end) =>
                                  MaterialRectCenterArcTween(
                                begin: begin,
                                end: end,
                              ),
                              child: Image.asset(
                                'assets/image/flag_ball.webp',
                                cacheWidth: imageDecodeWidth(
                                  logicalWidth: heroSize,
                                  devicePixelRatio:
                                      MediaQuery.devicePixelRatioOf(context),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: Dimensions.height10 *
                                (fitAllCardsLayout ? 0.7 : 1),
                          ),
                          Text(
                            'Flags Game',
                            style: TextStyle(
                              color: AppColors.mainBlackColor,
                              fontSize: Dimensions.font26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: Dimensions.width5 * 0.1,
                            ),
                          ),
                          SizedBox(height: sectionGap),
                          MenuButton(
                            onTap: () => Get.toNamed(
                                RouteHelper.getDailyChallengePage()),
                            title: 'Daily challenge'.tr,
                            icon: Icons.calendar_month_rounded,
                            accentColor: AppColors.purpleColor,
                            subText: '10',
                            height: menuHeight,
                          ),
                          SizedBox(height: menuGap),
                          MenuButton(
                            onTap: () => Get.toNamed(RouteHelper.getPlayPage()),
                            title: 'Play'.tr,
                            icon: Icons.explore_rounded,
                            accentColor: AppColors.mainColor,
                            height: menuHeight,
                          ),
                          SizedBox(height: menuGap),
                          MenuButton(
                            onTap: () => Get.toNamed(RouteHelper.getFlagPage()),
                            title: 'Find flag'.tr,
                            icon: Icons.flag_rounded,
                            accentColor: AppColors.coralColor,
                            height: menuHeight,
                          ),
                          SizedBox(height: menuGap),
                          MenuButton(
                            onTap: () =>
                                Get.toNamed(RouteHelper.getFlagsPage()),
                            title: 'Match flags'.tr,
                            icon: Icons.grid_view_rounded,
                            accentColor: AppColors.purpleColor,
                            height: menuHeight,
                          ),
                          SizedBox(height: menuGap),
                          MenuButton(
                            onTap: () =>
                                Get.toNamed(RouteHelper.getCountriesPage()),
                            title: 'Which country'.tr,
                            icon: Icons.public_rounded,
                            accentColor: AppColors.skyColor,
                            height: menuHeight,
                          ),
                          SizedBox(height: menuGap),
                          MenuButton(
                            onTap: () =>
                                Get.toNamed(RouteHelper.getGameServicesPage()),
                            title: 'Game services'.tr,
                            icon: Icons.emoji_events_rounded,
                            accentColor: AppColors.goldColor,
                            height: menuHeight,
                          ),
                          SizedBox(height: menuGap),
                          MenuButton(
                            key: const ValueKey('home-shop-menu-button'),
                            onTap: () => Get.toNamed(RouteHelper.getShopPage()),
                            title: 'Shop'.tr,
                            icon: Icons.shopping_bag_outlined,
                            accentColor: AppColors.yellowColor,
                            height: menuHeight,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
