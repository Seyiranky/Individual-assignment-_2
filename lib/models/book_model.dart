import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String ownerId;
  final String title;
  final String author;
  final String condition; // New, Like New, Good, Used
  final String coverUrl;
  final bool isAvailable;
  final Timestamp createdAt;

  Book({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.author,
    required this.condition,
    required this.coverUrl,
    required this.isAvailable,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'ownerId': ownerId,
        'title': title,
        'author': author,
        'condition': condition,
        'coverUrl': coverUrl,
        'isAvailable': isAvailable,
        'createdAt': createdAt,
      };

  factory Book.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Book(
      id: doc.id,
      ownerId: data['ownerId'],
      title: data['title'],
      author: data['author'],
      condition: data['condition'],
      coverUrl: data['coverUrl'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}
