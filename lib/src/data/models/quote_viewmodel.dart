import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class QuoteViewModel {
  final bool isEditable;
  final String userId;
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  final Map<String, String> traitMapping = {
    'O': 'Openness',
    'C': 'Conscientiousness',
    'E': 'Extraversion',
    'A': 'Assertiveness ',
    //LEAVE THE ' ' AFTER ASSERTIVENESS AS THE DB HAS A TYPO IN IT!!!!!!!!!!
    'N': 'Neuroticism',
  };

  QuoteViewModel(this.userId, {this.isEditable = true}) {
    if (userId.isEmpty) {
      if (kDebugMode) {
        print("Warning: Initialized QuoteViewModel with an empty userId.");
      }
    }
  }

  Future<String?> fetchMBTIType() async {
    if (kDebugMode) {
      print("Fetching MBTI Type for user: $userId");
    }

    if (userId.isEmpty) {
      if (kDebugMode) {
        print("Error: UserId is empty. Cannot fetch MBTI Type.");
      }
      return null;
    }

    try {
      DocumentSnapshot snapshot = await usersCollection.doc(userId).get();
      if (snapshot.exists && snapshot.data() != null) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        if (data.containsKey('mbtiType')) {
          String mbtiType = data['mbtiType'] as String;
          if (kDebugMode) {
            print("MBTI Type fetched: $mbtiType");
          }
          return mbtiType;
        } else {
          if (kDebugMode) {
            print("MBTI Type not found in the document for userId: $userId");
          }
          return null;
        }
      } else {
        if (kDebugMode) {
          print("Document does not exist or is null for userId: $userId");
        }
        return null;
      }
    } catch (error) {
      if (kDebugMode) {
        print("Error fetching MBTI Type for userId: $userId -> $error");
      }
      return null;
    }
  }

  Future<Map<String, dynamic>> fetchOCEANRawScores() async {
    if (kDebugMode) {
      print("Fetching OCEAN raw scores for user: $userId");
    }
    if (userId.isEmpty) {
      if (kDebugMode) {
        print("Error: UserId is empty. Cannot fetch OCEAN raw scores.");
      }
      return {};
    }

    try {
      DocumentSnapshot snapshot = await usersCollection.doc(userId).get();
      if (snapshot.exists && snapshot.data() != null) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        if (data.containsKey('OCEAN_raw_scores')) {
          Map<String, dynamic> oceanRawScores = data['OCEAN_raw_scores'];
          if (kDebugMode) {
            print("OCEAN raw scores fetched: $oceanRawScores");
          }
          return oceanRawScores; // Return the raw scores
        } else {
          if (kDebugMode) {
            print(
                "OCEAN raw scores not found in the document for userId: $userId");
          }
          return {};
        }
      } else {
        if (kDebugMode) {
          print("Document does not exist or is null for userId: $userId");
        }
        return {};
      }
    } catch (error) {
      if (kDebugMode) {
        print("Error fetching OCEAN raw scores for userId: $userId -> $error");
      }
      return {};
    }
  }

  Future<Map<String, dynamic>> fetchOCEANScores() async {
    if (kDebugMode) {
      print("Fetching OCEAN scores for user: $userId");
    }
    if (userId.isEmpty) {
      if (kDebugMode) {
        print("Error: UserId is empty. Cannot fetch OCEAN scores.");
      }
      return {};
    }

    try {
      DocumentSnapshot snapshot = await usersCollection.doc(userId).get();
      if (snapshot.exists && snapshot.data() != null) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        if (kDebugMode) {
          print("OCEAN scores fetched: $data");
        }
        return data.containsKey('OCEAN_scores')
            ? data['OCEAN_scores'] as Map<String, dynamic>
            : {};
      } else {
        if (kDebugMode) {
          print(
              "Failed to fetch OCEAN scores: Document does not exist or is null for userId: $userId");
        }
        return {};
      }
    } catch (error) {
      if (kDebugMode) {
        print("Error fetching OCEAN scores for userId: $userId -> $error");
      }
      return {};
    }
  }

  Future<Map<String, String?>> fetchReflectionQuotes(
      String trait, String score) async {
    if (kDebugMode) {
      print("Fetching reflection quotes for trait: $trait and score: $score");
    }

    if (trait.isEmpty || score.isEmpty) {
      if (kDebugMode) {
        print(
            "Error: Trait or Score is empty. Trait: '$trait', Score: '$score'");
      }
      return {'Strength': null, 'Watchout': null};
    }

    String? strengthQuote;
    String? watchoutQuote;
    String fullTraitName = traitMapping[trait] ?? 'Unknown Trait';
    if (fullTraitName == 'Unknown Trait') {
      if (kDebugMode) {
        print("Warning: Unknown trait '$trait' received.");
      }
    }
    String pathSegment = isEditable ? 'Reflection' : 'Perception';

    try {
      // Fetching all Strength Quotes
      QuerySnapshot strengthQuerySnapshot = await FirebaseFirestore.instance
          .collection('insights')
          .doc(pathSegment)
          .collection(fullTraitName)
          .doc(score)
          .collection('Strength')
          .get();
      if (kDebugMode) {
        print("Strength documents: ${strengthQuerySnapshot.docs.length}");
      }

      if (strengthQuerySnapshot.docs.isNotEmpty) {
        var randomDocData = strengthQuerySnapshot
            .docs[Random().nextInt(strengthQuerySnapshot.docs.length)]
            .data() as Map<String, dynamic>;
        strengthQuote = randomDocData['content'] as String?;
        if (strengthQuote == null) {
          if (kDebugMode) {
            print(
                "Warning: Content not found in strengthQuote document for trait: $trait, score: $score");
          }
        }
      }

      // Fetching all Watchout Quotes
      QuerySnapshot watchoutQuerySnapshot = await FirebaseFirestore.instance
          .collection('insights')
          .doc(pathSegment)
          .collection(fullTraitName)
          .doc(score)
          .collection('Watchout')
          .get();
      if (kDebugMode) {
        print("Watchout documents: ${watchoutQuerySnapshot.docs.length}");
      }

      if (watchoutQuerySnapshot.docs.isNotEmpty) {
        var randomDocData = watchoutQuerySnapshot
            .docs[Random().nextInt(watchoutQuerySnapshot.docs.length)]
            .data() as Map<String, dynamic>;
        watchoutQuote = randomDocData['content'] as String?;
        if (watchoutQuote == null) {
          if (kDebugMode) {
            print(
                "Warning: Content not found in watchoutQuote document for trait: $trait, score: $score");
          }
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print(
            "Error fetching reflection quotes for trait: $trait and score: $score -> $error");
      }
      return {'Strength': null, 'Watchout': null};
    }

    if (kDebugMode) {
      print(
          "Reflection quotes fetched for trait: $trait, score: $score -> {'Strength': $strengthQuote, 'Watchout': $watchoutQuote}");
    }
    return {
      'Strength': strengthQuote,
      'Watchout': watchoutQuote,
    };
  }
}
