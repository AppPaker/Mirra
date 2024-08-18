import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mirra/src/app/presentation/components/onboarding_model.dart';
import 'package:mirra/src/app/presentation/utils/constants.dart';
import 'package:mirra/src/domain/firebase/auth_service.dart';
import 'package:provider/provider.dart';
import '../profile_page/profile_page_widget.dart'; // Add this line

class CelebrationPage extends StatefulWidget {
  const CelebrationPage({super.key});

  @override
  _CelebrationPageState createState() => _CelebrationPageState();
}

class _CelebrationPageState extends State<CelebrationPage> {
  late ConfettiController _controller;
  String mbtiResult = '';
  String? userId;

  @override
  void initState() {
    super.initState();

    // Mark the onboarding as complete
    Provider.of<OnboardingModel>(context, listen: false).completeOnboarding();

    _controller = ConfettiController(duration: const Duration(seconds: 2));
    _controller.play();
    fetchMBTI();
  }

  Future<void> fetchMBTI() async {
    // Use the FirebaseAuthService to get the user ID
    final authService = FirebaseAuthService();
    userId = await authService.getUserId();
    DocumentSnapshot docSnapshot =
    await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (kDebugMode) {
      print(docSnapshot.data());
    }

    if (mounted) {
      setState(() {
        Map<String, dynamic> snapshotData =
        docSnapshot.data() as Map<String, dynamic>;
        mbtiResult = snapshotData.containsKey('mbtiType')
            ? snapshotData['mbtiType']
            : '';
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              kPurpleColor,
              kPrimaryAccentColor,
            ],
          ),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                        bottom: 16.0), // Adjust the margin as needed
                    child: Image.asset(
                      'assets/images/D51136ED-043D-4C43-B78B-2401B36407E9.png',
                      width: 120,
                      height: 120,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text(
                      'Congratulations!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 10, 30, 10),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.lato(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                        children: const [
                          TextSpan(
                            text: "You've now completed your profile.",
                          ),
                          TextSpan(
                              text: ""
                                  " Next up, add your bio and photos to show who you are")
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(25),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UserProfilePage(
                                  userId: userId!,
                                ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        backgroundColor: const Color(0xfff3f3f3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        elevation: 5,
                        shadowColor: Colors.grey.withOpacity(0.5),
                      ),
                      child: const Text('Click to explore more >'),
                    ),
                  ),
                  /*ElevatedButton(
                    onPressed: () {
                      _controller.play();
                    },
                    child: Text('Trigger Confetti'),
                  ),*/
                ],
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: ConfettiWidget(
                confettiController: _controller,
                blastDirection: 5,
                maxBlastForce: 100,
                minBlastForce: 15,
                emissionFrequency: 0.05,
                numberOfParticles: 65,
                gravity: 0.5,
                colors: const [
                  Colors.deepOrangeAccent,
                  Colors.white,
                  Colors.indigo,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
