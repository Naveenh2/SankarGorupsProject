import 'package:flutter/material.dart';

import '../models/quote_model.dart';

class QuoteCard extends StatelessWidget {
  const QuoteCard({
    super.key,
    required this.quote,
    required this.isLoading,
    required this.onRefresh,
  });

  final QuoteModel? quote;
  final bool isLoading;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final String content = quote?.content ?? 'Tap refresh to load motivation.';
    final String author = quote?.author ?? 'Quote API';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Motivational Quote',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  onPressed: isLoading ? null : onRefresh,
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded),
                  tooltip: 'Refresh quote',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('"$content"', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            Text(
              '- $author',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
