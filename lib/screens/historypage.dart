// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:currensee/screens/currency_history_graph.dart';
import 'package:currensee/screens/exchangerate.dart';
import 'package:currensee/screens/home_screen.dart';
import 'package:currensee/screens/settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Stream<QuerySnapshot> _stream;
  var user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _stream = FirebaseFirestore.instance
        .collection('ConvertedAmounts')
        .doc(user?.email)
        .collection('Conversions')
        .orderBy('Timestamp', descending: true)
        .snapshots();
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
                        'Conversion History',
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

                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _stream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error: ${snapshot.error}',
                              style: const TextStyle(
                                fontSize: 18, // Increase font size
                                color: Colors.white, // Set text color to white
                              ),
                            ),
                          );
                        }
                        if (snapshot.data == null ||
                            snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text(
                              'No data available',
                              style: TextStyle(
                                fontSize: 18, // Increase font size
                                color: Colors.white, // Set text color to white
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final doc = snapshot.data!.docs[index];
                            Map<String, dynamic> data =
                                doc.data() as Map<String, dynamic>;
                            // Check if OriginalAmount is not "0" and not an empty string
                            if (data['OriginalAmount'] != "0" &&
                                data['OriginalAmount'] != "") {
                              DateTime timestamp = data['Timestamp'].toDate();
                              String formattedDate =
                                  DateFormat.yMMMd().format(timestamp);
                              String formattedTime =
                                  DateFormat.jm().format(timestamp);
                              return ConversionTile(
                                originalAmount:
                                    data['OriginalAmount'].toString(),
                                originalCurrency: data['OriginalCurrency'],
                                convertedAmount:
                                    data['ConvertedAmount'].toString(),
                                convertedCurrency: data['ConvertedCurrency'],
                                formattedDate: formattedDate,
                                formattedTime: formattedTime,
                                onDelete: () {
                                  deleteConversion(user?.email ?? '', doc.id);
                                },
                              );
                            } else {
                              // Return an empty container if OriginalAmount is "0" or an empty string
                              return Container();
                            }
                          },
                        );
                      },
                    ),
                  )
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
              // Do nothing as we are already on the History page
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
        initialActiveIndex: 3,
      ),
    );
  }

  void deleteConversion(String userId, String docId) {
    FirebaseFirestore.instance
        .collection('ConvertedAmounts')
        .doc(userId)
        .collection('Conversions')
        .doc(docId)
        .delete()
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conversion deleted successfully'),
          duration: Duration(milliseconds: -300),
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete conversion: $error')),
      );
    });
  }
}

class ConversionTile extends StatefulWidget {
  final String originalAmount;
  final String originalCurrency;
  final String convertedAmount;
  final String convertedCurrency;
  final String formattedDate;
  final String formattedTime;
  final VoidCallback onDelete;

  const ConversionTile({
    super.key,
    required this.originalAmount,
    required this.originalCurrency,
    required this.convertedAmount,
    required this.convertedCurrency,
    required this.formattedDate,
    required this.formattedTime,
    required this.onDelete,
  });

  @override
  _ConversionTileState createState() => _ConversionTileState();
}

class _ConversionTileState extends State<ConversionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return SlideTransition(
          position: _offsetAnimation,
          child: Opacity(
            opacity: 1 - _controller.value,
            child: buildTile(),
          ),
        );
      },
    );
  }

  Widget buildTile() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${widget.originalAmount} ${widget.originalCurrency} = ${widget.convertedAmount} ${widget.convertedCurrency}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  onPressed: () async {
                    // Show deletion message immediately
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Deleting conversion...'),
                        duration: Duration(milliseconds: 400),
                      ),
                    );
                    // Start animation
                    _controller.forward().then((value) {
                      // After animation completion, perform deletion
                      widget.onDelete();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.formattedDate} at ${widget.formattedTime}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
