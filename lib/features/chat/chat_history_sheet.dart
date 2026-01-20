import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ChatHistorySheet extends StatefulWidget {
  const ChatHistorySheet({
    super.key,
    required this.chats,
    required this.onNewChat,
    required this.onPickChat,
    required this.activeChatId,
    required this.onRenameChat,
    required this.onDeleteChat,
    this.scrollController,
    this.autoFocusSearch = false,
    this.initialQuery = "",
  });

  final List<Map<String, dynamic>> chats;
  final VoidCallback onNewChat;
  final void Function(String chatId) onPickChat;
  final String? activeChatId;
  final Future<void> Function(String chatId, String newTitle) onRenameChat;
  final Future<void> Function(String chatId) onDeleteChat;

  final ScrollController? scrollController;
  final bool autoFocusSearch;
  final String initialQuery;

  @override
  State<ChatHistorySheet> createState() => _ChatHistorySheetState();
}

class _ChatHistorySheetState extends State<ChatHistorySheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  Timer? _debounce;
  String _query = "";

  @override
  void initState() {
    super.initState();

    if (widget.initialQuery.trim().isNotEmpty) {
      _searchCtrl.text = widget.initialQuery.trim();
      _query = _searchCtrl.text.trim();
    }

    _searchCtrl.addListener(_onSearchChanged);

    if (widget.autoFocusSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _searchFocus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 180), () {
      if (mounted) setState(() => _query = _searchCtrl.text.trim());
    });
  }

  List<Map<String, dynamic>> get _filteredChats {
    if (_query.isEmpty) return widget.chats;
    final q = _query.toLowerCase();
    return widget.chats.where((c) {
      final t = (c["title"] ?? "New chat").toString().toLowerCase();
      return t.contains(q);
    }).toList();
  }

  Future<void> _renameDialog(String id, String title) async {
    final ctrl = TextEditingController(text: title);

    final res = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text("Rename chat",
            style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context, ctrl.text.trim()),
              child: const Text("Save")),
        ],
      ),
    );

    if (res != null && res.trim().isNotEmpty) {
      await widget.onRenameChat(id, res.trim());
    }
  }

  Future<void> _confirmDelete(String id, String title) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text("Delete chat?",
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          "Delete \"$title\" ?",
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete",
                  style: TextStyle(color: Color(0xFFFF5A5F)))),
        ],
      ),
    );

    if (ok == true) {
      await widget.onDeleteChat(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredChats;

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchCtrl,
                focusNode: _searchFocus,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: "Search chats",
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),

            Expanded(
              child: list.isEmpty
                  ? const Center(child: Text("No chats"))
                  : ListView.separated(
                controller: widget.scrollController,
                itemCount: list.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, i) {
                  final chat = list[i];
                  final id = chat["id"] as String;
                  final title = (chat["title"] ?? "New chat").toString();
                  final isActive = id == widget.activeChatId;

                  return ListTile(
                    leading: Icon(
                      Icons.chat_bubble,
                      color: isActive
                          ? AppColors.accent
                          : AppColors.textSecondary,
                    ),
                    title: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: isActive ? null : () => widget.onPickChat(id),
                    trailing: PopupMenuButton<int>(
                      onSelected: (v) {
                        if (v == 0) {
                          _renameDialog(id, title);
                        } else {
                          _confirmDelete(id, title);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 0, child: Text("Rename")),
                        PopupMenuItem(
                          value: 1,
                          child: Text(
                            "Delete",
                            style: TextStyle(color: Color(0xFFFF5A5F)),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
