import 'package:flutter/material.dart';
import 'package:leyu_mobile/core/theme/app_colors.dart';
import '../../data/models/chat_message.dart';

class ChatBubbleWidget extends StatelessWidget {
  final ChatMessage message;
  final bool isFirstInGroup;
  final bool isLastInGroup;

  const ChatBubbleWidget({
    super.key,
    required this.message,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.type == MessageType.user;

    return Padding(
      padding: EdgeInsets.only(
        bottom: isLastInGroup ? 16 : 4,
        top: isFirstInGroup ? 8 : 0,
      ),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser && isLastInGroup) _buildAvatar(),
          if (!isUser && isLastInGroup) const SizedBox(width: 8),
          if (!isUser && !isLastInGroup) const SizedBox(width: 40),
          Flexible(
            child: _buildMessageBubble(isUser),
          ),
          if (isUser && isLastInGroup) const SizedBox(width: 8),
          if (isUser && isLastInGroup) _buildAvatar(),
          if (isUser && !isLastInGroup) const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(bool isUser) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: isUser
            ? const LinearGradient(
                colors: [AppColors.primary, Color(0xFF6366F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isUser
            ? null
            : message.isError
                ? const Color(0xFFFEE2E2)
                : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isUser ? 20 : (isFirstInGroup ? 20 : 4)),
          topRight: Radius.circular(isUser ? (isFirstInGroup ? 20 : 4) : 20),
          bottomLeft: Radius.circular(isUser ? 20 : (isLastInGroup ? 4 : 20)),
          bottomRight: Radius.circular(isUser ? (isLastInGroup ? 4 : 20) : 20),
        ),
        boxShadow: [
          BoxShadow(
            color: isUser
                ? AppColors.primary.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        message.text,
        style: TextStyle(
          color: isUser
              ? Colors.white
              : message.isError
                  ? const Color(0xFFDC2626)
                  : const Color(0xFF1F2937),
          fontSize: 15,
          height: 1.4,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final isUser = message.type == MessageType.user;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: isUser
            ? const LinearGradient(
                colors: [AppColors.primary, Color(0xFF6366F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFFF3F4F6), Color(0xFFE5E7EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        isUser ? Icons.person_rounded : Icons.smart_toy_rounded,
        color: isUser ? Colors.white : AppColors.primary,
        size: 18,
      ),
    );
  }
}
