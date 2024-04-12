// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:currensee/screens/change_password_screen.dart';
import 'package:currensee/screens/contactus_screen.dart';
import 'package:currensee/screens/currency_history_graph.dart';
import 'package:currensee/screens/exchangerate.dart';
import 'package:currensee/screens/faqs.dart';
import 'package:currensee/screens/historypage.dart';
import 'package:currensee/screens/home_screen.dart';
import 'package:currensee/screens/welcome_screen.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _showChangePasswordButton = false;

  @override
  void initState() {
    super.initState();
    // Check if the current user's email exists in the UserRegistration table
    _checkUserEmailExists();
  }

  Future<void> _checkUserEmailExists() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userEmail = currentUser.email;
      final exists = await checkEmailExists(userEmail!);
      setState(() {
        _showChangePasswordButton = exists;
      });
    }
  }

  Future<bool> checkEmailExists(String email) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('UserRegistration')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  Future<void> signout(BuildContext context) async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();

    // Clear all previous routes and navigate to the WelcomeScreen
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const WelcomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
      (route) => false, // This will prevent the user from being able to go back
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'Roboto', // Custom font
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue, // Make app bar transparent
        elevation: 0, // Remove app bar shadow
      ),
      // Extend background behind app bar
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage(
              'assets/images/bg1.png', // Change path to your image
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6), // Adjust opacity here
              BlendMode.multiply,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_showChangePasswordButton)
                _buildMenuItem(
                  icon: Icons.person,
                  title: 'Change Password',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePassword(),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 20), // Add spacing between items
              _buildMenuItem(
                icon: Icons.question_answer,
                title: 'FAQs',
                onTap: () {
                  // Navigate to FAQs screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FaqPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20), // Add spacing between items
              _buildMenuItem(
                icon: Icons.contact_mail,
                title: 'Contact Us',
                onTap: () {
                  // Navigate to Contact Us screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ContacUsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20), // Add spacing between items
              _buildMenuItem(
                icon: Icons.logout,
                title: 'Sign Out',
                onTap: () {
                  // Perform sign out action
                  signout(context);
                },
                textColor: Colors.red, // Set text color to red
                arrow_forward_ios:
                    Colors.red, // Set arrow color to red (fixed typo)
                iconColor: Colors.red, // Set icon color to red
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: ConvexAppBar.badge(
        const {},
        items: const [
          TabItem(icon: Icons.chat_rounded, title: 'Graph'),
          TabItem(icon: Icons.bar_chart, title: 'Rates'),
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.history, title: 'History'),
          TabItem(icon: Icons.settings, title: 'Settings'),
        ],
        onTap: (int index) {
          switch (index) {
            case 0:
              // Redirect to Graph page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const CurrencyHistoryGraph()),
              );
              break;
            case 1:
              // Redirect to Rates page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const ExchangeRateDetailsPage()),
              );
              break;
            case 2:
              // Redirect to Home page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
              break;
            case 3:
              // Redirect to History page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HistoryPage()),
              );
              break;
            case 4:
              // Redirect to Settings page
              // Replace `SettingsPage()` with the appropriate widget for your Settings page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
              break;
            default:
              break;
          }
        },
        initialActiveIndex: 4,
      ),
    );
  }
}

Widget _buildMenuItem({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
  Color textColor = Colors.black, // Default text color is black
  Color arrow_forward_ios = Colors.blue, // Default arrow color is blue
  Color iconColor = Colors.blue, // Default icon color is blue
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color:
            Colors.white.withOpacity(0.8), // Semi-transparent white background
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // Shadow color
            blurRadius: 10, // Spread radius
            offset: const Offset(0, 3), // Offset
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor, // Set icon color
            size: 30,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: textColor, // Set text color
                fontSize: 20,
                fontFamily: 'Roboto', // Custom font
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: arrow_forward_ios, // Set arrow color
            size: 20,
          ),
        ],
      ),
    ),
  );
}
