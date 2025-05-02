import 'package:flutter/material.dart';
import '../../shared/styles/colors.dart';
import '../../shared/styles/styles.dart';

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
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_categories.length, (index) {
              final selected = _selectedCategory == index;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient:
                          selected
                              ? const LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primaryDark,
                                ],
                              )
                              : null,
                      color: selected ? null : AppColors.white,
                      borderRadius: BorderRadius.circular(
                        AppStyles.smallBorderRadius - 2,
                      ),
                      border:
                          selected ? null : Border.all(color: AppColors.grey),
                    ),
                    child: Text(
                      _categories[index],
                      style: TextStyle(
                        color: selected ? AppColors.white : AppColors.text,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
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
