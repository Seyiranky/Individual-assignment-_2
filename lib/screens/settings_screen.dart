import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import 'auth/login_page.dart';
import '../providers/books_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Profile Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      child: Text(
                        user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      user?.displayName ?? 'User',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(user?.email ?? 'No email'),
                  ),
                  if (user?.emailVerified == false)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning, color: Colors.orange[800]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Email not verified',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange[800],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Please verify your email to use all features',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Notifications Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notifications',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Enable Notifications'),
                    subtitle: const Text(
                      'Receive notifications for swap requests',
                    ),
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            value
                                ? 'Notifications enabled'
                                : 'Notifications disabled',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Actions Section
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('About'),
                  subtitle: const Text('BookSwap v1.0.0'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('About BookSwap'),
                        content: const Text(
                          'BookSwap is a platform for students to exchange textbooks.\n\n'
                          'Version: 1.0.0\n'
                          'Built with Flutter & Firebase',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Icon(
                    Icons.add_circle,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  title: const Text('Add Dummy Books (Debug)'),
                  subtitle: const Text('Add sample books for testing'),
                  onTap: () async {
                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please log in first')),
                      );
                      return;
                    }

                    final booksProvider = Provider.of<BooksProvider>(
                      context,
                      listen: false,
                    );
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Add Dummy Books'),
                        content: const Text(
                          'This will add 6 sample books to the database. Continue?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Add'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      final dummyBooks = [
                        {
                          'title': 'Introduction to Algorithms',
                          'author': 'Thomas H. Cormen',
                          'condition': 'Like New',
                          'coverUrl': '',
                          'ownerId': user.uid,
                          'isAvailable': true,
                          'createdAt': Timestamp.now(),
                        },
                        {
                          'title': 'The Pragmatic Programmer',
                          'author': 'Andrew Hunt',
                          'condition': 'Good',
                          'coverUrl': '',
                          'ownerId': user.uid,
                          'isAvailable': true,
                          'createdAt': Timestamp.now(),
                        },
                        {
                          'title': 'Clean Code',
                          'author': 'Robert C. Martin',
                          'condition': 'New',
                          'coverUrl': '',
                          'ownerId': user.uid,
                          'isAvailable': true,
                          'createdAt': Timestamp.now(),
                        },
                        {
                          'title': 'Design Patterns',
                          'author': 'Gang of Four',
                          'condition': 'Used',
                          'coverUrl': '',
                          'ownerId': user.uid,
                          'isAvailable': true,
                          'createdAt': Timestamp.now(),
                        },
                        {
                          'title': 'Flutter Complete Reference',
                          'author': 'Alberto Miola',
                          'condition': 'Like New',
                          'coverUrl': '',
                          'ownerId': user.uid,
                          'isAvailable': true,
                          'createdAt': Timestamp.now(),
                        },
                        {
                          'title': 'System Design Interview',
                          'author': 'Alex Xu',
                          'condition': 'Good',
                          'coverUrl': '',
                          'ownerId': user.uid,
                          'isAvailable': true,
                          'createdAt': Timestamp.now(),
                        },
                      ];

                      int successCount = 0;
                      for (var book in dummyBooks) {
                        try {
                          await booksProvider.createBook(book);
                          successCount++;
                        } catch (e) {
                          debugPrint('Error adding book: $e');
                        }
                      }

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Added $successCount dummy books successfully!',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Log Out',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Log Out'),
                        content: const Text(
                          'Are you sure you want to log out?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Log Out'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      try {
                        // Sign out via provider/service
                        await authProvider.signOut();

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('You have been logged out.'),
                            ),
                          );

                          // Remove all routes and show the LoginPage so user can sign in again
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                            (route) => false,
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error logging out: $e')),
                          );
                        }
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
