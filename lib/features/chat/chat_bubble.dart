import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../core/theme/app_colors.dart';
import '../../services/tts/tts_service.dart';
import 'message_model.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onDelete;
  final TtsService? tts;

  const ChatBubble({
    super.key,
    required this.message,
    this.onDelete,
    this.tts,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;
    final isTyping = message.sender == MessageSender.typing;

    if (isTyping) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.75),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Text(
            "Orion is typing…",
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return GestureDetector(
      onLongPress: () => _showActions(context),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          constraints: const BoxConstraints(maxWidth: 320),
          decoration: BoxDecoration(
            color: isUser
                ? AppColors.accent.withOpacity(0.9)
                : AppColors.surface.withOpacity(0.85),
            borderRadius: BorderRadius.circular(14),
          ),
          child: isUser
              ? Text(
            message.text,
            style: const TextStyle(fontSize: 14, color: Colors.black),
          )
              : MarkdownBody(
            data: message.text,
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              code: TextStyle(
                backgroundColor: AppColors.background,
                color: AppColors.accent,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _item(
              icon: Icons.copy,
              label: "Copy",
              onTap: () {
                Clipboard.setData(ClipboardData(text: message.text));
                Navigator.pop(context);
              },
            ),
            if (tts != null && message.sender == MessageSender.orion)
              _item(
                icon: Icons.volume_up,
                label: "Speak",
                onTap: () {
                  tts!.speak(message.text);
                  Navigator.pop(context);
                },
              ),
            if (onDelete != null)
              _item(
                icon: Icons.delete,
                label: "Delete",
                color: Colors.redAccent,
                onTap: () {
                  onDelete!();
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _item({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = AppColors.textPrimary,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color)),
      onTap: onTap,
    );
  }
}
