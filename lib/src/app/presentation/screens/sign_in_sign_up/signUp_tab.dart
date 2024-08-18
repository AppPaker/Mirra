
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirra/src/app/controllers/auth/sign_up_model.dart';
import 'package:mirra/src/app/presentation/components/mirror_button.dart';
import 'package:mirra/src/app/presentation/components/social_auth.dart';
import 'package:mirra/src/app/presentation/utils/constants.dart';
import 'package:mirra/src/domain/firebase/cloud_storeage/firebase_storage.dart';
import 'package:mirra/src/domain/services/navigation_service.dart';
import 'package:provider/provider.dart';
import 'email_verification_page.dart';

class SignUpWidget extends StatelessWidget {
  const SignUpWidget({super.key, required this.storageService});

  final StorageService storageService;

  @override
  Widget build(BuildContext context) {
    return Consumer<SignInSignUpModel>(
      builder: (context, model, child) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: AutofillGroup(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 12),

                  // Email field
                  TextFormField(
                    cursorColor: kBlackColor,
                    style: Theme.of(context).textTheme.bodyMedium,
                    controller: model.emailAddressController,
                    autofillHints: const [AutofillHints.email],
                    decoration: InputDecoration(
                      hintText: 'Email',
                      fillColor: Colors.white70,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    validator: model.signupemailControllerValidator,
                  ),
                  const SizedBox(height: 10),

                  // Password field
                  TextFormField(
                    cursorColor: kBlackColor,
                    style: Theme.of(context).textTheme.bodyMedium,
                    controller: model.passwordController,
                    autofillHints: const [AutofillHints.newPassword],
                    decoration: InputDecoration(
                      hintText: 'Password',
                      fillColor: Colors.white70,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    obscureText: !model.passwordVisibility,
                    validator: model.passwordsignupControllerValidator,
                  ),
                  const SizedBox(height: 10),

                  // Confirm password field
                  TextFormField(
                    cursorColor: kBlackColor,
                    style: Theme.of(context).textTheme.bodyMedium,
                    controller: model.confirmPasswordController,
                    autofillHints: const [AutofillHints.newPassword],
                    decoration: InputDecoration(
                      hintText: 'Confirm Password',
                      fillColor: Colors.white70,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    obscureText: !model.confirmPasswordVisibility,
                    validator: model.confirmPasswordControllerValidator,
                  ),
                  const SizedBox(height: kPadding4),

                  // Sign up button
                  Row(
                    children: [
                      Expanded(
                        child: MirrorElevatedButton(
                          onPressed: () async {
                            String email =
                                model.emailAddressController.text.trim();
                            String password =
                                model.passwordController.text.trim();
                            await model.signUpUser(email, password, context);
                            navigatorKey.currentState?.pushReplacement(
                              MaterialPageRoute(
                                builder: (context) =>
                                    EmailVerificationCheckPage(
                                  storageService: storageService,
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            'Sign up',
                            style: TextStyle(
                              color: kPrimaryAccentColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: kPadding4),

                  // Other sign up methods
                  const Text('Or sign up with',
                      style: TextStyle(color: CupertinoColors.white)),

                  const SocialAuthWidget(),
                ],
              ),
            ),
          ),
        );
      },
      child: null,
    );
  }
}
