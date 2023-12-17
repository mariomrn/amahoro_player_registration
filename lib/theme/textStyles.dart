import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

TextStyle kTitleTextStyle = GoogleFonts.inter(
  textStyle: TextStyle(color: kAmahoroColor, letterSpacing: .5, fontWeight: FontWeight.w500),
);
TextStyle kDefaultTextStyle = GoogleFonts.inter(
  textStyle: TextStyle(color: kAmahoroColor),
);
TextStyle kDefaultTextStyle10pt = GoogleFonts.inter(
  textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.black54),
);
TextStyle kDefaultTextStyle11pt = GoogleFonts.inter(
  textStyle: TextStyle(fontSize: 11, color: kAmahoroColor),
);
TextStyle kDefaultTextStyle15pt = GoogleFonts.inter(
  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54),
);
TextStyle kDefaultTextStyleHeader = GoogleFonts.inter(
  textStyle: const TextStyle(fontSize: 40, fontWeight: FontWeight.w600, color: Color(0xff211814)),
);
TextStyle kTeamSelectionTextStyle = GoogleFonts.inter(
  textStyle: TextStyle(letterSpacing: -1.0, fontSize: 17, fontWeight: FontWeight.w600, color: kAmahoroColor),
);

TextStyle kNameTS = GoogleFonts.inter(
  textStyle: const TextStyle(fontSize: 20, letterSpacing: -1.0, fontWeight: FontWeight.w600, color: Color(0xff211814)),
);
TextStyle kBirthdayTS = GoogleFonts.inter(
  textStyle: const TextStyle(fontSize: 18, letterSpacing: -1.0, fontWeight: FontWeight.w500, color: Color(0xff211814)),
);

TextStyle kPlayerCardLeagueTS = GoogleFonts.inter(
  textStyle: TextStyle(fontSize: 30, letterSpacing: 2, fontWeight: FontWeight.w500, color: kAmahoroColor),
);

TextStyle kPlayerCardSubtitleTS = GoogleFonts.inter(
  textStyle: TextStyle(fontSize: 15, letterSpacing: 1, fontWeight: FontWeight.w500, color: Colors.black),
);

TextStyle kPlayerCardTextTS = GoogleFonts.inter(
  textStyle: TextStyle(fontSize: 15, letterSpacing: 0, fontWeight: FontWeight.w500, color: Colors.black),
);