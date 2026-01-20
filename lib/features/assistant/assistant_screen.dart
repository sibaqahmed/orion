import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:orion/features/account/about_screen.dart';
import 'package:orion/features/account/help_screen.dart';
import 'package:orion/services/tts/tts_service.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../ui/widgets/ai_orb.dart';
import '../chat/chat_controller.dart';
import '../chat/chat_bubble.dart';
import '../chat/chat_history_sheet.dart';
import 'assistant_controller.dart';

// ✅ NEW
import '../account/account_sheet.dart';

// ✅ NEW: Settings screen
import '../settings/settings_screen.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final AssistantController _assistantController = AssistantController();
  final TtsService _ttsService = TtsService();
  late final ChatController _chatController;

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool isTyping = false;

  // ✅ Menu IDs
  static const int _menuAccount = -1; // ✅ NEW (special top item)
  static const int _menuVoice = 0;
  static const int _menuNewChat = 1;
  static const int _menuSearchChats = 2;
  static const int _menuChatHistory = 3;
  static const int _menuSettings = 4;
  static const int _menuLogout = 99;

  bool _historyOpen = false;

  @override
  void initState() {
    super.initState();

    _assistantController.initSpeech();
    _ttsService.init();
    _assistantController.attachTts(_ttsService);

    _chatController = ChatController(ttsService: _ttsService);
    _chatController.start();

    _chatController.addListener(_scrollToBottom);
    _chatController.addListener(_syncAssistantStateWithChat);

    _assistantController.onFinalText = (finalText) {
      if (finalText.trim().isEmpty) return;
      _chatController.sendUserMessage(finalText);
    };
  }

  @override
  void dispose() {
    _chatController.removeListener(_scrollToBottom);
    _chatController.removeListener(_syncAssistantStateWithChat);
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _syncAssistantStateWithChat() {
    final s = _assistantController.state;

    if (_chatController.isBusy) {
      if (s != AssistantState.listening && s != AssistantState.speaking) {
        _assistantController.setThinking();
      }
      return;
    }

    if (s != AssistantState.listening && !_ttsService.isSpeaking) {
      _assistantController.setIdle();
    }
  }

  void _sendText() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _assistantController.setThinking();
    _chatController.sendUserMessage(text);

    _textController.clear();
    FocusScope.of(context).unfocus();
  }

  String _statusText() {
    switch (_assistantController.state) {
      case AssistantState.listening:
        return "Listening…";
      case AssistantState.thinking:
        return "Thinking…";
      case AssistantState.speaking:
        return "Speaking…";
      case AssistantState.idle:
      default:
        return "Ask Orion anything";
    }
  }

  void _toggleVoice() {
    setState(() => _ttsService.toggle());
    _syncAssistantStateWithChat();
  }

  Future<void> _onMicTap() async {
    if (_assistantController.state == AssistantState.listening) {
      _assistantController.stopListening();
      return;
    }

    if (_ttsService.isSpeaking) {
      await _ttsService.stop();
    }

    _assistantController.startListening();
  }

  Future<void> _confirmAndLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          "Logout?",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          "You will be signed out from Orion.",
          style: TextStyle(color: AppColors.textSecondary.withOpacity(0.95)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "Cancel",
              style: TextStyle(color: AppColors.textSecondary.withOpacity(0.9)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Logout",
              style: TextStyle(
                color: Color(0xFFFF5A5F),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    await _ttsService.stop();
    _assistantController.reset();
    await FirebaseAuth.instance.signOut();
  }

  void _comingSoon(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$title (coming soon)"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsScreen(tts: _ttsService),
      ),
    );
  }

  Future<void> _toggleHistory({bool openInSearchMode = false}) async {
    if (_historyOpen) {
      Navigator.of(context).maybePop();
      return;
    }

    setState(() => _historyOpen = true);

    final isWide = MediaQuery.of(context).size.width >= 700;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: isWide ? const BoxConstraints(maxWidth: 520) : null,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.62,
        minChildSize: 0.35,
        maxChildSize: 0.92,
        expand: false,
        builder: (context, scrollController) {
          return ChatHistorySheet(
            chats: _chatController.chats,
            activeChatId: _chatController.activeChatId,
            scrollController: scrollController,
            autoFocusSearch: openInSearchMode,
            initialQuery: "",
            onNewChat: () async {
              Navigator.pop(context);
              await _chatController.newChat();
            },
            onPickChat: (chatId) async {
              Navigator.pop(context);
              await _chatController.openChat(chatId);
            },
            onRenameChat: (chatId, newTitle) async {
              await _chatController.renameChat(chatId, newTitle);
            },
            onDeleteChat: (chatId) async {
              await _chatController.deleteChat(chatId);
            },
          );
        },
      ),
    );

    if (mounted) setState(() => _historyOpen = false);
  }

  // ✅ NEW: open Account/Profile sheet
  Future<void> _openAccountSheet() async {
    final isWide = MediaQuery.of(context).size.width >= 700;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: isWide ? const BoxConstraints(maxWidth: 520) : null,
      builder: (_) => AccountSheet(
        onOpenSettings: () {
          Navigator.pop(context);
          _openSettings();
        },
        onHelp: () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder:(_)=> const HelpScreen()));
        },
        onAbout: () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_)=> const AboutScreen()));
        },
        onLogout: () async {
          Navigator.pop(context);
          await _confirmAndLogout();
        },
      ),
    );
  }

  PopupMenuItem<int> _accountMenuItem() {
    final user = FirebaseAuth.instance.currentUser;
    final name = (user?.displayName ?? "").trim();
    final email = (user?.email ?? "").trim();
    final title = name.isNotEmpty ? name : (email.isNotEmpty ? email : "Account");

    String initials() {
      final s = title.trim();
      if (s.isEmpty) return "U";
      final parts = s.split(RegExp(r"\s+")).where((e) => e.isNotEmpty).toList();
      if (parts.length == 1) return parts.first[0].toUpperCase();
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }

    return PopupMenuItem<int>(
      value: _menuAccount,
      child: Row(
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withOpacity(0.18),
              border: Border.all(color: AppColors.accent.withOpacity(0.25)),
            ),
            alignment: Alignment.center,
            child: Text(
              initials(),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Account • Plan",
                  style: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.9),
                    fontSize: 12,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFF9FA8FF), // accent
              Color(0xFFEDEEFF), // primary text
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            "ORION",
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 25,
              letterSpacing: 4.5,
              fontWeight: FontWeight.w900,
              color: Colors.white, // required for ShaderMask
            ),
          ),
        ),

        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            color: AppColors.surface,
            onSelected: (value) async {
              switch (value) {
                case _menuAccount:
                  await _openAccountSheet();
                  break;
                case _menuVoice:
                  _toggleVoice();
                  break;
                case _menuNewChat:
                  await _chatController.newChat();
                  break;
                case _menuSearchChats:
                  await _toggleHistory(openInSearchMode: true);
                  break;
                case _menuChatHistory:
                  await _toggleHistory();
                  break;
                case _menuSettings:
                  _openSettings();
                  break;
                case _menuLogout:
                  await _confirmAndLogout();
                  break;
              }
            },
            itemBuilder: (_) => [
              _accountMenuItem(),
              const PopupMenuDivider(),

              PopupMenuItem<int>(
                value: _menuVoice,
                child: Row(
                  children: [
                    Icon(
                      _ttsService.enabled ? Icons.volume_up : Icons.volume_off,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        "Voice responses",
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                    Text(
                      _ttsService.enabled ? "ON" : "OFF",
                      style: TextStyle(
                        color: AppColors.textSecondary.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const PopupMenuDivider(),

              const PopupMenuItem<int>(
                value: _menuNewChat,
                child: Row(
                  children: [
                    Icon(Icons.add_rounded,
                        color: AppColors.textPrimary, size: 20),
                    SizedBox(width: 10),
                    Text("New chat",
                        style: TextStyle(color: AppColors.textPrimary)),
                  ],
                ),
              ),
              const PopupMenuItem<int>(
                value: _menuChatHistory,
                child: Row(
                  children: [
                    Icon(Icons.history_rounded,
                        color: AppColors.textPrimary, size: 20),
                    SizedBox(width: 10),
                    Text("Chat history",
                        style: TextStyle(color: AppColors.textPrimary)),
                  ],
                ),
              ),
              const PopupMenuItem<int>(
                value: _menuSearchChats,
                child: Row(
                  children: [
                    Icon(Icons.search_rounded,
                        color: AppColors.textPrimary, size: 20),
                    SizedBox(width: 10),
                    Text("Search chats",
                        style: TextStyle(color: AppColors.textPrimary)),
                  ],
                ),
              ),
              const PopupMenuItem<int>(
                value: _menuSettings,
                child: Row(
                  children: [
                    Icon(Icons.settings_rounded,
                        color: AppColors.textPrimary, size: 20),
                    SizedBox(width: 10),
                    Text("Settings",
                        style: TextStyle(color: AppColors.textPrimary)),
                  ],
                ),
              ),

              const PopupMenuDivider(),

              const PopupMenuItem<int>(
                value: _menuLogout,
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded,
                        color: Color(0xFFFF5A5F), size: 20),
                    SizedBox(width: 10),
                    Text(
                      "Logout",
                      style: TextStyle(
                        color: Color(0xFFFF5A5F),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _assistantController,
            _chatController,
            _ttsService,
          ]),
          builder: (_, __) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _chatController.messages.length,
                    itemBuilder: (context, index) {
                      final m = _chatController.messages[index];
                      return ChatBubble(message: m);
                    },
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: isTyping ? 0 : 1,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 300),
                    scale: isTyping ? 0.9 : 1,
                    child: AiOrb(
                      state: _assistantController.state,
                      onTap: _onMicTap,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (!isTyping)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      _assistantController.lastText.isNotEmpty &&
                          _assistantController.state ==
                              AssistantState.listening
                          ? _assistantController.lastText
                          : _statusText(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary.withOpacity(0.8),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Focus(
                          onFocusChange: (focus) =>
                              setState(() => isTyping = focus),
                          child: TextField(
                            controller: _textController,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: "Ask Orion…",
                              hintStyle: TextStyle(
                                color:
                                AppColors.textSecondary.withOpacity(0.6),
                              ),
                              filled: true,
                              fillColor: AppColors.surface.withOpacity(0.6),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onSubmitted: (_) => _sendText(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.send_rounded,
                            color: AppColors.accent),
                        onPressed: _sendText,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
