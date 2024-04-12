// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currensee/screens/settings_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:currensee/main.dart';
import 'package:currensee/provider/currency_data_provider.dart';
import 'package:currensee/provider/currency_selection_provider.dart';
import 'package:currensee/screens/currency_history_graph.dart';
import 'package:currensee/screens/exchangerate.dart';
import 'package:currensee/screens/historypage.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:currensee/widgets/currency_data_input_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:currensee/screens/select_currency_screen.dart';
import '/utils/utils.dart' as utils;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String route = '/';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;

  Future<void> signout() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MyApp(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Provider.of<CurrencySelectionProvider>(context, listen: false).amount = '';
    Provider.of<CurrencyDataProvider>(context, listen: false).getAllData();
  }

  @override
  Widget build(BuildContext context) {
    var data = context.watch<CurrencyDataProvider>();

    return Scaffold(
      appBar: null,
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Currency Converter',
                  style: TextStyle(
                    fontSize: 26.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10.0),
                const Text(
                  'Check live exchange rates and convert currencies',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20.0),
                Builder(builder: (context) {
                  if (data.isLoading) {
                    return _buildLoading();
                  } else if (data.errorMsg != null) {
                    return _buildError(data.errorMsg!);
                  } else {
                    return Expanded(
                      child: _buildChild(data),
                    );
                  }
                }),
              ],
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
        initialActiveIndex: 2,
      ),
    );
  }

  Widget _buildChild(CurrencyDataProvider data) {
    var exchangeRates = data.exchangeRates;

    return Column(
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 3.0,
          color: Colors.white.withOpacity(0.9),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Consumer<CurrencySelectionProvider>(
                  builder: (context, selections, child) =>
                      CurrencyDataInputForm(
                    title: 'Amount',
                    isInputEnabled: true,
                    selectedCurrency: selections.selectedFromCurrency,
                    onCurrencySelection: () {
                      Provider.of<CurrencySelectionProvider>(context,
                              listen: false)
                          .updatingCurrencyType = CurrencyInputType.from;
                      Navigator.pushNamed(
                        context,
                        SelectCurrencyScreen.route,
                      );
                    },
                    onInputChanged: (val) {
                      selections.amount = val;
                      FirebaseFirestore.instance
                          .collection('ConvertedAmounts')
                          .doc(user?.email)
                          .collection('Conversions')
                          .add({
                        'OriginalAmount': val,
                        'OriginalCurrency': selections.selectedFromCurrency,
                        'ConvertedAmount': utils.convertAnyToAny(
                            exchangeRates,
                            val,
                            selections.selectedFromCurrency,
                            selections.selectedToCurrency),
                        'ConvertedCurrency': selections.selectedToCurrency,
                        'Timestamp': Timestamp.now(),
                      });
                    },
                  ),
                ),
                const SizedBox(height: 10.0),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 1.0,
                        color: Colors.grey.shade300,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    IconButton(
                      onPressed: () {
                        Provider.of<CurrencySelectionProvider>(context,
                                listen: false)
                            .swapFromAndTo();

                        var selections = Provider.of<CurrencySelectionProvider>(
                            context,
                            listen: false);

                        String val = selections.amount;

                        if (val.trim().isNotEmpty && double.parse(val) != 0) {
                          FirebaseFirestore.instance
                              .collection('ConvertedAmounts')
                              .doc(user?.email)
                              .collection('Conversions')
                              .add({
                            'OriginalAmount': val,
                            'OriginalCurrency': selections.selectedFromCurrency,
                            'ConvertedAmount': utils.convertAnyToAny(
                                exchangeRates,
                                val,
                                selections.selectedFromCurrency,
                                selections.selectedToCurrency),
                            'ConvertedCurrency': selections.selectedToCurrency,
                            'Timestamp': Timestamp.now(),
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a valid amount'),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.swap_vert),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: Divider(
                        thickness: 1.0,
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),
                Consumer<CurrencySelectionProvider>(
                  builder: (context, selections, child) =>
                      CurrencyDataInputForm(
                    title: 'Converted Amount',
                    val: utils.convertAnyToAny(
                        exchangeRates,
                        selections.amount,
                        selections.selectedFromCurrency,
                        selections.selectedToCurrency),
                    isInputEnabled: false,
                    selectedCurrency: selections.selectedToCurrency,
                    onCurrencySelection: () {
                      Provider.of<CurrencySelectionProvider>(context,
                              listen: false)
                          .updatingCurrencyType = CurrencyInputType.to;
                      Navigator.pushNamed(
                        context,
                        SelectCurrencyScreen.route,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20.0),
        const Text(
          "Exchange Rates",
          style: TextStyle(
            fontSize: 18.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Consumer<CurrencySelectionProvider>(
          builder: (context, selections, child) {
            return Text(
              '1 ${selections.selectedFromCurrency} = ${utils.convertAnyToAny(exchangeRates, "1", selections.selectedFromCurrency, selections.selectedToCurrency)} ${selections.selectedToCurrency}',
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            );
          },
        )
      ],
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildError(String errorMsg) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          errorMsg,
          style: const TextStyle(
            fontSize: 16.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: () =>
              Provider.of<CurrencyDataProvider>(context, listen: false)
                  .getAllData(),
          child: const Text("Retry"),
        )
      ],
    );
  }
}
