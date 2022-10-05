import 'package:flag_app/helper/dimensions.dart';
import 'package:flutter/material.dart';

class LetterTile extends StatelessWidget {
  final String letter;

  const LetterTile({Key? key, required this.letter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Dimensions.screenWidth / 12,
      width: Dimensions.screenWidth / 12,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            stops: [
              0.34,
              0.42,
            ],
            colors: [
              Colors.white,
              Colors.grey.shade300
            ]),
        borderRadius: BorderRadius.circular(Dimensions.radius10),
        border: Border.all(
          width: 1,
          color: Colors.black,
        ),
      ),
      child: Center(
          child: Text(
        letter,
        style: TextStyle(
            fontSize: Dimensions.font16 * 1.2, fontWeight: FontWeight.bold),
      )),
    );
  }
}
