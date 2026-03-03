import 'dart:convert';

import 'package:http/http.dart' as http;

class ServicesInAppPurchase {
  static const String _productionUrl =
      'https://buy.itunes.apple.com/verifyReceipt';
  static const String _sandboxUrl =
      'https://sandbox.itunes.apple.com/verifyReceipt';
  static final _client = http.Client();

  static Future<http.Response> validateReceiptIos(
    Map<String, dynamic> receiptBody, {
    bool useSandbox = false,
  }) async {
    final url = useSandbox ? _sandboxUrl : _productionUrl;

    try {
      final response = await _client
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(receiptBody),
          )
          .timeout(const Duration(seconds: 10));

      return response;
    } catch (e) {
      rethrow;
    }
  }
}
