import 'dart:math';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirra/src/app/presentation/screens/swipe_card/expanded_content.dart';
import 'package:mirra/src/app/presentation/screens/users/user.dart';
import 'package:mirra/src/app/presentation/utils/constants.dart';
import 'package:mirra/src/data/models/swipe_card_model.dart';
import 'package:vibration/vibration.dart';

import '../../../../data/models/quote_viewmodel.dart';

class UserCardSwiper extends StatefulWidget {
  final List<User> users;
  final double cardHeight;
  final SwipeCardModel model;

  const UserCardSwiper({
    super.key,
    required this.users,
    required this.cardHeight,
    required this.model,
  });

  @override
  // ignore: library_private_types_in_public_api
  _UserCardSwiperState createState() => _UserCardSwiperState();
}

class _UserCardSwiperState extends State<UserCardSwiper>
    with TickerProviderStateMixin {
  late AnimationController _shadowController;
  bool isSuperLikeOverCard = false;
  bool isExpanded = false;
  double bottomPosition = 0;
  late double expandedPosition;
  late double collapsedPosition;
  double cardHeight = 440;

  late AnimationController _shimmerController;
  Map<String, String> compatibilityRatings = {};

  @override
  void initState() {
    super.initState();
    fetchCompatibilityRatings();

    _shadowController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );


    _shimmerController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Size size = MediaQuery.of(context).size;
    expandedPosition = size.height * 0.89 - widget.cardHeight;
    collapsedPosition = 5;
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _shadowController.dispose();
    super.dispose();
  }

  void _handleDragAction(String action) {
    if (widget.users.isNotEmpty) {
      String profileImageUrl = widget.users[0].profileImage ?? '';

      if (action == 'like') {
        Vibration.vibrate(duration: 100);
        _showLikedDialog(profileImageUrl);
        widget.model.onSwipe(
          widget.users[0],
          SwipeAction.like,
        );
      } else if (action == 'dislike') {
        widget.model.onSwipe(
          widget.users[0],
          SwipeAction.dislike,
        );
      } else if (action == 'superlike') {
        Vibration.vibrate(duration: 250);
        _showSuperLikedDialog(profileImageUrl);

        // This is the missing line to trigger the Firestore update
        widget.model.onSwipe(
          widget.users[0],
          SwipeAction.superlike,
        );
      }

      // Remove the current user from the list
      setState(() {
        widget.users.removeAt(0);
      });
    }
  }

  void _showSuperLikedDialog(String profileImageUrl) {
    // Create an animation controller for the bouncing profile pic

    AnimationController controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    Animation<double> animation = Tween<double>(
      begin: MediaQuery.of(context).size.height / 2 - 2 * 50.0,
      end: MediaQuery.of(context).size.height / 2 - 100.0,
    ).animate(controller);

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        controller.forward();
      }
    });

    controller.forward();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Automatically close the dialog after 2 seconds
        Future.delayed(const Duration(milliseconds: 950), () {
          Navigator.of(context).pop();
          // Dispose of the animation controller when the dialog is dismissed
          controller.dispose();
        });

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Bouncing profile pic animation
                AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return Positioned(
                      top: animation.value,
                      left: MediaQuery.of(context).size.width / 2 - 50.0,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(profileImageUrl),
                        radius: 50,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                const Icon(Icons.star, size: 40, color: Colors.purple),
                const SizedBox(height: 10),
                const Text(
                  'Super Liked!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text('You super liked this profile!'),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLikedDialog(String profileImageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Automatically close the dialog after 2 seconds
        Future.delayed(const Duration(milliseconds: 950), () {
          Navigator.of(context).pop();
        });

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(20.0),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.thumb_up, size: 40, color: Colors.green),
                SizedBox(height: 10),
                Text(
                  'Liked!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text('You liked this profile!'),
              ],
            ),
          ),
        );
      },
    );
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (details.delta.dy < 0) {
      setState(() {
        isExpanded = true;
      });
    } else if (details.delta.dy > 0) {
      setState(() {
        isExpanded = false;
      });
    }
  }

  Future<String> getCompatibilityRating(String profileUserId) async {
    try {
      HttpsCallable callable =
          FirebaseFunctions.instanceFor(region: 'europe-west1')
              .httpsCallable('getCompatibilityRating');
      final response = await callable
          .call(<String, dynamic>{'profileUserId': profileUserId});
      return response.data['compatibilityRating'];
    } catch (e, s) {
      if (kDebugMode) {
        print('Error when calling getCompatibilityRating: $e');
      }
      if (kDebugMode) {
        print('Detailed error: $s');
      }
      return 'Error';
    }
  }

  void fetchCompatibilityRatings() async {
    firebase_auth.FirebaseAuth auth = firebase_auth.FirebaseAuth.instance;

    if (auth.currentUser != null) {
      if (kDebugMode) {
        print('User is signed in with UID: ${auth.currentUser!.uid}');
      }
      // User is signed in, safe to call the function
      for (var user in widget.users) {
        try {
          String rating = await getCompatibilityRating(user.id);
          if (mounted) {
            // Check if the widget is still part of the tree
            setState(() {
              compatibilityRatings[user.id] = rating;
            });
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error fetching rating for ${user.id}: $e');
          }
        }
      }
    } else {
      // Handle the case where the user is not signed in
      if (kDebugMode) {
        print('User is not signed in');
      }
    }
  }

  Text _getCompatibilityLabel(String rating) {
    Color color;
    switch (rating) {
      case "High":
        color = Colors.green;
        break;
      case "Medium":
        color = Colors.blue; // or any turquoise shade you prefer
        break;
      case "Fair":
        color = Colors.amber;
        break;
      case "Low":
        color = Colors.deepOrange;
        break;
      default:
        color = Colors
            .white; // Default color for 'Fetching...' or other unexpected values
    }

    return Text(
      rating,
      style: TextStyle(
        color: color,
        fontSize: 16, // Adjust fontSize as needed
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildUserCard(User user) {
    String compatibilityRating = compatibilityRatings[user.id] ?? 'Fetching...';
    Size size = MediaQuery.of(context).size;
    double containerWidth = size.width * 0.84;
    double expandedPosition = size.height * 1 - cardHeight;
    double collapsedPosition = 5;
    QuoteViewModel viewModel = QuoteViewModel(user.id);

    return DragTarget<String>(
      builder: (context, candidateData, rejectedData) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ExpandedContentWidget with fixed positioning
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: isExpanded ? 1.0 : 0.0,
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    child: SizedBox(
                      width: size.width,
                      // Ensure it takes full width
                      height: isExpanded ? size.height * 0.55 : 0,
                      // Adjust height based on isExpanded
                      child: ExpandedContentWidget(
                          user: user, viewModel: viewModel),
                    ),
                  ),
                ),
              ),

              // Profile Card
              AnimatedPositioned(
                duration: const Duration(milliseconds: 500),
                bottom: bottomPosition,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      double delta = details.delta.dy;
                      bottomPosition = max(collapsedPosition,
                          min(expandedPosition, bottomPosition - delta));
                      isExpanded = bottomPosition <= expandedPosition;
                    });
                  },
                  onTap: () {
                    setState(() {
                      isExpanded = !isExpanded;
                      bottomPosition =
                          isExpanded ? expandedPosition : collapsedPosition;
                    });
                  },
                  child: Container(
                    width: containerWidth,
                    height: cardHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25.0),
                      image: DecorationImage(
                        image: NetworkImage(user.profileImage ?? ''),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: containerWidth,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(25.0),
                              bottomRight: Radius.circular(25.0),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.firstName ?? '',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${user.age}, ',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                  Text(
                                    user.mbtiType ?? '',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FontStyle.italic,
                                        fontSize: 20),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'Mirra Compatibility:',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  _getCompatibilityLabel(compatibilityRating),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                child: AnimatedArrow(
                  isExpanded: isExpanded,
                  color: isExpanded ? Colors.white : Colors.deepPurple,
                ),
              )
            ],
          ),
        );
      },
      onWillAccept: (data) {
        if (data == 'superlike') {
          setState(() {
            isSuperLikeOverCard = true;
          });
        }
        return true;
      },
      onLeave: (data) {
        if (data == 'superlike') {
          setState(() {
            isSuperLikeOverCard = false;
          });
        }
      },
      onAccept: (data) {
        _handleDragAction(data);
        setState(() {
          isSuperLikeOverCard = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.users.isNotEmpty
        ? Expanded(
            child: Stack(
              children: [
                Column(
                  children: [
                    // Card
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            bottom:
                                100.0), // Adjust this value to move the cards up
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: widget.users.reversed
                                .toList()
                                .asMap()
                                .entries
                                .map((entry) {
                              User user = entry.value;
                              return _buildUserCard(user);
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom:
                      10, // Adjust position to fit above the draggable icons
                  width: MediaQuery.of(context).size.width,
                  child: const Center(
                    child: Text(
                      'Drag your choice!', // Instructional text
                      style: TextStyle(
                        color: Colors.grey, // Choose a color that stands out
                        fontSize: 16, // Adjust font size as needed
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: MediaQuery.of(context).size.width * 0.1,
                  child: Draggable<String>(
                    data: 'dislike',
                    feedback: FloatingActionButton(
                      onPressed: () {},
                      backgroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      child: const Icon(Icons.close, color: Colors.red),
                    ),
                    childWhenDragging: Container(),
                    child: FloatingActionButton(
                      onPressed: () {
                        if (widget.users.isNotEmpty) {
                          // Remove the current user from the list
                          setState(() {
                            widget.users.removeAt(0);
                          });
                        }
                      },
                      backgroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      child: const Icon(Icons.close, color: Colors.red),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: MediaQuery.of(context).size.width * 0.48 - 20,
                  child: Draggable<String>(
                    data: 'superlike',
                    feedback: FloatingActionButton(
                      onPressed: () {},
                      backgroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      child: const Icon(Icons.star, color: Colors.purple),
                    ),
                    childWhenDragging: Container(),
                    child: FloatingActionButton(
                      onPressed: () {},
                      backgroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      child: const Icon(Icons.star, color: Colors.purple),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  right: MediaQuery.of(context).size.width * 0.1,
                  child: Draggable<String>(
                    data: 'like',
                    feedback: FloatingActionButton(
                      onPressed: () {},
                      backgroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      child: const Icon(Icons.favorite, color: Colors.green),
                    ),
                    childWhenDragging: Container(),
                    child: FloatingActionButton(
                      onPressed: () {},
                      backgroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      child: const Icon(Icons.favorite, color: Colors.green),
                    ),
                  ),
                ),
                Positioned(
                  top: 1,
                  left: 10,
                  child: FloatingActionButton(
                    onPressed: () {
                      if (widget.users.isNotEmpty) {
                        // Move the current user to the end of the list to redo
                        setState(() {
                          widget.users.insert(0, widget.users.removeLast());
                        });
                      }
                    },
                    backgroundColor: kPurpleColor,
                    shape: const StadiumBorder(),
                    child: const Icon(Icons.refresh, color: Colors.white),
                  ),
                ),
              ],
            ),
          )
        : const Center(child: Text("No Users"));
  }
}

class AnimatedProfilePic extends StatefulWidget {
  final double top;
  final double left;
  final String imageUrl;
  final VoidCallback onComplete;

  const AnimatedProfilePic({
    super.key,
    required this.top,
    required this.left,
    required this.imageUrl,
    required this.onComplete,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AnimatedProfilePicState createState() => _AnimatedProfilePicState();
}

class _AnimatedProfilePicState extends State<AnimatedProfilePic>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this, // Use 'this' as the TickerProvider
    );

    _animation = Tween<double>(begin: widget.top, end: widget.top - 100)
        .animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: _animation.value,
          left: widget.left,
          child: CircleAvatar(
            backgroundImage: NetworkImage(widget.imageUrl),
            radius: 50,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class AnimatedArrow extends StatefulWidget {
  final bool isExpanded;
  final Color color;

  const AnimatedArrow({
    super.key,
    required this.isExpanded,
    required this.color,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AnimatedArrowState createState() => _AnimatedArrowState();
}

class _AnimatedArrowState extends State<AnimatedArrow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.50),
    ).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: Icon(
        widget.isExpanded ? Icons.arrow_downward : Icons.arrow_upward,
        color: widget.color,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
