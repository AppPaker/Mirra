import 'package:flutter/material.dart';
import 'package:mirra/src/app/presentation/utils/constants.dart';

class MirrorElevatedButton extends StatelessWidget {
  final BorderRadiusGeometry? borderRadius;
  final double? width;
  final double height;
  final Gradient gradient;
  final VoidCallback? onPressed;
  final Widget child;
  final TextStyle? textStyle;

  const MirrorElevatedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.textStyle = const TextStyle(color: kPurpleColor), // Set a default color
    this.borderRadius,
    this.width,
    this.height = 44.0,
    this.gradient = const LinearGradient(
      colors: [
        Colors.white30,
        Colors.white30
        /*Color(0xFF1E90C6),
        Color(0xDE7644CB),
        Color(0xFF034EBA),
        Color(0xFF1E90C6),*/
      ],
    ),

  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = this.borderRadius ?? BorderRadius.circular(10);
    return Material(
      elevation: 8.0,
      borderRadius: borderRadius,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: borderRadius,
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius,
              side: BorderSide(color: kPrimaryColor),
            ),
          ),
          child: DefaultTextStyle(
            style: textStyle ?? Theme.of(context).textTheme.labelLarge!,
            child: child,
          ),
        ),
      ),
    );
  }
}
