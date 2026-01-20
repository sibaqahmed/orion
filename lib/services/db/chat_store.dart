import 'package:cloud_firestore/cloud_firestore.dart';

class ChatStore {
  ChatStore({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _chatsRef(String uid) {
    return _db.collection('users').doc(uid).collection('chats');
  }

  CollectionReference<Map<String, dynamic>> _messagesRef(String uid, String chatId) {
    return _chatsRef(uid).doc(chatId).collection('messages');
  }

  /// Create a new chat and return its id
  Future<String> createChat(String uid) async {
    final now = FieldValue.serverTimestamp();
    final doc = await _chatsRef(uid).add({
      'title': 'New chat',
      'createdAt': now,
      'updatedAt': now,
      'lastMessage': '',
      'lastSender': '',
    });
    return doc.id;
  }

  /// Save one message
  Future<void> addMessage({
    required String uid,
    required String chatId,
    required String text,
    required String sender, // "user" | "orion"
  }) async {
    final now = FieldValue.serverTimestamp();

    await _messagesRef(uid, chatId).add({
      'text': text,
      'sender': sender,
      'createdAt': now,
    });

    // update chat preview
    await _chatsRef(uid).doc(chatId).set({
      'updatedAt': now,
      'lastMessage': text,
      'lastSender': sender,
    }, SetOptions(merge: true));
  }

  /// Stream all messages for a chat (oldest -> newest)
  Stream<QuerySnapshot<Map<String, dynamic>>> messagesStream({
    required String uid,
    required String chatId,
  }) {
    return _messagesRef(uid, chatId)
        .orderBy('createdAt', descending: false)
        .snapshots();
  }
}
