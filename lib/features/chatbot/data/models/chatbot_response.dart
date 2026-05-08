class ChatbotResponse {
  final String answer;
  final List<SourceDocument> sources;
  final double confidenceScore;
  final double processingTime;

  ChatbotResponse({
    required this.answer,
    required this.sources,
    required this.confidenceScore,
    required this.processingTime,
  });

  factory ChatbotResponse.fromJson(Map<String, dynamic> json) {
    return ChatbotResponse(
      answer: json['answer'] ?? '',
      sources: (json['sources'] as List<dynamic>?)
              ?.map((source) => SourceDocument.fromJson(source))
              .toList() ??
          [],
      confidenceScore: (json['confidence_score'] ?? 0.0).toDouble(),
      processingTime: (json['processing_time'] ?? 0.0).toDouble(),
    );
  }
}

class SourceDocument {
  final String content;
  final double similarity;
  final Map<String, dynamic> metadata;

  SourceDocument({
    required this.content,
    required this.similarity,
    required this.metadata,
  });

  factory SourceDocument.fromJson(Map<String, dynamic> json) {
    return SourceDocument(
      content: json['content'] ?? '',
      similarity: (json['similarity'] ?? 0.0).toDouble(),
      metadata: json['metadata'] ?? {},
    );
  }
}
