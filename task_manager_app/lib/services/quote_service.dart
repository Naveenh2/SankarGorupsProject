import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/quote_model.dart';

class QuoteService {
  static const String _quoteUrl = 'https://api.quotable.io/random';

  Future<QuoteModel> fetchRandomQuote() async {
    final http.Response response = await http.get(Uri.parse(_quoteUrl));
    if (response.statusCode != 200) {
      throw Exception('Unable to fetch quote. Please try again.');
    }
    final Map<String, dynamic> json = jsonDecode(response.body);
    return QuoteModel.fromMap(json);
  }
}
