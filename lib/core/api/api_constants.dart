import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1/api';

  // Notification endpoint
  static const String notificationsMe = "/notifications/me";
  static const String notificationsCountNew = "/notifications/count-new";
  static const String notificationsMarkAsRead = "/notifications"; // + /:id/read
  static const String notificationsMarkAllAsRead = "/notifications/read-all";

  // AI Chatbot endpoint
  static const String chatbotAsk = "/v1/ask";

  // Withdraw endpoints
  static const String withdrawOptions = "/wallet/get-withdraw-options";
  static const String withdrawMoney = "/wallet/withdraw-money";
}
