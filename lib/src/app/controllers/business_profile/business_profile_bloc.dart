
// Events
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mirra/src/app/controllers/notification/notification_provider.dart';
import 'package:mirra/src/app/controllers/users/user_service.dart';
import 'package:mirra/src/app/presentation/screens/users/user.dart';
import 'package:mirra/src/domain/firebase/auth_service.dart';
import 'package:mirra/src/domain/firebase/cloud_firestore/real_firestore_service.dart';
import 'package:mirra/src/domain/services/invites.dart';

abstract class BusinessProfileEvent {}

class FetchInvitesForBusinessEvent extends BusinessProfileEvent {
  final String businessId;

  FetchInvitesForBusinessEvent(this.businessId);
}

class BusinessInvitesLoadedState extends BusinessProfileState {
  final List<Invite> invites;

  BusinessInvitesLoadedState(this.invites);
}

class SendInviteEvent extends BusinessProfileEvent {
  final User matchedUser; // The user who is being invited
  final User invitingUser; // The logged-in user who is sending the invite
  final String
      businessId; // The ID of the business where the date will take place
  final String businessName;

  SendInviteEvent(
      this.matchedUser, this.invitingUser, this.businessId, this.businessName);
}

class AcceptInviteEvent extends BusinessProfileEvent {
  final String bookingId; // A unique ID for the booking/invite

  AcceptInviteEvent(this.bookingId);
}

class DeclineInviteEvent extends BusinessProfileEvent {
  final String bookingId;

  DeclineInviteEvent(this.bookingId);
}

class CancelInviteEvent extends BusinessProfileEvent {
  final String bookingId;

  CancelInviteEvent(this.bookingId);
}

// Define more specific states with clear meaning
abstract class BusinessProfileState {}

class InitialState extends BusinessProfileState {
  late User user;
}

class InviteSentState extends BusinessProfileState {
  final User matchedUser;
  final String bookingId;

  InviteSentState(this.matchedUser, this.bookingId);
}

class InviteAcceptedState extends BusinessProfileState {
  final String bookingId;

  InviteAcceptedState(this.bookingId);
}

class InviteDeclinedState extends BusinessProfileState {
  final String bookingId;

  InviteDeclinedState(this.bookingId);
}

class InviteCancelledState extends BusinessProfileState {
  final String bookingId;

  InviteCancelledState(this.bookingId);
}

// Bloc implementation
class BusinessProfileBloc
    extends Bloc<BusinessProfileEvent, BusinessProfileState> {
  final AuthService authService;
  final RealFirestoreService firestoreService;
  final UserService userService;
  double currentPage = 0.0;
  User? selectedUser;
  final NotificationProvider notificationProvider;

  // Modify the constructor to accept userService
  BusinessProfileBloc({
    required this.userService,
    required this.authService,
    required this.firestoreService,
    required this.notificationProvider,
  }) : super(InitialState()) {
    on<SendInviteEvent>(_onSendInviteEvent);
    on<AcceptInviteEvent>(_onAcceptInviteEvent);
    on<DeclineInviteEvent>(_onDeclineInviteEvent);
    on<CancelInviteEvent>(_onCancelInviteEvent);
    on<FetchInvitesForBusinessEvent>(_onFetchInvitesForBusinessEvent);
  }

  Future<List<Invite>> fetchInvitesForBusiness(String businessId) async {
    final invitesRef = FirebaseFirestore.instance.collection('invites');
    final querySnapshot =
        await invitesRef.where('businessId', isEqualTo: businessId).get();

    List<Invite> invites = [];
    for (var doc in querySnapshot.docs) {
      User matchedUser = await userService.fetchUserById(doc['matchedUserId']);
      invites.add(Invite.fromDocument(doc, matchedUser));
    }
    return invites;
  }

  Future<void> _onFetchInvitesForBusinessEvent(
      FetchInvitesForBusinessEvent event,
      Emitter<BusinessProfileState> emit) async {
    List<Invite> invites = await fetchInvitesForBusiness(event.businessId);
    emit(BusinessInvitesLoadedState(invites));
  }

  Future<void> _onSendInviteEvent(
      SendInviteEvent event, Emitter<BusinessProfileState> emit) async {
    // Existing logic to send invite
    String bookingId = await firestoreService.createBooking(
        event.matchedUser.id, event.invitingUser.id, event.businessId);

    // Check if invite was successfully sent before proceeding
    if (bookingId.isNotEmpty) {
      if (kDebugMode) {
        print(
            "Emitting InviteSentState for user: ${event.matchedUser.firstName}");
      }
      emit(InviteSentState(event.matchedUser, bookingId));

      // Send notification
      String title = "New Invitation";
      String body = "You've been invited to ${event.businessName}!";
      // Use a default value or ensure non-nullability for senderName
      String senderName = event.invitingUser.firstName ?? "A user";
      notificationProvider.sendNotificationToUser(
        receiverId: event.matchedUser.id,
        senderId: event.invitingUser.id,
        senderName: senderName,
        title: title,
        body: body,
        inviteStatus: "Pending",
      );
    }
  }

  Future<void> _onAcceptInviteEvent(
      AcceptInviteEvent event, Emitter<BusinessProfileState> emit) async {
    // Logic to accept the invite and update Firestore
    await firestoreService.acceptBooking(event.bookingId);
    emit(InviteAcceptedState(event.bookingId));
  }

  Future<void> _onDeclineInviteEvent(
      DeclineInviteEvent event, Emitter<BusinessProfileState> emit) async {
    // Logic to decline the invite and update Firestore
    await firestoreService.declineBooking(event.bookingId);
    emit(InviteDeclinedState(event.bookingId));
  }

  Future<void> _onCancelInviteEvent(
      CancelInviteEvent event, Emitter<BusinessProfileState> emit) async {
    // Logic to cancel the invite and update Firestore
    await firestoreService.cancelBooking(event.bookingId);
    emit(InviteCancelledState(event.bookingId));
  }

  Future<void> showMatchedUsersDialog(
      BuildContext context, Function(User) onUserSelected) async {
    final userService = UserService();
    final matchedUsers = await userService.fetchMatchedUsers();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Invite Matched Users'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: matchedUsers.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        NetworkImage(matchedUsers[index].profileImage ?? ''),
                  ),
                  title: Text(matchedUsers[index].firstName ?? ''),
                  onTap: () {
                    onUserSelected(matchedUsers[index]);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
