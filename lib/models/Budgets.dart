import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetModel {
  final String id;
  final double amount;
  final double Paid;
  final DocumentReference category;
  final DateTime createdAt;
  final DocumentReference eventId;
  final String name;
  final String note;
  final DateTime updatedAt;

  BudgetModel({
    required this.id,
    required this.amount,
    required this.Paid,
    required this.category,
    required this.createdAt,
    required this.eventId,
    required this.name,
    required this.note,
    required this.updatedAt,
  });

  factory BudgetModel.fromFirestore(Map<String, dynamic> data, String id) {
    return BudgetModel(
      id: id,
      amount: (data['amount'] as num).toDouble(),
      Paid: (data['Paid'] as num? ?? 0.0).toDouble(),
      category: data['category'] as DocumentReference,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      eventId: data['eventId'] as DocumentReference,
      name: data['name'] as String,
      note: data['note'] as String,
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'amount': amount,
      'Paid': Paid,
      'category': category,
      'createdAt': Timestamp.fromDate(createdAt),
      'eventId': eventId,
      'name': name,
      'note': note,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
