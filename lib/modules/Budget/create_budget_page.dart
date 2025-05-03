import 'package:flutter/material.dart';
import '../category-page.dart';
import '../../shared/styles/colors.dart';
import '../../shared/styles/styles.dart';

class AddCostScreen extends StatefulWidget {
  const AddCostScreen({Key? key}) : super(key: key);

  @override
  _AddCostScreenState createState() => _AddCostScreenState();
}

class _AddCostScreenState extends State<AddCostScreen> {
  String? selectedCategory = 'Attire & Accessories';
  final TextEditingController nameController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.text),
        title: Text(
          'Add a new cost',
          style: AppStyles.titleStyle.copyWith(fontSize: 22),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppStyles.smallPadding - 3,
            vertical: AppStyles.smallPadding - 3,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                  final result = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(builder: (_) => SelectCategoryPage()),
                  );
                  if (result != null) {
                    setState(() {
                      selectedCategory = result;
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
                      Icon(
                        Icons.checkroom,
                        color: AppColors.primaryDark,
                        size: AppStyles.iconSize - 2,
                      ),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Category',
                            style: AppStyles.subtitleStyle.copyWith(
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            selectedCategory ?? '',
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
              SizedBox(height: AppStyles.defaultPadding - 8),
              Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    AppStyles.smallBorderRadius,
                  ),
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppStyles.smallBorderRadius,
                      ),
                    ),
                  ),
                  child: Text(
                    'ADD',
                    style: AppStyles.titleStyle.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  onPressed: () {
                    // Handle save logic
                    print("Name: \\${nameController.text}");
                    print("Note: \\${noteController.text}");
                    print("Category: \\${selectedCategory}");
                    print("Amount: \\${amountController.text}");
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
