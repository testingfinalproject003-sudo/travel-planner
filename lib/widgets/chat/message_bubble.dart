import 'package:flutter/material.dart';
import '../../models/message_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext buildContext) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppDimensions.xs, horizontal: AppDimensions.md),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(left: AppDimensions.xs, bottom: 2),
                child: Text(message.senderName, style: AppTextStyles.label),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg, vertical: AppDimensions.sm),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : AppColors.white,
                border: isMe ? null : Border.all(color: AppColors.border, width: 0.5),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14),
                  topRight: const Radius.circular(14),
                  bottomLeft: Radius.circular(isMe ? 14 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 14),
                ),
              ),
              child: Text(
                message.text,
                style: isMe ? AppTextStyles.whiteBody : AppTextStyles.body,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xs, vertical: 2),
              child: Text(
                timeago.format(message.timestamp),
                style: isMe ? AppTextStyles.small.copyWith(fontSize: 9) : AppTextStyles.small.copyWith(fontSize: 9),
              ),
            )
          ],
        ),
      ),
    );
  }
}