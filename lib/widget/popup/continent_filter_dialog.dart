import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/sound_controller.dart';
import '../../helper/app_colors.dart';
import '../../helper/dimensions.dart';
import '../../models/training_continent.dart';
import 'app_dialog.dart';

Future<TrainingContinent?> showContinentFilterDialog({
  required BuildContext context,
  required TrainingContinent selectedContinent,
  required Color accentColor,
  required int Function(TrainingContinent continent) recordFor,
}) {
  return showDialog<TrainingContinent>(
    context: context,
    builder: (context) => AppDialog(
      accentColor: accentColor,
      accentEndColor: AppColors.yellowColor,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          Dimensions.width20,
          Dimensions.height15,
          Dimensions.width20,
          Dimensions.height20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppDialogHeader(
              title: 'Choose continent'.tr,
              icon: Icons.travel_explore_rounded,
              accentColor: accentColor,
            ),
            SizedBox(height: Dimensions.height15),
            _ContinentOption(
              continent: TrainingContinent.all,
              selected: selectedContinent == TrainingContinent.all,
              record: recordFor(TrainingContinent.all),
              accentColor: accentColor,
            ),
            SizedBox(height: Dimensions.height10),
            ..._continentRows(
              selectedContinent: selectedContinent,
              accentColor: accentColor,
              recordFor: recordFor,
            ),
          ],
        ),
      ),
    ),
  );
}

List<Widget> _continentRows({
  required TrainingContinent selectedContinent,
  required Color accentColor,
  required int Function(TrainingContinent continent) recordFor,
}) {
  final continents = TrainingContinent.values.skip(1).toList();
  final rows = <Widget>[];

  for (var index = 0; index < continents.length; index += 2) {
    final first = continents[index];
    final second = continents[index + 1];
    rows.add(
      Row(
        children: [
          Expanded(
            child: _ContinentOption(
              continent: first,
              selected: selectedContinent == first,
              record: recordFor(first),
              accentColor: accentColor,
            ),
          ),
          SizedBox(width: Dimensions.width10),
          Expanded(
            child: _ContinentOption(
              continent: second,
              selected: selectedContinent == second,
              record: recordFor(second),
              accentColor: accentColor,
            ),
          ),
        ],
      ),
    );
    if (index < continents.length - 2) {
      rows.add(SizedBox(height: Dimensions.height10));
    }
  }
  return rows;
}

class _ContinentOption extends StatelessWidget {
  final TrainingContinent continent;
  final bool selected;
  final int record;
  final Color accentColor;

  const _ContinentOption({
    required this.continent,
    required this.selected,
    required this.record,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: continent.translationKey.tr,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (Get.isRegistered<SoundController>()) {
              Get.find<SoundController>().clickSound();
            }
            Navigator.of(context).pop(continent);
          },
          borderRadius: BorderRadius.circular(Dimensions.radius15),
          child: Ink(
            height: Dimensions.height20 * 2.65,
            padding: EdgeInsets.symmetric(horizontal: Dimensions.width10),
            decoration: BoxDecoration(
              color: selected
                  ? accentColor.withValues(alpha: 0.12)
                  : AppColors.lightGreen.withValues(alpha: 0.54),
              borderRadius: BorderRadius.circular(Dimensions.radius15),
              border: Border.all(
                color: accentColor.withValues(alpha: selected ? 0.55 : 0.14),
                width: Dimensions.width5 * 0.2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: Dimensions.width20 * 1.55,
                  height: Dimensions.height20 * 1.55,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(Dimensions.radius10),
                  ),
                  child: Icon(
                    _continentIcon(continent),
                    color: accentColor,
                    size: Dimensions.iconSize16,
                  ),
                ),
                SizedBox(width: Dimensions.width10 * 0.7),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        continent.translationKey.tr,
                        maxLines: 1,
                        presetFontSizes: [
                          Dimensions.font16 * 0.82,
                          Dimensions.font16 * 0.72,
                          Dimensions.font16 * 0.62,
                        ],
                        style: TextStyle(
                          color: AppColors.mainBlackColor,
                          fontSize: Dimensions.font16 * 0.82,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: Dimensions.height10 * 0.15),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: AppColors.yellowColor,
                            size: Dimensions.iconSize16 * 0.72,
                          ),
                          SizedBox(width: Dimensions.width5 * 0.35),
                          Text(
                            '$record',
                            style: TextStyle(
                              color: AppColors.textColorGray,
                              fontSize: Dimensions.font16 * 0.7,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (selected) ...[
                            const Spacer(),
                            Icon(
                              Icons.check_circle_rounded,
                              color: accentColor,
                              size: Dimensions.iconSize16 * 0.82,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

IconData _continentIcon(TrainingContinent continent) {
  return switch (continent) {
    TrainingContinent.all => Icons.public_rounded,
    TrainingContinent.africa => Icons.wb_sunny_rounded,
    TrainingContinent.asia => Icons.temple_buddhist_rounded,
    TrainingContinent.europe => Icons.account_balance_rounded,
    TrainingContinent.northAmerica => Icons.location_city_rounded,
    TrainingContinent.oceania => Icons.water_rounded,
    TrainingContinent.southAmerica => Icons.forest_rounded,
  };
}
