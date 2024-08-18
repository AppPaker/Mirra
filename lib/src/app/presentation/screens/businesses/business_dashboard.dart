import 'package:flutter/material.dart';
import 'package:mirra/src/app/presentation/screens/businesses/business_edit_page/business_profile_page.dart';
import 'package:mirra/src/app/presentation/screens/businesses/usage_page/usage_page.dart';

import '../sign_in_sign_up/sign_in_sign_up_widget.dart';
import 'bookings_page/bookings.dart';

class BusinessDashboard extends StatefulWidget {
  final String initialEmail;
  final String id;

  const BusinessDashboard({
    super.key,
    required this.initialEmail,
    required this.id,
  });

  @override
  _BusinessDashboardState createState() => _BusinessDashboardState();
}

class _BusinessDashboardState extends State<BusinessDashboard> {
  int _currentIndex = 0;
  late List<Widget> _children;
  final List<String> _titles = ['Bookings', 'QR Scanner', 'Usage', 'Profile'];

  void _navigateToSignInSignUpPage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const SignInSignUpPage(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _children = [
      const BookingsScreen(),
      //const QRScannerScreen(),
      const UsageScreen(),
      BusinessProfileEditPage(
        initialEmail: widget.initialEmail,
        id: widget.id,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]), // Set the title dynamically
        actions: [
          IconButton(
            icon: const Icon(Icons.logout), // icon for logout
            onPressed:
                _navigateToSignInSignUpPage, // method to be called on pressed
            tooltip: 'Logout', // tooltip for the icon
          ),
        ],
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
        child: _children[_currentIndex], // This is your body content
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.blue, // Selected icon color
        unselectedItemColor: Colors.purple, // Unselected icon color
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: 'QR Scanner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Usage',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
