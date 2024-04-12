// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:currensee/screens/currency_history_graph.dart';
import 'package:currensee/screens/historypage.dart';
import 'package:currensee/screens/home_screen.dart';
import 'package:currensee/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

class ExchangeRateDetailsPage extends StatefulWidget {
  const ExchangeRateDetailsPage({super.key});

  @override
  _ExchangeRateDetailsPageState createState() =>
      _ExchangeRateDetailsPageState();
}

class _ExchangeRateDetailsPageState extends State<ExchangeRateDetailsPage> {
  late List<String> _currencies;
  late String _selectedCurrency;
  late Map<String, dynamic> _exchangeRateData;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _selectedCurrency = 'USD'; // Default selected currency
    _exchangeRateData = {};
    _currencies = []; // Initialize _currencies
    fetchExchangeRateData();
  }

  Future<void> fetchExchangeRateData() async {
    final response = await http.get(Uri.parse(
        'https://api.exchangerate-api.com/v4/latest/$_selectedCurrency'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<String> currencies = data['rates'].keys.toList();

      setState(() {
        _exchangeRateData = data;
        _currencies = currencies;
      });
    } else {
      throw Exception('Failed to load exchange rate data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg1.png'), // Background image path
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Container(
            color:
                Colors.black.withOpacity(0.6), // Background color with opacity
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Styled Heading
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        'Exchange Rates',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 3.0,
                              color: Colors.black.withOpacity(0.5),
                              offset: const Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  if (_currencies.isNotEmpty) ...[
                    Center(
                      child: DropdownButton<String>(
                        value: _selectedCurrency,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCurrency = newValue!;
                          });
                          fetchExchangeRateData();
                        },
                        dropdownColor: Colors.blue, // Adjust opacity here
                        borderRadius: BorderRadius.circular(8),
                        items: _currencies
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20.0),
                  if (_exchangeRateData.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Expanded(
                      child: Scrollbar(
                        controller: _scrollController,
                        showTrackOnHover: true,
                        thumbVisibility: true, // Set isAlwaysShown to true
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: Column(
                            children: List.generate(
                              _exchangeRateData['rates'].length,
                              (index) {
                                final currency = _exchangeRateData['rates']
                                    .keys
                                    .elementAt(index);
                                final rate =
                                    _exchangeRateData['rates'][currency];
                                return ListTile(
                                  title: Text(
                                    '$currency: $rate',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    const Center(
                      child:
                          CircularProgressIndicator(), // Display loading indicator while data is being fetched
                    ),
                  ],
                ],
              ),
            ),
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
              // No action needed for current page
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
              break;
            default:
              break;
          }
        },
        initialActiveIndex: 1, // Set the initial active index to the Rates tab
      ),
    );
  }
}
