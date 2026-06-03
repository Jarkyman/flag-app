import 'package:flutter/material.dart';

import '../helper/app_colors.dart';

class InfoColumn extends StatelessWidget {
  final String header;
  final String info;
  final bool divider;

  const InfoColumn({
    super.key,
    required this.info,
    required this.header,
    this.divider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$header: '),
            Text(info),
          ],
        ),
        if (divider)
          const Divider(
            color: AppColors.mainColor,
          ),
      ],
    );
  }
}
