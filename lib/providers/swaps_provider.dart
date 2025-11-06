import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/swap_model.dart';

class SwapsProvider extends ChangeNotifier {
  final FirestoreService _db = FirestoreService();

  // Stream all swaps sent to me (as book owner)
  Stream<List<Swap>> userSwaps(String userId) => _db.streamUserSwaps(userId);

  // Stream all swaps I requested from others
  Stream<List<Swap>> mySwapRequests(String userId) => _db.streamMySwapRequests(userId);

  // Create new swap request
  Future<void> requestSwap(Map<String, dynamic> data) => _db.createSwap(data);

  // Update swap manually if needed
  Future<void> updateSwap(String id, Map<String, dynamic> data) => _db.updateSwap(id, data);

  // Respond to a swap request (accept or reject)
  Future<void> respondToSwap(String swapId, bool accept) async {
    await _db.respondToSwap(swapId, accept);
    notifyListeners();
  }
}
