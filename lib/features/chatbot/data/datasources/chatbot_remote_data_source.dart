import 'package:leyu_mobile/core/api/api_client.dart';
import 'package:leyu_mobile/core/api/api_constants.dart';
import '../models/chatbot_request.dart';
import '../models/chatbot_response.dart';

class ChatbotRemoteDataSource {
  final ApiClient _apiClient;

  ChatbotRemoteDataSource(this._apiClient);

  Future<ChatbotResponse> askQuestion(ChatbotRequest request) async {
    try {
      final response = await _apiClient.post(ApiConstants.chatbotAsk,
          data: request.toJson());
      return ChatbotResponse.fromJson(response.data);
    } catch (e) {
      if (e.toString().contains('400')) {
        throw Exception('Invalid request: Please check your question');
      } else if (e.toString().contains('503')) {
        throw Exception('Service unavailable. Please try again later.');
      } else if (e.toString().contains('504')) {
        throw Exception('Request timeout. Please try again.');
      } else {
        throw Exception('Network error: ${e.toString()}');
      }
    }
  }
}
