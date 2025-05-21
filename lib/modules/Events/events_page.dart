import 'package:event_planner/models/Events.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../shared/network/remote/firebase_operations.dart';
import '../../shared/styles/colors.dart';
import '../../shared/styles/styles.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  State<EventsPage> createState() => EventsPageState();
}

class EventsPageState extends State<EventsPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  MobileScannerController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List>(
      stream: getData('events', EventModel.fromFirestore),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return ListView.builder(
            padding: const EdgeInsets.all(AppStyles.smallPadding),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final event = snapshot.data![index];
              return _buildEventCard(
                context,
                title: event.name,
                subtitle: event.subTitle,
                date: event.formattedDate,
                icon: Icons.mic,
                iconBg: AppColors.primary,
              );
            },
          );
        }

        return const Center(child: Text('No events found'));
      },
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
