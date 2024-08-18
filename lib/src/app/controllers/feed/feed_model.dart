import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:mirra/src/app/presentation/screens/user_feed/comment.dart';
import 'package:mirra/src/domain/firebase/cloud_firestore/real_firestore_service.dart';

class FeedPost {
  final String uid;
  final String firstName;
  final String content;
  final DateTime timestamp;
  final String? imageURL;
  final String postId;
  int commentsCount; // Field to store the number of comments

  String? profileImage;
  List<String> likes; // List of user IDs who liked the post
  List<UserFeedComment> comments; // List of comments

  FeedPost({
    required this.uid,
    required this.firstName,
    required this.content,
    required this.timestamp,
    this.imageURL,
    this.profileImage,
    required this.postId,
    required this.commentsCount, // Initialize this in the constructor

    required this.likes,
    required this.comments,
  }) {
    if (kDebugMode) {
      print(
          'Creating FeedPost. Likes: ${likes.length}, Comments: ${comments.length}');
    }
  }

  factory FeedPost.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) throw Exception('Document data is null');

    final likes =
        (data['likes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
            [];
    final commentsData = data['comments'] as List<dynamic>? ?? [];
    final comments =
        commentsData.map((data) => UserFeedComment.fromMap(data)).toList();
    final postId = doc.id;

    // Calculate commentsCount based on the length of the comments list
    final commentsCount = comments.length;

    return FeedPost(
      uid: data['uid'],
      firstName: data['firstName'],
      content: data['content'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      imageURL: data['imageURL'],
      likes: likes,
      comments: comments,
      postId: postId,
      commentsCount: commentsCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'content': content,
      'timestamp': timestamp,
      'imageURL': imageURL,
      'postId': postId, // Include postId in the map
    };
  }
}

class FeedModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RealFirestoreService firestoreService = RealFirestoreService();
  User? user;
  List<FeedPost> posts = [];

  DocumentSnapshot? lastDocument; // Keeps track of the last document fetched
  int postsLimit = 10; // Number of posts to fetch per batch
  bool hasMorePosts = true;

  FeedModel() {
    // Initialize the user in the constructor
    user = FirebaseAuth.instance.currentUser;
  }

  Future<void> updateCommentsForPost(String postId, String userId) async {
    int postIndex = posts.indexWhere((post) => post.postId == postId);
    if (postIndex == -1) return; // Post not found

    try {
      QuerySnapshot commentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId) // Use userId of the post creator
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .get();

      // Update the comments count for the post
      posts[postIndex].commentsCount = commentSnapshot.docs.length;
      notifyListeners(); // Notify to update the UI
    } catch (e) {
      if (kDebugMode) {
        print('Error updating comments for post: $e');
      }
    }
  }

  Stream<List<FeedPost>> getPosts() async* {
    if (!hasMorePosts) {
      yield []; // If no more posts, yield an empty list
      return;
    }

    Query query = _firestore
        .collectionGroup('posts')
        .orderBy('timestamp', descending: true)
        .limit(postsLimit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument!);
    }

    await for (var snapshot in query.snapshots()) {
      if (kDebugMode) {
        print(
            'Fetched ${snapshot.docs.length} posts. Last Document: $lastDocument');
      }
      if (snapshot.docs.isEmpty) {
        hasMorePosts = false; // Set to false when no more documents are fetched
        yield []; // Yield an empty list to signal the end of data
        return;
      }

      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;
      }

      List<FeedPost> feedPosts =
          await Future.wait(snapshot.docs.map((doc) async {
        var feedPost = FeedPost.fromDocument(doc);
        feedPost.profileImage = await _fetchUserProfileImage(feedPost.uid);
        return feedPost;
      }));

      yield feedPosts;
    }
  }

  Future<void> addPost(String uid, String firstName, String content,
      [String? imageURL]) async {
    DocumentReference postRef =
        _firestore.collection('users').doc(uid).collection('posts').doc();

    try {
      await postRef.set({
        'uid': uid,
        'firstName': firstName,
        'content': content,
        'timestamp': FieldValue
            .serverTimestamp(), // Automatically set the timestamp when adding the post
        'imageURL': imageURL ?? '', // Use an empty string if imageURL is null
      });
    } catch (error) {
      if (kDebugMode) {
        print("Error adding post: $error");
      }
      rethrow; // Rethrow the error or handle it as needed
    }
  }

  Future<String?> _fetchUserProfileImage(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      // Cast the data to Map<String, dynamic> before accessing it
      var userData = userDoc.data() as Map<String, dynamic>?;
      return userData?['profileImage'];
    } catch (e) {
      // Handle exceptions
      if (kDebugMode) {
        print('Error fetching user profile image: $e');
      }
      return null;
    }
  }

  void refreshPosts() {
    lastDocument = null;
    hasMorePosts = true;
    notifyListeners(); // Notify listeners to rebuild widgets that depend on this model
  }

  Future<void> likePost(String userId, String postId) async {
    if (user != null) {
      if (kDebugMode) {
        print('Attempting to add like. User: ${user!.uid}, Post: $postId');
      }

      try {
        await firestoreService.addLikeToPost(userId, postId, user!.uid);

        if (kDebugMode) {
          print(
              'Like added successfully to Post: $postId by User: ${user!.uid}');
        }

        // Update the local state to reflect the like
        final index = posts.indexWhere((post) => post.postId == postId);
        if (index != -1) {
          posts[index].likes.add(user!.uid);
          notifyListeners(); // Notify listeners about the state change.
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error adding like to Post: $postId, Error: $e');
        }
        rethrow;
      }
    } else {
      if (kDebugMode) {
        print('User not logged in. Cannot like post.');
      }
    }
  }

  Future<void> addComment(
      String userId, String postId, UserFeedComment comment) async {
    if (user != null) {
      try {
        // Correct path to the post's comments subcollection
        CollectionReference commentsRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('posts')
            .doc(postId)
            .collection('comments');

        // Construct the comment data
        Map<String, dynamic> commentData = {
          'userId': user!.uid, // ID of the user who made the comment
          'text': comment.text, // Text of the comment
          'timestamp': FieldValue.serverTimestamp(), // Timestamp of the comment
        };

        // Add the comment to Firestore
        await commentsRef.add(commentData);

        if (kDebugMode) {
          print('Comment added to Post: $postId, Comment: ${comment.text}');
        }
      } catch (error) {
        if (kDebugMode) {
          print("Error adding comment to Post: $postId, Error: $error");
        }
        rethrow;
      }
    } else {
      if (kDebugMode) {
        print('User not logged in. Cannot add comment.');
      }
    }
  }
}
