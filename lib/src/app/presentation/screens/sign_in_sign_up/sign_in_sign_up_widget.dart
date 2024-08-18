import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mirra/src/app/controllers/auth/sign_in_model.dart';
import 'package:mirra/src/app/controllers/auth/sign_up_model.dart';
import 'package:mirra/src/app/controllers/users/create_profile_model.dart';
import 'package:mirra/src/app/presentation/screens/create_profile/create_profile_widget.dart';
import 'package:mirra/src/app/presentation/screens/home/home_page_widget.dart';
import 'package:mirra/src/app/presentation/screens/sign_in_sign_up/signIn_tab.dart';
import 'package:mirra/src/app/presentation/screens/sign_in_sign_up/signUp_tab.dart';
import 'package:mirra/src/app/presentation/utils/constants.dart';
import 'package:mirra/src/domain/firebase/cloud_storeage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'business_reg.dart';

class SignInSignUpPage extends StatefulWidget {
  const SignInSignUpPage({super.key});

  @override
  _SignInSignUpPageState createState() => _SignInSignUpPageState();
}

class _SignInSignUpPageState extends State<SignInSignUpPage>
    with TickerProviderStateMixin {
  late final StorageService storageService;
  late final SignInSignUpModel _model;

  @override
  void initState() {
    super.initState();
    storageService = Provider.of<StorageService>(context, listen: false);
    _model = SignInSignUpModel(this, storageService);
    checkAuth();
  }

  void checkAuth() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool onBoarded = prefs.getBool('hasCompletedOnboarding') ?? false;
      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) {
          if (onBoarded) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          } else {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider<CreateProfileModel>(
                create: (context) => CreateProfileModel(
                  storageService: storageService,
                  userId: user.uid,
                ),
                child: const CreateProfilePage(),
              ),
            ));
          }
        },
      );
    }
  }

  @override
  void dispose() {
    _model.dispose(); // Call the model's dispose method
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SignInSignUpModel>.value(
      value: _model,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.5, 0.8),
              radius: 5,
              colors: [
                kPurpleColor,
                kPrimaryAccentColor,
                // Other gradient colors...
              ],
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top),
              // Add company logo here
              Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Center(
                  child: Image.asset(
                    'assets/images/D51136ED-043D-4C43-B78B-2401B36407E9.png',
                    width: 100,
                    height: 100,
                  ),
                ),
              ),
              const SizedBox(height: 30), // Add space between logo and tab bar
              Expanded(
                child: Stack(
                  children: [
                    // Background image
                    /*Positioned.fill(
                      child: Image.asset(
                        'assets/images/Asset_3@10x.png',
                        fit: BoxFit.contain,
                      ),
                    ),*/
                    Column(
                      children: [
                        Consumer<SignInSignUpModel>(
                          builder: (context, model, child) {
                            return TabBar(
                              controller: model.tabController,
                              labelColor: Colors.white,
                              unselectedLabelColor:
                                  Colors.white.withOpacity(0.3),
                              indicatorColor: Colors.white,
                              tabs: const <Widget>[
                                Tab(text: 'Sign up'),
                                Tab(text: 'Sign in'),
                                //Tab(text: 'Business'),
                              ],
                            );
                          },
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _model.tabController,
                            children: [
                              SingleChildScrollView(
                                child: SignUpWidget(
                                  storageService: storageService,
                                ),
                              ),
                              SingleChildScrollView(
                                child: ChangeNotifierProvider(
                                  create: (context) => SignInModel(),
                                  child: const SignInWidget(),
                                ),
                              ),
                              /*const SingleChildScrollView(
                                child: BusinessSignInSignUpWidget(),
                              ),*/
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Navigate to the Business Sign In/Sign Up page
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => const BusinessSignInSignUpWidget()),
            );
          }, // Change the icon as needed
          backgroundColor: Colors.grey,
          child: const Icon(Icons.business), // Change the color as needed
        ),
      ),
    );
  }
}
