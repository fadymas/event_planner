import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../layout/entry_form_layout.dart';
import '../../shared/styles/colors.dart';
import '../../shared/styles/styles.dart';
import '../category/category-page.dart';
import '../../models/Events.dart';
import '../../models/Categories.dart';
import '../../shared/network/remote/firebase_operations.dart';

class ChecklistCreatePage extends StatefulWidget {
  const ChecklistCreatePage({Key? key}) : super(key: key);

  @override
  State<ChecklistCreatePage> createState() => _ChecklistCreatePageState();
}

class _ChecklistCreatePageState extends State<ChecklistCreatePage> {
  final _taskNameController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime? _selectedDate;
  EventModel? _selectedEvent;
  CategoryModel? _selectedCategoryModel;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
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
      return const _CategoryPlaceholder();
    }

    return _CategoryDisplay(category: _selectedCategoryModel!);
  }

  @override
  Widget build(BuildContext context) {
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
          title: 'Create Task',
          fields: [
            _EventDropdown(
              events: events,
              selectedEvent: _selectedEvent,
              onChanged: (EventModel? event) {
                setState(() {
                  _selectedEvent = event;
                });
              },
            ),
            const SizedBox(height: 12),

            _TaskNameField(controller: _taskNameController),
            const SizedBox(height: 12),

            _NoteField(controller: _noteController),
            const SizedBox(height: 12),

            _CategorySelector(
              selectedCategory: _selectedCategoryModel,
              onCategorySelected: (CategoryModel? category) {
                setState(() {
                  _selectedCategoryModel = category;
                });
              },
            ),
            const SizedBox(height: 12),

            _DateSelector(
              selectedDate: _selectedDate,
              onDateSelected: _pickDate,
            ),
          ],
          buttonText: 'CREATE',
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
        await createDocument('checklists', {
          'eventId': eventRef,
          'note': _noteController.text,
          'taskName': _taskNameController.text,
          'category': categoryRef,
          'date': _selectedDate?.toIso8601String().split('T').first ?? '',
          'isCompleted': false,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        });

        if (mounted) {
          Navigator.pop(context, {'success': true});
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating checklist item: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Task name is required')));
    }
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}

class _CategoryPlaceholder extends StatelessWidget {
  const _CategoryPlaceholder();

  @override
  Widget build(BuildContext context) {
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
}

class _CategoryDisplay extends StatelessWidget {
  final CategoryModel category;

  const _CategoryDisplay({required this.category});

  @override
  Widget build(BuildContext context) {
    IconData categoryIcon = Icons.category;
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
              category.name,
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
}

class _EventDropdown extends StatelessWidget {
  final List<EventModel> events;
  final EventModel? selectedEvent;
  final ValueChanged<EventModel?> onChanged;

  const _EventDropdown({
    required this.events,
    required this.selectedEvent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppStyles.smallPadding,
        vertical: AppStyles.smallPadding - 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppStyles.smallBorderRadius),
        border: Border.all(color: AppColors.grey),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedEvent?.id,
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
          onChanged(events.firstWhere((e) => e.id == newId));
        },
      ),
    );
  }
}

class _TaskNameField extends StatelessWidget {
  final TextEditingController controller;

  const _TaskNameField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Task Name',
        labelStyle: AppStyles.menuLabelStyle.copyWith(
          fontSize: 14,
          color: AppColors.grey,
        ),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyles.smallBorderRadius),
          borderSide: BorderSide(color: AppColors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyles.smallBorderRadius),
          borderSide: BorderSide(color: AppColors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyles.smallBorderRadius),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
      maxLines: 1,
    );
  }
}

class _NoteField extends StatelessWidget {
  final TextEditingController controller;

  const _NoteField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Note',
        labelStyle: AppStyles.menuLabelStyle.copyWith(
          fontSize: 14,
          color: AppColors.grey,
        ),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyles.smallBorderRadius),
          borderSide: BorderSide(color: AppColors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyles.smallBorderRadius),
          borderSide: BorderSide(color: AppColors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyles.smallBorderRadius),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
      maxLines: 1,
    );
  }
}

class _CategorySelector extends StatelessWidget {
  final CategoryModel? selectedCategory;
  final ValueChanged<CategoryModel?> onCategorySelected;

  const _CategorySelector({
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final selectedCategory = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SelectCategoryPage()),
        );
        if (selectedCategory != null && selectedCategory is CategoryModel) {
          onCategorySelected(selectedCategory);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppStyles.smallPadding,
          vertical: AppStyles.smallPadding - 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppStyles.smallBorderRadius),
          border: Border.all(color: AppColors.grey),
        ),
        child: Row(
          children: [
            if (selectedCategory != null)
              _CategoryDisplay(category: selectedCategory!)
            else
              const _CategoryPlaceholder(),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.grey,
              size: AppStyles.smallIconSize,
            ),
          ],
        ),
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  final DateTime? selectedDate;
  final VoidCallback onDateSelected;

  const _DateSelector({
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDateSelected,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppStyles.smallPadding,
          vertical: AppStyles.smallPadding + 5,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppStyles.smallBorderRadius),
          border: Border.all(color: AppColors.grey),
        ),
        child: Row(
          children: [
            Text('Date', style: AppStyles.subtitleStyle.copyWith(fontSize: 14)),
            const SizedBox(width: 12),
            Text(
              selectedDate != null
                  ? "${selectedDate!.month}/${selectedDate!.day}/${selectedDate!.year.toString().substring(2)}"
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
    );
  }
}
