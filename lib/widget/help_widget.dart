import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../helper/dimensions.dart';

class HelpWidget extends StatelessWidget {
  final Widget icon;
  final String description;

  const HelpWidget({
    Key? key,
    required this.icon,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
            height: Dimensions.height30,
            width: Dimensions.width30,
            child: icon),
        const Text(' - '),
        Expanded(
          child: SizedBox(
            height: Dimensions.height30 * 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: AutoSizeText(
                description,
                maxLines: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
