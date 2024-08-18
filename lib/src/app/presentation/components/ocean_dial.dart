import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class OceanScoreDial extends StatelessWidget {
  final Map<String, dynamic> oceanScores;
  final double width;
  final double height;

  const OceanScoreDial({
    super.key,
    required this.oceanScores,
    this.width = 70.0,
    this.height = 70.0,
  });

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("Building OceanScoreDial with scores: $oceanScores");
    }

    return CustomPaint(
      size: Size(width, height), // Use the provided size
      painter: _OceanScoreDialPainter(oceanScores),
    );
  }
}

class _OceanScoreDialPainter extends CustomPainter {
  final Map<String, dynamic> oceanScores;
  final double maxScore; // The maximum score possible for a trait

  _OceanScoreDialPainter(this.oceanScores, {this.maxScore = 5});

  // Map of trait initials to their corresponding colors
  final Map<String, Color> traitColors = {
    'O': Colors.orange,
    'C': Colors.cyan,
    'E': Colors.green,
    'A': Colors.red,
    'N': Colors.blue,
  };

  @override
  void paint(Canvas canvas, Size size) {
    if (kDebugMode) {
      print("Painting OceanScoreDial with size: $size");
    }

    const double padding = 8.0;
    const double barHeight = 15.0; // Set a fixed height for thinner bars

    double startY = (size.height -
            (barHeight * oceanScores.length +
                padding * (oceanScores.length - 1))) /
        2;

    const textStyle = TextStyle(
        color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold);
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    // Define the order of the traits
    const order = ['O', 'C', 'E', 'A', 'N'];

    for (var trait in order) {
      final score = oceanScores[trait];
      if (score == null) continue;

      final normalizedScore = (score + maxScore) / (2 * maxScore);
      final barWidth = normalizedScore * size.width;

      // Calculate the starting x-coordinate for the bar to be centered
      final startX = (size.width - barWidth) / 2;

      // Set the paint color based on the trait
      final paint = Paint()..color = traitColors[trait] ?? Colors.grey;

      // Create a rounded rectangle and draw it
      final roundedRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(startX, startY, barWidth, barHeight),
          const Radius.circular(
              20) // This controls the roundness of the corners
          );
      canvas.drawRRect(roundedRect, paint);

      // Calculate the vertical center for the text
      final textY = startY + (barHeight - textStyle.fontSize!) / 2;

      // Draw the trait letters at the center of the bar
      textPainter.text = TextSpan(text: trait, style: textStyle);
      textPainter.layout();
      textPainter.paint(
          canvas, Offset(startX + barWidth / 2 - textPainter.width / 2, textY));

      startY += barHeight + padding;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
