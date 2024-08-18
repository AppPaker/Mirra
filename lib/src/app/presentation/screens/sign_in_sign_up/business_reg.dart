import 'package:flutter/material.dart';
import 'package:mirra/src/app/presentation/utils/constants.dart';
import 'package:provider/provider.dart';

import '../../components/gradient_appbar.dart';
import '../../../../data/models/business_reg_model.dart';

class BusinessSignInSignUpWidget extends StatefulWidget {
  const BusinessSignInSignUpWidget({super.key});

  @override
  _BusinessSignInSignUpWidgetState createState() =>
      _BusinessSignInSignUpWidgetState();
}

class _BusinessSignInSignUpWidgetState
    extends State<BusinessSignInSignUpWidget> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: SizedBox(
          height: 40,
          child: Image.asset(
              'assets/images/D51136ED-043D-4C43-B78B-2401B36407E9.png'), // Your app logo here
        ),
        centerTitle: true,
      ),
      body: ChangeNotifierProvider(
        create: (context) => BusinessSignInSignUpModel(),
        child: Consumer<BusinessSignInSignUpModel>(
          builder: (context, model, child) {
            return SingleChildScrollView(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.5, 0.8),
                    radius: 5,
                    colors: [
                      Colors.indigo,
                      kPrimaryAccentColor,
                      // Other gradient colors...
                    ],
                  ),
                ),
                width: double.infinity,
                child: Center(
                  // Center the content vertically and horizontally
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height -
                          Scaffold.of(context)
                              .appBarMaxHeight! - // AppBar height
                          MediaQuery.of(context)
                              .padding
                              .top - // Status bar height
                          MediaQuery.of(context)
                              .padding
                              .bottom, // Bottom padding or navigation bar height
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 60),
                          const Text(
                            'Business Portal', // The title goes here
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 80),

                          // Business Email field
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              hintText: 'Email',
                              fillColor: Colors.white70,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),

                          // Password field
                          TextField(
                            controller: passwordController,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              fillColor: Colors.white70,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                            obscureText: true,
                          ),
                          const SizedBox(height: 16),

                          // Confirm Password field (only for sign-up)
                          if (model.isSignUpMode) // <-- Here's the change
                            TextField(
                              controller: confirmPasswordController,
                              decoration: InputDecoration(
                                hintText: 'Confirm Password',
                                fillColor: Colors.white70,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                              obscureText: true,
                            ),
                          if (model.isSignUpMode)
                            const SizedBox(height: 16), // <-- Here's the change

                          // Sign-in and Sign-up buttons

                          Column(
                            children: [
                              // Sign-in/Sign-up button

                              ElevatedButton(
                                onPressed: () async {
                                  try {
                                    if (model.isSignUpMode) {
                                      await model.signUpBusiness(
                                          context,
                                          emailController.text,
                                          passwordController.text);
                                    } else {
                                      await model.signInBusiness(
                                          context,
                                          emailController.text,
                                          passwordController.text);
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('Error: ${e.toString()}')),
                                    );
                                  }
                                },
                                child: Text(
                                    model.isSignUpMode ? 'Sign up' : 'Sign in'),
                              ),

                              const SizedBox(height: 16),
                              // Adjust spacing as needed
                              // Toggle Sign-in/Sign-up mode button

                              TextButton(
                                onPressed: () {
                                  model.toggleSignUpMode();
                                },
                                style: TextButton.styleFrom(
                                  alignment: Alignment
                                      .center, // Center-align button content
                                ),
                                child: Text(
                                  model.isSignUpMode
                                      ? 'Already have an account? Sign in'
                                      : 'Don\'t have an account? Sign up',
                                  style: const TextStyle(color: Colors.white),
                                  textAlign:
                                      TextAlign.center, // Center-align the text
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
