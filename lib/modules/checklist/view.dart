import 'package:event_planner/shared/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:event_planner/modules/checklist/create.dart';
import '../../shared/components/components.dart';

class ChecklistPage extends StatefulWidget {
  const ChecklistPage({Key? key}) : super(key: key);

  @override
  State<ChecklistPage> createState() => ChecklistPageState();
}

class ChecklistPageState extends State<ChecklistPage> {
  List<Map<dynamic, dynamic>> checklistItems = [];
  final List<String> months = [
    'January 2025',
    'February 2025',
    'March 2025',
    'April 2025',
    'May 2025',
    'June 2025',
    'July 2025',
    'August 2025',
    'September 2025',
    'October 2025',
    'November 2025',
    'December 2025',
  ];
  int selectedMonthIndex = 0;

  void navigateToCreatePage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChecklistCreatePage()),
    );

    if (result != null && result is Map) {
      setState(() {
        final item = Map<String, dynamic>.from(result);
        item['checkbox_value'] = false;
        checklistItems.add(item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const SizedBox(height: 4),
        scrollSelectorRow(
          items: months,
          selectedIndex: selectedMonthIndex,
          onSelected: (index) {
            setState(() {
              selectedMonthIndex = index;
            });
          },
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(4),
            itemCount: checklistItems.length,
            itemBuilder: (context, index) {
              final item = checklistItems[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: AppColors.white,
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 10,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        activeColor: AppColors.primaryDark,
                        value: item['checkbox_value'] ?? false,
                        onChanged: (val) {
                          setState(() {
                            item['checkbox_value'] = val ?? false;
                          });
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['eventName'] ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  (item['categoryIcon']),
                                  size: 18,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item['category'] ?? '',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  item['date'] ?? '',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
