import 'package:flag_app/helper/dimensions.dart';
import 'package:flutter/material.dart';

class LevelCard extends StatelessWidget {
  final bool guessed;
  final String image;

  const LevelCard({Key? key, required this.guessed, required this.image})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        image: guessed
            ? DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage(image),
              )
            : DecorationImage(
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.grey, BlendMode.color),
                image: AssetImage(image),
              ),
      ),
    );
  }
}
