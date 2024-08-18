import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mirra/src/app/presentation/utils/constants.dart';

MaterialColor generateMaterialColor(Color color) {
  return MaterialColor(
    color.value,
    {
      50: tintColor(color, 0.9),
      100: tintColor(color, 0.8),
      200: tintColor(color, 0.6),
      300: tintColor(color, 0.4),
      400: tintColor(color, 0.2),
      500: color,
      600: shadeColor(color, 0.1),
      700: shadeColor(color, 0.2),
      800: shadeColor(color, 0.3),
      900: shadeColor(color, 0.4),
    },
  );
}

int tintValue(int value, double factor) =>
    max(0, min((value + ((255 - value) * factor)).round(), 255));

Color tintColor(Color color, double factor) => Color.fromRGBO(
    tintValue(color.red, factor),
    tintValue(color.green, factor),
    tintValue(color.blue, factor),
    1);

int shadeValue(int value, double factor) =>
    max(0, min(value - (value * factor).round(), 255));

Color shadeColor(Color color, double factor) => Color.fromRGBO(
      shadeValue(color.red, factor),
      shadeValue(color.green, factor),
      shadeValue(color.blue, factor),
      1,
    );

class AppTheme {
  ThemeData theme = ThemeData(
      fontFamily: GoogleFonts.lato().fontFamily,
      scaffoldBackgroundColor: kBackgroundColor,
      textTheme: TextTheme(
        titleSmall: GoogleFonts.lato(
          color: kWhiteColor,
          fontSize: kBodyFontSize3,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: GoogleFonts.lato(
          color: kPrimaryColor,
          fontSize: kBodyFontSize4,
          fontWeight: FontWeight.w400,
        ),
        titleLarge: GoogleFonts.lato(
          color: kWhiteColor,
          fontSize: kBodyFontSize6,
          fontWeight: FontWeight.w700,
        ),
        labelLarge: GoogleFonts.lato(
          color: kBlackColor,
          fontSize: kBodyFontSize6,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: GoogleFonts.lato(
          color: kBlackColor,
          fontSize: kBodyFontSize4,
          fontWeight: FontWeight.w600,
        ),
        labelSmall: GoogleFonts.lato(
          color: kBlackColor,
          fontSize: kBodyFontSize2,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.lato(
          color: kBlackColor,
          fontSize: kBodyFontSize3,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: GoogleFonts.lato(
          color: kBlackColor,
          fontSize: kBodyFontSize2,
          fontWeight: FontWeight.w600,
        ),
        bodySmall: GoogleFonts.lato(
          color: kBlackColor,
          fontSize: kBodyFontSize1,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.italic
        ),
        displayMedium: GoogleFonts.lato(
          color: kBlackColor,
          fontSize: kBodyFontSize4,
          fontWeight: FontWeight.w400,
        ),
      ),
      primarySwatch: generateMaterialColor(kSecondaryColor),
      indicatorColor: kSecondaryColor,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all(
            GoogleFonts.lato(
              color: kWhiteColor,
              fontSize: kBodyFontSize4,
              fontWeight: FontWeight.w600,
            ),
          ),
          foregroundColor: MaterialStateProperty.all(kWhiteColor),
          backgroundColor: MaterialStateProperty.all(kAccentColor),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        side: const BorderSide(color: kWhiteColor),
        fillColor: MaterialStateProperty.all(kSecondaryColor),
        checkColor: MaterialStateProperty.all(kAccentColor),
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(horizontal: kPadding3),
        hintStyle: GoogleFonts.lato(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
            fontSize: kBodyFontSize3),
        labelStyle: GoogleFonts.lato(color: Colors.grey),
        fillColor: Colors.white70,
        filled: true,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kPadding4),
            borderSide: const BorderSide(color: Colors.transparent)),
      ),
      sliderTheme: const SliderThemeData(
        thumbColor: Colors.blue,
        activeTrackColor: Colors.blue,
      ));

  ThemeData darkTheme = ThemeData(
    fontFamily: GoogleFonts.lato().fontFamily,
    scaffoldBackgroundColor: Colors.white,
    primarySwatch: Colors.blue,
  );
}
