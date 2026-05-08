class ChatbotRequest {
  final String question;
  final int? maxSources;
  final double? minSimilarity;

  ChatbotRequest({
    required this.question,
    this.maxSources = 3,
    this.minSimilarity = 0.1,
  });

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'max_sources': maxSources,
      'min_similarity': minSimilarity,
    };
  }
}
