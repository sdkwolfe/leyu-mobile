import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leyu_mobile/core/theme/app_colors.dart';
import '../controllers/chatbot_controller.dart';
import '../widgets/chat_bubble_widget.dart';
import '../widgets/typing_indicator_widget.dart';

class ChatbotPage extends StatelessWidget {
  const ChatbotPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatbotController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildModernAppBar(),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: Obx(() {
              return ListView.builder(
                controller: controller.scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  return ChatBubbleWidget(
                    message: message,
                    isFirstInGroup: _isFirstInGroup(controller.messages, index),
                    isLastInGroup: _isLastInGroup(controller.messages, index),
                  );
                },
              );
            }),
          ),

          // Typing indicator
          Obx(() => controller.isLoading.value
              ? const TypingIndicatorWidget()
              : const SizedBox.shrink()),

          // Input field
          _buildModernInputField(controller),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.05),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.appBgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.darkGray, size: 18),
        ),
        onPressed: () => Get.back(),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF6366F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child:
                const Icon(Icons.support_agent, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'chatbot.title'.tr,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGray,
                ),
              ),
              Text(
                'chatbot.online'.tr,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.green.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernInputField(ChatbotController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: AppColors.gray,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: controller.messageController,
                  decoration: InputDecoration(
                    hintText: 'chatbot.input_hint'.tr,
                    hintStyle: TextStyle(
                      color: AppColors.grayText,
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.darkGray,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Obx(() => GestureDetector(
                  onTap: controller.isLoading.value
                      ? null
                      : () => controller.sendMessage(
                            controller.messageController.text,
                          ),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: controller.isLoading.value
                          ? null
                          : const LinearGradient(
                              colors: [AppColors.primary, Color(0xFF6366F1)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      color: controller.isLoading.value
                          ? AppColors.gray.withOpacity(0.3)
                          : null,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: controller.isLoading.value
                          ? null
                          : [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.send_rounded,
                        color: controller.isLoading.value
                            ? AppColors.gray
                            : Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  bool _isFirstInGroup(List messages, int index) {
    if (index == 0) return true;
    return messages[index].type != messages[index - 1].type;
  }

  bool _isLastInGroup(List messages, int index) {
    if (index == messages.length - 1) return true;
    return messages[index].type != messages[index + 1].type;
  }
}
