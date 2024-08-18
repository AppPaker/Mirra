import 'package:flutter/material.dart';
import 'package:mirra/src/app/presentation/utils/constants.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GradientAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.useBorder = false,
    this.centerTitle = true,
  });

  final Widget title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool useBorder;
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: BoxDecoration(
          gradient: const RadialGradient(
            center: Alignment(1.2, 1.3),
            radius: 1.3,
            colors: [
              kPurpleColor,
              kPurpleColor,

              /*Color(0xDE7644CB),
                Color(0xFF7E28FE),
                Color(0xFF034EBA),*/
            ],
            /*stops: [0, 0.1, 0.45, 0.9, 1],
            begin: Alignment(1, 1.35), // Bottom right
            end: Alignment(-1, -1.35), // Top left*/
          ),
          borderRadius: useBorder
              ? const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                )
              : null,
        ),
        child: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: centerTitle,
          title: title,
          actions: actions,
          leading: leading,
          shape: useBorder
              ? const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
