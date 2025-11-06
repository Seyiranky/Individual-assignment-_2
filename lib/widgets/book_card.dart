import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';
import '../providers/swaps_provider.dart';
import '../providers/books_provider.dart';
import '../screens/book_detail_screen.dart';
import '../screens/post_book_screen.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final bool showEditDelete;

  const BookCard({super.key, required this.book, this.showEditDelete = false});

  Future<void> _requestSwap(BuildContext context, Book book) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to request a swap')),
      );
      return;
    }

    if (user.uid == book.ownerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot swap your own book')),
      );
      return;
    }

    if (book.isAvailable != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This book is not available')),
      );
      return;
    }

    // Grab providers before awaiting anything that may unmount this context.
    final swapsProvider = Provider.of<SwapsProvider>(context, listen: false);
    final booksProvider = Provider.of<BooksProvider>(context, listen: false);

    // Confirm swap request
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Swap'),
        content: Text('Request swap for "${book.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Request'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // ---------------- 1️⃣ Create the swap ----------------
      await swapsProvider.requestSwap({
        'bookId': book.id,
        'fromUserId': user.uid, // Must match FirestoreService rules
        'toUserId': book.ownerId,
        'status': 'pending',
        'createdAt': Timestamp.now(),
      });

      // ---------------- 2️⃣ Safely mark book unavailable ----------------
      if (book.isAvailable == true) {
        try {
          await booksProvider.updateBook(book.id, {'isAvailable': false});
        } catch (_) {
          // Non-critical: swap still succeeds
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Swap requested, but could not update book availability',
                ),
              ),
            );
          }
        }
      }

      // ---------------- 3️⃣ Success feedback ----------------
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Swap requested successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error requesting swap: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isOwner = user?.uid == book.ownerId;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: book.coverUrl.isNotEmpty
                    ? Image.network(
                        book.coverUrl,
                        width: 56,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 56,
                            height: 80,
                            color: Colors.grey[200],
                            child: const Icon(Icons.book),
                          );
                        },
                      )
                    : Container(
                        width: 56,
                        height: 80,
                        color: Colors.grey[200],
                        child: const Icon(Icons.book),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${book.author} • ${book.condition}',
                      style: TextStyle(color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (book.isAvailable == false)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Not Available',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
              if (showEditDelete && isOwner) ...[
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PostBookScreen(bookToEdit: book),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    // TODO: add delete logic
                  },
                ),
              ] else if (!isOwner && book.isAvailable == true)
                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: () => _requestSwap(context, book),
                    child: const Text('Swap'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
