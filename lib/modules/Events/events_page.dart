import '../../exports.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../shared/components/event_qr_dialog.dart';

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
    return StreamBuilder<List<EventModel>>(
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
                event: event,
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
    required EventModel event,
    required String title,
    required String subtitle,
    required String date,
    required IconData icon,
    required Color iconBg,
  }) {
    return Dismissible(
      key: Key(title),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(AppStyles.borderRadius - 4),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) async {
        try {
          // Find the event document by name
          final querySnapshot =
              await FirebaseFirestore.instance
                  .collection('events')
                  .where('name', isEqualTo: title)
                  .get();

          if (querySnapshot.docs.isNotEmpty) {
            // Delete the event
            await querySnapshot.docs.first.reference.delete();

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Event deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error deleting event: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppStyles.smallPadding),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppStyles.borderRadius - 4),
          boxShadow: [BoxShadow(color: AppColors.grey, blurRadius: 8)],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 2,
          ),
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
          title: Text(
            title,
            style: AppStyles.titleStyle.copyWith(fontSize: 13),
          ),
          subtitle: Text(
            subtitle,
            style: AppStyles.subtitleStyle.copyWith(fontSize: 11),
          ),
          trailing: Text(
            date,
            style: AppStyles.subtitleStyle.copyWith(fontSize: 11),
          ),
          onTap: () {
            event.isOwner
                ? showDialog(
                  context: context,
                  builder:
                      (context) => EventQRDialog(
                        qrCodeBase64: event.qrCode,
                        eventName: event.name,
                      ),
                )
                : null;
          },
        ),
      ),
    );
  }
}
