import 'package:flutter/material.dart';
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
        standardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hhdhh', style: AppStyles.titleStyle.copyWith(fontSize: 13)),
              const SizedBox(height: 4),
              progressBar(value: 1),
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
      ],
    );
  }
}
