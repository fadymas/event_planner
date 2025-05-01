import 'package:flutter/material.dart';
import '../shared/styles/colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.home_outlined, color: AppColors.text),
            SizedBox(width: 8),
            Text(
              'Home',
              style: TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: AppColors.text),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        color: AppColors.background,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCountdownTimer(),
                _buildMenuGrid(),
                _buildChecklistSection(),
                _buildBudgetSection(),
                _buildRateAppSection(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildTimeUnit(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.white, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildTimeSeparator() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        '.',
        style: TextStyle(
          color: AppColors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCountdownTimer() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTimeUnit('01', 'Days'),
                _buildTimeSeparator(),
                _buildTimeUnit('08', 'Hours'),
                _buildTimeSeparator(),
                _buildTimeUnit('22', 'Mins'),
                _buildTimeSeparator(),
                _buildTimeUnit('12', 'Secs'),
              ],
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.2),
              child: const Icon(Icons.event, color: AppColors.primary),
            ),
            title: const Text(
              'Name is not defined',
              style: TextStyle(color: AppColors.text),
            ),
            subtitle: const Text(
              '4/30/25, Your event',
              style: TextStyle(color: AppColors.grey),
            ),
            trailing: const Icon(Icons.menu, color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuGrid() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: const [
                Icon(Icons.grid_view, size: 20, color: AppColors.text),
                SizedBox(width: 12),
                Text(
                  'MENU',
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.lightGrey),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMenuItem(Icons.checklist, 'Checklist', AppColors.primary),
                _buildMenuItem(Icons.event, 'Events', AppColors.primary),
                _buildMenuItem(Icons.attach_money, 'Budget', AppColors.primary),
                _buildMenuItem(
                  Icons.people_outline,
                  'Helpers',
                  AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Row(
                  children: [
                    Icon(Icons.checklist_rtl, size: 20, color: AppColors.text),
                    SizedBox(width: 8),
                    Text(
                      'CHECKLIST',
                      style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Summary >',
                  style: TextStyle(color: AppColors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.lightGrey),
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Image.asset('images/checklist.png', height: 75),
                const SizedBox(height: 16),
                const Text(
                  'There are no uncompleted tasks',
                  style: TextStyle(color: AppColors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 100,
                    backgroundColor: AppColors.lightGrey,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                    minHeight: 8,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        '0% completed',
                        style: TextStyle(color: AppColors.grey, fontSize: 12),
                      ),
                      Text(
                        '0 out of 0',
                        style: TextStyle(color: AppColors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildBudgetSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 20,
                      color: AppColors.text,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'BUDGET',
                      style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Balance >',
                  style: TextStyle(color: AppColors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.lightGrey),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildBudgetRow('Budget', 'Not defined'),
                _buildBudgetRow('Paid', '\$0'),
                _buildBudgetRow('Pending', '\$0'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.text, fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              color: value == 'Not defined' ? AppColors.grey : AppColors.text,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateAppSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.announcement_outlined,
                  size: 20,
                  color: AppColors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Please take a moment to rate this app or share your feedback with us',
                    style: TextStyle(color: AppColors.grey, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'RATE THIS APP',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.checklist),
          label: 'Checklist',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Guests'),
        BottomNavigationBarItem(
          icon: Icon(Icons.attach_money),
          label: 'Budget',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
      ],
      currentIndex: 0,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.grey,
    );
  }
}
