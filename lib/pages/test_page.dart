import 'package:flag_app/widget/background_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/country_controller.dart';
import '../models/country_model.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  late List<CountryModel> countries;
  bool isLoading = true;
  int count = 0;
  TextEditingController textEditingController = TextEditingController();

  void generateCountries() {
    setState(() {
      countries = Get.find<CountryController>().getTestObj();
      isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    generateCountries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? CircularProgressIndicator()
          : BackgroundImage(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$count/${countries.length} - ${countries[count].countryCode} - ${countries[count].countryName}',
                    style: TextStyle(fontSize: 30),
                  ),
                  Container(
                    width: double.maxFinite,
                    height: 300,
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(),
                    child: Image.asset(
                      //'assets/image/flags/${countries[count].countryCode.toString().toLowerCase()}.png',
                      'assets/image/countries/${countries[count].countryCode.toString().toLowerCase()}-full.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        count++;
                      });
                    },
                    child: Text('NEXT'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        count--;
                      });
                    },
                    child: Text('BACK'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        count = 0;
                      });
                    },
                    child: Text('RESET'),
                  ),
                  TextField(
                    onSubmitted: (value) {
                      setState(() {
                        count = int.parse(value);
                      });
                    },
                    controller: textEditingController,
                    decoration: InputDecoration(
                      hintText: 'count',
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          width: 1.0,
                          color: Colors.white,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          width: 1.0,
                          color: Colors.white,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
