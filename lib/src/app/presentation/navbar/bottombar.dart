import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mirra/src/app/presentation/components/mirror_card.dart';
import 'package:mirra/src/app/presentation/screens/businesses/qr_scanner/user_scanner.dart';
import 'package:mirra/src/app/presentation/screens/chat/matched_list_widget.dart';
import 'package:mirra/src/app/presentation/screens/home/home_page_widget.dart';
import 'package:mirra/src/app/presentation/screens/map/map_widget.dart';
import 'package:mirra/src/app/presentation/screens/profile_page/profile_page_widget.dart';
import 'package:mirra/src/app/presentation/screens/swipe_card/swipe_card_widget.dart';
import 'package:mirra/src/app/presentation/utils/constants.dart';

enum AppPage { home, maps, profile, cardSwipe, card, chat, qrScanner }

final FirebaseAuth _auth = FirebaseAuth.instance;
final String? currentUserId = _auth.currentUser?.uid;

final List<Widget> pages = [
  const MapPage(),
  UserProfilePage(userId: currentUserId ?? ''),
  const SwipeCardWidget(),
  const HomePage(),
  MirrorCard(),
  const MatchedListPage(),
  const UserQRScannerScreen(),
];

class CustomBottomNavigationBar extends StatefulWidget {
  final Function(AppPage) onTabSelected;
  final AppPage selectedPage;

  const CustomBottomNavigationBar(
      {super.key, required this.onTabSelected, required this.selectedPage});

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 62,
        child: BottomAppBar(
          color: kPurpleColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildIconButton(
                  AppPage.profile, 'assets/images/ProfileIcon.png'),
              _buildIconButton(AppPage.cardSwipe, Icons.swipe_sharp),
              _buildIconButton(AppPage.home, Icons.other_houses_outlined),
              _buildIconButton(AppPage.card, Icons.credit_card_rounded),
              _buildIconButton(AppPage.chat, Icons.chat_outlined),
              _buildIconButton(AppPage.qrScanner, Icons.camera_alt),
            ],
          ),
        ));
  }

  Widget _buildIconButton(AppPage page, dynamic icon) {
    return IconButton(
      icon: icon is String
          ? Image.asset(
              icon,
              color: widget.selectedPage == page ? Colors.blue : Colors.white,
              width: 30.0, // Adjust the width as needed
              height: 30.0, // Adjust the height as needed
            )
          : Icon(
              icon,
              color: widget.selectedPage == page ? Colors.blue : Colors.white,
            ),
      onPressed: () => widget.onTabSelected(page),
    );
  }
}
