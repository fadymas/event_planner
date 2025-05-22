import '../../exports.dart';

class BudgetEditPage extends StatefulWidget {
  final BudgetModel budgetItem;

  const BudgetEditPage({Key? key, required this.budgetItem}) : super(key: key);

  @override
  _BudgetEditPageState createState() => _BudgetEditPageState();
}

class _BudgetEditPageState extends State<BudgetEditPage> {
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();
  final _amountController = TextEditingController();
  final _paidController = TextEditingController();
  CategoryModel? _selectedCategoryModel;
  EventModel? _selectedEvent;

  bool _isLoading = true;
  String _errorMessage = '';
  double _initialAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchBudgetItemData();
  }

  Future<void> _fetchBudgetItemData() async {
    try {
      final eventSnapshot = await widget.budgetItem.eventId.get();
      final EventModel? event =
          eventSnapshot.exists
              ? EventModel.fromFirestore(
                eventSnapshot.data() as Map<String, dynamic>,
                eventSnapshot.id,
              )
              : null;

      final categorySnapshot = await widget.budgetItem.category.get();
      final CategoryModel? category =
          categorySnapshot.exists
              ? CategoryModel.fromFirestore(
                categorySnapshot.data() as Map<String, dynamic>,
                categorySnapshot.id,
              )
              : null;

      setState(() {
        _nameController.text = widget.budgetItem.name;
        _noteController.text = widget.budgetItem.note;
        _amountController.text = widget.budgetItem.amount.toString();
        _paidController.text = widget.budgetItem.Paid.toString();
        _initialAmount = widget.budgetItem.amount;
        _selectedEvent = event;
        _selectedCategoryModel = category;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load budget item: $e';
        _isLoading = false;
      });
      print('Error fetching budget item data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Budget')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Budget')),
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
          title: 'Edit Budget',
          fields: [
            TextField(
              controller: _nameController,
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
                    if (_selectedCategoryModel != null)
                      _buildCategoryDisplay()
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
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _amountController,
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
              maxLines: 1,
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _paidController,
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
              maxLines: 1,
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

  Widget _buildCategoryDisplay() {
    if (_selectedCategoryModel == null) {
      return const _CategoryPlaceholder();
    }

    IconData categoryIcon = Icons.category;
    try {
      if (_selectedCategoryModel!.icon.isNotEmpty) {
        int iconCode = int.parse(_selectedCategoryModel!.icon);
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

    final name = _nameController.text.trim();
    final amountText = _amountController.text.trim();
    final note = _noteController.text.trim();
    final paidText = _paidController.text.trim();

    if (name.isEmpty || amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and Amount are required')),
      );
      return;
    }

    double newAmount;
    try {
      newAmount = double.parse(amountText);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid amount entered')));
      return;
    }

    final double amountDifference = newAmount - _initialAmount;

    if (amountDifference > 0) {
      try {
        final eventDoc =
            await FirebaseFirestore.instance
                .collection('events')
                .doc(_selectedEvent!.id)
                .get();
        if (!eventDoc.exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Associated event not found during budget check.'),
            ),
          );
          return;
        }

        final eventData = eventDoc.data() as Map<String, dynamic>;
        final currentBudget = (eventData['budget'] as num? ?? 0.0).toDouble();

        if (amountDifference > currentBudget) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Increase exceeds the remaining budget for ${_selectedEvent!.name}.',
              ),
            ),
          );
          return;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking event budget: $e')),
        );
        print('Error checking event budget: $e');
        return;
      }
    }

    try {
      await updateDocument('budgets', widget.budgetItem.id, {
        'name': name,
        'note': note,
        'amount': newAmount,
        'Paid': double.parse(paidText),
        'category': FirebaseFirestore.instance
            .collection('categories')
            .doc(_selectedCategoryModel!.id),
        'updatedAt': DateTime.now(),
      });

      if (amountDifference != 0) {
        final eventRef = FirebaseFirestore.instance
            .collection('events')
            .doc(_selectedEvent!.id);
        await eventRef.update({
          'budget': FieldValue.increment(-amountDifference),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Budget item updated successfully!')),
      );

      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating budget item: $e')));
      print('Error updating budget item: $e');
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
                  'Are you sure you want to delete this budget item?',
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
        await deleteDocument('budgets', widget.budgetItem.id);

        final eventRef = FirebaseFirestore.instance
            .collection('events')
            .doc(_selectedEvent!.id);
        await eventRef.update({'budget': FieldValue.increment(_initialAmount)});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Budget item deleted successfully!')),
        );

        if (mounted) {
          Navigator.pop(context);
          Navigator.pop(context);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting budget item: $e')));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    _amountController.dispose();
    _paidController.dispose();
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
