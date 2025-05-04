import 'package:flutter/material.dart';
import '../../shared/styles/colors.dart';
import '../../shared/styles/styles.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppStyles.smallPadding),
      children: [
        _buildEventCard(
          context,
          title: 'Name is not defined',
          subtitle: 'Your event',
          date: '4/30/25',
          icon: Icons.mic,
          iconBg: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildEventCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String date,
    required IconData icon,
    required Color iconBg,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppStyles.smallPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppStyles.borderRadius - 4),
        boxShadow: [BoxShadow(color: AppColors.grey, blurRadius: 8)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        leading: ClipOval(
          child: Container(
            color: iconBg,
            width: AppStyles.iconSize * 2,
            height: AppStyles.iconSize * 2,
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: AppColors.white,
              size: AppStyles.largeIconSize,
            ),
          ),
        ),
        title: Text(title, style: AppStyles.titleStyle.copyWith(fontSize: 13)),
        subtitle: Text(
          subtitle,
          style: AppStyles.subtitleStyle.copyWith(fontSize: 11),
        ),
        trailing: Text(
          date,
          style: AppStyles.subtitleStyle.copyWith(fontSize: 11),
        ),
        onTap: () {},
      ),
    );
  }
}
