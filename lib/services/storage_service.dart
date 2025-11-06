import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final _bucket = FirebaseStorage.instance;

  Future<String> uploadBookCoverFromPath(String filePath) async {
    final file = File(filePath);
    final id = Uuid().v4();
    final ref = _bucket.ref().child('book_covers/$id.jpg');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<String> uploadBookCoverBytes(Uint8List bytes, String fileName) async {
    final id = Uuid().v4();
    final extension = fileName.split('.').last;
    final ref = _bucket.ref().child('book_covers/$id.$extension');
    await ref.putData(bytes);
    return await ref.getDownloadURL();
  }
}
