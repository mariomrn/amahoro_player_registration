import 'package:flutter/material.dart';
import '../../theme/textStyles.dart';

class BasicWidgets{

  static Widget buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title.toUpperCase(),
        style: kTitleTextStyle,
      ),
    );
  }

}