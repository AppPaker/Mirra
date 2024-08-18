import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QRScannerLogic {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> recordCheckIn(
      String businessId, String userId, String subscriptionLevel) async {
    final timestamp = DateTime.now();
    final today = timestamp
        .toIso8601String()
        .split('T')[0]; // Get today's date in YYYY-MM-DD format

    // Reference to the specific business and today's date
    final docRef = _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('checkIn')
        .doc(today);

    // Check if today's document exists
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      // If the document doesn't exist, create it with the user and their count
      await docRef.set({
        'date': today,
        'customers': {
          userId: {
            'count': 1,
            'subscriptionLevel': subscriptionLevel,
          }
        }
      });
    } else {
      // If the document exists, update the user's count or add them if they're not there
      final currentCount = docSnapshot.get('customers.$userId.count') ?? 0;
      await docRef.set(
          {
            'customers.$userId': {
              'count': currentCount + 1,
              'subscriptionLevel': subscriptionLevel,
            }
          },
          SetOptions(
              merge:
                  true)); // Using merge: true to ensure we don't overwrite other data
    }
  }

  void showUserDialog(
      BuildContext context, String firstName, String subscriptionLevel) {
    Color? dialogColor;
    switch (subscriptionLevel) {
      case 'free':
        dialogColor = Colors.grey;
        break;
      case 'Subscriber':
        dialogColor = Colors.blue[300];
        break;
      case 'premium':
        dialogColor = Colors.amberAccent;
        break;
      case 'VIP':
        dialogColor = Colors.black;
        break;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: dialogColor,
          title: Text(firstName),
          content: Text(subscriptionLevel),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
