import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// light theme
ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 13, 13, 13),
    brightness: Brightness.light,
  ),
  useMaterial3: true,
  textTheme: GoogleFonts.spaceGroteskTextTheme(ThemeData.light().textTheme),
  fontFamily: GoogleFonts.spaceGrotesk().fontFamily,
);

// dark theme
ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 228, 228, 228),
    brightness: Brightness.dark,
  ),
  useMaterial3: true,
  textTheme: GoogleFonts.spaceGroteskTextTheme(ThemeData.dark().textTheme),
  fontFamily: GoogleFonts.spaceGrotesk().fontFamily,
);
