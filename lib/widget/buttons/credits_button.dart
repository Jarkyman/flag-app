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

  final String credits = 'This is an app with flags from all over the world\n\n'
      'If you love flags, countries and coat of arms, this is the perfect app for you.\n'
      'I have collected all the countries and some information about them.\n'
      'As you complete each level and work your way through all the flags you '
      'will learn a lot of new things, the capital, the currency and what the flag looks like.'
      '\n\nThere is also the option to practice, here you play with a flag or a country and '
      'get options on which country it is.\nTo practice your skills for the flags of the different countries'
      '\n\nYou have the option to complete levels with flags, countries, and coats of arms.'
      '\nAs you get through the different levels, you get better and better. See if you can complete all the levels.'
      '\n\nLanguage in the app:\nBrasileiro\nDansk\nDeutsch\nEnglish\nEspañol\nFrançais\nNorsk\nPortuguês\nSvenska\n\n'
      'If you find any errors or mistakes, please write to me at';

  final String ccCredits =
      '\n\nSound Effect from Pixabay (https://pixabay.com/sound-effects)\nCountries are from Djiass map icon (https://github.com/djaiss/mapsicon)';

  final String emailAddress = 'hartvig.develop@gmail.com';
  final Uri webPage =
      Uri.parse('https://sites.google.com/view/flagsgame/support');

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
