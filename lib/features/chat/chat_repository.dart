import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ChatRepository {
  ChatRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  String get _uid {
    final u = _auth.currentUser;
    if (u == null) throw Exception("Not logged in");
    return u.uid;
  }

  CollectionReference<Map<String, dynamic>> _chatsRef() =>
      _db.collection("users").doc(_uid).collection("chats");

  CollectionReference<Map<String, dynamic>> _messagesRef(String chatId) =>
      _chatsRef().doc(chatId).collection("messages");

  /// Stream chat list (latest first)
  Stream<QuerySnapshot<Map<String, dynamic>>> watchChats() {
    return _chatsRef()
        .orderBy("updatedAt", descending: true)
        .limit(50)
        .snapshots();
  }

  /// Stream messages of a chat (oldest -> newest)
  Stream<QuerySnapshot<Map<String, dynamic>>> watchMessages(String chatId) {
    return _messagesRef(chatId)
        .orderBy("createdAt", descending: false)
        .limit(200)
        .snapshots();
  }

  /// Create a brand new chat doc and return its id
  Future<String> createChat({String title = "New chat"}) async {
    final doc = _chatsRef().doc();

    await doc.set({
      "title": title,
      "createdAt": FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  Future<void> renameChat(String chatId, String title) async {
    await _chatsRef().doc(chatId).update({
      "title": title,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> touchChat(String chatId) async {
    await _chatsRef().doc(chatId).update({
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  /// ✅ Rename only if title is still "New chat" (safe auto-title)
  Future<void> autoTitleIfDefault(String chatId, String newTitle) async {
    final chatDoc = _chatsRef().doc(chatId);

    final snap = await chatDoc.get();
    if (!snap.exists) return;

    final data = snap.data();
    final currentTitle = (data?["title"] ?? "New chat").toString().trim();

    if (currentTitle.toLowerCase() == "new chat") {
      await chatDoc.update({
        "title": newTitle,
        "updatedAt": FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> addMessage({
    required String chatId,
    required String sender, // "user" or "orion"
    required String text,
  }) async {
    final msgRef = _messagesRef(chatId).doc();

    await msgRef.set({
      "sender": sender,
      "text": text,
      "createdAt": FieldValue.serverTimestamp(),
    });

    await touchChat(chatId);
  }

  // ✅ HARD DELETE: delete messages subcollection (ALL) then delete chat doc
  Future<void> deleteChat(String chatId) async {
    try {
      final messages = _messagesRef(chatId);

      // Firestore batch limit is 500. Keep it safe.
      const pageSize = 450;

      while (true) {
        final snap = await messages
            .orderBy(FieldPath.documentId)
            .limit(pageSize)
            .get();

        if (snap.docs.isEmpty) break;

        final batch = _db.batch();
        for (final d in snap.docs) {
          batch.delete(d.reference);
        }
        await batch.commit();
      }

      // Finally delete chat doc
      await _chatsRef().doc(chatId).delete();
    } catch (e) {
      debugPrint("❌ deleteChat failed: $e");
      rethrow;
    }
  }
}
