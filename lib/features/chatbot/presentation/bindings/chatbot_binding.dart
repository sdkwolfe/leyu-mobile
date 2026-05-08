import 'package:get/get.dart';
import 'package:leyu_mobile/core/api/api_client.dart';
import '../../data/datasources/chatbot_remote_data_source.dart';
import '../controllers/chatbot_controller.dart';

class ChatbotBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ApiClient());
    Get.lazyPut(() => ChatbotRemoteDataSource(Get.find<ApiClient>()));
    Get.lazyPut(() => ChatbotController(remoteDataSource: Get.find()));
  }
}
