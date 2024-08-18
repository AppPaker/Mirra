import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mirra/src/domain/firebase/auth_service.dart';
import 'package:provider/provider.dart';

class NeuroticismQuestion {
  final String id;
  final String questionText;
  final String bigFiveLabel;
  final int chargeKey;
  int score;

  String get scoreEmoji {
    if (score < -3) return '🙃';
    if (score < 0) return '🫤';
    if (score == 0) return '🤔';
    if (score <= 3) return '😏';
    return '🤩';
  }

  NeuroticismQuestion({
    required this.id,
    required this.questionText,
    required this.bigFiveLabel,
    required this.chargeKey,
    this.score = 0,
  });
}

class NeuroticismQuizManager {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String userId;

  List<NeuroticismQuestion> questions = [];
  List<String> fetchedQuestionIds = [];

  NeuroticismQuizManager({required this.userId}) {
    if (kDebugMode) {
      print("User ID in NeuroticismQuizManager: $userId");
    }
  }

  Future<void> fetchCurrentUser(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    String? currentUserUid = await authService.getUserId();
    await fetchUsers(currentUserUid);
  }

  Future<void> fetchUsers(String userId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get(); // get the current user's document

    if (!userDoc.exists) {
      // Initialize the user with default values
      await firestore.collection('users').doc(userId).set({});
    }
  }

  Future<void> initializeQuestions() async {
    for (int i = 0; i < 4; i++) {
      NeuroticismQuestion newQuestion = await getRandomQuestion();
      questions.add(newQuestion);
    }
  }

  Future<void> saveAnswer(int index) async {
    // Reference to the answer document within the openness_answers subcollection
    DocumentReference answerRef = firestore
        .collection('users')
        .doc(userId)
        .collection('neuroticism_answers')
        .doc(questions[index].id);

    // Set the answer
    await answerRef.set({
      'question': questions[index].questionText,
      'score': questions[index].score,
      'bigFiveLabel': questions[index].bigFiveLabel,
      'chargeKey': questions[index].chargeKey,
    });
  }

  Future<NeuroticismQuestion> getRandomQuestion() async {
    // Get a random document from the 'agreeable_questions' collection
    final response = await http.get(
      Uri.parse(
          'https://firestore.googleapis.com/v1/projects/mirr00/databases/(default)/documents/Questions_raw/neuroticism/neuroticism_questions'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final documents = data['documents'];
      documents.shuffle();
      var randomDocument = documents.first;

      // If the fetched question ID is already in the fetchedQuestionIds list, fetch another one
      while (fetchedQuestionIds.contains(randomDocument['name'])) {
        randomDocument = (documents..shuffle()).first;
      }

      // Add the fetched question ID to the fetchedQuestionIds list
      fetchedQuestionIds.add(randomDocument['name']);

      // Create a new OpennessQuestion from the document data
      NeuroticismQuestion question = NeuroticismQuestion(
        id: randomDocument['name'].split('/').last,
        questionText: randomDocument['fields']['question']['stringValue'],
        bigFiveLabel: randomDocument['fields']['bigFiveLabel']['stringValue'],
        chargeKey:
            int.parse(randomDocument['fields']['chargeKey']['integerValue']),
      );

      return question;
    } else {
      throw Exception('Failed to load questions');
    }
  }
}
