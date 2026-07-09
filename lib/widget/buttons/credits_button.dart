import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../helper/app_colors.dart';
import '../../helper/dimensions.dart';

class CreditsButton extends StatelessWidget {
  CreditsButton({
    super.key,
  });

  final String credits = 'Credits Words'.tr;

  final String ccCredits =
      '\n\n${'Sound Effect from Pixabay'.tr}(https://pixabay.com/sound-effects)\n${'Countries are from Djiass map icon'.tr}(https://github.com/djaiss/mapsicon)';

  final String emailAddress = 'flags@hartvigsolutions.com';
  final Uri webPage = Uri.parse('https://hartvigsolutions.com/#flags-game');

  final Email email = Email(
    body: '\n\n\n'
        'What did you experience?\n\n'
        'If you have any photos or documentation, please send it along.\n\n',
    subject: 'Report',
    recipients: ['flags@hartvigsolutions.com'],
    isHTML: false,
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.bottomSheet(
          _CreditsSheet(
            credits: credits,
            ccCredits: ccCredits,
            emailAddress: emailAddress,
            onEmailTap: () => FlutterEmailSender.send(email),
            onWebsiteTap: () async {
              if (await canLaunchUrl(webPage)) {
                await launchUrl(webPage);
              }
            },
          ),
          backgroundColor: Colors.transparent,
          enableDrag: true,
          isScrollControlled: true,
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width15,
          vertical: Dimensions.height10,
        ),
        child: Text(
          'Credits'.tr,
          style: const TextStyle(
            color: AppColors.textColorGray,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _CreditsSheet extends StatelessWidget {
  final String credits;
  final String ccCredits;
  final String emailAddress;
  final Future<void> Function() onEmailTap;
  final Future<void> Function() onWebsiteTap;

  const _CreditsSheet({
    required this.credits,
    required this.ccCredits,
    required this.emailAddress,
    required this.onEmailTap,
    required this.onWebsiteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: Dimensions.screenHeight * 0.78,
      ),
      decoration: BoxDecoration(
        color: Color(0xFFFCFFFE),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimensions.radius30),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: Dimensions.height10),
          Container(
            width: Dimensions.width20 * 2.1,
            height: Dimensions.height10 / 2,
            decoration: BoxDecoration(
              color: AppColors.textColorGray.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(Dimensions.radius30),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                Dimensions.width20,
                Dimensions.height20,
                Dimensions.width20,
                Dimensions.height30,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: Dimensions.width20 * 2.2,
                        height: Dimensions.height20 * 2.2,
                        decoration: BoxDecoration(
                          color: AppColors.mainColor.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(Dimensions.radius15),
                        ),
                        child: const Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.mainColor,
                        ),
                      ),
                      SizedBox(width: Dimensions.width15),
                      Expanded(
                        child: Text(
                          'Credits'.tr,
                          style: TextStyle(
                            color: AppColors.mainBlackColor,
                            fontSize: Dimensions.font20 * 1.1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height20),
                  Text(
                    credits,
                    style: const TextStyle(
                      color: AppColors.mainBlackColor,
                      height: 1.45,
                    ),
                  ),
                  SizedBox(height: Dimensions.height20),
                  _CreditLink(
                    icon: Icons.mail_outline_rounded,
                    label: emailAddress,
                    onTap: onEmailTap,
                  ),
                  SizedBox(height: Dimensions.height10),
                  _CreditLink(
                    icon: Icons.language_rounded,
                    label: 'hartvigsolutions.com',
                    onTap: onWebsiteTap,
                  ),
                  SizedBox(height: Dimensions.height20),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(Dimensions.width15),
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(Dimensions.radius15),
                    ),
                    child: Text(
                      ccCredits.trim(),
                      style: TextStyle(
                        color: AppColors.mainBlackColor,
                        fontSize: Dimensions.font16 * 0.8,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreditLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final Future<void> Function() onTap;

  const _CreditLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.mainColor.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(Dimensions.radius15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.width15,
            vertical: Dimensions.height15,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppColors.mainColor,
                size: Dimensions.iconSize24,
              ),
              SizedBox(width: Dimensions.width10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.mainBlackColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.open_in_new_rounded,
                color: AppColors.textColorGray,
                size: Dimensions.iconSize16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
