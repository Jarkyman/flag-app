import 'package:flag_app/helper/dimensions.dart';
import 'package:flutter/material.dart';

class EmptyTile extends StatelessWidget {
  const EmptyTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Dimensions.screenWidth / 12,
      width: Dimensions.screenWidth / 12,
      decoration: BoxDecoration(
        boxShadow: [
          const BoxShadow(
            color: Colors.grey,
          ),
          BoxShadow(
            color: Colors.grey.shade200,
            spreadRadius: -3.0,
            blurRadius: 3.0,
          ),
        ],
        borderRadius: BorderRadius.circular(Dimensions.radius10),
        border: Border.all(
          width: 1,
          color: Colors.black,
        ),
      ),
    );
  }
}
