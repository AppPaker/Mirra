import 'package:flutter/material.dart';
import 'package:mirra/src/app/presentation/components/gradient_appbar.dart';
import 'package:mirra/src/app/presentation/components/loading_screen.dart';
import 'package:mirra/src/app/presentation/components/mirror_button.dart';
import 'package:mirra/src/app/presentation/utils/constants.dart';
import 'mbti_result.dart';
import '../../../../data/models/neuroticism_quiz_model.dart';

class NeuroticismQuizWidget extends StatefulWidget {
  final NeuroticismQuizManager quizManager;

  const NeuroticismQuizWidget({super.key, required this.quizManager});

  @override
  _NeuroticismQuizWidgetState createState() => _NeuroticismQuizWidgetState();
}

class _NeuroticismQuizWidgetState extends State<NeuroticismQuizWidget> {
  late Future _initQuestionsFuture;

  @override
  void initState() {
    super.initState();
    _initQuestionsFuture = _initData();
  }

  Future _initData() async {
    await widget.quizManager.fetchCurrentUser(context);
    await widget.quizManager.initializeQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initQuestionsFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return Scaffold(
              backgroundColor: Colors.grey[200],
              appBar: snapshot.connectionState == ConnectionState.waiting
                  ? null
                  : const GradientAppBar(
                      useBorder: true,
                      leading: SizedBox(),
                      title: Center(
                        child: Text(
                          'Personality Profile',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
              body: FutureBuilder(
                future: _initQuestionsFuture,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  Widget child;
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    child = const LoadingScreen();
                  } else if (snapshot.hasError) {
                    child = Text('Error: ${snapshot.error}');
                  } else {
                    child = Padding(
                      padding: const EdgeInsets.all(kPadding4),
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: widget.quizManager.questions.length,
                              itemBuilder: (context, index) {
                                String questionText = widget
                                    .quizManager.questions[index].questionText;
                                int score =
                                    widget.quizManager.questions[index].score;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        '"$questionText"',
                                        style: const TextStyle(
                                            fontFamily: 'Poppins'),
                                      ),
                                      Slider(
                                        value: score.toDouble(),
                                        min: -5,
                                        max: 5,
                                        divisions: 10,
                                        activeColor: kPurpleColor,
                                        onChanged: (double value) {
                                          if (mounted) {
                                            setState(() {
                                              widget
                                                  .quizManager
                                                  .questions[index]
                                                  .score = value.round();
                                            });
                                          }
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Strongly Disagree'),
                                            Text(
                                              widget.quizManager
                                                  .questions[index].scoreEmoji,
                                              style:
                                                  const TextStyle(fontSize: 30),
                                            ),
                                            const Text('Strongly Agree'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: MirrorElevatedButton(
                                  onPressed: () async {
                                    for (int i = 0;
                                        i < widget.quizManager.questions.length;
                                        i++) {
                                      await widget.quizManager.saveAnswer(i);
                                    }

                                    // Fetch the user ID directly using FirebaseAuthService

                                    // Navigate to CelebrationPage
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const CelebrationPage()),
                                    );
                                  },
                                  child: const Text(
                                    'Save & next',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: kPurpleColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              height: MediaQuery.of(context).padding.bottom),
                        ],
                      ),
                    );
                  }

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    child: child,
                  );
                },
              ));
        });
  }
}
