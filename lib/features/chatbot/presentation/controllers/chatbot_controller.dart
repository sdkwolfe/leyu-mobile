import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/datasources/chatbot_remote_data_source.dart';
import '../../data/models/chat_message.dart';
import '../../data/models/chatbot_request.dart';

class ChatbotController extends GetxController {
  final ChatbotRemoteDataSource remoteDataSource;

  ChatbotController({required this.remoteDataSource});

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = false.obs;
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    _addWelcomeMessage();
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _addWelcomeMessage() {
    messages.add(ChatMessage(
      text: 'chatbot.welcome_message'.tr,
      type: MessageType.bot,
    ));
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    messages.add(ChatMessage(
      text: text,
      type: MessageType.user,
    ));

    messageController.clear();
    _scrollToBottom();

    // Show loading
    isLoading.value = true;

    try {
      final request = ChatbotRequest(
        question: text,
        maxSources: 5,
        minSimilarity: 0.5,
      );

      final response = await remoteDataSource.askQuestion(request);

      // Add bot response
      messages.add(ChatMessage(
        text: response.answer,
        type: MessageType.bot,
        sources: response.sources,
        confidenceScore: response.confidenceScore,
      ));
    } catch (e) {
      // Add user-friendly error message
      String errorMessage = 'chatbot.error_general'.tr;

      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('network') || errorStr.contains('connection')) {
        errorMessage = 'chatbot.error_network'.tr;
      } else if (errorStr.contains('timeout')) {
        errorMessage = 'chatbot.error_timeout'.tr;
      } else if (errorStr.contains('unavailable')) {
        errorMessage = 'chatbot.error_unavailable'.tr;
      }

      messages.add(ChatMessage(
        text: errorMessage,
        type: MessageType.bot,
        isError: true,
      ));
    } finally {
      isLoading.value = false;
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
