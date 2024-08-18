import 'package:flutter/material.dart';

class AnimatedProfilePic extends StatefulWidget {
  final double top;
  final double left;
  final String imageUrl;
  final VoidCallback onComplete;

  const AnimatedProfilePic({
    super.key,
    required this.top,
    required this.left,
    required this.imageUrl,
    required this.onComplete,
  });

  @override
  _AnimatedProfilePicState createState() => _AnimatedProfilePicState();
}

class _AnimatedProfilePicState extends State<AnimatedProfilePic>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this, // Use 'this' as the TickerProvider
    );

    _animation = Tween<double>(begin: widget.top, end: widget.top - 100)
        .animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: _animation.value,
          left: widget.left,
          child: CircleAvatar(
            backgroundImage: NetworkImage(widget.imageUrl),
            radius: 50,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
