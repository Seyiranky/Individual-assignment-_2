import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book_model.dart';
import '../providers/books_provider.dart';
import 'post_book_screen.dart';

class BookDetailScreen extends StatelessWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isOwner = user?.uid == book.ownerId;
    final booksProvider = Provider.of<BooksProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Book Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: book.coverUrl.isNotEmpty
                    ? Image.network(
                        book.coverUrl,
                        height: 300,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 300,
                            color: Colors.grey[300],
                            child: const Icon(Icons.book, size: 100),
                          );
                        },
                      )
                    : Container(
                        height: 300,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(Icons.book, size: 100),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              book.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'by ${book.author}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.star, color: Theme.of(context).colorScheme.secondary),
                const SizedBox(width: 8),
                Text(
                  'Condition: ${book.condition}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  book.isAvailable ? Icons.check_circle : Icons.cancel,
                  color: book.isAvailable ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  book.isAvailable ? 'Available' : 'Not Available',
                  style: TextStyle(
                    color: book.isAvailable ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (isOwner) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PostBookScreen(bookToEdit: book),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Book'),
                            content: const Text('Are you sure you want to delete this book?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await booksProvider.deleteBook(book.id);
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Book deleted')),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ] else ...[
              ElevatedButton(
                onPressed: () {
                  // Swap functionality will be handled by BookCard
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Back to Browse'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

