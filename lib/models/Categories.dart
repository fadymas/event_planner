class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final String note;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.note,
  });

  factory CategoryModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CategoryModel(
      id: id,
      name: data['name']?.toString() ?? '',
      icon: data['icon']?.toString() ?? "", // Default icon
      note: data['note']?.toString() ?? '',
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {'name': name, 'icon': icon, 'note': note};
  }
}
