import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mirra/src/app/controllers/notification/notification_provider.dart';
import 'package:mirra/src/app/controllers/users/user_service.dart';
import 'package:mirra/src/app/controllers/business_profile/business_profile_bloc.dart';
import 'package:mirra/src/app/controllers/users/create_profile_model.dart';
import 'package:mirra/src/app/controllers/users/profile_page_viewmodel.dart';
import 'package:mirra/src/app/controllers/business_profile/business_profile_model.dart';
import 'package:mirra/src/app/controllers/feed/feed_model.dart';
import 'package:mirra/src/app/controllers/admanager/ad_service.dart';
import 'package:mirra/src/app/presentation/components/app_theme.dart';
import 'package:mirra/src/app/presentation/components/mirror_card.dart';
import 'package:mirra/src/app/presentation/components/onboarding_model.dart';
import 'package:mirra/src/app/presentation/config/environment.dart';
import 'package:mirra/src/app/presentation/screens/chat/chat_widget.dart';
import 'package:mirra/src/app/controllers/intro_slides/intro_slide_model.dart';
import 'package:mirra/src/app/controllers/store/store_model.dart';
import 'package:mirra/src/app/presentation/screens/chat/matched_list_widget.dart';
import 'package:mirra/src/app/presentation/screens/create_profile/create_profile_widget.dart';
import 'package:mirra/src/app/presentation/screens/home/home_page_widget.dart';
import 'package:mirra/src/app/presentation/screens/map/map_widget.dart';
import 'package:mirra/src/app/presentation/screens/profile_page/profile_page_widget.dart';
import 'package:mirra/src/app/presentation/screens/sign_in_sign_up/sign_in_sign_up_widget.dart';
import 'package:mirra/src/app/presentation/screens/swipe_card/swipe_card_widget.dart';
import 'package:mirra/src/app/controllers/home/home_page_model.dart';
import 'package:mirra/src/domain/firebase/auth_service.dart';
import 'package:mirra/src/domain/firebase/cloud_storeage/firebase_storage.dart';
import 'package:mirra/src/domain/firebase/cloud_firestore/firestore_service.dart';
import 'package:mirra/src/domain/firebase/cloud_firestore/real_firestore_service.dart';
import 'package:mirra/src/domain/firebase/cloud_firestore/user_firestore_service.dart';
import 'package:mirra/src/domain/messaging/firebase_messaging.dart';
import 'package:mirra/src/domain/services/navigation_service.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
// ignore: library_prefixes
import 'src/app/presentation/screens/users/user.dart' as appUser;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await MobileAds.instance.initialize();
  MobileAds.instance.initialize().then((InitializationStatus status) {
    if (kDebugMode) {
      print('Initialization done');
    }
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.unspecified,
        testDeviceIds: <String>[
          "B3D84197F5C16BBD4C1C275FD73613E0",
          'adb-2B251FDH300AE5-GbBqJ8._adb-tls-connect._tcp.',
          '5717580B-6157-4FD3-8305-CA0E9C4CB382',
        ],
      ),
    );
  });

  final storageService = StorageService();

  initializePushNotifications();

  OnboardingModel onboardingModel = OnboardingModel();
  await onboardingModel.loadOnboardingStatus();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // ignore: unused_element
  void initializeNotifications() {
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<UserService>(create: (_) => UserService()),
        Provider<FirebaseAuthService>(create: (_) => FirebaseAuthService()),
        Provider<RealFirestoreService>(create: (_) => RealFirestoreService()),
        Provider<AuthService>.value(value: FirebaseAuthService()),
        ChangeNotifierProvider<NotificationProvider>(
          create: (context) => NotificationProvider(
            FirebaseAuth.instance.currentUser?.uid ?? '',
          ),
        ),
        Provider<BusinessProfileBloc>(
          create: (context) => BusinessProfileBloc(
            userService: context.read<UserService>(),
            authService: context.read<FirebaseAuthService>(),
            firestoreService: context.read<RealFirestoreService>(),
            notificationProvider: context.read<NotificationProvider>(),
          ),
        ),
        Provider<CreateProfileModel>(
          create: (context) =>
              CreateProfileModel(storageService: storageService),
        ),
        ChangeNotifierProvider(
          create: (context) => ProfilePageViewModel(
            authService: Provider.of<AuthService>(context, listen: false),
            userId: FirebaseAuth.instance.currentUser?.uid ?? '',
          ),
        ),
        Provider<StorageService>.value(value: storageService),
        Provider<FirestoreService>.value(value: FirestoreService()),
        ChangeNotifierProvider(
          create: (context) => BusinessProfileModel(),
        ),
        ChangeNotifierProvider(
            create: (context) => HomePageViewModel(
                  authService: Provider.of<AuthService>(context, listen: false),
                )),
        ChangeNotifierProvider(create: (_) => FeedModel()),
        ChangeNotifierProvider.value(value: onboardingModel),
        ChangeNotifierProvider(create: (_) => appUser.User.empty()),
        ChangeNotifierProvider<IntroSlideModel>(
          create: (context) => IntroSlideModel(authService: authService),
        ),
        ChangeNotifierProvider(create: (context) => ShardModel(shards: 0)),
        ChangeNotifierProvider<ShardStoreModel>(
          create: (context) => ShardStoreModel(ShardModel(shards: 0)),
        ),
        ChangeNotifierProvider(
          create: (context) => ShardStoreModel(
            Provider.of<ShardModel>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider<AdManager>(create: (_) => AdManager()),
      ],
      child: const MyApp(),
    ),
  );
}

enum AppPage { home, maps, profile, cardSwipe, card, chat } // Define app pages

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? userId;

  UserFirestoreService userFirestoreService = UserFirestoreService();

  late AuthService authService;
  late FirestoreService firestoreService;
  late appUser.User user;

  final List<Widget> _pages = [
    const HomePage(),
    const MapPage(),
    const Placeholder(), // Placeholder for UserProfilePage, replace when you have userId
    const SwipeCardWidget(),
    MirrorCard(),
    const MatchedListPage(),
  ];

  // ignore: unused_element
  void _checkOnboardingStatus(BuildContext context) {
    final onboardingModel =
        Provider.of<OnboardingModel>(context, listen: false);
    if (!onboardingModel.hasCompletedOnboarding) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CreateProfilePage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      _pages[2] = UserProfilePage(userId: userId!);
    }
    final adManager = AdManager();
    adManager.initializeBannerAd(() {
      if (kDebugMode) {
        print("Ad Loaded Successfully.");
      }
    }, () {
      if (kDebugMode) {
        print("Ad Failed to Load");
      }
    });
  }

  void handleDeepLink(String link) {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: Environment.appName,
        navigatorKey: navigatorKey,
        theme: AppTheme().theme,
        debugShowCheckedModeBanner: false,
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                return const HomePage();
              } else {
                return const SignInSignUpPage();
              }
            }

            return const CircularProgressIndicator();
          },
        ));
  }
}
