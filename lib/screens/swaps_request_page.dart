import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/swaps_provider.dart';
import '../models/swap_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SwapRequestsPage extends StatelessWidget {
  const SwapRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const Center(
        child: Text('Please log in to view your swap requests.'),
      );
    }

    final swapsProvider = Provider.of<SwapsProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Swap Requests'), centerTitle: true),
      body: StreamBuilder<List<Swap>>(
        stream: swapsProvider.userSwaps(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final swaps = snapshot.data ?? [];

          if (swaps.isEmpty) {
            return const Center(child: Text('No swap requests yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: swaps.length,
            itemBuilder: (context, index) {
              final swap = swaps[index];
              final isPending = swap.status == 'pending';

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.swap_horiz,
                    color: Colors.blueAccent,
                    size: 36,
                  ),
                  title: Text(
                    'Swap Request from ${swap.fromUserName ?? "Unknown"}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Book requested: ${swap.toBookTitle ?? "Untitled"}'),
                      Text('Their book: ${swap.fromBookTitle ?? "Untitled"}'),
                      const SizedBox(height: 4),
                      Text(
                        'Status: ${swap.status.toUpperCase()}',
                        style: TextStyle(
                          color: swap.status == 'accepted'
                              ? Colors.green
                              : swap.status == 'rejected'
                              ? Colors.red
                              : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  trailing: isPending
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                              tooltip: 'Accept Swap',
                              onPressed: () async {
                                await swapsProvider.respondToSwap(
                                  swap.id,
                                  true,
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        '✅ Swap accepted successfully!',
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              tooltip: 'Reject Swap',
                              onPressed: () async {
                                await swapsProvider.respondToSwap(
                                  swap.id,
                                  false,
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('❌ Swap rejected.'),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
