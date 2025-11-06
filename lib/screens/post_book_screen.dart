import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/books_provider.dart';
import '../services/storage_service.dart';
import '../models/book_model.dart';

class PostBookScreen extends StatefulWidget {
  final Book? bookToEdit;

  const PostBookScreen({super.key, this.bookToEdit});

  @override
  State<PostBookScreen> createState() => _PostBookScreenState();
}

class _PostBookScreenState extends State<PostBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _conditionController = TextEditingController();
  XFile? _imageFile;
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  final List<String> _conditions = ['New', 'Like New', 'Good', 'Used'];

  @override
  void initState() {
    super.initState();
    if (widget.bookToEdit != null) {
      _titleController.text = widget.bookToEdit!.title;
      _authorController.text = widget.bookToEdit!.author;
      _conditionController.text = widget.bookToEdit!.condition;
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() {
        _imageFile = image;
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Capture provider before any await to avoid using BuildContext across async gaps.
    final booksProvider = Provider.of<BooksProvider>(context, listen: false);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please log in first')));
        return;
      }

      String? coverUrl = widget.bookToEdit?.coverUrl;

      if (_imageFile != null) {
        final storageService = StorageService();
        if (kIsWeb) {
          coverUrl = await storageService.uploadBookCoverBytes(
            _imageBytes!,
            _imageFile!.name,
          );
        } else {
          coverUrl = await storageService.uploadBookCoverFromPath(
            _imageFile!.path,
          );
        }
      }

      final bookData = {
        'title': _titleController.text.trim(),
        'author': _authorController.text.trim(),
        'condition': _conditionController.text,
        'coverUrl': coverUrl ?? '',
        'ownerId': user.uid,
        'isAvailable': true,
        'createdAt': widget.bookToEdit?.createdAt ?? Timestamp.now(),
      };

      if (widget.bookToEdit != null) {
        await booksProvider.updateBook(widget.bookToEdit!.id, bookData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Book updated successfully!')),
          );
        }
      } else {
        await booksProvider.createBook(bookData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Book posted successfully!')),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _conditionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bookToEdit != null ? 'Edit Book' : 'Post a Book'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _imageBytes != null
                      ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                      : widget.bookToEdit?.coverUrl.isNotEmpty == true
                      ? Image.network(
                          widget.bookToEdit!.coverUrl,
                          fit: BoxFit.cover,
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.add_photo_alternate, size: 50),
                            SizedBox(height: 8),
                            Text('Tap to add book cover'),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'Author',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an author';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _conditionController.text.isEmpty
                    ? null
                    : _conditionController.text,
                decoration: const InputDecoration(
                  labelText: 'Condition',
                  prefixIcon: Icon(Icons.star),
                ),
                items: _conditions.map((condition) {
                  return DropdownMenuItem(
                    value: condition,
                    child: Text(condition),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _conditionController.text = value ?? '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a condition';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        widget.bookToEdit != null ? 'Update Book' : 'Post Book',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
