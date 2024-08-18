import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../presentation/config/environment.dart';

class AdManager with ChangeNotifier {
  static final AdManager _instance = AdManager._internal();

  factory AdManager() => _instance;

  AdManager._internal();

  DateTime? lastAdDisplayTime;
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;

  bool _isAdLoaded = false;

  void initializeBannerAd(
      VoidCallback onAdLoadedCallback, VoidCallback onAdFailedCallback) {
    if (_bannerAd == null) {
      if (kDebugMode) {
        print('Creating banner ad');
      }

      // Choose the ad unit ID based on the platform
      String adUnitId = Platform.isIOS
          ? Environment.kCardBannerAdIOS
          : Environment.kCardBannerAdAndroid;

      _bannerAd = BannerAd(
        adUnitId: adUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (_) {
            _onAdLoaded(onAdLoadedCallback);
          },
          onAdFailedToLoad: (_, __) => _onAdFailed(onAdFailedCallback),
        ),
      );
      _bannerAd?.load();
    }
  }

  void createBannerAd(
      VoidCallback onAdLoadedCallback, VoidCallback onAdFailedCallback) {
    if (_bannerAd == null || !_isAdLoaded) {
      if (kDebugMode) {
        print('Creating banner ad');
      }

      // Choose the ad unit ID based on the platform
      String adUnitId = Platform.isIOS
          ? Environment.kCardBannerAdIOS
          : Environment.kCardBannerAdAndroid;

      _bannerAd = BannerAd(
        adUnitId: adUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (_) {
            _onAdLoaded(onAdLoadedCallback);
          },
          onAdFailedToLoad: (_, __) => _onAdFailed(onAdFailedCallback),
        ),
      );
      _bannerAd?.load();
    }
  }

  void _onAdLoaded(VoidCallback onAdLoadedCallback) {
    if (kDebugMode) {
      print('Ad Loaded');
    }
    _isAdLoaded = true;
    onAdLoadedCallback.call();
    // Defer notifyListeners or control its invocation more carefully
    if (hasListeners) {
      notifyListeners();
    }
  }

  void _onAdFailed(VoidCallback onAdFailedCallback) {
    if (kDebugMode) {
      print('Ad Failed to Load');
    }
    _isAdLoaded = false;
    onAdFailedCallback.call();
    // Defer notifyListeners or control its invocation more carefully
    if (hasListeners) {
      notifyListeners();
    }
  }

  bool isAdLoaded() {
    return _isAdLoaded;
  }

  bool shouldLoadAds() {
    if (lastAdDisplayTime == null ||
        DateTime.now().difference(lastAdDisplayTime!).inMinutes >= 5) {
      return true;
    }
    return false;
  }

  void updateLastAdDisplayTime() {
    lastAdDisplayTime = DateTime.now();
  }

  Widget getBannerAdWidget() {
    if (_isAdLoaded && _bannerAd != null) {
      // BannerAd bannerAd = _bannerAd!;
      return Container(
        alignment: Alignment.center,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        // key: UniqueKey(),
        child: AdWidget(ad: _bannerAd!), // Ensuring a unique widget is returned
      );
    } else {
      return Container(height: 50); // Placeholder for unloaded ad
    }
  }

  /*Widget getBannerAdWidget() {
    if (_isAdLoaded && _bannerAd != null) {
      BannerAd bannerAd = _bannerAd!;
      return Container(
        alignment: Alignment.center,
        width: bannerAd.size.width.toDouble(),
        height: bannerAd.size.height.toDouble(),
        key: UniqueKey(),
        child: AdWidget(ad: bannerAd), // Ensuring a unique widget is returned
      );
    } else {
      return Container(height: 50); // Placeholder for unloaded ad
    }
  }*/

  void disposeBannerAd() {
    _bannerAd!.dispose();
    _bannerAd = null;
    _isAdLoaded = false;
    if (hasListeners) {
      notifyListeners();
    }
  }

  void disposeAd() {
    if (kDebugMode) {
      print('Disposing ad');
    } // Logging ad disposal
    _bannerAd?.dispose();
    _bannerAd = null;
    _isAdLoaded = false;
    notifyListeners(); // Notify listeners about the state change
  }

  Future<void> loadInterstitialAd() async {
    if (shouldLoadAds()) {
      String adUnitId = Platform.isIOS
          ? Environment.kCardInterstitialAdIOS
          : Environment.kCardInterstitialAdAndroid;

      InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('Interstitial Ad Failed to Load: $error');
          },
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            // Don't show it here, just load it
          },
        ),
      );
    }
  }

  void showInterstitialAd() {
    if (_interstitialAd != null && shouldLoadAds()) {
      _interstitialAd!.show();
      _interstitialAd = null; // Reset after showing
      updateLastAdDisplayTime(); // Update display time
    }
  }

  void maybeShowInterstitialAd() {
    if (_interstitialAd != null && shouldLoadAds()) {
      _interstitialAd!.show();
      _interstitialAd = null; // Reset after showing
      updateLastAdDisplayTime(); // Update display time
    }
  }
}
