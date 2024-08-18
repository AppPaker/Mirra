import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../config/constants.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  List<String> images = [
    'assets/images/mirraloading_White.gif',
    'assets/images/mirraloading_White.gif',
    // Add more image paths...
  ];
  late String currentImage;
  late Timer timer;
  Random random = Random();
  double opacityLevel = 1.0;
  /*List<String> quotes = [
    '"Knowing yourself is the beginning of all wisdom." - Aristotle',
    '"The only journey is the journey within." - Rainer Maria Rilke',
    '"The greatest discovery of all time is that a person can change his future by merely changing his attitude." - Oprah Winfrey',
    "\"Believe you can and you're halfway there.\" - Theodore Roosevelt",
    '"The only way to do great work is to love what you do." - Steve Jobs',
    '"In the middle of difficulty lies opportunity." - Albert Einstein',
    '"The only limit to our realization of tomorrow will be our doubts of today." - Franklin D. Roosevelt',
    '"Life is either a daring adventure or nothing at all." - Helen Keller',
    '"The best way to predict your future is to create it." - Peter Drucker',
    '"The only thing we have to fear is fear itself." - Franklin D. Roosevelt',
    '"The greatest glory in living lies not in never falling, but in rising every time we fall." - Nelson Mandela',
    "\"The only thing standing between you and your goal is the story you keep telling yourself as to why you can't achieve it.\" - Jordan Belfort",
    '"The best and most beautiful things in the world cannot be seen or even touched - they must be felt with the heart." - Helen Keller',
    '"It is during our darkest moments that we must focus to see the light." - Aristotle',
    "\"Don't judge each day by the harvest you reap but by the seeds that you plant.\" - Robert Louis Stevenson",
    // Add more quotes...
  ];
  late String currentQuote;
  late Timer timer;
  Random random = Random();
  double opacityLevel = 1.0;*/

  bool isAdLoaded = false;

  @override
  void initState() {
    super.initState();

    currentImage = images[random.nextInt(images.length)];
    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      changeQuote();
    });
  }

  void changeQuote() {
    if (mounted) {
      setState(() {
        opacityLevel = 0.0; // Start the fade out
      });

      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            currentImage = images[random.nextInt(images.length)];
            opacityLevel = 1.0; // Start the fade in
          });
        }
      });
    }
  }

  @override
  void dispose() {
    timer.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.8, 0.5),
                  radius: 3,
                  colors: [
                    kPurpleColor,
                    kPrimaryAccentColor,
                    // Other gradient colors...
                  ],
                ),
              ),
              child: Center(
                child: AnimatedOpacity(
                  opacity: opacityLevel,
                  duration: const Duration(seconds: 5),
                  child: Image.asset(currentImage), // Display the current image
                ), /*AnimatedOpacity(
                  opacity: opacityLevel,
                  duration: const Duration(seconds: 5),
                  child: Text(
                    currentImage,
                    style: const TextStyle(fontSize: 24, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),*/
              ),
            ),
          ),
        ],
      ),
    );
  }
}
