import 'package:flutter/material.dart';
import '../layout/main_layout.dart';
import '../shared/styles/colors.dart';
import '../shared/styles/styles.dart';
import '../shared/components/components.dart';
import 'Events/events_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _navigateToPage(int index) {
    final mainScaffoldState =
        context.findAncestorStateOfType<MainScaffoldState>();
    if (mainScaffoldState != null) {
      mainScaffoldState.setState(() {
        mainScaffoldState.setSelectedIndex(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.smallPadding),
        child: Column(
          children: [
            _buildCountdownTimer(),
            _buildMenuGrid(),
            _buildChecklistSection(),
            _buildBudgetSection(),
            _buildRateAppSection(),
          ],
        ),
      ),
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
      padding: EdgeInsets.symmetric(horizontal: AppStyles.smallPadding),
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
      margin: const EdgeInsets.only(bottom: AppStyles.smallPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppStyles.borderRadius - 4),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppStyles.borderRadius - 4),
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 0,
            ),
            leading: ClipOval(
              child: Container(
                width: 36,
                height: 36,
                color: AppColors.primary,
                child: const Icon(
                  Icons.event,
                  color: AppColors.white,
                  size: 18,
                ),
              ),
            ),
            title: Text(
              'Name is not defined',
              style: AppStyles.titleStyle.copyWith(fontSize: 13),
            ),
            subtitle: Text(
              '4/30/25, Your event',
              style: AppStyles.subtitleStyle.copyWith(fontSize: 11),
            ),
            trailing: const Icon(Icons.menu, color: AppColors.grey, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppStyles.smallPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppStyles.borderRadius - 4),
      ),
      child: Column(
        children: [
          sectionHeader(icon: Icons.grid_view, title: 'MENU'),
          const Divider(height: 1, color: AppColors.grey),
          Padding(
            padding: const EdgeInsets.all(AppStyles.smallPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                menuItem(
                  icon: Icons.checklist,
                  label: 'Checklist',
                  onTap: () => _navigateToPage(1),
                ),
                menuItem(
                  icon: Icons.event,
                  label: 'Events',
                  onTap: () => _navigateToPage(2),
                ),
                menuItem(
                  icon: Icons.attach_money,
                  label: 'Budget',
                  onTap: () => _navigateToPage(3),
                ),
                menuItem(
                  icon: Icons.calendar_month,
                  label: 'Calendar',
                  onTap: () => _navigateToPage(4),
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
      margin: const EdgeInsets.only(bottom: AppStyles.smallPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppStyles.borderRadius - 4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          sectionHeader(
            icon: Icons.checklist_rtl,
            title: 'CHECKLIST',
            onActionTap: () {},
          ),
          const Divider(height: 1, color: AppColors.grey),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Image.asset('images/checklist.png', height: 55),
                const SizedBox(height: AppStyles.smallPadding),
                Text(
                  'There are no uncompleted tasks',
                  style: AppStyles.subtitleStyle.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppStyles.smallPadding,
            ),
            child: Column(
              children: [
                progressBar(value: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '0% completed',
                        style: AppStyles.subtitleStyle.copyWith(fontSize: 10),
                      ),
                      Text(
                        '0 out of 0',
                        style: AppStyles.subtitleStyle.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppStyles.smallPadding - 2),
        ],
      ),
    );
  }

  Widget _buildBudgetSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppStyles.smallPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppStyles.borderRadius - 4),
      ),
      child: Column(
        children: [
          sectionHeader(
            icon: Icons.account_balance_wallet_outlined,
            title: 'BUDGET',
            onActionTap: () {},
          ),
          const Divider(height: 1, color: AppColors.grey),
          Padding(
            padding: const EdgeInsets.all(AppStyles.smallPadding),
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
      padding: const EdgeInsets.symmetric(vertical: AppStyles.smallPadding - 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppStyles.titleStyle.copyWith(fontSize: 11)),
          Text(
            value,
            style: TextStyle(
              color: value == 'Not defined' ? AppColors.grey : AppColors.text,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateAppSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppStyles.smallPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppStyles.borderRadius - 4),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppStyles.smallPadding),
            child: Row(
              children: [
                Icon(
                  Icons.announcement_outlined,
                  size: AppStyles.smallIconSize - 2,
                  color: AppColors.grey,
                ),
                const SizedBox(width: AppStyles.smallPadding - 2),
                Expanded(
                  child: Text(
                    'Please take a moment to rate this app or share your feedback with us',
                    style: AppStyles.subtitleStyle.copyWith(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppStyles.smallPadding,
              vertical: AppStyles.smallPadding - 2,
            ),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: AppStyles.smallPadding,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppStyles.smallBorderRadius - 2,
                  ),
                ),
              ),
              child: const Text(
                'RATE THIS APP',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: AppStyles.smallPadding - 2),
        ],
      ),
    );
  }
}
