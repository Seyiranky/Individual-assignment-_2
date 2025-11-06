// Development-only script to populate Firestore with dummy books.
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bookswap/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final db = FirebaseFirestore.instance;
  final booksRef = db.collection('books');

  final dummyBooks = [
    {
      'title': 'Introduction to Algorithms',
      'author': 'Thomas H. Cormen',
      'condition': 'Like New',
      'coverUrl': '',
      'ownerId': 'dummy_user_1',
      'isAvailable': true,
      'createdAt': Timestamp.now(),
    },
    {
      'title': 'The Pragmatic Programmer',
      'author': 'Andrew Hunt',
      'condition': 'Good',
      'coverUrl': '',
      'ownerId': 'dummy_user_2',
      'isAvailable': true,
      'createdAt': Timestamp.now(),
    },
    {
      'title': 'Clean Code',
      'author': 'Robert C. Martin',
      'condition': 'New',
      'coverUrl': '',
      'ownerId': 'dummy_user_3',
      'isAvailable': true,
      'createdAt': Timestamp.now(),
    },
    {
      'title': 'Design Patterns',
      'author': 'Gang of Four',
      'condition': 'Used',
      'coverUrl': '',
      'ownerId': 'dummy_user_1',
      'isAvailable': true,
      'createdAt': Timestamp.now(),
    },
    {
      'title': 'Flutter Complete Reference',
      'author': 'Alberto Miola',
      'condition': 'Like New',
      'coverUrl': '',
      'ownerId': 'dummy_user_2',
      'isAvailable': true,
      'createdAt': Timestamp.now(),
    },
    {
      'title': 'System Design Interview',
      'author': 'Alex Xu',
      'condition': 'Good',
      'coverUrl': '',
      'ownerId': 'dummy_user_3',
      'isAvailable': true,
      'createdAt': Timestamp.now(),
    },
  ];

  // Script runs silently by default.

  for (var book in dummyBooks) {
    try {
      await booksRef.add(book);
      // added
    } catch (e) {
      // failed
    }
  }

  // done
}
