import 'dart:convert';
import 'package:currensee/models/currency.dart';

List<Currency> currencyListFromJson(String str) =>
    Map<String, String>.from(json.decode(str))
        .entries
        .map<Currency>((e) => Currency(name: e.value, shortName: e.key))
        .toList();
