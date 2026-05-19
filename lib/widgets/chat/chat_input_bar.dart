import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class ChatInputBar extends StatefulWidget {
  final Function(String) onSend;

  const ChatInputBar({super.key, required this.onSend});

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();

  void _handleSend() {
    if (_controller.text.trim().isEmpty) return;
    widget.onSend(_controller.text);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext buildContext) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.sm),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: TextField(
                  controller: _controller,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Message the group...',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: AppDimensions.lg, vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.sm),
            CircleAvatar(
              backgroundColor: AppColors.primary,
              radius: 20,
              child: IconButton(
                icon: const Icon(Icons.send, color: AppColors.white, size: 18),
                onPressed: _handleSend,
              ),
            )
          ],
        ),
      ),
    );
  }
}