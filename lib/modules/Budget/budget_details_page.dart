import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../layout/entry_form_layout.dart';
import '../../shared/styles/colors.dart';
import '../../shared/styles/styles.dart';
import '../category/category-page.dart';
import '../../models/Budgets.dart';
import '../../models/Events.dart';
import '../../models/Categories.dart';
import '../../shared/network/remote/firebase_operations.dart';
import '../../shared/components/components.dart';
import 'edit_budget_page.dart'; // Assuming standardCard and sectionHeader are here

class BudgetDetailsPage extends StatefulWidget {
  final BudgetModel budgetItem;

  const BudgetDetailsPage({Key? key, required this.budgetItem})
    : super(key: key);

  @override
  _BudgetDetailsPageState createState() => _BudgetDetailsPageState();
}

class _BudgetDetailsPageState extends State<BudgetDetailsPage> {
  CategoryModel? _selectedCategoryModel;
  EventModel? _selectedEvent;

  bool _isLoading = true;
  String _errorMessage = '';

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
        appBar: AppBar(title: const Text('Budget Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Budget Details')),
        body: Center(child: Text('Error: $_errorMessage')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.budgetItem.name),
        backgroundColor: AppColors.primary, // Assuming AppColors.primary exists
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
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
                  _buildDetailRow('Name', widget.budgetItem.name),
                  _buildDetailRow('Note', widget.budgetItem.note),
                  _buildCategoryRow('Category', _selectedCategoryModel),
                  _buildDetailRow('Event', _selectedEvent?.name ?? 'N/A'),
                ],
              ),
            ),
            standardCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sectionHeader(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'BALANCE',
                  ),
                  const Divider(),
                  _buildDetailRow(
                    'Amount',
                    widget.budgetItem.amount.toStringAsFixed(2),
                  ),
                  _buildDetailRow(
                    'Paid',
                    widget.budgetItem.Paid.toStringAsFixed(2),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Remaining',
                            style: AppStyles.subtitleStyle.copyWith(
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            '${(widget.budgetItem.amount - widget.budgetItem.Paid).toStringAsFixed(2)} \$',
                            style: AppStyles.menuLabelStyle.copyWith(
                              fontSize: 14,
                              color:
                                  (widget.budgetItem.amount -
                                              widget.budgetItem.Paid) >=
                                          0
                                      ? AppColors.primary
                                      : AppColors
                                          .primaryDark, // Assuming AppColors.green and AppColors.red exist
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () {
          // Navigate to Edit Budget Page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => BudgetEditPage(
                    budgetItem: widget.budgetItem,
                  ), // Assuming BudgetEditPage exists
            ),
          );
        },
        backgroundColor: AppColors.primary, // Assuming AppColors.primary exists
        child: const Icon(Icons.edit),
      ),
      backgroundColor: AppColors.white, // Assuming AppColors.white exists
    );
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
                  categoryName.isNotEmpty ? categoryName : 'No Category',
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
  void dispose() {
    // Dispose controllers if they were used, but we removed them
    super.dispose();
  }
}
