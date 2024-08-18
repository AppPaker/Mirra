import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirra/src/app/controllers/notification/notification_provider.dart';
import 'package:mirra/src/app/presentation/components/mirror_button.dart';
import 'package:mirra/src/app/presentation/screens/users/user.dart';
import 'package:mirra/src/domain/firebase/auth_service.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:swipe_cards/swipe_cards.dart';

import '../../../../../data/models/chat_model.dart';
import '../../profile_page/profile_page_widget.dart';
// Import other necessary packages and models

class UserQRScannerScreen extends StatefulWidget {
  //final Function(User, String) onMatchFound;

  const UserQRScannerScreen({
    super.key,
    /*required this.onMatchFound*/
  });

  @override
  _UserQRScannerScreenState createState() => _UserQRScannerScreenState();
}

class _UserQRScannerScreenState extends State<UserQRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isComplete = false;
  late final FirebaseAuthService authService;

  late final Function(User, String) onMatchFound;
  List<User> users = [];
  String? currentUserUid;
  DocumentSnapshot? lastDocument;
  List<SwipeItem> swipeItems = [];
  MatchEngine? matchEngine;

  @override
  void initState() {
    super.initState();

    // Postpone the execution until after the build method is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Retrieve the authService using Provider
      authService = Provider.of<FirebaseAuthService>(context, listen: false);

      // Fetch the current user and then check camera permission and start scanning
      fetchCurrentUser().then((_) {
        if (mounted) {
          _checkCameraPermission().then((_) {
            if (mounted) {
              scanBarcode();
            }
          });
        }
      });
    });
  }

  Future<void> fetchCurrentUser() async {
    currentUserUid = await authService.getUserId();
    if (kDebugMode) {
      print("Fetched User ID: $currentUserUid");
    }
  }

  Future<void> _checkCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
      if (!status.isGranted) {
        // Handle the case where the user did not grant the permission
      }
    }
  }

  Future<void> scanBarcode() async {
    if (kDebugMode) {
      print("Scanning QR Code for user: $currentUserUid");
    }
    if (currentUserUid == null) {
      if (kDebugMode) {
        print("currentUserUid is null, unable to scan.");
      }
      return;
    }
    try {
      // String scannedUserId = await FlutterBarcodeScanner.scanBarcode(
      //     '#ff6666', 'Cancel', true, ScanMode.QR);
      // if (scannedUserId != '-1') {
      //   await addScannedUserToMatches(scannedUserId);
      // }
    } catch (e) {
      // Handle any errors here
      if (kDebugMode) {
        print("Error scanning QR Code: $e");
      }
    }
  }

  Future<void> addScannedUserToMatches(String scannedUserId) async {
    bool alreadySwiped = await hasAlreadyInteractedWithUser(scannedUserId);
    if (!alreadySwiped) {
      await handleMatch(currentUserUid!, scannedUserId);
    } else {
      // Handle already swiped case
      if (kDebugMode) {
        print("User already swiped: $scannedUserId");
      }
    }
  }

  Future<bool> hasAlreadyInteractedWithUser(String scannedUserId) async {
    String currentUserUid = auth.FirebaseAuth.instance.currentUser!.uid;
    List<String> interactedUsers = await fetchInteractedUsers(currentUserUid);

    return interactedUsers.contains(scannedUserId);
  }

  Future<List<String>> fetchInteractedUsers(String currentUserUid) async {
    final currentUserRef = _firestore.collection('users').doc(currentUserUid);
    final matchEngineRef =
        currentUserRef.collection('matchEngine').doc('actions');
    DocumentSnapshot doc = await matchEngineRef.get();

    if (!doc.exists) {
      if (kDebugMode) {
        print("No interactions found for the user");
      }
      return [];
    }

    List<String> allInteractedUsers = [];
    if (doc.exists) {
      allInteractedUsers = [
        ...doc.get('likes'),
        ...doc.get('superlikes'),
        ...doc.get('dislikes')
      ];
    }

    return allInteractedUsers;
  }

  Future<void> handleMatch(String user1Id, String user2Id,
      [BuildContext? context]) async {
    final matchesRef = FirebaseFirestore.instance.collection('matches');
    final usersRef = FirebaseFirestore.instance.collection('users');

    // Create a list of the two user IDs and sort them
    List<String> userIds = [user1Id, user2Id]..sort();

    // Create a unique match ID based on the sorted user IDs
    String matchId = userIds.join('_');

    // Add the match to the database
    await matchesRef.doc(matchId).set({
      'users': userIds,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Create an initial chat for the match
    final chatModel = ChatModel();
    await chatModel.createChatForMatch(matchId);

    // Fetch matched user data for the dialog.
    DocumentSnapshot userDoc = await usersRef.doc(user2Id).get();
    User matchedUser = User.fromDocument(userDoc);

    // Show the match dialog
    onMatchFound(matchedUser, matchId);

    // Navigate to the matched user's profile
    Navigator.of(context!).push(
      MaterialPageRoute(
        builder: (context) => UserProfilePage(
          userId: matchedUser.id,
          isEditable:
              false, // Set to false as this is not the current user's profile
        ),
      ),
    );

    // Assuming currentUserId is available or fetch it as needed
    String currentUserId = user1Id; // Placeholder for the current user ID
    User currentUser = await usersRef
        .doc(currentUserId)
        .get()
        .then((doc) => User.fromDocument(doc));

    // Assuming NotificationProvider is accessible
    NotificationProvider notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);

    notificationProvider.sendNotificationToUser(
      receiverId: matchedUser.id,
      senderId: currentUser.id,
      senderName: currentUser.firstName ?? "A user",
      title: "New Match!",
      body:
          "You have a new match with ${matchedUser.firstName}. Tap to view details.",
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserProfilePage(
          userId: matchedUser.id,
          isEditable: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Code Scanner')),
      body: Center(
        child: MirrorElevatedButton(
          onPressed: scanBarcode,
          child: const Text('Scan QR Code'),
        ),
      ),
    );
  }
}
