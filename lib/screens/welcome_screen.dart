import 'package:flutter/material.dart';
import 'package:currensee/screens/signin_screen.dart';
import 'package:currensee/screens/signup_screen.dart';
import 'package:currensee/widgets/custom_scaffold.dart';
import 'package:currensee/widgets/welcome_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Flexible(
              flex: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 40.0,
                ),
                child: Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      children: [
                        TextSpan(
                            text: 'Welcome Back!\n',
                            style: TextStyle(
                              fontSize: 45.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            )),
                        TextSpan(
                            text: 'Your Currency Copanion Convert With Ease',
                            style: TextStyle(fontSize: 20, color: Colors.white
                                // height: 0,
                                ))
                      ],
                    ),
                  ),
                ),
              )),
          const Flexible(
            flex: 5,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Row(
                children: [
                  Expanded(
                    child: WelcomeButton(
                      buttonText: 'Sign in',
                      onTap: SignInScreen(),
                      color: Colors.transparent,
                      textColor: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: WelcomeButton(
                      buttonText: 'Sign up',
                      onTap: SignUpScreen(),
                      color: Colors.white,
                      textColor: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
