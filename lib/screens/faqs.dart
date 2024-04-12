// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  _FaqPageState createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  final List<String> questions = [
    "1: How do I sign up for the currency converter app?",
    "2: Can I convert currency without logging in?",
    "3: Is the currency converter app free to use?",
    "4: How can I view a graph of currency exchange rates?",
    "5: Is my personal data secure when using the currency converter app?",
  ];

  final List<String> answers = [
    "To access the currency converter app, simply tap on the Sign Up button on the home screen and provide your email address. After providing your email, you'll receive a verification link sent to your Gmail account. Click on the verification link to confirm your email address and complete the sign-up process. Once verified, you can log in to the app using your email and password. If you've already signed up, you can directly log in with your credentials.",
    "No, you need to log in first to access the currency converter feature. Once logged in, you can freely convert currencies using the app.",
    "Yes, the currency converter app is completely free to use. There are no hidden charges or subscription fees. Enjoy unlimited currency conversions and other features without any cost.",
    "To view a graph of currency exchange rates, simply navigate to the Graphs section of the app. Here, you'll be able to select the currencies you're interested in and choose a time period for the graph. The graph will display historical exchange rate data to help you analyze currency trends.",
    "Yes, your privacy and security are our top priorities. We utilize industry-standard encryption protocols to safeguard your personal data, including login credentials and transaction history. Additionally, we do not store any sensitive financial information on our servers. Rest assured that your information is kept confidential and protected at all times.",
  ];

  // Track the currently expanded question index
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FAQs',
          style: TextStyle(
            fontFamily: 'Roboto', // Custom font
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue, // Make app bar transparent
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/bg1.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6),
              BlendMode.multiply,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: questions.length,
            itemBuilder: (context, index) {
              return ExpansionTile(
                iconColor: Colors.white, // Set default icon color to white
                onExpansionChanged: (expanded) {
                  setState(() {
                    _expandedIndex = expanded ? index : null;
                  });
                },
                title: Container(
                  color: _expandedIndex == index
                      ? Colors.transparent
                      : Colors.transparent,
                  child: Text(
                    questions[index],
                    style: const TextStyle(
                      color: Colors.white, // Set text color to white
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      answers[index],
                      style: const TextStyle(
                        color: Colors.white, // Set text color to white
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
