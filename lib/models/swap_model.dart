import 'package:cloud_firestore/cloud_firestore.dart';

/// A lightweight Swap model that matches the Firestore documents used by the
/// app UI. The original project stored fields such as `status`, `fromUserName`
/// and book title strings on the swap document; the UI code reads those fields
/// directly. This model provides nullable fields for those values while
/// keeping required ids and createdAt.
class Swap {
  final String id;
  final String bookId;
  final String fromUserId; // who initiated swap
  final String toUserId; // owner of the book

  // Optional, may be stored on the swap doc for convenience
  final String? fromUserName;
  final String? toUserName;
  final String? fromBookTitle;
  final String? toBookTitle;

  /// Status is stored as a lowercase string like 'pending', 'accepted', 'rejected'
  final String status;
  final Timestamp createdAt;

  Swap({
    required this.id,
    required this.bookId,
    required this.fromUserId,
    required this.toUserId,
    this.fromUserName,
    this.toUserName,
    this.fromBookTitle,
    this.toBookTitle,
    this.status = 'pending',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'bookId': bookId,
    'fromUserId': fromUserId,
    'toUserId': toUserId,
    if (fromUserName != null) 'fromUserName': fromUserName,
    if (toUserName != null) 'toUserName': toUserName,
    if (fromBookTitle != null) 'fromBookTitle': fromBookTitle,
    if (toBookTitle != null) 'toBookTitle': toBookTitle,
    'status': status,
    'createdAt': createdAt,
  };

  factory Swap.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Swap(
      id: doc.id,
      bookId: (data['bookId'] ?? '') as String,
      fromUserId: (data['fromUserId'] ?? '') as String,
      toUserId: (data['toUserId'] ?? '') as String,
      fromUserName: data['fromUserName'] as String?,
      toUserName: data['toUserName'] as String?,
      fromBookTitle: data['fromBookTitle'] as String?,
      toBookTitle: data['toBookTitle'] as String?,
      status: (data['status'] ?? 'pending') as String,
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }
}
