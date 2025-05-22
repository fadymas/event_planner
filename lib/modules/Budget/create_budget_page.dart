import '../../exports.dart';

class AddCostScreen extends StatefulWidget {
  const AddCostScreen({Key? key}) : super(key: key);

  @override
  _AddCostScreenState createState() => _AddCostScreenState();
}

class _AddCostScreenState extends State<AddCostScreen> {
  CategoryModel? _selectedCategoryModel;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController paidController = TextEditingController();

  EventModel? _selectedEvent;
  List<EventModel> _events = [];

  @override
  void dispose() {
    nameController.dispose();
    noteController.dispose();
    amountController.dispose();
    paidController.dispose();
    super.dispose();
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

  Widget _buildEventDropdown() {
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
            _events.map((EventModel event) {
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
            _selectedEvent = _events.firstWhere((e) => e.id == newId);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<EventModel>>(
      stream: getData<EventModel>(
        'events',
        (data, id) => EventModel.fromFirestore(data, id),
        queryBuilder: (query) => query.where('isOwner', isEqualTo: true),
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error loading events: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        _events = snapshot.data ?? [];
        if (_events.isNotEmpty && _selectedEvent == null) {
          _selectedEvent = _events.first;
        }

        return EntryFormLayout(
          title: 'Add a new cost',
          fields: [
            _buildEventDropdown(),
            const SizedBox(height: AppStyles.smallPadding),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
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
            ),
            SizedBox(height: AppStyles.smallPadding),
            TextField(
              controller: noteController,
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
            ),
            SizedBox(height: AppStyles.smallPadding),
            GestureDetector(
              onTap: () async {
                final selectedCategory = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SelectCategoryPage()),
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
            SizedBox(height: AppStyles.smallPadding),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
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
            ),

            SizedBox(height: AppStyles.smallPadding),
            TextField(
              controller: paidController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Paid Amount',
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
            ),
          ],
          buttonText: 'ADD',
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

    final name = nameController.text.trim();
    final amountText = amountController.text.trim();
    final note = noteController.text.trim();
    final paidText = paidController.text.trim();

    if (name.isEmpty || amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and Amount are required')),
      );
      return;
    }

    double amount;
    try {
      amount = double.parse(amountText);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid amount entered')));
      return;
    }

    try {
      final eventDoc =
          await FirebaseFirestore.instance
              .collection('events')
              .doc(_selectedEvent!.id)
              .get();
      if (!eventDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selected event not found.')),
        );
        return;
      }

      final eventData = eventDoc.data() as Map<String, dynamic>;
      final currentBudget = (eventData['budget'] as num? ?? 0.0).toDouble();

      if (currentBudget <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedEvent!.name} has no budget left.'),
          ),
        );
        return;
      }

      if (amount > currentBudget) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Amount exceeds the remaining budget for ${_selectedEvent!.name}.',
            ),
          ),
        );
        return;
      }

      final budgetCollection = FirebaseFirestore.instance.collection('budgets');
      await budgetCollection.add({
        'name': name,
        'note': note,
        'amount': amount,
        'Paid': double.parse(paidText),
        'category': FirebaseFirestore.instance
            .collection('categories')
            .doc(_selectedCategoryModel!.id),
        'eventId': FirebaseFirestore.instance
            .collection('events')
            .doc(_selectedEvent!.id),
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      });

      final eventRef = FirebaseFirestore.instance
          .collection('events')
          .doc(_selectedEvent!.id);
      await eventRef.update({'budget': FieldValue.increment(-amount)});

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cost added successfully!')));

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error adding cost: $e')));
      print('Error adding cost: $e');
    }
  }
}
