import 'package:flutter/material.dart';
import 'package:mirra/src/app/controllers/admanager/ad_service.dart';

import 'nearby_page_widget.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late AdManager _adManager; // Use AdManager for managing the ad

  @override
  void initState() {
    super.initState();
    _adManager = AdManager();
    _adManager.createBannerAd(
      () {
        // Actions when the ad is loaded
        if (mounted) setState(() {});
      },
      () {
        // Do nothing if the ad fails to load
      },
    );

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _controller.forward().then((_) {
      _controller.reverse().then((_) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const NearbyPage(),
        ));
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _adManager.disposeAd();
    _adManager.disposeBannerAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E90C6),
      body: FadeTransition(
        opacity: _controller,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Explore what's around you!",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              const SizedBox(height: 20),
              const Text(
                "Invite others and discover together.",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              _adManager.getBannerAdWidget(), // Get the Banner Ad Widget
            ],
          ),
        ),
      ),
    );
  }
}
