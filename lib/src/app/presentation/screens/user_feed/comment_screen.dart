import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../components/gradient_appbar.dart';
import 'comment.dart';

class CommentScreen extends StatefulWidget {
  final String userId;
  final String postId;
  final VoidCallback onCommentAdded;

  const CommentScreen({
    super.key,
    required this.userId,
    required this.postId,
    required this.onCommentAdded,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _commentController = TextEditingController();
  List<CommentModel> comments = [];

  @override
  void initState() {
    super.initState();
    _fetchComments();

  }

  Future<void> _fetchComments() async {
    final commentsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .orderBy('timestamp', descending: false);

    final querySnapshot = await commentsRef.get();
    List<CommentModel> fetchedComments = [];

    for (var doc in querySnapshot.docs) {
      final commentData = UserFeedComment.fromMap(doc.data());
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(commentData.userId)
          .get();
      final userData = userSnapshot.data() as Map<String, dynamic>;

      fetchedComments.add(
        CommentModel(
          text: commentData.text,
          firstName: userData['firstName'] ??
              '', // Replace with the correct key for firstName
          profileImage: userData['profileImage'] ??
              '', // Replace with the correct key for profileImage
        ),
      );
    }

    setState(() {
      comments = fetchedComments;
    });
  }

  void _addComment() async {
    if (_commentController.text.isNotEmpty) {
      final newComment = _commentController.text;
      final currentUserId =
          FirebaseAuth.instance.currentUser?.uid; // Get the current user's ID

      try {
        final commentsRef = FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('posts')
            .doc(widget.postId)
            .collection('comments');

        DocumentReference commentDocRef = await commentsRef.add({
          'text': newComment,
          'commenterId':
              currentUserId, // Make sure to include the commenter's ID
          'timestamp': FieldValue.serverTimestamp(),
        });

        if (kDebugMode) {
          print('Comment added successfully: $newComment');
          print(
              'Comment path in Firestore: /users/${widget.userId}/posts/${widget.postId}/comments/${commentDocRef.id}');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error adding comment: $e');
        }
      }

      widget.onCommentAdded();
      _fetchComments(); // Refresh the comments list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(
        title: Text('Comments'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                return CommentCard(comment: comments[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addComment,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CommentCard extends StatelessWidget {
  final CommentModel comment;

  const CommentCard({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: <Widget>[
                CircleAvatar(
                  backgroundImage: NetworkImage(comment.profileImage),
                ),
                const SizedBox(width: 10),
                Text(comment.firstName),
              ],
            ),
            const SizedBox(height: 8),
            Text(comment.text),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                    icon: const Icon(Icons.thumb_up_alt), onPressed: () {}),
                IconButton(icon: const Icon(Icons.reply), onPressed: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
