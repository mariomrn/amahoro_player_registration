import 'package:flutter/material.dart';

Color kAmahoroColor = Color.fromRGBO(163, 119, 101, 1);
const MaterialColor kAmahoroColorMaterial = MaterialColor(
  0xffa37765, // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
  <int, Color>{
    50: Color(0xffe3d6d1), //10%
    100: Color(0xffd1bbb2), //20%
    200: Color(0xffbfa093), //30%
    300: Color(0xffac8574), //40%
    400: Color(0xffa37765), //50%
    500: Color(0xff825f51), //60%
    600: Color(0xff725347), //70%
    700: Color(0xff62473d), //80%
    800: Color(0xff413028), //90%
    900: Color(0xff211814), //100%
  },
);
