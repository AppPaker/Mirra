import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirra/src/app/controllers/admanager/ad_service.dart';
import 'package:mirra/src/app/controllers/home/home_page_model.dart';
import 'package:mirra/src/app/presentation/components/ad_card.dart';
import 'package:mirra/src/app/presentation/components/app_logo.dart';
import 'package:mirra/src/app/presentation/components/gradient_appbar.dart';
import 'package:mirra/src/app/presentation/screens/home/home_page_widget.dart';
import 'package:mirra/src/app/presentation/screens/swipe_card/filter_page.dart';
import 'package:mirra/src/app/presentation/screens/swipe_card/user_card_swiper.dart';
import 'package:mirra/src/app/presentation/screens/users/user.dart';
import 'package:mirra/src/data/models/filter_page_model.dart';
import 'package:mirra/src/data/models/swipe_card_model.dart';
import 'package:mirra/src/domain/firebase/auth_service.dart';
import 'package:provider/provider.dart';

class SwipeCardWidget extends StatefulWidget {
  const SwipeCardWidget({super.key});

  @override
  _SwipeCardWidgetState createState() => _SwipeCardWidgetState();
}

class _SwipeCardWidgetState extends State<SwipeCardWidget> {
  final SwipeCardModel model = SwipeCardModel(
      authService: FirebaseAuthService(), onMatchFound: (user, matchId) {});
  List<User> users = [];
  int currentPage = 0;
  final int usersPerPage = 20;
  late Future<bool> future;
// Define this to keep track of the current card index
  DateTime? lastAdDisplayTime;

  @override
  void initState() {
    super.initState();
   
    future = model.fetchUsers(currentPage, usersPerPage);

   
  }

  @override
  void dispose() {
    final adManager = Provider.of<AdManager>(context, listen: false);
    adManager.disposeAd();
    adManager.disposeBannerAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // // When the user is close to the end of the current list, fetch more users
    // if (users.length - _currentIndex <= 5) {
    //   _fetchUsers();
    // }
    return Scaffold(
      appBar: GradientAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider<HomePageViewModel>(
                create: (_) => HomePageViewModel(
                  authService: Provider.of<AuthService>(context, listen: false),
                ),
                child: const HomePage(),
              ),
            ),
          ),
        ),
        title: const AppLogo(),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () async {
              final userId = fb.FirebaseAuth.instance.currentUser?.uid;
              if (userId != null) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return ChangeNotifierProvider(
                        create: (_) => FilterPageModel(userId: userId),
                        child: FilterPage(userId: userId),
                      );
                    },
                  ),
                );
              }
              setState(() {
                future = model.fetchUsers(currentPage, usersPerPage);
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          const Text(
            "Connect with people",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 24, color: Colors.black),
          ),
          FutureBuilder(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (kDebugMode) {
                  print('Number of users in CardSwiper: ${model.users.length}');
                }
                if (kDebugMode) {
                  print(model.users);
                }

                if (model.users.isNotEmpty) {
            
                  return UserCardSwiper(
                    users: model.users,
                    cardHeight: 300, 
                    model: model,
                  );
                } else {
                  return Column(
                    children: [
                      const Center(child: Text("No Users")),
                      const SizedBox(height: 20),
                      AdCardWidget(
                        onClose: () {
                          setState(() {
               
                          });
                        },
                      )
                    ],
                  );
                }
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          Align(
            alignment: Alignment.topCenter,
            child: SafeArea(
              child: Provider.of<AdManager>(context, listen: false)
                  .getBannerAdWidget(),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
