import 'package:flutter/material.dart';
import '../styles/colors.dart';
import '../styles/styles.dart';

Widget scrollSelectorRow({
  required List<String> items,
  required int selectedIndex,
  required ValueChanged<int> onSelected,
  double? horizontalPadding,
  double? verticalPadding,
}) {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: List.generate(items.length, (index) {
        final selected = selectedIndex == index;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding ?? 2.0),
          child: GestureDetector(
            onTap: () => onSelected(index),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: verticalPadding ?? 6,
              ),
              decoration: BoxDecoration(
                gradient:
                    selected
                        ? const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                        )
                        : null,
                color: selected ? null : AppColors.white,
                borderRadius: BorderRadius.circular(
                  AppStyles.smallBorderRadius - 2,
                ),
                border: selected ? null : Border.all(color: AppColors.grey),
              ),
              child: Text(
                items[index],
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
  );
}
