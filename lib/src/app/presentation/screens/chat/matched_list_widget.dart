import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirra/src/app/controllers/users/user_service.dart';
import 'package:mirra/src/app/presentation/components/gradient_appbar.dart';
import 'package:mirra/src/app/presentation/screens/users/user.dart';

import '../home/home_page_widget.dart';
import 'chat_widget.dart';

List<User> getDummyMatches() {
  return [
    User(
        id: '1',
        firstName: 'Alice',
        matchId: 'match1',
        profileImage:
            'https://images.unsplash.com/photo-1544725176-7c40e5a71c5e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MXwyMDg1NzN8MHwxfGFsbHwxfHx8fHx8fHwxNjEzNzE5MzE5&ixlib=rb-1.2.1&q=80&w=400'),
    User(
        id: '2',
        firstName: 'Bob',
        matchId: 'match2',
        profileImage:
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MXwyMDg1NzN8MHwxfGFsbHwxfHx8fHx8fHwxNjEzNzE5MzE5&ixlib=rb-1.2.1&q=80&w=400'),
    User(
        id: '3',
        firstName: 'Charlie',
        matchId: 'match3',
        profileImage:
            'https://images.unsplash.com/photo-1546975490-e8b92a360b24?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MXwyMDg1NzN8MHwxfGFsbHwxfHx8fHx8fHwxNjEzNzE5MzE5&ixlib=rb-1.2.1&q=80&w=400'),
    User(
        id: '4',
        firstName: 'David',
        matchId: 'match4',
        profileImage:
            'https://images.unsplash.com/photo-1542103749-8ef59b94f47e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MXwyMDg1NzN8MHwxfGFsbHwxfHx8fHx8fHwxNjEzNzE5MzE5&ixlib=rb-1.2.1&q=80&w=400'),
    User(
        id: '5',
        firstName: 'Eva',
        matchId: 'match5',
        profileImage:
            'https://images.unsplash.com/photo-1546539782-6fc531453083?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MXwyMDg1NzN8MHwxfGFsbHwxfHx8fHx8fHwxNjEzNzE5MzE5&ixlib=rb-1.2.1&q=80&w=400'),
  ];
}

class MatchedListPage extends StatefulWidget {
  const MatchedListPage({super.key});

  @override
  _MatchedListPageState createState() => _MatchedListPageState();
}

class _MatchedListPageState extends State<MatchedListPage> {
  late Future<List<User>> matchedUsersFuture;
  UserService userService = UserService();
  List<String> selectedChatUserIds = [];
  DateTime? lockExpires;
  bool isSelectionLocked = false;
  Timer? countdownTimer;

  @override
  void initState() {
    super.initState();
    matchedUsersFuture = userService.fetchMatchedUsers();
    initializeLockStatus();
  }

  void initializeLockStatus() async {
    try {
      // Use getCurrentUserId to fetch the current user's ID
      String? currentUserId = await userService.getCurrentUserId();
      if (currentUserId != null) {
        // Use fetchUserById to fetch the current user's full profile
        final currentUser = await userService.fetchUserById(currentUserId);
        if (mounted) {
          setState(() {
            lockExpires = currentUser.chatSelectionsLockExpires;
            isSelectionLocked =
                lockExpires != null && lockExpires!.isAfter(DateTime.now());
            // Assuming 'selectedChatUserIds' is a part of the User model
            selectedChatUserIds = currentUser.selectedChatUserIds;
          });
        }
      } else {
        if (kDebugMode) {
          print("No current user ID found");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Failed to fetch current user: $e");
      }
      // Handle error appropriately
    }
    // After setting `lockExpires`, start a countdown timer if locked
    if (isSelectionLocked && lockExpires != null) {
      countdownTimer?.cancel(); // Cancel any existing timer
      countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final now = DateTime.now();
        if (now.isAfter(lockExpires!)) {
          setState(() {
            isSelectionLocked = false;
          });
          timer.cancel();
        } else {
          setState(() {}); // Trigger rebuild to update countdown display
        }
      });
    }
  }

  void lockInChatSelections() {
    if (selectedChatUserIds.isNotEmpty && selectedChatUserIds.length <= 6) {
      final now = DateTime.now();
      // Example: Lock for 1 hour
      const lockDuration = Duration(hours: 1);
      setState(() {
        lockExpires = now.add(lockDuration);
        isSelectionLocked = true;
      });

      startCountdownTimer();
    }
  }

  void startCountdownTimer() {
    countdownTimer?.cancel(); // Cancel any existing timer
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (DateTime.now().isAfter(lockExpires!)) {
        setState(() {
          isSelectionLocked = false;
        });
        timer.cancel();
      } else {
        setState(() {}); // Trigger rebuild to update countdown display
      }
    });
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: const Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 35, 0),
          child: Center(child: Text("Matches")),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => const HomePage(),
            ));
          },
        ),
      ),
      body: FutureBuilder<List<User>>(
        future: matchedUsersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text("No matches found"));
          } else {
            final matches = snapshot.data!;
            return Column(
              children: [
                if (isSelectionLocked && lockExpires != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.red,
                    child: Text(
                      'Selections unlock in ${lockExpires!.difference(DateTime.now()).inMinutes} minutes and ${lockExpires!.difference(DateTime.now()).inSeconds % 60} seconds',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                if (selectedChatUserIds.isNotEmpty &&
                    selectedChatUserIds.length <= 6 &&
                    !isSelectionLocked)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        lockInChatSelections();
                      },
                      child: const Text('Lock in Chat Selections'),
                    ),
                  ),
                Expanded(
                  child: Row(
                    children: [
                      // Left Column for chats
                      Expanded(
                        flex: 3, // Takes 75% of the space
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Who's talking?",
                                style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: matches
                                      .length, // This should be your list of chats, not matches
                                  itemBuilder: (context, index) {
                                    final user = matches[
                                        index]; // This should be a filtered list based on selections
                                    if (!selectedChatUserIds.contains(user.id))
                                      return Container(); // Skip if not selected

                                    return ListTile(
                                        leading: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              user.profileImage ?? ''),
                                        ),
                                        title:
                                            Text(user.firstName ?? "Unknown"),
                                        subtitle: const Text("See your chat >"),
                                        trailing: const SizedBox(
                                          width: 16.0,
                                          height: 16.0,
                                          child: Icon(Icons.circle,
                                              color: Colors.purple, size: 13.0),
                                        ),
                                        onTap: () {
                                          if (!isSelectionLocked ||
                                              !selectedChatUserIds
                                                  .contains(user.id)) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Please lock in your chat selections first.'),
                                            ));
                                            return;
                                          }
                                          if (kDebugMode) {
                                            print("Match ID: ${user.matchId}");
                                          }
                                          if (kDebugMode) {
                                            print("User ID: ${user.id}");
                                          }

                                          if (user.matchId == null ||
                                              user.matchId!.isEmpty ||
                                              user.id.isEmpty) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                    content: Text(
                                                        'Invalid user or match ID!')));
                                          } else {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ChatPage(
                                                          matchedUser: user,
                                                          matchId:
                                                              user.matchId!,
                                                        )));
                                          }
                                        });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Divider for visual separation (optional)
                      const VerticalDivider(width: 1, color: Colors.grey),
                      // Right Column for new matches
                      Expanded(
                        flex: 1, // Takes 25% of the space
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Recent Matches",
                                style: TextStyle(
                                    color: Colors.grey[400], fontSize: 11),
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: matches.length,
                                itemBuilder: (context, index) {
                                  final user = matches[index];
                                  final isSelected =
                                      selectedChatUserIds.contains(user.id);
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(user.profileImage ?? ''),
                                    ),
                                    title: Text(user.firstName ?? "Unknown"),
                                    trailing: isSelected
                                        ? const Icon(Icons.check_circle,
                                            color: Colors.green)
                                        : const Icon(
                                            Icons.check_circle_outline),
                                    onTap: () {
                                      setState(() {
                                        if (isSelected) {
                                          selectedChatUserIds.remove(user.id);
                                        } else if (selectedChatUserIds.length <
                                                5 &&
                                            !isSelectionLocked) {
                                          selectedChatUserIds.add(user.id);
                                        }
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

/*class _MatchedListPageState extends State<MatchedListPage> {
  late Future<List<User>> matchedUsersFuture;
  UserService userService = UserService();

  @override
  void initState() {
    super.initState();
    matchedUsersFuture = userService.fetchMatchedUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: const Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 35, 0),
          child: Center(child: Text("Matches")),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => const HomePage(),
            ));
          },
        ),
      ),
      body: FutureBuilder<List<User>>(
        future: matchedUsersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text("No matches found"));
          } else {
            final matches = snapshot.data!;
            return Row(
              children: [
                // Left Column (Chats)
                Expanded(
                  flex:
                      3, // This means it takes 75% of the space (3 parts of 4)
                  child: Material(
                    elevation: 8.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Who's talking?",
                            style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 13,
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: matches.length,
                            itemBuilder: (context, index) {
                              final user = matches[index];
                              return Column(
                                children: [
                                  ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            user.profileImage ?? ''),
                                      ),
                                      title: Text(user.firstName ?? "Unknown"),
                                      subtitle: const Text("See your chat >"),
                                      trailing: const SizedBox(
                                        width: 16.0,
                                        height: 16.0,
                                        child: Icon(Icons.circle,
                                            color: Colors.purple, size: 13.0),
                                      ),
                                      onTap: () {
                                        if (kDebugMode) {
                                          print("Match ID: ${user.matchId}");
                                        }
                                        if (kDebugMode) {
                                          print("User ID: ${user.id}");
                                        }

                                        if (user.matchId == null ||
                                            user.matchId!.isEmpty ||
                                            user.id.isEmpty) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      'Invalid user or match ID!')));
                                        } else {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ChatPage(
                                                        matchedUser: user,
                                                        matchId: user.matchId!,
                                                      )));
                                        }
                                      }),
                                  const Divider(color: Colors.grey),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Right Column (New Matches)
                Expanded(
                  flex: 1, // This means it takes 25% of the space (1 part of 4)
                  child: Column(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Recent Matches",
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 11),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: matches.length,
                          itemBuilder: (context, index) {
                            final user = matches[index];
                            return Column(
                              children: [
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Stack(
                                      alignment: Alignment.bottomRight,
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              user.profileImage ?? ''),
                                        ),
                                        const Icon(Icons.circle,
                                            color: Colors.cyan, size: 11.0),
                                      ],
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Text(user.firstName ?? "Unknown"),
                                ),
                                const Divider(color: Colors.grey),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}*/
