import 'package:flutter/material.dart';
import 'package:mirra/src/app/presentation/utils/constants.dart';

class DefaultButtonTheme {
  static ButtonStyle? buttonThemed(context,
      {bool useRed = false, bool noPadding = true}) {
    return Theme.of(context).elevatedButtonTheme.style?.copyWith(
          padding: MaterialStateProperty.all(EdgeInsets.zero),
          textStyle: MaterialStateProperty.all(
            Theme.of(context).textTheme.bodyMedium?.copyWith(),
          ),
          overlayColor:
              MaterialStateProperty.all(useRed ? kErrorColor : kAccentColor),
          foregroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return Colors.grey;
            }
            if (states.contains(MaterialState.pressed)) {
              return kWhiteColor;
            }
            return kPrimaryColor;
          }),
          backgroundColor: MaterialStateProperty.all(kWhiteColor),
        );
  }

  static ButtonStyle? blackButtonTheme(context) {
    return ButtonStyle(
      padding: MaterialStateProperty.all(EdgeInsets.zero),
      textStyle: MaterialStateProperty.all(
          Theme.of(context).textTheme.bodyMedium?.copyWith()),
      backgroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.pressed)) {
          return Colors.white;
        }
        return Colors.black;
      }),
      foregroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.pressed)) {
          return Colors.black;
        }
        return Colors.white;
      }),
    );
  }
}
