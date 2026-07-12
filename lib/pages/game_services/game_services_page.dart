import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/game_services_controller.dart';
import '../../helper/app_colors.dart';
import '../../helper/dimensions.dart';
import '../../widget/buttons/menu_button.dart';
import '../../widget/menu_background.dart';
import '../../widget/menu_page_header.dart';

class GameServicesPage extends StatelessWidget {
  const GameServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MenuBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              MenuPageHeader(
                title: 'Game services'.tr,
                showHintBadge: false,
                leadingAccentColor: AppColors.goldColor,
              ),
              Expanded(
                child: GetBuilder<GameServicesController>(
                  builder: (controller) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        Dimensions.width20,
                        Dimensions.height15,
                        Dimensions.width20,
                        Dimensions.height30,
                      ),
                      child: Column(
                        children: [
                          _GameServicesStatusCard(controller: controller),
                          SizedBox(height: Dimensions.height20),
                          MenuButton(
                            onTap: controller.showAchievements,
                            title: 'Achievements'.tr,
                            icon: Icons.emoji_events_rounded,
                            accentColor: AppColors.goldColor,
                            subText:
                                '${controller.catalog?.achievements.length ?? 23}',
                          ),
                          SizedBox(height: Dimensions.height10),
                          MenuButton(
                            onTap: controller.showLeaderboards,
                            title: 'Leaderboards'.tr,
                            icon: Icons.leaderboard_rounded,
                            accentColor: AppColors.skyColor,
                            subText:
                                '${controller.catalog?.leaderboards.length ?? 3}',
                          ),
                          if (controller.isConfigured &&
                              !controller.isSignedIn) ...[
                            SizedBox(height: Dimensions.height10),
                            MenuButton(
                              onTap: controller.signIn,
                              title: 'Sign in'.tr,
                              icon: Icons.login_rounded,
                              accentColor: AppColors.mainColor,
                            ),
                          ],
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

class _GameServicesStatusCard extends StatelessWidget {
  final GameServicesController controller;

  const _GameServicesStatusCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final statusColor = controller.isSignedIn
        ? AppColors.correctColor
        : controller.isConfigured
            ? AppColors.coralColor
            : AppColors.goldColor;
    final statusText = controller.isSignedIn
        ? 'Connected'.tr
        : controller.isConfigured
            ? 'Not connected'.tr
            : 'Platform setup required'.tr;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Dimensions.width20),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFFFE).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(Dimensions.radius20),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.mainBlackColor.withValues(alpha: 0.06),
            blurRadius: Dimensions.radius15,
            offset: Offset(0, Dimensions.height10 * 0.6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: Dimensions.width20 * 3,
            height: Dimensions.width20 * 3,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(Dimensions.radius20),
            ),
            child: Icon(
              Icons.sports_esports_rounded,
              color: statusColor,
              size: Dimensions.iconSize24 * 1.25,
            ),
          ),
          SizedBox(width: Dimensions.width15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Game services'.tr,
                  style: TextStyle(
                    color: AppColors.mainBlackColor,
                    fontSize: Dimensions.font20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: Dimensions.height10 / 2),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: Dimensions.font16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (controller.isBusy)
            SizedBox(
              width: Dimensions.iconSize24,
              height: Dimensions.iconSize24,
              child: CircularProgressIndicator(
                color: statusColor,
                strokeWidth: Dimensions.width5 * 0.5,
              ),
            ),
        ],
      ),
    );
  }
}
