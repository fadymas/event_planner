import 'package:flutter/material.dart';
import '../shared/styles/colors.dart';
import '../shared/styles/styles.dart';

class SelectCategoryPage extends StatefulWidget {
  @override
  _SelectCategoryPageState createState() => _SelectCategoryPageState();
}

class _SelectCategoryPageState extends State<SelectCategoryPage> {
  final List<Map<String, dynamic>> categories = [
    {"name": "Unassigned category", "icon": Icons.scatter_plot},
    {"name": "Attire & Accessories", "icon": Icons.checkroom},
    {"name": "Health & Beauty", "icon": Icons.spa},
    {"name": "Music & Show", "icon": Icons.music_note},
    {"name": "Flowers & Decor", "icon": Icons.local_florist},
    {"name": "Photo & Video", "icon": Icons.photo_camera},
    {"name": "Accessories", "icon": Icons.emoji_events},
    {"name": "Reception", "icon": Icons.room_service},
    {"name": "Transportation", "icon": Icons.directions_car},
    {"name": "Accommodation", "icon": Icons.home},
  ];

  int? selectedIndex = 1; // Default to "Attire & Accessories"

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.text),
        title: Text(
          'Category',
          style: AppStyles.titleStyle.copyWith(fontSize: 22),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          vertical: AppStyles.smallPadding,
          horizontal: 3,
        ),
        children: [
          for (int index = 0; index < categories.length; index++) ...[
            GestureDetector(
              onTap: () {
                Navigator.pop(context, [
                  categories[index]["name"],
                  categories[index]["icon"],
                ]);
              },
              child: Container(
                margin: EdgeInsets.only(bottom: AppStyles.smallPadding),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppStyles.borderRadius),
                  border:
                      selectedIndex == index
                          ? Border.all(color: AppColors.primary, width: 1.5)
                          : null,
                ),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      categories[index]["icon"],
                      color: AppColors.primaryDark,
                      size: AppStyles.iconSize,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        categories[index]["name"],
                        style: AppStyles.menuLabelStyle.copyWith(fontSize: 16),
                      ),
                    ),
                    if (selectedIndex == index)
                      Icon(
                        Icons.check,
                        color: AppColors.primary,
                        size: AppStyles.iconSize - 2,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
