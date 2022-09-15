import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helper/route_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () {
              Get.toNamed(RouteHelper.getFlagPage());
            },
            child: Container(
              width: 300,
              height: 100,
              color: Colors.blueAccent,
              child: Center(child: Text('Flag guess')),
            ),
          ),
          GestureDetector(
            onTap: () {
              Get.toNamed(RouteHelper.getFlagsPage());
            },
            child: Container(
              width: 300,
              height: 100,
              color: Colors.blueAccent,
              child: Center(child: Text('Flags guess')),
            ),
          ),
        ],
      ),
    );
  }
}
