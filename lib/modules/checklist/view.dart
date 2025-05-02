import 'package:flutter/material.dart';
import 'package:event_planner/modules/checklist/create.dart';

class ChecklistPage extends StatefulWidget {
  const ChecklistPage({Key? key}) : super(key: key);

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  List<Map<String, String>> checklistItems = [];

  void _navigateToCreatePage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChecklistCreatePage()),
    );

    if (result != null && result is Map<String, String>) {
      setState(() {
        checklistItems.add(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: checklistItems.length,
      itemBuilder: (context, index) {
        final item = checklistItems[index];
        return ListTile(
          title: Text(item['eventName'] ?? ''),
          subtitle: Text(item['note'] ?? ''),
          trailing: Text(item['date'] ?? ''),
        );
      },
    );
  }
}
