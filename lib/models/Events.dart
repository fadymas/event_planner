import 'formatDate.dart';

class EventModel implements FormatDate {
  final String id;
  final String name;
  final String subTitle;
  final String date;
  final String time;
  final double budget;
  final String qrCode;
  final bool isOwner;
  final String createdAt;
  final String updatedAt;

  EventModel({
    required this.id,
    required this.name,
    required this.subTitle,
    required this.date,
    required this.time,
    required this.budget,
    required this.qrCode,
    required this.isOwner,
    required this.createdAt,
    required this.updatedAt,
  });

  String get formattedDate => FormatDate.formatDate(date);

  factory EventModel.fromFirestore(Map<String, dynamic> data, String id) {
    return EventModel(
      id: id,
      name: data['name']?.toString() ?? '',
      subTitle: data['subTitle'] ?? '',
      date: data['date']?.toString() ?? '',
      time: data['time']?.toString() ?? '',
      budget:
          (data['budget'] is num) ? (data['budget'] as num).toDouble() : 0.0,
      qrCode: data['qrCode']?.toString() ?? '',
      isOwner: data['isOwner'] ?? false,
      createdAt: data['createdAt']?.toString() ?? '',
      updatedAt: data['updatedAt']?.toString() ?? '',
    );
  }
}
