import 'package:flutter/material.dart';
import '../../shared/styles/colors.dart';
import '../../shared/styles/styles.dart';
import '../../shared/components/components.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({Key? key}) : super(key: key);

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final List<String> _categories = [
    'Attire & Accessories',
    'Health & Beauty',
    'Music & Show',
    'Photo & Video',
    'Accessories',
    'Reception',
    'Transportation',
    'Accommodation',
    'Unassigned category',
  ];
  int _selectedCategory = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        scrollSelectorRow(
          items: _categories,
          selectedIndex: _selectedCategory,
          onSelected: (index) {
            setState(() {
              _selectedCategory = index;
            });
          },
        ),
        const SizedBox(height: 8),

        // Single hardcoded card
        Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppStyles.borderRadius - 4),
            boxShadow: [BoxShadow(color: AppColors.grey, blurRadius: 5)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hhdhh', style: AppStyles.titleStyle.copyWith(fontSize: 13)),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: 1, // paid / amount
                backgroundColor: AppColors.grey.withOpacity(0.15),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
                minHeight: 6,
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Paid: 0 \$',
                    style: AppStyles.subtitleStyle.copyWith(fontSize: 11),
                  ),
                  Text(
                    'Amount: 2000 \$',
                    style: AppStyles.subtitleStyle.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),

        // End single card
      ],
    );
  }
}
