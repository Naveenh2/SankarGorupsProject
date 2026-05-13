class QuoteModel {
  const QuoteModel({
    required this.content,
    required this.author,
  });

  final String content;
  final String author;

  factory QuoteModel.fromMap(Map<String, dynamic> json) {
    return QuoteModel(
      content: (json['content'] as String?) ?? 'Stay motivated and keep going.',
      author: (json['author'] as String?) ?? 'Unknown',
    );
  }
}
