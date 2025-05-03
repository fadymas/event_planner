import 'package:event_planner/modules/Budget/budget_page.dart';
import 'package:event_planner/modules/Budget/create_budget_page.dart';
import 'package:event_planner/modules/calendar_page.dart';
import 'package:event_planner/modules/checklist/view.dart';
import 'package:flutter/material.dart';
import '../shared/styles/colors.dart';
import '../modules/Events/events_page.dart';
import '../modules/home_page.dart';
import '../modules/Events/create_event_page.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({Key? key}) : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;
  final GlobalKey<ChecklistPageState> _checklistKey =
      GlobalKey<ChecklistPageState>();

  List<Widget> get _pages => [
    const HomePage(),
    ChecklistPage(key: _checklistKey),  
    const EventsPage(),
    const BudgetPage(), 
    const Calendar(),
  ];

  String get _title {
    switch (_selectedIndex) {
      case 0:
        return 'Home';
      case 1:
        return 'Checklist';
      case 2:
        return 'Events';
      case 3:
        return 'Budget';
      case 4:
        return 'Calendar';
      default:
        return '';
    }
  }

  IconData get _titleIcon {
    switch (_selectedIndex) {
      case 0:
        return Icons.home_outlined;
      case 1:
        return Icons.task_alt;
      case 2:
        return Icons.event;
      case 3:
        return Icons.account_balance_wallet_outlined;
      case 4:
        return Icons.access_time;
      default:
        return Icons.home_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Icon(_titleIcon, color: AppColors.text),
            const SizedBox(width: 8),
            Text(
              _title,
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.white,
      ),
      body: _pages[_selectedIndex],
      backgroundColor: AppColors.background,
      floatingActionButton:
          _selectedIndex >= 1 && _selectedIndex <= 3
              ? FloatingActionButton(
                onPressed: () {
                  switch (_selectedIndex) {
                    case 1: 
                      _checklistKey.currentState?.navigateToCreatePage();
                      break;
                    case 2: 
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const CreateEventPage(),
                        ),
                      );
                      break;
                    case 3: 
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AddCostScreen(),
                        ),
                      );
                  }
                },
                backgroundColor: AppColors.primary,
                shape: const CircleBorder(),
                child: Icon(
                  _selectedIndex == 1
                      ? Icons.add_task
                      : _selectedIndex == 2
                      ? Icons.add
                      : Icons.add_chart,
                  color: AppColors.white,
                ),
              )
              : null,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt),
            label: 'Checklist',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Budget',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time_filled),
            label: 'Calendar',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
