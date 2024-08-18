import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:mirra/src/data/models/notification_model.dart';
import 'package:uuid/uuid.dart';

class NotificationProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<NotificationModel> notifications = [];
  final String currentUserId;

  NotificationProvider(this.currentUserId) {
    listenForNotifications(currentUserId);
  }

  void addNotification(NotificationModel notification) async {
    await _firestore
        .collection('notifications')
        .doc(notification.id)
        .set(notification.toJson());
    notifications.add(notification);
    notifyListeners();
  }

  void listenForNotifications(String userId) {
    _firestore
        .collection('notifications')
        .where('receiverId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isEmpty) {
        // You might not want to add a default notification every time there's no data.
        // addDefaultNotification(userId);
      } else {
        notifications = snapshot.docs
            .map((doc) => NotificationModel.fromJson(doc.data()))
            .toList();
      }
      notifyListeners();
    });
  }

  void addDefaultNotification(
      String userId, String senderId, String senderName) {
    var uuid = const Uuid();
    var defaultNotification = NotificationModel(
      id: uuid.v4(), // Generate a unique ID
      title: 'Welcome to The Mirror Social',
      body:
          'Start making new friends and explore exciting things to do nearby.',
      timestamp: DateTime.now(),
      read: false,
      receiverId: userId, senderId: senderId, senderName: senderName,
    );
    addNotification(defaultNotification);
  }

  void markNotificationAsRead(String notificationId) async {
    int index = notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      notifications[index].toggleRead();
      // Update the notification read status in Firestore
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'read': notifications[index].read});
      notifyListeners();
    }
  }

  Future<void> sendNotificationToUser({
    required String receiverId,
    required String senderId,
    required String senderName,
    required String title,
    required String body,
    String inviteStatus = "Pending", // Default value if not provided
  }) async {
    // Generate a unique ID for the notification, Firestore can auto-generate this if preferred
    String notificationId =
        FirebaseFirestore.instance.collection('notifications').doc().id;

    NotificationModel notification = NotificationModel(
      id: notificationId,
      title: title,
      body: body,
      receiverId: receiverId,
      timestamp: DateTime.now(),
      read: false,
      senderId: senderId,
      senderName: senderName,
      inviteStatus: inviteStatus,
    );

    // Save the notification to Firestore
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .set(notification.toJson());
  }
}
