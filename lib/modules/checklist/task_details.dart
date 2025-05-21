import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/styles/colors.dart';
import '../../shared/styles/styles.dart';
import '../../shared/components/components.dart'; // Assuming standardCard and sectionHeader are here
import '../../models/ListItems.dart';
import '../../models/Events.dart';
import '../../models/Categories.dart';
import '../../shared/network/remote/firebase_operations.dart'; // Assuming getData and getDocument are here
import '../checklist/edit.dart';

class TaskDetailsPage extends StatefulWidget {
  final String checklistItemId;

  const TaskDetailsPage({Key? key, required this.checklistItemId})
    : super(key: key);

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  ChecklistModel? _checklistItem;
  EventModel? _event;
  CategoryModel? _category;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchTaskDetails();
  }

  Future<void> _fetchTaskDetails() async {
    try {
      // Fetch the checklist item
      final checklistItems =
          await getData<ChecklistModel>(
            'checklists',
            ChecklistModel.fromFirestore,
            queryBuilder:
                (query) => query.where(
                  FieldPath.documentId,
                  isEqualTo: widget.checklistItemId,
                ),
          ).first; // Listen for the first emission and then cancel

      if (checklistItems.isEmpty) {
        setState(() {
          _errorMessage = 'Checklist item not found.';
          _isLoading = false;
        });
        return;
      }
      _checklistItem = checklistItems.first;

      // Fetch the related event
      if (_checklistItem!.eventId != null) {
        final eventSnapshot = await _checklistItem!.eventId.get();
        if (eventSnapshot.exists) {
          _event = EventModel.fromFirestore(
            eventSnapshot.data() as Map<String, dynamic>,
            eventSnapshot.id,
          );
        }
      }

      // Fetch the related category
      if (_checklistItem!.category != null) {
        final categorySnapshot = await _checklistItem!.category.get();
        if (categorySnapshot.exists) {
          _category = CategoryModel.fromFirestore(
            categorySnapshot.data() as Map<String, dynamic>,
            categorySnapshot.id,
          );
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load task details: $e';
        _isLoading = false;
      });
      print('Error fetching task details: $e');
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppStyles.subtitleStyle.copyWith(fontSize: 14),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppStyles.menuLabelStyle.copyWith(
                fontSize: 14,
                color: AppColors.text,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(String label, CategoryModel? category) {
    IconData categoryIcon = Icons.category;
    String categoryName = '';

    if (category != null) {
      categoryName = category.name;
      try {
        if (category.icon.isNotEmpty) {
          int iconCode = int.parse(category.icon);
          if (iconCode >= 0xe000 && iconCode <= 0xf8ff) {
            categoryIcon = IconData(iconCode, fontFamily: 'MaterialIcons');
          }
        }
      } catch (e) {
        print('Error parsing category icon: $e');
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppStyles.subtitleStyle.copyWith(fontSize: 14),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Icon(
                  categoryIcon,
                  color: AppColors.primaryDark,
                  size: AppStyles.iconSize - 6,
                ),
                const SizedBox(width: 8),
                Text(
                  categoryName,
                  style: AppStyles.menuLabelStyle.copyWith(
                    fontSize: 14,
                    color: AppColors.text,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Loading...',
            style: TextStyle(color: AppColors.text),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error', style: TextStyle(color: AppColors.text)),
        ),
        body: Center(child: Text('Error: $_errorMessage')),
      );
    }

    if (_checklistItem == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Not Found', style: TextStyle(color: Colors.black)),
        ),
        body: const Center(child: Text('Checklist item not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _checklistItem!.taskName,
          style: TextStyle(color: AppColors.text),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            standardCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sectionHeader(icon: Icons.info_outline, title: 'DETAILS'),
                  const Divider(),
                  _buildDetailRow('Name', _checklistItem!.taskName),
                  _buildDetailRow('Note', _checklistItem!.note),
                  _buildCategoryRow('Category', _category),
                  _buildDetailRow('Date', _checklistItem!.formattedDate),
                  // Status and Images sections omitted as requested
                ],
              ),
            ),
            // Subtasks section omitted as requested
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      ChecklistEditPage(checklistItem: _checklistItem!),
            ),
          );
          if (result == true) {
            if (mounted) {
              Navigator.pop(context);
            }
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.edit),
      ),
      backgroundColor: AppColors.white,
    );
  }
}
