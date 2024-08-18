import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:mirra/src/app/controllers/notification/notification_provider.dart';


class ChatModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentReference<Object?>> addMatch(
      String user1Id, String user2Id) async {
    CollectionReference matches =
        FirebaseFirestore.instance.collection('matches');

    return await matches.add({
      'user1Id': user1Id,
      'user2Id': user2Id,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<String> ensureChatExists(String user1Id, String user2Id) async {
    final matches = _firestore.collection('matches');
    final chats = _firestore.collection('chats');

    // Check if a match exists between the two users
    final matchQuery = await matches
        .where('user1Id', isEqualTo: user1Id)
        .where('user2Id', isEqualTo: user2Id)
        .get();

    String matchId;
    if (matchQuery.docs.isEmpty) {
      // If no match exists, create a new match
      final matchDoc = await matches.add({
        'user1Id': user1Id,
        'user2Id': user2Id,
        'timestamp': FieldValue.serverTimestamp(),
      });
      matchId = matchDoc.id;

      // Create a chat for the new match
      await chats.doc(matchId).set({
        'lastMessage': '',
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
      });
    } else {
      matchId = matchQuery.docs.first.id;
    }

    return matchId;
  }

  Future<void> createChatForMatch(String matchId) async {
    CollectionReference chats = FirebaseFirestore.instance.collection('chats');

    return await chats.doc(matchId).set({
      'lastMessage': '',
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<DocumentReference<Object?>> sendMessage(
      String matchId,
      String senderId,
      String content,
      NotificationProvider notificationProvider) async {
    try {
      if (kDebugMode) {
        print('Match ID: $matchId');
      }
      if (kDebugMode) {
        print('Sender ID: $senderId');
      }
      if (kDebugMode) {
        print('Content: $content');
      }

      if (matchId.isEmpty || senderId.isEmpty || content.isEmpty) {
        if (kDebugMode) {
          print('Error: One of the required fields is empty');
        }
        // ignore: null_argument_to_non_null_type
        return Future.value(null);
      }

      CollectionReference messages =
          _firestore.collection('chats').doc(matchId).collection('messages');

      DocumentReference docRef = await messages.add({
        'senderId': senderId,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
      });
      if (kDebugMode) {
        print('Message added to Firestore with ID: ${docRef.id}');
      }
      if (kDebugMode) {
        print('DocumentReference returned: $docRef');
      } // Debugging line

      // Notify the receiver of the new message
      if (kDebugMode) {
        print(
            'Calling notifyNewMessage with matchId: $matchId, senderId: $senderId, content: $content');
      }
      await notifyNewMessage(matchId, senderId, content, notificationProvider);

      return docRef;
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during sendMessage: $e');
      }
      if (kDebugMode) {
        print(
            'Current state at error: Match ID: $matchId, Sender ID: $senderId, Content: $content');
      }
      // ignore: null_argument_to_non_null_type
      return Future.value(null);
    }
  }

  Stream<QuerySnapshot> getMessagesForChat(String matchId) {
    CollectionReference messages =
        _firestore.collection('chats').doc(matchId).collection('messages');

    return messages.orderBy('timestamp', descending: false).snapshots();
  }

  Future<void> notifyNewMessage(String matchId, String senderId, String content,
      NotificationProvider notificationProvider) async {
    if (kDebugMode) {
      print(
          "notifyNewMessage called with matchId: $matchId, senderId: $senderId, content: $content");
    }

    String senderName = 'Unknown User';
    try {
      DocumentSnapshot senderDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(senderId)
          .get();
      if (senderDoc.exists) {
        Map<String, dynamic>? data = senderDoc.data() as Map<String, dynamic>?;
        if (data != null) {
          senderName = data['firstName'] ?? 'Unknown User';
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching sender name: $e');
      }
    }

    String receiverId = '';
    try {
      DocumentSnapshot matchDoc = await FirebaseFirestore.instance
          .collection('matches')
          .doc(matchId)
          .get();
      if (matchDoc.exists) {
        Map<String, dynamic>? data = matchDoc.data() as Map<String, dynamic>?;
        if (data != null) {
          List<dynamic> users = data['users'];
          receiverId = users.firstWhere((userId) => userId != senderId,
              orElse: () => null);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching match data: $e');
      }
      return; // Exit if receiver ID not found or any error occurs
    }

    if (receiverId.isNotEmpty) {
      notificationProvider.sendNotificationToUser(
        receiverId: receiverId,
        senderId: senderId,
        senderName: senderName,
        title: "New Message from $senderName",
        body: content,
        // Assuming the method signature of `sendNotificationToUser` has been updated accordingly
      );
    }
  }
}
