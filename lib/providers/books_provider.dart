import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../models/book_model.dart';

class BooksProvider extends ChangeNotifier {
  final FirestoreService _db = FirestoreService();

  Stream<List<Book>> get allBooks => _db.streamAllBooks();

  Stream<List<Book>> userBooks(String userId) => _db.streamUserBooks(userId);

  Future<DocumentReference> createBook(Map<String, dynamic> data) => _db.createBook(data);

  Future<void> updateBook(String id, Map<String, dynamic> data) => _db.updateBook(id, data);

  Future<void> deleteBook(String id) => _db.deleteBook(id);
}
