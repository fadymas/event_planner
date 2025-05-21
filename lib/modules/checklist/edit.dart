import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../layout/entry_form_layout.dart';
import '../../shared/styles/colors.dart';
import '../../shared/styles/styles.dart';
import '../category/category-page.dart';
import '../../models/Events.dart';
import '../../models/Categories.dart';
import '../../models/ListItems.dart';
import '../../shared/network/remote/firebase_operations.dart';

class ChecklistEditPage extends StatefulWidget {
  final ChecklistModel checklistItem;

  const ChecklistEditPage({Key? key, required this.checklistItem})
    : super(key: key);

  @override
  State<ChecklistEditPage> createState() => _ChecklistEditPageState();
}

class _ChecklistEditPageState extends State<ChecklistEditPage> {
  final _taskNameController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime? _selectedDate;
  EventModel? _selectedEvent;
  CategoryModel? _selectedCategoryModel;

  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchChecklistItemData();
  }

  Future<void> _fetchChecklistItemData() async {
    try {
      final eventSnapshot = await widget.checklistItem.eventId.get();
      final EventModel? event =
          eventSnapshot.exists
              ? EventModel.fromFirestore(
                eventSnapshot.data() as Map<String, dynamic>,
                eventSnapshot.id,
              )
              : null;

      final categorySnapshot = await widget.checklistItem.category.get();
      final CategoryModel? category =
          categorySnapshot.exists
              ? CategoryModel.fromFirestore(
                categorySnapshot.data() as Map<String, dynamic>,
                categorySnapshot.id,
              )
              : null;

      DateTime? date;
      try {
        date = DateTime.parse(widget.checklistItem.date);
      } catch (e) {
        print('Error parsing date string: ${widget.checklistItem.date} - $e');
      }

      setState(() {
        _taskNameController.text = widget.checklistItem.taskName ?? '';
        _noteController.text = widget.checklistItem.note;
        _selectedDate = date;
        _selectedEvent = event;
        _selectedCategoryModel = category;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load checklist item: $e';
        _isLoading = false;
      });
      print('Error fetching checklist item data: $e');
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildCategoryDisplay() {
    if (_selectedCategoryModel == null) {
      return Row(
        children: [
          Icon(
            Icons.widgets_outlined,
            color: AppColors.grey,
            size: AppStyles.iconSize - 2,
          ),
          const SizedBox(width: 8),
          Text(
            'Select Category',
            style: AppStyles.menuLabelStyle.copyWith(
              fontSize: 14,
              color: AppColors.grey,
            ),
          ),
        ],
      );
    }

    IconData categoryIcon = Icons.category;
    try {
      if (_selectedCategoryModel!.icon.isNotEmpty) {
        int iconCode = int.parse(_selectedCategoryModel!.icon);
        if (iconCode >= 0xe000 && iconCode <= 0xf8ff) {
          categoryIcon = IconData(iconCode, fontFamily: 'MaterialIcons');
        } else {
          print('Warning: Invalid icon code point: $iconCode');
        }
      }
    } catch (e) {
      print('Error parsing category icon: $e');
    }

    return Row(
      children: [
        Icon(
          categoryIcon,
          color: AppColors.primaryDark,
          size: AppStyles.iconSize - 2,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category',
              style: AppStyles.subtitleStyle.copyWith(fontSize: 11),
            ),
            Text(
              _selectedCategoryModel!.name,
              style: AppStyles.menuLabelStyle.copyWith(
                fontSize: 14,
                color: AppColors.text,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Task')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Task')),
        body: Center(child: Text('Error: $_errorMessage')),
      );
    }

    return StreamBuilder<List<EventModel>>(
      stream: getData<EventModel>(
        'events',
        (data, id) => EventModel.fromFirestore(data, id),
      ),
      builder: (context, eventSnapshot) {
        if (eventSnapshot.hasError) {
          return const Center(
            child: Text('Something went wrong loading events'),
          );
        }

        if (eventSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final events =
            eventSnapshot.data?.where((event) => event.isOwner).toList() ?? [];

        return EntryFormLayout(
          title: 'Edit Task',
          fields: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppStyles.smallPadding,
                vertical: AppStyles.smallPadding - 5,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(
                  AppStyles.smallBorderRadius,
                ),
                border: Border.all(color: AppColors.grey),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedEvent?.id,
                decoration: InputDecoration(
                  labelText: 'Event',
                  labelStyle: AppStyles.menuLabelStyle.copyWith(
                    fontSize: 14,
                    color: AppColors.grey,
                  ),
                  border: InputBorder.none,
                ),
                items:
                    events.map((EventModel event) {
                      return DropdownMenuItem<String>(
                        value: event.id,
                        child: Text(
                          event.name,
                          style: AppStyles.menuLabelStyle.copyWith(
                            fontSize: 14,
                            color: AppColors.text,
                          ),
                        ),
                      );
                    }).toList(),
                onChanged: (String? newId) {
                  setState(() {
                    _selectedEvent = events.firstWhere((e) => e.id == newId);
                  });
                },
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _taskNameController,
              decoration: InputDecoration(
                labelText: 'Task Name',
                labelStyle: AppStyles.menuLabelStyle.copyWith(
                  fontSize: 14,
                  color: AppColors.grey,
                ),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppStyles.smallBorderRadius,
                  ),
                  borderSide: BorderSide(color: AppColors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppStyles.smallBorderRadius,
                  ),
                  borderSide: BorderSide(color: AppColors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppStyles.smallBorderRadius,
                  ),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Note',
                labelStyle: AppStyles.menuLabelStyle.copyWith(
                  fontSize: 14,
                  color: AppColors.grey,
                ),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppStyles.smallBorderRadius,
                  ),
                  borderSide: BorderSide(color: AppColors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppStyles.smallBorderRadius,
                  ),
                  borderSide: BorderSide(color: AppColors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppStyles.smallBorderRadius,
                  ),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: () async {
                final selectedCategory = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SelectCategoryPage()),
                );
                if (selectedCategory != null &&
                    selectedCategory is CategoryModel) {
                  setState(() {
                    _selectedCategoryModel = selectedCategory;
                  });
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppStyles.smallPadding,
                  vertical: AppStyles.smallPadding - 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(
                    AppStyles.smallBorderRadius,
                  ),
                  border: Border.all(color: AppColors.grey),
                ),
                child: Row(
                  children: [
                    _buildCategoryDisplay(),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.grey,
                      size: AppStyles.smallIconSize,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppStyles.smallPadding,
                  vertical: AppStyles.smallPadding + 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(
                    AppStyles.smallBorderRadius,
                  ),
                  border: Border.all(color: AppColors.grey),
                ),
                child: Row(
                  children: [
                    Text(
                      'Date',
                      style: AppStyles.subtitleStyle.copyWith(fontSize: 14),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDate != null
                          ? "${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year.toString().substring(2)}"
                          : '',
                      style: AppStyles.menuLabelStyle.copyWith(fontSize: 14),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.calendar_today,
                      color: AppColors.grey,
                      size: AppStyles.smallIconSize,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppStyles.smallBorderRadius,
                    ),
                  ),
                ),
                onPressed: _deleteItem,
                child: Text(
                  'DELETE',
                  style: AppStyles.titleStyle.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
          buttonText: 'SAVE',
          onSubmit: _submitForm,
        );
      },
    );
  }

  void _submitForm() async {
    if (_selectedEvent == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select an event')));
      return;
    }
    if (_selectedCategoryModel == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    if (_taskNameController.text.isNotEmpty) {
      final eventRef = FirebaseFirestore.instance
          .collection('events')
          .doc(_selectedEvent!.id);
      final categoryRef = FirebaseFirestore.instance
          .collection('categories')
          .doc(_selectedCategoryModel!.id);

      try {
        await updateDocument('checklists', widget.checklistItem.id, {
          'eventId': eventRef,
          'note': _noteController.text,
          'taskName': _taskNameController.text,
          'category': categoryRef,
          'date': _selectedDate?.toIso8601String().split('T').first ?? '',
          'isCompleted': widget.checklistItem.isCompleted,
          'updatedAt': DateTime.now().toIso8601String(),
        });

        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating checklist item: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Task name is required')));
    }
  }

  void _deleteItem() async {
    try {
      bool confirmDelete =
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Confirm Delete'),
                content: const Text(
                  'Are you sure you want to delete this checklist item?',
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Delete'),
                  ),
                ],
              );
            },
          ) ??
          false;

      if (confirmDelete) {
        await deleteDocument('checklists', widget.checklistItem.id);
        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting checklist item: $e')),
      );
    }
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}
