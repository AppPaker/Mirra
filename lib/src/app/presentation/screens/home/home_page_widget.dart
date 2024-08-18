import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirra/src/app/controllers/admanager/ad_service.dart';
import 'package:mirra/src/app/controllers/notification/notification_provider.dart';
import 'package:mirra/src/app/presentation/components/app_logo.dart';
import 'package:mirra/src/app/presentation/components/drawer.dart';
import 'package:mirra/src/app/presentation/components/gradient_appbar.dart';
import 'package:mirra/src/app/presentation/components/mirror_card.dart';
import 'package:mirra/src/app/presentation/navbar/bottombar.dart';
import 'package:mirra/src/app/presentation/screens/chat/matched_list_widget.dart';
import 'package:mirra/src/app/presentation/screens/home/tab_widget.dart';
import 'package:mirra/src/app/presentation/screens/map/map_widget.dart';
import 'package:mirra/src/app/presentation/screens/notification_view.dart';
import 'package:mirra/src/app/presentation/screens/profile_page/profile_page_widget.dart';
import 'package:mirra/src/app/presentation/screens/swipe_card/swipe_card_widget.dart';
import 'package:provider/provider.dart';
import '../../components/page_indicator.dart';
import '../businesses/qr_scanner/user_scanner.dart';
import '../insights/insights_page.dart';
import '../../../../data/models/quote_viewmodel.dart';
import '../user_feed/feed_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late QuoteViewModel viewModel;
  late TabController _tabController;
  late AdManager _adManager;
  late PageController _pageController;
  AppPage _selectedPage = AppPage.home;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print('HomePage initState called');
    }
    _tabController = TabController(length: 2, vsync: this);
    viewModel = QuoteViewModel(FirebaseAuth.instance.currentUser!.uid);
    _adManager = AdManager();
    _initializeBannerAd();
    _pageController = PageController();
    _pageController.addListener(_pageChanged);
  }

  void _initializeBannerAd() {
    if (kDebugMode) {
      print('Initializing Banner Ad');
    }
    _adManager.initializeBannerAd(
      () {
        if (kDebugMode) {
          print('Ad loaded successfully');
        }
        if (mounted) setState(() {});
      },
      () {
        if (kDebugMode) {
          print('Ad failed to load');
        }
        // No action needed if ad fails to load
      },
    );
  }

  void _pageChanged() {
    if (kDebugMode) {
      print('Page changed listener triggered');
    }
    int nextIndex = _pageController.page!.round();
    if (kDebugMode) {
      print('Current page index: $_currentPageIndex, Next index: $nextIndex');
    }
    if (_currentPageIndex != nextIndex) {
      setState(() {
        _currentPageIndex = nextIndex;
        _adManager.disposeBannerAd();
        _initializeBannerAd();
      });
    }
  }

  @override
  void dispose() {
    if (kDebugMode) {
      print('HomePage dispose called');
    }
    _adManager.disposeBannerAd();
    _tabController.dispose();
    _pageController.removeListener(_pageChanged);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('HomePage build method called');
    }
    return Scaffold(
      body: _selectedPageContent(),
      bottomNavigationBar: CustomBottomNavigationBar(
        onTabSelected: (selectedPage) {
          if (kDebugMode) {
            print('Bottom navigation tab selected: $selectedPage');
          }
          setState(() {
            _selectedPage = selectedPage;
            _adManager.disposeBannerAd();
            _initializeBannerAd();
          });
        },
        selectedPage: _selectedPage,
      ),
    );
  }

  Widget _selectedPageContent() {
    if (kDebugMode) {
      print('Building content for selected page: $_selectedPage');
    }
    switch (_selectedPage) {
      case AppPage.home:
        return _homePageScaffold();
      case AppPage.maps:
        return const MapPage();
      case AppPage.profile:
        return UserProfilePage(userId: FirebaseAuth.instance.currentUser!.uid);
      case AppPage.cardSwipe:
        return const SwipeCardWidget();
      case AppPage.card:
        return MirrorCard();
      case AppPage.chat:
        return const MatchedListPage();
      case AppPage.qrScanner:
        return const UserQRScannerScreen();
      default:
        return _homePageScaffold();
    }
  }

  Widget _homePageScaffold() {
    if (kDebugMode) {
      print('Building home page scaffold');
    }
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: AppDrawer(userId: FirebaseAuth.instance.currentUser?.uid),
      appBar: GradientAppBar(
        title: const Center(child: AppLogo()),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              final userId = FirebaseAuth.instance.currentUser?.uid;
              if (userId != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider(
                      create: (_) => NotificationProvider(userId),
                      child: const NotificationView(),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPageIndex = index;
                });
              },
              children: <Widget>[
                ProfileTab(
                    tabController: _tabController, adManager: _adManager),
                QuoteView(userId: FirebaseAuth.instance.currentUser!.uid),
                FeedWidget(
                    tabController: _tabController, adManager: _adManager),
              ],
            ),
          ),
          CustomPageIndicator(
            currentPage: _currentPageIndex,
            numPages: 3,
          ),
        ],
      ),
    );
  }
}
