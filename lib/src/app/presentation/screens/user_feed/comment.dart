import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class UserFeedComment {
  final String userId;
  final String text;

  UserFeedComment({
    required this.userId,
    required this.text,
  });

  factory UserFeedComment.fromMap(Map<String, dynamic> data) {
    if (!data.containsKey('commenterId') || data['commenterId'] == null) {
      if (kDebugMode) {
        print('UserFeedComment.fromMap: commenterId is null or missing in data: $data');
      }
      throw Exception('UserFeedComment.fromMap: commenterId is null or missing');
    }

    return UserFeedComment(
      userId: data['commenterId'], // Use the correct field name
      text: data['text'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'text': text,
    };
  }
}
class CommentModel {
  final String text;
  final String firstName;
  final String profileImage;

  CommentModel({
    required this.text,
    required this.firstName,
    required this.profileImage,
  });

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      text: data['text'] ?? '',
      firstName: data['firstName'] ?? '', // Assuming 'firstName' is part of your comment document
      profileImage: data['profileImage'] ?? '', // Assuming 'profileImage' is part of your comment document
    );
  }
}
