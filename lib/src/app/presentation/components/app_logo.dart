import 'package:flutter/material.dart';
import 'package:mirra/src/app/presentation/utils/constants.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/153DD5DB-35C2-42F3-9EE2-15B4D2306DF0.png',
      height: kPadding9,
    );
  }
}
