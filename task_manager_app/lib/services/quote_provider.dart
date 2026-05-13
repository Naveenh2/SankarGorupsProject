import 'package:flutter/material.dart';

import '../models/quote_model.dart';
import 'quote_service.dart';

class QuoteProvider extends ChangeNotifier {
  QuoteProvider(this._quoteService);

  final QuoteService _quoteService;

  QuoteModel? _quote;
  bool _isLoading = false;
  String? _errorMessage;

  QuoteModel? get quote => _quote;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchQuote() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _quote = await _quoteService.fetchRandomQuote();
    } catch (_) {
      _errorMessage = 'Unable to fetch quote.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
