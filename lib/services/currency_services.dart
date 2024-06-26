import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import '../constants/constants.dart';
import '../models/currency.dart';
import '../models/rates_model.dart';
import '../utils/api_result.dart';
import 'package:http/http.dart' as http;
import '../models/all_currencies_response.dart';

class CurrencyServices {
  Future<ApiResult<List<Currency>>> getCurrencies() async {
    try {
      var response = await http.get(Uri.https(baseUrl, '/api/currencies.json', {
        'prettyprint': 'false',
        'show_alternative': 'false',
        'show_inactive': 'false'
      }));
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        log(response.body);
        return ApiResult.success(currencyListFromJson(response.body));
      } else {
        return ApiResult.failure(
            response.reasonPhrase ?? 'Something went wrong');
      }
    } on SocketException {
      return ApiResult.failure("No internet connection");
    } on Exception catch (e) {
      return ApiResult.failure("An error occurred $e");
    }
  }

  Future<ApiResult<RatesModel>> getUSDToAnyExchangeRates() async {
    try {
      var response = await http.get(Uri.https(baseUrl, "/api/latest.json", {
        'prettyprint': 'false',
        'show_alternative': 'false',
        'show_inactive': 'false',
        'app_id': 'c11b72a5c98449a996480762ca96572b'
      }));
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        log(response.body);
        return ApiResult.success(
            RatesModel.fromJson(jsonDecode(response.body)));
      } else {
        return ApiResult.failure(
            response.reasonPhrase ?? 'Something went wrong');
      }
    } on SocketException {
      return ApiResult.failure("No internet connection");
    } on Exception catch (e) {
      return ApiResult.failure("An error occurred $e");
    }
  }
}
