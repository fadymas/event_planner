import 'package:event_planner/shared/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:event_planner/modules/checklist/create.dart';
import 'package:event_planner/modules/checklist/edit.dart';
import '../../shared/components/components.dart';
import '../../models/ListItems.dart';
import '../../models/Categories.dart';
import '../../shared/network/remote/firebase_operations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../checklist/task_details.dart';

class ChecklistPage extends StatefulWidget {
  const ChecklistPage({Key? key}) : super(key: key);

  @override
  State<ChecklistPage> createState() => ChecklistPageState();
}

class ChecklistPageState extends State<ChecklistPage> {
  int year = DateTime.now().year;
  late final List<String> months;
  int selectedMonthIndex = 0;

  @override
  void initState() {
    super.initState();
    months = List.generate(12, (index) {
      final monthNames = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      return '${monthNames[index]} $year';
    });
  }

  void navigateToCreatePage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChecklistCreatePage()),
    );

    if (result != null && result is Map) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final year = now.year;
    final selectedMonth = selectedMonthIndex + 1;

    final DateTime startDate = DateTime(year, selectedMonth, 1);
    final DateTime endDate = DateTime(year, selectedMonth + 1, 0);

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
          child: StreamBuilder<List<ChecklistModel>>(
            stream: getData<ChecklistModel>(
              'checklists',
              ChecklistModel.fromFirestore,
              queryBuilder:
                  (query) => query
                      .where(
                        'date',
                        isGreaterThanOrEqualTo:
                            startDate.toIso8601String().split('T').first,
                      )
                      .where(
                        'date',
                        isLessThanOrEqualTo:
                            endDate.toIso8601String().split('T').first,
                      )
                      .orderBy('date', descending: false),
            ),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final checklistItems = snapshot.data ?? [];

              if (checklistItems.isEmpty) {
                return const Center(
                  child: Text('No checklist items found for this month'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: checklistItems.length,
                cacheExtent: 1000,
                itemBuilder: (context, index) {
                  final item = checklistItems[index];
                  return _ChecklistItem(
                    item: item,
                    onDelete: () {
                      deleteDocument('checklists', item.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${item.taskName} dismissed')),
                      );
                    },
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  TaskDetailsPage(checklistItemId: item.id),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  final ChecklistModel item;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _ChecklistItem({
    required this.item,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: AppColors.white,
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CheckboxWidget(item: item),
                const SizedBox(width: 4),
                Expanded(
                  child: FutureBuilder<DocumentSnapshot>(
                    future: item.category.get(),
                    builder: (context, categorySnapshot) {
                      if (!categorySnapshot.hasData) {
                        return const SizedBox.shrink();
                      }

                      final categoryData =
                          categorySnapshot.data!.data() as Map<String, dynamic>;
                      final category = CategoryModel.fromFirestore(
                        categoryData,
                        categorySnapshot.data!.id,
                      );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.taskName,
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (category.icon.isNotEmpty)
                                Icon(
                                  IconData(
                                    int.parse(category.icon),
                                    fontFamily: 'MaterialIcons',
                                  ),
                                  size: 18,
                                  color: Colors.grey,
                                ),
                              const SizedBox(width: 4),
                              Text(
                                category.name,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                item.formattedDate,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckboxWidget extends StatelessWidget {
  final ChecklistModel item;

  const _CheckboxWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      activeColor: AppColors.primaryDark,
      value: item.isCompleted,
      onChanged: (val) {
        updateDocument("checklists", item.id, {"isCompleted": val});
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    );
  }
}
