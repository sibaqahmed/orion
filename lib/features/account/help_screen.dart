import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const String _supportEmail = "sibaqahmed@gmail.com";

  Widget _card({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withOpacity(0.12)),
      ),
      child: child,
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.9),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary.withOpacity(0.8)),
          ],
        ),
      ),
    );
  }

  void _snack(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _contactSupport(BuildContext context) async {
    final uri = Uri(
      scheme: "mailto",
      path: _supportEmail,
      query: Uri.encodeQueryComponent(
        "subject=Orion Support&body=Hi Sibaq,%0A%0AI need help with:%0A%0A(Device/Android/iOS/Web):%0A(App version):%0A(What happened):%0A(What you expected):%0A%0AThanks!",
      ).replaceAll("%3D", "=").replaceAll("%26", "&"), // keep query clean
    );

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      _snack(context, "Could not open email app. Email: $_supportEmail");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          "Help",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 18),
        children: [
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Quick help",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Here are the most common things people need help with.",
                  style: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                _tile(
                  icon: Icons.history_rounded,
                  title: "Chat history & search",
                  subtitle: "Find chats, rename, delete",
                  onTap: () => _snack(context, "Tip: Open 3-dots → Search chats."),
                ),
                _tile(
                  icon: Icons.volume_up_rounded,
                  title: "Voice replies",
                  subtitle: "Toggle voice + adjust settings",
                  onTap: () => _snack(context, "Go to Settings → Voice responses."),
                ),
                _tile(
                  icon: Icons.lock_outline_rounded,
                  title: "Privacy",
                  subtitle: "Your chats stay in your account",
                  onTap: () => _snack(
                    context,
                    "Chats are stored under your Firebase user in Firestore.",
                  ),
                ),
              ],
            ),
          ),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "FAQ",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                _faq(
                  q: "Why does Orion say “Mind is offline”?",
                  a: "That happens when GEMINI_API_KEY is missing. Run your app with --dart-define=GEMINI_API_KEY=YOUR_KEY.",
                ),
                _faq(
                  q: "Why is a deleted chat still showing?",
                  a: "If you delete only the chat doc, Firestore can still keep the messages subcollection in storage. The UI list will update after the stream refreshes.",
                ),
                _faq(
                  q: "Can I recover deleted chats?",
                  a: "Not yet. We’ll add restore/archive later if you want.",
                ),
              ],
            ),
          ),
          _card(
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _contactSupport(context),
                  icon: const Icon(Icons.support_agent_rounded),
                  label: const Text("Contact support"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent.withOpacity(0.22),
                    foregroundColor: AppColors.textPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Email support: $_supportEmail",
                  style: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _faq({required String q, required String a}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background.withOpacity(0.18),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.accent.withOpacity(0.10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              q,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              a,
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.92),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
