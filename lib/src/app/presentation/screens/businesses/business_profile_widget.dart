import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mirra/src/app/controllers/notification/notification_provider.dart';
import 'package:mirra/src/app/controllers/users/user_service.dart';
import 'package:mirra/src/app/presentation/screens/users/user.dart';
import 'package:mirra/src/domain/firebase/auth_service.dart';
import 'package:mirra/src/domain/firebase/cloud_firestore/real_firestore_service.dart';
import 'package:provider/provider.dart';

import '../../components/mirror_button.dart';
import '../chat/chat_widget.dart';
import '../map/map_widget.dart';
import '../../../controllers/business_profile/business_profile_bloc.dart';
import 'businesses.dart';


class BusinessProfilePage extends StatefulWidget {
  final Business business;
  final AuthService authService;

  const BusinessProfilePage({
    super.key,
    required this.business,
    required this.authService,
  });

  @override
  // ignore: library_private_types_in_public_api
  _BusinessProfilePageState createState() => _BusinessProfilePageState();
}

class _BusinessProfilePageState extends State<BusinessProfilePage> {
  final ValueNotifier<List<Widget>> inviteWidgetsNotifier = ValueNotifier([]);

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  TimeOfDay? preferredTime;
  String? userId;
  UserService userService = UserService();
  late NotificationProvider notificationProvider;

  final firestoreService = RealFirestoreService();
  late BusinessProfileBloc bloc;

  Future<void> _selectBookingDateTime(BuildContext context) async {
    DateTime currentDate = DateTime.now();
    TimeOfDay currentTime = TimeOfDay.now();

    DateTime? date = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: currentDate,
      lastDate: DateTime(currentDate.year + 5),
    );

    if (date != null) {
      // ignore: use_build_context_synchronously
      TimeOfDay? start = await showDialog<TimeOfDay>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select Start Time'),
            content: const Text(
                'Please pick a time range you would like (Earliest).'),
            actions: [
              TextButton(
                child: const Text('Select Time'),
                onPressed: () async {
                  TimeOfDay? selectedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                        hour: currentTime.hour + 1, minute: currentTime.minute),
                  );
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop(selectedTime);
                },
              ),
            ],
          );
        },
      );

      if (start != null) {
        // ignore: use_build_context_synchronously
        TimeOfDay? end = await showDialog<TimeOfDay>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Select End Time'),
              content: const Text(
                  'Please pick a time range you would like (Latest).'),
              actions: [
                TextButton(
                  child: const Text('Select Time'),
                  onPressed: () async {
                    TimeOfDay? selectedTime = await showTimePicker(
                      context: context,
                      initialTime:
                          TimeOfDay(hour: start.hour + 1, minute: start.minute),
                    );
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop(selectedTime);
                  },
                ),
              ],
            );
          },
        );

        if (end != null) {
          // ignore: use_build_context_synchronously
          TimeOfDay? preferred = await showDialog<TimeOfDay>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Select Preferred Time'),
                content: const Text('What is your preferred time?'),
                actions: [
                  TextButton(
                    child: const Text('Select Time'),
                    onPressed: () async {
                      TimeOfDay? selectedTime = await showTimePicker(
                        context: context,
                        initialTime: start,
                      );
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop(selectedTime);
                    },
                  ),
                ],
              );
            },
          );

          if (preferred != null) {
            setState(() {
              selectedDate = date;
              startTime = start;
              endTime = end;
              preferredTime = preferred;
            });
          }
        }
      }
    }
  }

  Future<void> _addBookingToFirestore() async {
    try {
      await firestoreService.addBookingToUser(
        bloc.selectedUser!.id,
        selectedDate!,
        startTime!,
        endTime!,
        preferredTime!,
        widget.business.id,
      );
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking added to Firestore!')),
      );
      String? currentUserId = authService
          .currentUserId; // Placeholder: Get the actual current user ID
      User currentUser = await userService.fetchUserById(currentUserId!);

      notificationProvider.sendNotificationToUser(
        receiverId: bloc.selectedUser!.id,
        senderId: currentUserId,
        senderName: currentUser.firstName ??
            "Unknown", // Provide a default value for null
        title: "New Invitation",
        body:
            "You've been invited to ${widget.business.name} on $selectedDate. Tap to view details.",
        inviteStatus: "Pending", // Indicate that this is a new, pending invite
      );
    } catch (error) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding booking: $error')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    userId = widget.authService.currentUserId;
    NotificationProvider notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);

    bloc = BusinessProfileBloc(
      userService: userService,
      authService: widget.authService,
      firestoreService: firestoreService,
      notificationProvider: notificationProvider,
    );
  }

  @override
  void dispose() {
    inviteWidgetsNotifier.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    // Trigger fetching invites when the widget builds
    context
        .read<BusinessProfileBloc>()
        .add(FetchInvitesForBusinessEvent(widget.business.id));

    return BlocListener<BusinessProfileBloc, BusinessProfileState>(
      listener: (context, state) {
        // When an invite is sent, update the UI accordingly
        if (state is InviteSentState) {

          var newInviteWidget = ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(state.matchedUser.profileImage ??
                  "https://via.placeholder.com/150"),
            ),
            title: Text(state.matchedUser.firstName ?? "Unknown"),
            subtitle: const Text("Invite sent"),
          );

          // Update the list of widgets to include the new invite
          inviteWidgetsNotifier.value = List.from(inviteWidgetsNotifier.value)
            ..add(newInviteWidget);
        
          // inviteWidgetsNotifier.notifyListeners();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.business.name),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Business images carousel
                SizedBox(
                  height: 200,
                  child: PageView.builder(
                    itemCount: widget.business.imageUrls.length,
                    onPageChanged: (int page) =>
                        setState(() => bloc.currentPage = page.toDouble()),
                    itemBuilder: (context, index) => ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Image.network(widget.business.imageUrls[index],
                          fit: BoxFit.cover),
                    ),
                  ),
                ),
                if (widget.business.imageUrls.isNotEmpty)
                  DotsIndicator(
                    dotsCount: widget.business.imageUrls.length,
                    position: bloc.currentPage.toInt(),
                    decorator: const DotsDecorator(activeColor: Colors.blue),
                  ),
                const SizedBox(height: 16.0),

                // Business details
                Text(
                  widget.business.name,
                  style: const TextStyle(
                      fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                Text(
                    '${widget.business.amenity} - ${widget.business.cuisine ?? ''}'),
                const Text('Description:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(widget.business.description),
                InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MapPage(
                            address: widget.business.address,
                            name: widget.business.name)),
                  ),
                  child: Text(widget.business.address,
                      style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline)),
                ),
                const Text('Website:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(widget.business.website),

                // Invite button
                Row(children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        String? currentUserId =
                            await userService.getCurrentUserId();
                        if (currentUserId != null) {
                          User loggedInUser =
                              await userService.fetchUserById(currentUserId);
                          // ignore: use_build_context_synchronously
                          bloc.showMatchedUsersDialog(context,
                              (User selectedUser) {
                            context.read<BusinessProfileBloc>().add(
                                SendInviteEvent(selectedUser, loggedInUser,
                                    widget.business.id, widget.business.name));
                          });
                        }
                      },
                      child: const Text('Invite'),
                    ),
                  ),
                ]),

                // Dynamically updated list of invites
                ValueListenableBuilder<List<Widget>>(
                  valueListenable: inviteWidgetsNotifier,
                  builder: (context, inviteWidgets, _) => Column(
                      children: inviteWidgets.isNotEmpty
                          ? inviteWidgets
                          : [const Text("No invites yet.")]),
                ),

                BlocBuilder<BusinessProfileBloc, BusinessProfileState>(
                  builder: (context, state) {
                    return Row(
                      children: [
                        Expanded(
                          child: MirrorElevatedButton(
                            onPressed: (state is InviteAcceptedState ||
                                    state is InviteSentState)
                                ? () async {
                                    await _selectBookingDateTime(context);
                                    if (selectedDate != null &&
                                        selectedTime != null) {
                                      await _addBookingToFirestore();
                                    }
                                  }
                                : null,
                            child: const Text('Book a Table'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
