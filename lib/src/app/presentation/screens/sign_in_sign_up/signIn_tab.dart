import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirra/src/app/controllers/auth/sign_in_model.dart';
import 'package:mirra/src/app/presentation/components/mirror_button.dart';
import 'package:mirra/src/app/presentation/components/social_auth.dart';
import 'package:mirra/src/app/presentation/utils/constants.dart';
import 'package:provider/provider.dart';

class SignInWidget extends StatefulWidget {
  const SignInWidget({super.key});

  @override
  _SignInWidgetState createState() => _SignInWidgetState();
}

class _SignInWidgetState extends State<SignInWidget> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 12),

            TextField(
              cursorColor: kBlackColor,
              style: Theme.of(context).textTheme.bodyMedium,
              onChanged: (value) =>
                  context.read<SignInModel>().updateEmail(value),
              decoration: InputDecoration(
                hintText: 'Email',
                fillColor: Colors.white70,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              cursorColor: kBlackColor,
              style: Theme.of(context).textTheme.bodyMedium,
              onChanged: (value) =>
                  context.read<SignInModel>().updatePassword(value),
              decoration: InputDecoration(
                hintText: 'Password',
                fillColor: Colors.white70,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: kPadding4),

            // Sign in button
            Row(
              children: [
                Expanded(
                  child: MirrorElevatedButton(
                    onPressed: () =>
                        context.read<SignInModel>().navigateToHomePage(context),
                    child: const Text('Sign in'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            // Add spacing between sign-in button and forgot password

            // Forgot password
            Row(
              children: [
                InkWell(
                  onTap: () {},
                  child: Text(
                    'Forgot Password?',
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(color: kWhiteColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
 
            const Text('Or sign in with',
                style: TextStyle(color: CupertinoColors.white)),
            const SocialAuthWidget(),
          ],
        ),
      ),
    );
  }
}
