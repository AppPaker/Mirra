import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirra/src/app/controllers/users/profile_page_viewmodel.dart';
import 'package:mirra/src/app/presentation/screens/profile_page/EditProfilePage.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Helper method to launch URLs
  void _launchURL(String url) async {
    final Uri url0 = Uri.parse(url); // Convert the string URL to a Uri object
    if (await canLaunchUrl(url0)) {
      await launchUrl(url0);
    } else {
      // Can't launch the URL, handle the error
      if (kDebugMode) {
        print('Could not launch $url');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          /*ListTile(
            title: const Text('Notifications Settings'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NotificationsPage()));
            },
          ),*/
          ListTile(
            title: const Text('Edit Profile'),
            onTap: () {
              final model =
                  Provider.of<ProfilePageViewModel>(context, listen: false);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(userId: model.user.id),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Invite Friends'),
            onTap: () {
              // Implement Invite Friends functionality
            },
          ),
          ExpansionTile(
            title: const Text('Protection Information'),
            children: <Widget>[
              ListTile(
                title: const Text('Privacy Policy'),
                onTap: () {
                  _launchURL(
                      'https://www.themirrorsocial.com/privacy-policy.html');
                },
              ),
              ListTile(
                title: const Text('Terms & Conditions'),
                onTap: () {
                  _launchURL(
                      'https://www.themirrorsocial.com/termsandconditions.html');
                },
              ),
            ],
          ),
          ListTile(
            title: const Text('Support'),
            onTap: () {
              // Navigate to Support page or open support email/chat
            },
          ),
        ],
      ),
    );
  }
}
