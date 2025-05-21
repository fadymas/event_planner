import 'package:event_planner/modules/Budget/budget_page.dart';
import 'package:event_planner/modules/Budget/create_budget_page.dart';
import 'package:event_planner/modules/calendar_page.dart';
import 'package:event_planner/modules/checklist/view.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../shared/styles/colors.dart';
import '../modules/Events/events_page.dart';
import '../modules/home_page.dart';
import '../modules/Events/create_event_page.dart';
import '../shared/styles/styles.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({Key? key}) : super(key: key);

  @override
  State<MainScaffold> createState() => MainScaffoldState();
}

class MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;
  MobileScannerController controller = MobileScannerController();
  bool isScanning = false;

  void setSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void onDetect(BarcodeCapture capture) {
    final barcode = capture.barcodes.first;
    print('QR Code scanned: \\${barcode.rawValue}');
    controller.stop();
    setState(() {
      isScanning = false;
    });
    Navigator.pop(context);
  }

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

  Future<void> showQRScanner() async {
    try {
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder:
            (context) => Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppStyles.borderRadius),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Scan QR Code',
                          style: AppStyles.titleStyle.copyWith(fontSize: 18),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            controller.stop();
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        MobileScanner(
                          controller: controller,
                          onDetect: onDetect,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      );
    } catch (e) {
      print('Error showing QR scanner: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error initializing camera: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Row(
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
            ),
            if (_selectedIndex == 2)
              IconButton(
                onPressed: showQRScanner,
                icon: const Icon(Icons.qr_code_scanner),
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
        onTap: setSelectedIndex,
      ),
    );
  }
}
