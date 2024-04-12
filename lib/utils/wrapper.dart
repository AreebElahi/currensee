import 'package:currensee/screens/home_screen.dart';
import 'package:currensee/screens/welcome_screen.dart';
import 'package:currensee/services/verify_email.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          if (snapshot.hasData && snapshot.data != null) {
            if (snapshot.data!.emailVerified) {
              return const HomeScreen();
            } else {
              return const VerifyEmail();
            }
          } else {
            return const WelcomeScreen();
          }
        }
      },
    );
  }
}
