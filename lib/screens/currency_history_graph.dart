// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:currensee/provider/currency_data_provider.dart';
import 'package:currensee/screens/home_screen.dart';
import 'package:currensee/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:currensee/screens/exchangerate.dart';
import 'package:currensee/screens/historypage.dart';

class CurrencyHistoryGraph extends StatefulWidget {
  const CurrencyHistoryGraph({super.key});

  @override
  _CurrencyHistoryGraphState createState() => _CurrencyHistoryGraphState();
}

class _CurrencyHistoryGraphState extends State<CurrencyHistoryGraph> {
  List<ChartData> currencyRates = [];
  bool isLoading = true;
  String selectedCurrency1 = 'USD'; // Default selected currency1
  String selectedCurrency2 = 'PKR'; // Default selected currency2
  final currencyDataProvider =
      CurrencyDataProvider(); // Create an instance of CurrencyDataProvider
  List<String> currencies =
      []; // List to store currency short names for dropdown items

  @override
  void initState() {
    super.initState();
    currencyDataProvider.getAllData(); // Fetch currencies and exchange rates
    currencyDataProvider
        .addListener(_updateCurrencies); // Add listener to update currencies
    fetchCurrencyHistory(selectedYear);
  }

  @override
  void dispose() {
    currencyDataProvider.removeListener(
        _updateCurrencies); // Remove listener to prevent memory leaks
    super.dispose();
  }

  // Listener function to update currencies when data provider notifies changes
  void _updateCurrencies() {
    setState(() {
      currencies = currencyDataProvider.currencies
          .map((currency) => currency.shortName)
          .toList();
    });
  }

  int selectedYear = DateTime.now().year; // Default selected year
  List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Currency History',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                /* DropdownButton<String>(
                  value: selectedCurrency1,
                  onChanged: (newValue) {
                    setState(() {
                      selectedCurrency1 = newValue!;
                      isLoading = true;
                    });
                    if (newValue == 'All Time') {
                      fetchAllTimeCurrencyHistory();
                    } else {
                      fetchCurrencyHistory(selectedYear);
                    }
                  },
                  items: <String>[
                    'USD',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ), */
                DropdownButton<String>(
                  value: selectedCurrency2,
                  onChanged: (newValue) {
                    setState(() {
                      selectedCurrency2 = newValue!;
                      // Fetch currency history based on selectedCurrency2
                      fetchCurrencyHistory(selectedYear);
                    });
                  },
                  items:
                      currencies.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                DropdownButton<int>(
                  value: selectedYear,
                  onChanged: (newValue) {
                    setState(() {
                      selectedYear = newValue!;
                      isLoading = true;
                    });
                    fetchCurrencyHistory(selectedYear);
                  },
                  items: List.generate(DateTime.now().year - 2000,
                          (index) => DateTime.now().year - index)
                      .map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : currencyRates.isNotEmpty
                      ? SfCartesianChart(
                          primaryXAxis: const CategoryAxis(),
                          primaryYAxis: NumericAxis(
                            minimum: currencyRates
                                    .map((e) => e.low.toDouble())
                                    .reduce((a, b) => a < b ? a : b) *
                                0.9,
                            maximum: currencyRates
                                    .map((e) => e.high.toDouble())
                                    .reduce((a, b) => a > b ? a : b) *
                                1.1,
                          ),
                          series: <CartesianSeries>[
                            LineSeries<ChartData, String>(
                              dataSource: currencyRates,
                              xValueMapper: (ChartData data, _) => data.month,
                              yValueMapper: (ChartData data, _) =>
                                  (data.low + data.high) /
                                  2, // Use average value as y-value
                              markerSettings:
                                  const MarkerSettings(isVisible: true),
                              // Show data points as dots
                              color: Colors.purple,
                            ),
                          ],
                          // Enable crosshair
                          crosshairBehavior: CrosshairBehavior(
                            enable: true,
                            // Set to true to enable crosshair
                            activationMode: ActivationMode.singleTap,
                            // Choose activation mode
                            lineType: CrosshairLineType
                                .both, // Choose line type (vertical, horizontal, or both)
                            shouldAlwaysShow:
                                true, // Set to true to always show crosshair
                            lineColor: Colors.grey[400], // Set line color
                            lineWidth: 1, // Set line width
                            lineDashArray: <double>[
                              5,
                              5
                            ], // Set line dash array
                          ),
                        )
                      : const Center(
                          child: Text(
                            'No data available',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
            ),
          ),
        ],
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
              Navigator.push(
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
              break;
            default:
              break;
          }
        },
        initialActiveIndex: 0,
      ),
    );
  }

  Future<void> fetchCurrencyHistory(int year) async {
    const String appId = 'c11b72a5c98449a996480762ca96572b';
    List<ChartData> historicalRates = [];

    final DateTime currentDate = DateTime.now();
    final int currentYear = currentDate.year;
    final int currentMonth = currentDate.month;
    final int maxMonth = (year == currentYear) ? currentMonth : 12;

    for (int month = 1; month <= maxMonth; month++) {
      final String dateString = '$year-${month.toString().padLeft(2, '0')}-01';
      final String url =
          'https://openexchangerates.org/api/historical/$dateString.json'
          '?app_id=$appId'
          '&symbols=$selectedCurrency2' // Update to use selectedCurrency2
          '&base=$selectedCurrency1'; // Update to use selectedCurrency1

      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          if (data['rates'] != null &&
              data['rates'][selectedCurrency2] != null) {
            historicalRates.add(
              ChartData(
                month: months[month - 1],
                low: data['rates'][selectedCurrency2].toDouble(),
                high: data['rates'][selectedCurrency2].toDouble(),
              ),
            );
          } else {
            print('No rate data available for $dateString');
          }
        } else {
          print('Failed to fetch currency history for $dateString');
        }
      } catch (error) {
        print('Error fetching currency history for $dateString: $error');
      }
    }
    setState(() {
      currencyRates = historicalRates;
      isLoading = false;
    });
  }

  Future<void> fetchAllTimeCurrencyHistory() async {
    final int currentYear = DateTime.now().year;
    setState(() {
      isLoading = true;
    });

    for (int year = 2001; year <= currentYear; year++) {
      await fetchCurrencyHistory(year);
    }

    setState(() {
      isLoading = false;
    });
  }
}

class ChartData {
  final String month;
  final double low;
  final double high;

  ChartData({required this.month, required this.low, required this.high});
}
