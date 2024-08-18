import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirra/src/app/controllers/admanager/ad_service.dart';
import 'package:mirra/src/app/presentation/screens/user_feed/post.dart';
import 'package:mirra/src/app/presentation/utils/constants.dart';
import 'package:provider/provider.dart';

import 'comment_screen.dart';
import '../../../controllers/feed/feed_model.dart';

class Post {
  final String profileImage;
  final String firstName;
  final String content;
  final String? imageUrl;

  Post({
    required this.profileImage,
    required this.firstName,
    required this.content,
    this.imageUrl,
  });
}

class FeedWidget extends StatefulWidget {
  const FeedWidget({
    super.key,
    required TabController tabController,
    required AdManager adManager,
  });

  @override
  _FeedWidgetState createState() => _FeedWidgetState();
}

class _FeedWidgetState extends State<FeedWidget> {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;
  String? userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_loadMore);
  }

  _loadMore() {
    final feedModel = Provider.of<FeedModel>(context, listen: false);
    if (kDebugMode) {
      print(
          'Load more triggered. isLoadingMore: $_isLoadingMore, hasMorePosts: ${feedModel.hasMorePosts}');
    }

    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore &&
        feedModel.hasMorePosts) {
      // If at the bottom, not currently loading, and more posts are available
      setState(() {
        _isLoadingMore = true;
      });

      // The StreamBuilder in your widget will automatically handle fetching more posts
      // based on the updated lastDocument and hasMorePosts values

      // Once done, set _isLoadingMore to false
      // Consider using a delay or a callback to reset _isLoadingMore after posts have been fetched
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoadingMore = false;
        });
      });
    }
  }

  Future<void> _refreshPosts() async {
    final feedModel = Provider.of<FeedModel>(context, listen: false);
    feedModel
        .refreshPosts(); // This will reset the state and call notifyListeners()
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Widget _buildFeedItem(FeedPost feedPost) {
    try {
      return Card(
        margin: const EdgeInsets.symmetric(
            horizontal: kPadding3, vertical: kPadding3),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(kPadding3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(feedPost.profileImage ?? ''),
                    radius: 25,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feedPost.firstName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        _formatTimestamp(feedPost.timestamp),
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                feedPost.content,
                style: const TextStyle(fontSize: 15),
              ),
              if (feedPost.imageURL != null &&
                  Uri.tryParse(feedPost.imageURL!)?.hasAbsolutePath == true)
                Image.network(feedPost.imageURL!),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.thumb_up),
                    onPressed: () {
                      final feedModel =
                          Provider.of<FeedModel>(context, listen: false);
                      feedModel.likePost(
                          feedPost.uid,
                          feedPost
                              .postId); // Use uid for userId and postId for the document ID
                    },
                  ),
                  Text('${feedPost.likes.length} Likes'),
                  IconButton(
                    icon: const Icon(Icons.comment),
                    onPressed: () {
                      if (userId != null) {
                        final postCreatorUserId = feedPost.uid;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CommentScreen(
                              postId: feedPost.postId,
                              userId: userId!,
                              // userId of the logged-in user adding the comment
                              onCommentAdded: () {},
                            ),
                          ),
                        ).then((_) {
                          // Update comments count after returning from CommentScreen
                          final feedModel =
                              Provider.of<FeedModel>(context, listen: false);
                          feedModel.updateCommentsForPost(
                              feedPost.postId, postCreatorUserId);
                        });
                      } else {
                        // Handle no logged-in user
                      }
                    },
                  ),
                  Text('${feedPost.comments.length} Comments'),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {}, // Share button logic
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error building feed item: $e');
      }
      return const Text('Error displaying post');
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedModel = Provider.of<FeedModel>(context);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: StreamBuilder<List<FeedPost>>(
          stream: feedModel.getPosts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              // Use a SingleChildScrollView to allow refresh when there are no posts
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context)
                      .size
                      .height, // Take the height of the screen
                  child: const Center(
                      child: Text('No posts available. Pull to refresh')),
                ),
              );
            }

            return ListView.builder(
              controller: _scrollController,
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                final feedPost = snapshot.data![index];
                return _buildFeedItem(feedPost);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePostDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreatePostDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CreatePostWidget(
            feedModel: Provider.of<FeedModel>(context, listen: false));
      },
    );
  }
}
