import 'chatbot_response.dart';

enum MessageType { user, bot }

class ChatMessage {
  final String text;
  final MessageType type;
  final DateTime timestamp;
  final List<SourceDocument>? sources;
  final double? confidenceScore;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.type,
    DateTime? timestamp,
    this.sources,
    this.confidenceScore,
    this.isError = false,
  }) : timestamp = timestamp ?? DateTime.now();
}
