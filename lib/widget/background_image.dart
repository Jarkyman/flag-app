import 'package:flutter/cupertino.dart';

import '../helper/app_colors.dart';

class BackgroundImage extends StatelessWidget {
  final Widget child;

  const BackgroundImage({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.lightGreen,
            AppColors.lightGreen2,
          ],
        ),
      ),
      child: child,
    );
  }
}
