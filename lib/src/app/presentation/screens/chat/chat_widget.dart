import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mirra/src/app/controllers/notification/notification_provider.dart';
import 'package:mirra/src/app/presentation/screens/users/user.dart';
import 'package:mirra/src/app/presentation/utils/constants.dart';
import 'package:mirra/src/domain/firebase/auth_service.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/chat_model.dart';

final authService = FirebaseAuthService();

class ChatPage extends StatefulWidget {
  final User matchedUser;
  final String matchId;

  const ChatPage({super.key, required this.matchedUser, required this.matchId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Message> messages = [
    Message(content: "Hello!", timestamp: "10:00 AM", isMe: false),
    Message(content: "Hi there!", timestamp: "10:01 AM", isMe: true),
  ];
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserId();
  }

  void _fetchCurrentUserId() async {
    currentUserId = await authService.getUserId();
    setState(() {});
  }

  void _sendMessage() async {
    try {
      if (_messageController.text.isNotEmpty) {
        final userId = await authService.getUserId();

        // Fetch NotificationProvider instance
        final notificationProvider =
            Provider.of<NotificationProvider>(context, listen: false);

        final chatModel = ChatModel();
        final matchId = widget.matchId;

        // Pass notificationProvider as the fourth argument
        await chatModel.sendMessage(
            matchId, userId, _messageController.text, notificationProvider);

        setState(() {
          messages.add(Message(
            content: _messageController.text,
            timestamp: formattedTimestamp(DateTime.now()),
            isMe: true,
          ));
        });

        _messageController.clear();

        // Scroll to the bottom of the chat
        _scrollToBottom();
      }
    } catch (error) {
      // Providing more detailed error information
      if (kDebugMode) {
        print("Error sending message: ${error.toString()}");
      }
    }
  }

  void _scrollToBottom() {
    // Delay scrolling to allow UI to complete render
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        final position = _scrollController.position.maxScrollExtent;
        _scrollController.animateTo(
          position,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final chatModel = ChatModel();
    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(kPadding4),
                child: Image.network(
                  widget.matchedUser.profileImage ?? '',
                  height: kPadding6,
                ),
              ),
              const SizedBox(width: kPadding3),
              Text(
                widget.matchedUser.firstName ?? "User",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          backgroundColor: kPrimaryAccentColor,
          foregroundColor: kWhiteColor,
          centerTitle: false,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1E90C6),
                Color(0xFFDC51FF),
                Color(0xDE7644CB),
                Color(0xFF7E28FE),
                Color(0xFF034EBA),
              ],
              stops: [0, 0.1, 0.45, 0.9, 1],
              begin: AlignmentDirectional(1, 0.34),
              end: AlignmentDirectional(-1, -0.34),
            ),
          ),
          child: Container(
            color: Colors.grey
                .withOpacity(0.4), // This is the semi-transparent overlay
            child: Column(children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: chatModel.getMessagesForChat(widget.matchId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    final messagesDocs = snapshot.data!.docs;
                    final messages = messagesDocs
                        .map((doc) {
                          final data = doc.data() as Map<String, dynamic>;

                          final timestamp = data['timestamp'] as Timestamp?;
                          if (timestamp == null) return null;

                          final isMe = data['senderId'] == currentUserId;

                          return Message(
                            content: data['content'],
                            timestamp: formattedTimestamp(timestamp.toDate()),
                            isMe: isMe,
                          );
                        })
                        .where((message) => message != null)
                        .toList();

                    return SingleChildScrollView(
                      controller: _scrollController,
                      reverse: true,
                      child: Column(
                        children: messages
                            .map((message) => ChatBubble(
                                  message: message!.content,
                                  isMe: message.isMe,
                                  timestamp: message.timestamp,
                                ))
                            .toList(),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: Theme.of(context).textTheme.bodyMedium,
                        controller: _messageController,
                        cursorColor: kBlackColor,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: kPadding4),
                          hintText: "Type a message...",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: kPadding4),
            ]),
          ),
        ));
  }
}

String formattedTimestamp(DateTime dateTime) {
  return DateFormat('dd MMM yy HH:mm').format(dateTime);
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String timestamp;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            decoration: BoxDecoration(
              color: isMe ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.circular(15.0),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 15.0,
            ),
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isMe ? Colors.white : Colors.black,
                      ),
                ),
                Text(
                  timestamp,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isMe ? Colors.white : Colors.black,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Message {
  final String content;
  final String timestamp;
  final bool isMe;

  Message({required this.content, required this.timestamp, required this.isMe});
}
