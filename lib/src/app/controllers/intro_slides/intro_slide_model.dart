import 'package:flutter/material.dart';
import 'package:mirra/src/domain/firebase/auth_service.dart';

import '../../presentation/screens/personality_quiz/openness_quiz_model.dart';
import '../../presentation/screens/personality_quiz/openness_quiz_widget.dart';

class IntroSlideModel extends ChangeNotifier {
  final AuthService authService;
  final List<String> slides = [
    'Mirra is all about getting to know yourself as well as understanding others.',
    "We aim to promote fun, healthy interactions, friendships, and relationships between people.",
    "Our specialized algorithm matches people based on their personality types, and we understand that mood affects personality daily, which is why we encourage frequent engagement with the app.",
    // Add more informative slides as needed
  ];
  IntroSlideModel({required this.authService});

  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void nextSlide() {
    if (_currentIndex < slides.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }

  void previousSlide() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  bool get isLastSlide => _currentIndex == slides.length - 1;

  void reset() {
    _currentIndex = 0;
    notifyListeners();
  }

  void navigateToQuiz(BuildContext context) async {
    // Fetch the user ID directly using FirebaseAuthService
    final authService = FirebaseAuthService();
    final userId = await authService.getUserId();

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => OpennessQuizWidget(
          quizManager: OpennessQuizManager(
            userId: userId,
          ),
        ),
        transitionDuration: const Duration(seconds: 3),
        transitionsBuilder: (context, animation, animationTime, child) {
          return FadeTransition(
            opacity: Tween(begin: 0.0, end: 3.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(
                  0.4,
                  0.5,
                  curve: Curves.easeOut,
                ),
              ),
            ),
            child: child,
          );
        },
      ),
    );
  }
}
