import 'package:currensee/screens/home_screen.dart';
import 'package:currensee/utils/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:currensee/provider/currency_selection_provider.dart';
import 'package:currensee/provider/currency_data_provider.dart';
import 'package:currensee/screens/select_currency_screen.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: 'AIzaSyByS7ewbd4PPOthWbq_NSXSGxgELLZ5ybw',
          appId: '1:277817688001:android:672dd32be0fc547966b940',
          messagingSenderId: '277817688001',
          projectId: 'currensee-e0640'));
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CurrencyDataProvider()),
        ChangeNotifierProvider(
          create: (context) => CurrencySelectionProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Converter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: MaterialStateProperty.all<Color>(
              Colors.blue), // Change the color here
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: HomeScreen.route,
      routes: {
        HomeScreen.route: (context) => const Wrapper(),
        SelectCurrencyScreen.route: (context) => const SelectCurrencyScreen(),
      },
    );
  }
}
