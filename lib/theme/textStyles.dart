import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

TextStyle kTitleTextStyle = GoogleFonts.inter(
  textStyle: TextStyle(color: kAmahoroColor, letterSpacing: .5, fontWeight: FontWeight.w500),
);
TextStyle kDefaultTextStyle = GoogleFonts.inter(
  textStyle: TextStyle(color: kAmahoroColor),
);
TextStyle kDefaultTextStyle11pt = GoogleFonts.inter(
  textStyle: TextStyle(fontSize: 11, color: kAmahoroColor),
);

TextStyle kPlayerCardLeagueTS = GoogleFonts.patrickHand(
  textStyle: TextStyle(fontSize: 35, letterSpacing: 2, fontWeight: FontWeight.w700, color: kAmahoroColor),
);

TextStyle kPlayerCardSubtitleTS = GoogleFonts.patrickHand(
  textStyle: TextStyle(fontSize: 20, letterSpacing: 1, fontWeight: FontWeight.w700, color: Colors.black54),
);

TextStyle kPlayerCardTextTS = GoogleFonts.patrickHand(
  textStyle: TextStyle(fontSize: 22, letterSpacing: 1, fontWeight: FontWeight.w800, color: Colors.black54),
);