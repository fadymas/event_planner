import 'package:flutter/material.dart';
import '../../layout/entry_form_layout.dart';
import '../../shared/styles/colors.dart';
import '../../shared/styles/styles.dart';
import '../../modules/category-page.dart';

class ChecklistCreatePage extends StatefulWidget {
  const ChecklistCreatePage({Key? key}) : super(key: key);

  @override
  State<ChecklistCreatePage> createState() => _ChecklistCreatePageState();
}

class _ChecklistCreatePageState extends State<ChecklistCreatePage> {
  final _eventNameController = TextEditingController();
  final _noteController = TextEditingController();
  String? _selectedCategory;
  IconData? _selectedCategoryIcon;
  DateTime? _selectedDate;

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

  @override
  Widget build(BuildContext context) {
    return EntryFormLayout(
      title: 'Add a new task',
      fields: [
        TextField(
          controller: _eventNameController,
          decoration: InputDecoration(
            labelText: 'Name',
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
        ),
        SizedBox(height: AppStyles.smallPadding),
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
        ),
        SizedBox(height: AppStyles.smallPadding),
        GestureDetector(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SelectCategoryPage()),
            );
            if (result != null && result is List && result.length == 2) {
              setState(() {
                _selectedCategory = result[0] as String;
                _selectedCategoryIcon = result[1] as IconData;
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
              borderRadius: BorderRadius.circular(AppStyles.smallBorderRadius),
              border: Border.all(color: AppColors.grey),
            ),
            child: Row(
              children: [
                Icon(
                  _selectedCategoryIcon ?? Icons.widgets_outlined,
                  color: AppColors.primaryDark,
                  size: AppStyles.iconSize - 2,
                ),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category',
                      style: AppStyles.subtitleStyle.copyWith(fontSize: 11),
                    ),
                    Text(
                      _selectedCategory ?? '',
                      style: AppStyles.menuLabelStyle.copyWith(
                        fontSize: 14,
                        color: AppColors.text,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.grey,
                  size: AppStyles.smallIconSize,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: AppStyles.smallPadding),
        GestureDetector(
          onTap: _pickDate,
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
                Text(
                  'Date',
                  style: AppStyles.subtitleStyle.copyWith(fontSize: 14),
                ),
                SizedBox(width: 12),
                Text(
                  _selectedDate != null
                      ? "${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year.toString().substring(2)}"
                      : '',
                  style: AppStyles.menuLabelStyle.copyWith(fontSize: 14),
                ),
                Spacer(),
                Icon(
                  Icons.calendar_today,
                  color: AppColors.grey,
                  size: AppStyles.smallIconSize,
                ),
              ],
            ),
          ),
        ),
      ],
      buttonText: 'ADD',
      onSubmit: _submitForm,
    );
  }

  void _submitForm() {
    if (_eventNameController.text.isNotEmpty) {
      Navigator.pop(context, {
        'eventName': _eventNameController.text,
        'note': _noteController.text,
        'category': _selectedCategory ?? '',
        'categoryIcon': _selectedCategoryIcon,
        'date': _selectedDate?.toIso8601String().split('T').first ?? '',
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Event name is required')));
    }
  }
}
