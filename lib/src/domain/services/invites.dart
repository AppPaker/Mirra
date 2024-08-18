import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mirra/src/app/presentation/screens/users/user.dart';


class Invite {
  final String id;
  final String matchedUserId;
  final User matchedUser;
  final String invitingUserId;
  final String businessId;
  final String status;

  Invite({
    required this.id,
    required this.matchedUserId,
    required this.matchedUser,
    required this.invitingUserId,
    required this.businessId,
    required this.status,
  });

  // Assuming this constructor no longer fetches user details itself
  factory Invite.fromDocument(DocumentSnapshot doc, User matchedUser) {
    return Invite(
      id: doc.id,
      matchedUserId: doc['matchedUserId'],
      matchedUser: matchedUser,
      invitingUserId: doc['invitingUserId'],
      businessId: doc['businessId'],
      status: doc['status'],
    );
  }
}
