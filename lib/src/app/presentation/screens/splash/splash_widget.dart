import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../home/home_page_widget.dart';
import '../sign_in_sign_up/sign_in_sign_up_widget.dart';
import '../../../../data/models/splash_model.dart';

class SplashWidget extends StatefulWidget {
  const SplashWidget({super.key});

  @override
  _SplashWidgetState createState() => _SplashWidgetState();
}

class _SplashWidgetState extends State<SplashWidget>
    with TickerProviderStateMixin {
  late SplashModel _model;

  late AnimationController _containerAnimationController;
  late AnimationController _columnAnimationController;
  late AnimationController _imageAnimationController;
  late AnimationController _textAnimationController;

  @override
  void initState() {
    super.initState();

    _model = SplashModel();

    _containerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _columnAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _imageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _textAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _imageAnimationController
        .forward(); // Move this line here after initialization

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));

    // Add a delay before navigating to the sign-up page
    // Add a delay before navigating based on authentication status
    Future.delayed(const Duration(seconds: 2), () {
      if (FirebaseAuth.instance.currentUser != null) {
        // User is signed in
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const HomePage()));
      } else {
        // User is not signed in
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const SignInSignUpPage()));
      }
    });
  }

  @override
  void dispose() {
    _model.dispose();

    _containerAnimationController.dispose();
    _columnAnimationController.dispose();
    _imageAnimationController.dispose();
    _textAnimationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7F3F98),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: const [
                  Color(0xFF1E90C6),
                  Color(0xFFDC51FF),
                  Color(0xDE7644CB),
                  Color(0xFF7E28FE),
                  Color(0xFF034EBA)
                ],
                stops: const [0, 0.1, 0.45, 0.9, 1],
                begin: orientation == Orientation.portrait
                    ? const AlignmentDirectional(1, 0.34)
                    : const AlignmentDirectional(0.34, 1),
                end: orientation == Orientation.portrait
                    ? const AlignmentDirectional(-1, -0.34)
                    : const AlignmentDirectional(-0.34, -1),
              ),
            ),
            child: orientation == Orientation.portrait
                ? _portraitLayout()
                : _landscapeLayout(),
          );
        },
      ),
    );
  }

  Widget _portraitLayout() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: _commonWidgets(),
    );
  }

  Widget _landscapeLayout() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: _commonWidgets(),
    );
  }

  List<Widget> _commonWidgets() {
    return [
      Padding(
        padding: const EdgeInsets.only(top: 165.0), // Add this line
        child: AnimatedBuilder(
          animation: _imageAnimationController,
          builder: (context, child) {
            return Opacity(
              opacity: _imageAnimationController.value,
              child: Transform.translate(
                offset: Offset(_imageAnimationController.value * 1,
                    _imageAnimationController.value * 1),
                child: Image.asset(
                  'assets/images/Asset_6.png',
                  width: 140,
                  height: 140,
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 100),
      InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () async {
          Navigator.pushNamed(context, 'Home1');
        },
        child: AnimatedBuilder(
          animation: _textAnimationController,
          builder: (context, child) {
            return Opacity(
              opacity: _textAnimationController.value,
              child: Text(
                'Connect >',
                style: TextStyle(
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            );
          },
        ),
      ),
    ];
  }
}
