// ignore_for_file: use_build_context_synchronously

import 'package:currensee/utils/wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:currensee/widgets/custom_scaffold.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({super.key});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  @override
  void initState() {
    sendVerificationLink();
    super.initState();
  }

  sendVerificationLink() async {
    final user = FirebaseAuth.instance.currentUser!;
    await user.sendEmailVerification().then((value) {
      Get.snackbar('Email Verification', 'A link has been sent to your email',
          margin: const EdgeInsets.all(30),
          snackPosition: SnackPosition.BOTTOM);
    });
  }

  Future<void> signout() async {
    final user = FirebaseAuth.instance.currentUser!;
    await user.reload();
    if (user.emailVerified) {
      // Redirect to home or desired page if email is verified
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Wrapper(), // Replace with desired page
        ),
      );
    } else {
      // Stay on verify email page if email is not verified
      Get.snackbar('Email Verification', 'Your email is not yet verified',
          margin: const EdgeInsets.all(30),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(height: 10),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Email Verification',
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.w900,
                      color: Colors.blue, // Update color as needed
                    ),
                  ),
                  const SizedBox(height: 40.0),
                  const Text(
                    'Open your email and click the link to verify your email',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      sendVerificationLink();
                    },
                    child: const Text('Resend Verification Email'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: signout,
                    child: const Text('Verified'),
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
