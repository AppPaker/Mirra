import 'package:flutter/material.dart';
import 'package:mirra/src/app/presentation/utils/constants.dart';
class CustomPageIndicator extends StatelessWidget {
  final int currentPage;
  final int numPages;

  const CustomPageIndicator(
      {super.key, required this.currentPage, required this.numPages});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kPurpleColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(numPages, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              width: currentPage == index ? 16.0 : 8.0,
              height: 8.0,
              decoration: BoxDecoration(
                color: currentPage == index ? Colors.blue : Colors.grey,
                borderRadius: BorderRadius.circular(4.0),
              ),
            );
          }),
        ),
      ),
    );
  }
}
