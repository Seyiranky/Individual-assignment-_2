import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book_model.dart';
import '../models/swap_model.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // ---------------- BOOKS ----------------
  Stream<List<Book>> streamAllBooks() {
    return _db
        .collection('books')
        .snapshots()
        .map((snap) {
          debugPrint('📚 Received ${snap.docs.length} books from Firestore');
          final books = snap.docs
              .map((d) => Book.fromDoc(d))
              .where((book) => book.isAvailable)
              .toList();
          debugPrint('✅ ${books.length} books are available');
          books.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return books;
        })
        .handleError((error) {
          debugPrint('❌ Firestore error in streamAllBooks: $error');
          throw error;
        });
  }

  Stream<List<Book>> streamUserBooks(String userId) {
    return _db
        .collection('books')
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Book.fromDoc(d)).toList());
  }

  Future<DocumentReference> createBook(Map<String, dynamic> data) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.uid != data['ownerId']) {
      throw Exception(
        'Unauthorized: Only the logged-in user can create this book',
      );
    }
    return _db.collection('books').add(data);
  }

  Future<void> updateBook(String bookId, Map<String, dynamic> data) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('User not logged in');

    final docRef = _db.collection('books').doc(bookId);
    final snapshot = await docRef.get();
    if (!snapshot.exists) throw Exception('Book not found');

    final bookData = snapshot.data()!;
    if (currentUser.uid == bookData['ownerId']) {
      await docRef.update(data);
      return;
    }

    if (data.keys.length == 1 &&
        data.containsKey('isAvailable') &&
        bookData['isAvailable'] == true &&
        data['isAvailable'] == false) {
      await docRef.update(data);
      return;
    }

    throw Exception('Unauthorized: Cannot update this book');
  }

  Future<void> deleteBook(String bookId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('User not logged in');

    final docRef = _db.collection('books').doc(bookId);
    final snapshot = await docRef.get();
    if (!snapshot.exists) throw Exception('Book not found');

    if (currentUser.uid != snapshot.data()!['ownerId']) {
      throw Exception('Unauthorized: Only the owner can delete this book');
    }

    await docRef.delete();
  }

  Future<Book?> getBook(String bookId) async {
    final doc = await _db.collection('books').doc(bookId).get();
    if (doc.exists) {
      return Book.fromDoc(doc);
    }
    return null;
  }

  // ---------------- SWAPS ----------------
  Stream<List<Swap>> streamUserSwaps(String userId) {
    return _db
        .collection('swaps')
        .where('toUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Swap.fromDoc(d)).toList());
  }

  Stream<List<Swap>> streamMySwapRequests(String userId) {
    return _db
        .collection('swaps')
        .where('fromUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Swap.fromDoc(d)).toList());
  }

  Future<DocumentReference> createSwap(Map<String, dynamic> data) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.uid != data['fromUserId']) {
      throw Exception('Unauthorized: fromUserId must match logged-in user');
    }
    return _db.collection('swaps').add(data);
  }

  Future<void> updateSwap(String swapId, Map<String, dynamic> data) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('User not logged in');

    final docRef = _db.collection('swaps').doc(swapId);
    final snapshot = await docRef.get();
    if (!snapshot.exists) throw Exception('Swap not found');

    final swapData = snapshot.data()!;
    final allowed =
        currentUser.uid == swapData['fromUserId'] ||
        currentUser.uid == swapData['toUserId'];

    if (!allowed) throw Exception('Unauthorized: Only participants can update');

    if ((data['fromUserId'] != null &&
            data['fromUserId'] != swapData['fromUserId']) ||
        (data['toUserId'] != null &&
            data['toUserId'] != swapData['toUserId'])) {
      throw Exception('Cannot change swap participants');
    }

    await docRef.update(data);
  }

  // ✅ NEW: Book owner accepts or rejects swap
  Future<void> respondToSwap(String swapId, bool accept) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('User not logged in');

    final docRef = _db.collection('swaps').doc(swapId);
    final snapshot = await docRef.get();
    if (!snapshot.exists) throw Exception('Swap not found');

    final swapData = snapshot.data()!;
    if (swapData['toUserId'] != currentUser.uid) {
      throw Exception('Unauthorized: Only the book owner can respond to swaps');
    }

    final newStatus = accept ? 'accepted' : 'rejected';

    await docRef.update({'status': newStatus, 'respondedAt': Timestamp.now()});
  }

  // ---------------- CHATS ----------------
  Stream<List<Map<String, dynamic>>> streamChats(String userId) {
    return _db
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) {
            final data = d.data();
            return {'id': d.id, ...data};
          }).toList(),
        );
  }

  Stream<List<Map<String, dynamic>>> streamMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) {
            final data = d.data();
            return {'id': d.id, ...data};
          }).toList(),
        );
  }

  Future<void> sendMessage(
    String chatId,
    Map<String, dynamic> messageData,
  ) async {
    await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData);
    await _db.collection('chats').doc(chatId).update({
      'lastMessage': messageData['text'],
      'lastMessageTime': messageData['timestamp'],
    });
  }

  Future<String> getOrCreateChat(String userId1, String userId2) async {
    final chats = await _db
        .collection('chats')
        .where('participants', arrayContainsAny: [userId1, userId2])
        .get();

    for (var chat in chats.docs) {
      final data = chat.data();
      final participants = List<String>.from(data['participants'] ?? []);
      if (participants.contains(userId1) && participants.contains(userId2)) {
        return chat.id;
      }
    }

    final newChat = await _db.collection('chats').add({
      'participants': [userId1, userId2],
      'createdAt': Timestamp.now(),
      'lastMessage': '',
      'lastMessageTime': Timestamp.now(),
    });

    return newChat.id;
  }
}
