import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/config/app_config.dart';
import '../../services/ai/gemini_services.dart';
import 'package:orion/services/tts/tts_service.dart';
import 'chat_repository.dart';
import 'message_model.dart';

class ChatController extends ChangeNotifier {
  ChatController({
    required TtsService ttsService,
    ChatRepository? repo,
  })  : _tts = ttsService,
        _repo = repo ?? ChatRepository() {
    final key = AppConfig.geminiApiKey.trim();
    debugPrint("GEMINI KEY LENGTH: ${key.length}");
    if (key.isNotEmpty) _gemini = GeminiService(apiKey: key);
  }

  final TtsService _tts;
  final ChatRepository _repo;
  GeminiService? _gemini;

  bool get hasMind => _gemini != null;

  String? _activeChatId;
  String? get activeChatId => _activeChatId;

  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  List<Map<String, dynamic>> _chats = [];
  List<Map<String, dynamic>> get chats => List.unmodifiable(_chats);

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _chatsSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _messagesSub;

  final Set<String> _titledChats = {};

  // ✅ Prevent “deleted chat comes back” due to cache/stream timing
  final Set<String> _deletingChatIds = {};

  bool _isBusy = false;
  bool get isBusy => _isBusy;

  void _setBusy(bool v) {
    if (_isBusy == v) return;
    _isBusy = v;
    notifyListeners();
  }

  /// Call this once from AssistantScreen initState
  void start() {
    _chatsSub?.cancel();
    _chatsSub = _repo.watchChats().listen((snap) async {
      // Build chat list, excluding those in delete-flight
      final nextChats = snap.docs
          .where((d) => !_deletingChatIds.contains(d.id))
          .map((d) {
        final data = d.data();
        return {
          "id": d.id,
          "title": (data["title"] ?? "New chat").toString(),
          "updatedAt": data["updatedAt"],
        };
      }).toList();

      _chats = nextChats;

      // ✅ If no active chat → open first or create
      if (_activeChatId == null) {
        if (_chats.isNotEmpty) {
          await openChat(_chats.first["id"] as String);
        } else {
          await newChat();
        }
        return;
      }

      // ✅ If active chat got deleted (or filtered out), switch safely
      final stillExists = _chats.any((c) => c["id"] == _activeChatId);
      if (!stillExists) {
        // Stop listening to messages of a chat that no longer exists
        await _messagesSub?.cancel();
        _messagesSub = null;

        _activeChatId = null;
        _messages.clear();
        notifyListeners();

        if (_chats.isNotEmpty) {
          await openChat(_chats.first["id"] as String);
        } else {
          await newChat();
        }
        return;
      }

      notifyListeners();
    });
  }

  @override
  void dispose() {
    _chatsSub?.cancel();
    _messagesSub?.cancel();
    super.dispose();
  }

  Future<void> newChat() async {
    // ✅ instantly clear UI (snappy)
    _messages.clear();
    notifyListeners();

    final chatId = await _repo.createChat(title: "New chat");
    await openChat(chatId);
  }

  Future<void> renameChat(String chatId, String title) async {
    final t = title.trim();
    if (t.isEmpty) return;
    await _repo.renameChat(chatId, t);
  }

  /// ✅ HARD delete (messages + doc) + no “revive”
  Future<void> deleteChat(String chatId) async {
    final wasActive = (_activeChatId == chatId);

    // Mark as deleting so watchChats() ignores it even if cache shows it
    _deletingChatIds.add(chatId);

    // Remove from local list immediately (snappy UI)
    _chats = _chats.where((c) => c["id"] != chatId).toList();

    // If deleting active chat → cancel message stream RIGHT NOW
    if (wasActive) {
      await _messagesSub?.cancel();
      _messagesSub = null;

      _activeChatId = null;
      _messages.clear();
    }

    notifyListeners();

    try {
      await _repo.deleteChat(chatId);
    } finally {
      // Remove delete-flight mark once finished
      _deletingChatIds.remove(chatId);
      notifyListeners();
    }

    // Don’t force open here; the chats stream will handle it.
    // But add a small safety fallback if stream is slow:
    if (_activeChatId == null) {
      if (_chats.isNotEmpty) {
        final nextId = _chats.first["id"]?.toString();
        if (nextId != null && nextId.isNotEmpty) {
          await openChat(nextId);
        } else {
          await newChat();
        }
      } else {
        await newChat();
      }
    }
  }

  Future<void> openChat(String chatId) async {
    if (_activeChatId == chatId) return;

    _activeChatId = chatId;

    // ✅ instantly clear (ChatGPT feel)
    _messages.clear();
    notifyListeners();

    await _messagesSub?.cancel();
    _messagesSub = _repo.watchMessages(chatId).listen((snap) {
      _messages
        ..clear()
        ..addAll(
          snap.docs.map((d) {
            final data = d.data();
            final sender = ChatMessage.senderFromString(
              (data["sender"] ?? "orion").toString(),
            );
            return ChatMessage(
              id: d.id,
              text: (data["text"] ?? "").toString(),
              sender: sender,
            );
          }),
        );
      notifyListeners();
    });

    notifyListeners();
  }

  void _addTyping() {
    _messages.add(
      ChatMessage(
        id: "typing",
        text: "Orion is typing…",
        sender: MessageSender.typing,
      ),
    );
    notifyListeners();
  }

  void _removeTypingIfAny() {
    if (_messages.isNotEmpty && _messages.last.sender == MessageSender.typing) {
      _messages.removeLast();
    }
  }

  String _makeTitleFromUserText(String text) {
    final t = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (t.isEmpty) return "New chat";
    const max = 40;
    if (t.length <= max) return t;
    return "${t.substring(0, max).trim()}…";
  }

  Future<void> _maybeAutoTitle(String chatId, String firstUserText) async {
    if (_titledChats.contains(chatId)) return;

    final newTitle = _makeTitleFromUserText(firstUserText);
    if (newTitle.trim().isEmpty || newTitle.toLowerCase() == "new chat") return;

    _titledChats.add(chatId);

    try {
      await _repo.autoTitleIfDefault(chatId, newTitle);
    } catch (_) {}
  }

  Future<void> sendUserMessage(String text) async {
    final cleaned = text.trim();
    if (cleaned.isEmpty) return;

    if (_activeChatId == null) {
      await newChat();
      if (_activeChatId == null) return;
    }

    final chatId = _activeChatId!;

    await _repo.addMessage(chatId: chatId, sender: "user", text: cleaned);
    await _maybeAutoTitle(chatId, cleaned);

    if (_gemini == null) {
      await _repo.addMessage(
        chatId: chatId,
        sender: "orion",
        text:
        "Mind is offline.\nRun:\nflutter run --dart-define=GEMINI_API_KEY=YOUR_KEY",
      );
      return;
    }

    _setBusy(true);
    _addTyping();

    try {
      final reply = await _gemini!.sendMessage(cleaned);

      _removeTypingIfAny();

      await _repo.addMessage(chatId: chatId, sender: "orion", text: reply);
      await _tts.speak(reply);
    } catch (e) {
      _removeTypingIfAny();
      await _repo.addMessage(
        chatId: chatId,
        sender: "orion",
        text: "Something went wrong talking to Orion's mind.\n$e",
      );
    } finally {
      _setBusy(false);
    }
  }
}
