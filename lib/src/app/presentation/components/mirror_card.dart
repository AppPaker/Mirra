import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:mirra/src/app/controllers/home/home_page_model.dart';
import 'package:mirra/src/app/presentation/components/gradient_appbar.dart';
import 'package:mirra/src/app/presentation/components/qr_widget.dart';
import 'package:mirra/src/app/presentation/components/tastecard.dart';
import 'package:mirra/src/app/presentation/screens/home/home_page_widget.dart';
import 'package:mirra/src/app/presentation/screens/users/user.dart';
import 'package:mirra/src/app/presentation/utils/constants.dart';
import 'package:mirra/src/domain/firebase/auth_service.dart';
import 'package:provider/provider.dart';
class MirrorCard extends StatelessWidget {
  late final Future<User> userDataFuture;

  @override
  Widget build(BuildContext context) {
    userDataFuture =
        Provider.of<HomePageViewModel>(context, listen: false).fetchUserData();
    final email = auth.FirebaseAuth.instance.currentUser?.email ?? 'No email';
    final timestamp = DateTime.now();

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
        title: const Text('Mirra Card'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder<User>(
          future: userDataFuture,
          builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (snapshot.data != null) {
                Color subscriptionColor;
                switch (snapshot.data!.subscriptionLevel) {
                  case 'Free':
                    subscriptionColor = Colors.grey;
                    break;
                  case 'Subscriber':
                    subscriptionColor = Colors.blue[300]!;
                    break;
                  case 'Premium':
                    subscriptionColor = Colors.amberAccent;
                    break;
                  case 'VIP':
                    subscriptionColor = Colors.black;
                    break;
                  default:
                    subscriptionColor = Colors.grey;
                }
                return Column(
                  children: [
                    Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          gradient: const RadialGradient(
                            center: Alignment(0.8, 1),
                            radius: 3,
                            colors: [
                              kPurpleColor,
                              kPrimaryAccentColor,
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    // This is the new row containing the QR code and the image
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      QRWidget(
                                        data: snapshot.data!.id,
                                        size: 90.0,
                                      ),
                                      const SizedBox(width: 135),
                                      // Add space between the QR code and the image

                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 65,
                                          maxHeight: 65, // Fixed maximum height
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.all(5),
                                          child: Image(
                                            image: AssetImage(
                                                'assets/images/D51136ED-043D-4C43-B78B-2401B36407E9.png'),
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    snapshot.data!.firstName ?? "",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    snapshot.data!.id,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TasteCard(
                      name: snapshot.data!.firstName ??
                          'Default Name', // Provide a default name
                      expiryDate: "Expiry Date Here",
                      memberNumber: "Member Number Here",
                    ),
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          "Timestamp: ${timestamp.day}/${timestamp.month} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Subscription Level: ${snapshot.data!.subscriptionLevel}',
                      style: TextStyle(color: subscriptionColor, fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Text('Email: $email', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 20),
                    const SizedBox(height: 20),
                  ],
                );
              } else {
                return const Text('User data is null.');
              }
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
