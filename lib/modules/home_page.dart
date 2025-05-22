import '../exports.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? _timer;
  EventModel? _upcomingEvent;
  Duration _remainingTime = Duration.zero;
  List<ChecklistModel> _checklistItems = [];
  List<BudgetModel> _budgetItems = [];
  double _totalBudget = 0;
  double _totalPaid = 0;

  @override
  void initState() {
    super.initState();
    _loadUpcomingEvent();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    // Update immediately
    _updateRemainingTime();

    // Update every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateRemainingTime();
    });
  }

  Future<void> _loadUpcomingEvent() async {
    try {
      final now = DateTime.now();
      final events =
          await FirebaseFirestore.instance.collection('events').get();

      if (events.docs.isNotEmpty) {
        final upcomingEvents =
            events.docs
                .map((doc) => EventModel.fromFirestore(doc.data(), doc.id))
                .where((event) {
                  final eventDate = DateTime.parse(event.date);
                  final timeParts = event.time.split(':');
                  int hour = int.parse(timeParts[0]);
                  final minute = int.parse(timeParts[1].split(' ')[0]);

                  if (event.time.toLowerCase().contains('pm') && hour != 12) {
                    hour += 12;
                  } else if (event.time.toLowerCase().contains('am') &&
                      hour == 12) {
                    hour = 0;
                  }

                  final eventDateTime = DateTime(
                    eventDate.year,
                    eventDate.month,
                    eventDate.day,
                    hour,
                    minute,
                  );
                  return eventDateTime.isAfter(now);
                })
                .toList()
              ..sort((a, b) {
                final aDate = DateTime.parse(a.date);
                final bDate = DateTime.parse(b.date);
                final aTimeParts = a.time.split(':');
                final bTimeParts = b.time.split(':');

                int aHour = int.parse(aTimeParts[0]);
                int bHour = int.parse(bTimeParts[0]);
                int aMinute = int.parse(aTimeParts[1].split(' ')[0]);
                int bMinute = int.parse(bTimeParts[1].split(' ')[0]);

                if (a.time.toLowerCase().contains('pm') && aHour != 12)
                  aHour += 12;
                if (b.time.toLowerCase().contains('pm') && bHour != 12)
                  bHour += 12;
                if (a.time.toLowerCase().contains('am') && aHour == 12)
                  aHour = 0;
                if (b.time.toLowerCase().contains('am') && bHour == 12)
                  bHour = 0;

                final aDateTime = DateTime(
                  aDate.year,
                  aDate.month,
                  aDate.day,
                  aHour,
                  aMinute,
                );
                final bDateTime = DateTime(
                  bDate.year,
                  bDate.month,
                  bDate.day,
                  bHour,
                  bMinute,
                );

                return aDateTime.compareTo(bDateTime);
              });

        if (upcomingEvents.isNotEmpty) {
          setState(() {
            _upcomingEvent = upcomingEvents.first;
          });
          await _loadEventDetails();
        }
      }
    } catch (e) {
      print('Error loading upcoming event: $e');
    }
  }

  Future<void> _loadEventDetails() async {
    if (_upcomingEvent == null) return;

    try {
      // Create event reference
      final eventRef = FirebaseFirestore.instance
          .collection('events')
          .doc(_upcomingEvent!.id);

      // Only load checklist and budget items if the event is owned by the user
      if (_upcomingEvent!.isOwner) {
        // Load checklist items
        final checklistSnapshot =
            await FirebaseFirestore.instance
                .collection('checklists')
                .where('eventId', isEqualTo: eventRef)
                .get();

        setState(() {
          _checklistItems =
              checklistSnapshot.docs
                  .map(
                    (doc) => ChecklistModel.fromFirestore(doc.data(), doc.id),
                  )
                  .toList();
        });

        // Load budget items
        final budgetSnapshot =
            await FirebaseFirestore.instance
                .collection('budgets')
                .where('eventId', isEqualTo: eventRef)
                .get();

        final budgetItems =
            budgetSnapshot.docs
                .map((doc) => BudgetModel.fromFirestore(doc.data(), doc.id))
                .toList();

        setState(() {
          _budgetItems = budgetItems;
          _totalPaid = budgetItems.fold(
            0,
            (sum, item) => sum + (item.Paid ?? 0),
          );
          _totalBudget = (_upcomingEvent?.budget ?? 0) + _totalPaid;
        });
      } else {
        // Clear checklist and budget items for non-owned events
        setState(() {
          _checklistItems = [];
          _budgetItems = [];
          _totalPaid = 0;
          _totalBudget = 0;
        });
      }
    } catch (e) {
      print('Error loading event details: $e');
    }
  }

  void _updateRemainingTime() {
    if (_upcomingEvent == null) return;

    setState(() {
      final eventDate = DateTime.parse(_upcomingEvent!.date);
      final timeParts = _upcomingEvent!.time.split(':');
      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1].split(' ')[0]);

      if (_upcomingEvent!.time.toLowerCase().contains('pm') && hour != 12) {
        hour += 12;
      } else if (_upcomingEvent!.time.toLowerCase().contains('am') &&
          hour == 12) {
        hour = 0;
      }

      final eventDateTime = DateTime(
        eventDate.year,
        eventDate.month,
        eventDate.day,
        hour,
        minute,
      );

      final now = DateTime.now();
      if (now.isBefore(eventDateTime)) {
        _remainingTime = eventDateTime.difference(now);
      } else {
        _remainingTime = Duration.zero;
      }
    });
  }

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
    if (_upcomingEvent == null) {
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
              child: const Center(
                child: Text(
                  'No upcoming events',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final days = _remainingTime.inDays;
    final hours = _remainingTime.inHours.remainder(24);
    final minutes = _remainingTime.inMinutes.remainder(60);
    final seconds = _remainingTime.inSeconds.remainder(60);

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
                _buildTimeUnit(days.toString().padLeft(2, '0'), 'Days'),
                _buildTimeSeparator(),
                _buildTimeUnit(hours.toString().padLeft(2, '0'), 'Hours'),
                _buildTimeSeparator(),
                _buildTimeUnit(minutes.toString().padLeft(2, '0'), 'Mins'),
                _buildTimeSeparator(),
                _buildTimeUnit(seconds.toString().padLeft(2, '0'), 'Secs'),
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
              _upcomingEvent?.name ?? 'No event',
              style: AppStyles.titleStyle.copyWith(fontSize: 13),
            ),
            subtitle: Text(
              _upcomingEvent?.formattedDate ?? '',
              style: AppStyles.subtitleStyle.copyWith(fontSize: 11),
            ),
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
    if (_upcomingEvent == null) {
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
                    'No event selected',
                    style: AppStyles.subtitleStyle.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final completedTasks =
        _checklistItems.where((task) => task.isCompleted).length;
    final totalTasks = _checklistItems.length;
    final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppStyles.smallPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppStyles.borderRadius - 4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          sectionHeader(icon: Icons.checklist_rtl, title: 'CHECKLIST'),
          const Divider(height: 1, color: AppColors.grey),
          if (_checklistItems.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Image.asset('images/checklist.png', height: 55),
                  const SizedBox(height: AppStyles.smallPadding),
                  Text(
                    'There are no tasks for this event',
                    style: AppStyles.subtitleStyle.copyWith(fontSize: 11),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount:
                  _checklistItems.length > 3 ? 3 : _checklistItems.length,
              itemBuilder: (context, index) {
                final task = _checklistItems[index];
                return ListTile(
                  trailing: Icon(
                    task.isCompleted
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color:
                        task.isCompleted ? AppColors.primary : AppColors.grey,
                  ),
                  title: Text(
                    task.taskName,
                    style: AppStyles.titleStyle.copyWith(fontSize: 13),
                  ),
                  subtitle: Text(
                    task.formattedDate,
                    style: AppStyles.subtitleStyle.copyWith(fontSize: 11),
                  ),
                );
              },
            ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppStyles.smallPadding,
            ),
            child: Column(
              children: [
                progressBar(value: progress),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(progress * 100).toInt()}% completed',
                        style: AppStyles.subtitleStyle.copyWith(fontSize: 10),
                      ),
                      Text(
                        '$completedTasks out of $totalTasks',
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
    if (_upcomingEvent == null) {
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
            onActionTap: () => _navigateToPage(3),
          ),
          const Divider(height: 1, color: AppColors.grey),
          Padding(
            padding: const EdgeInsets.all(AppStyles.smallPadding),
            child: Column(
              children: [
                _buildBudgetRow(
                  'Budget',
                  '\$${_totalBudget.toStringAsFixed(2)}',
                ),
                _buildBudgetRow('Paid', '\$${_totalPaid.toStringAsFixed(2)}'),
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
}
