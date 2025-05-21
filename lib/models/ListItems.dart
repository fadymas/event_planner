import 'package:cloud_firestore/cloud_firestore.dart';
import 'formatDate.dart';

class ChecklistModel implements FormatDate {
  final String id;
  final String taskName;
  final DocumentReference eventId;
  final String note;
  final DocumentReference category;
  final String createdAt;
  final String date;
  final bool isCompleted;
  final String updatedAt;

  ChecklistModel({
    required this.id,
    required this.taskName,
    required this.eventId,
    required this.note,
    required this.category,
    required this.createdAt,
    required this.date,
    required this.isCompleted,
    required this.updatedAt,
  });
  String get formattedDate => FormatDate.formatDate(date);

  factory ChecklistModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ChecklistModel(
      id: id,
      eventId: data['eventId'] as DocumentReference,
      taskName: data['taskName']?.toString() ?? '',
      note: data['note']?.toString() ?? '',
      category: data['category'] as DocumentReference,
      createdAt: data['createdAt']?.toString() ?? '',
      date: data['date']?.toString() ?? '',
      isCompleted: data['isCompleted'] ?? false,
      updatedAt: data['updatedAt']?.toString() ?? '',
    );
  }
}
