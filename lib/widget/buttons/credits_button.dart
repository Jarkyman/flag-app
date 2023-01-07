import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../helper/app_colors.dart';
import '../../helper/dimensions.dart';

class CreditsButton extends StatelessWidget {
  CreditsButton({
    Key? key,
  }) : super(key: key);

  final String credits = 'Credits Words'.tr;

  final String ccCredits = '\n\n' +
      'Sound Effect from Pixabay'.tr +
      '(https://pixabay.com/sound-effects)\n' +
      'Countries are from Djiass map icon'.tr +
      '(https://github.com/djaiss/mapsicon)';

  final String emailAddress = 'hartvig.develop@gmail.com';
  final Uri webPage = Uri.parse('http://flagsgame.epizy.com/support');

  final Email email = Email(
    body: '\n\n\n'
        'What did you experience?\n\n'
        'If you have any photos or documentation, please send it along.\n\n',
    subject: 'Report',
    recipients: ['hartvig.develop@gmail.com'],
    isHTML: false,
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.bottomSheet(
          Container(
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(Dimensions.radius30),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                      left: Dimensions.width20,
                      right: Dimensions.width20,
                      top: Dimensions.height10,
                      bottom: Dimensions.height45),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: Dimensions.height30,
                      ),
                      Text(credits, textScaleFactor: 1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Email: ',
                            textScaleFactor: 1,
                          ),
                          GestureDetector(
                            onTap: () async {
                              await FlutterEmailSender.send(email);
                            },
                            child: Text(
                              emailAddress,
                              textScaleFactor: 1,
                              style: const TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text(
                            'Website: ',
                            textScaleFactor: 1,
                          ),
                          GestureDetector(
                            onTap: () async {
                              if (await canLaunchUrl(webPage)) {
                                await launchUrl(webPage);
                              } else {
                                throw 'Could not launch $webPage';
                              }
                            },
                            child: const Text(
                              'support page',
                              textScaleFactor: 1,
                              style: TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        ccCredits,
                        textScaleFactor: 1,
                      ),
                    ],
                  ),
                ),
              )),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimensions.radius30)),
          enableDrag: true,
        );
      },
      child: Text(
        'Credits'.tr,
        style: TextStyle(color: AppColors.textColorGray),
      ),
    );
  }
}
