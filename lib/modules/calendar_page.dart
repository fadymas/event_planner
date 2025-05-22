import '../exports.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timeline_tile/timeline_tile.dart';
class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime date = DateTime.now();
  List<EventModel> _events = [];
  List<ChecklistModel> _checklistItems = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _loadChecklistItems();
  }

  void _loadEvents() {
    getData<EventModel>('events', EventModel.fromFirestore).listen((events) {
      setState(() {
        _events = events;
      });
    });
  }

  void _loadChecklistItems() {
    getData<ChecklistModel>('checklists', ChecklistModel.fromFirestore).listen((
      items,
    ) {
      setState(() {
        _checklistItems = items;
      });
    });
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      date = selectedDay;
    });
  }

  List<EventModel> _getEventsForDay(DateTime day) {
    return _events.where((event) {
      final eventDate = DateTime.parse(event.date);
      return isSameDay(eventDate, day);
    }).toList();
  }

  List<ChecklistModel> _getChecklistItemsForDay(DateTime day) {
    return _checklistItems.where((item) {
      final itemDate = DateTime.parse(item.date);
      return isSameDay(itemDate, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dailyEvents = _getEventsForDay(date);
    final dailyChecklistItems = _getChecklistItemsForDay(date);

    // Sort events by time
    dailyEvents.sort((a, b) => a.time.compareTo(b.time));

    // Sort checklist items by date
    dailyChecklistItems.sort((a, b) => a.date.compareTo(b.date));

    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppStyles.defaultPadding,
              vertical: AppStyles.smallPadding,
            ),
            child: _buildCalendar(),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppStyles.defaultPadding,
              ),
              child: _buildTimeline(dailyEvents, dailyChecklistItems),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      focusedDay: date,
      locale: 'en_US',
      rowHeight: 43,
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: AppStyles.titleStyle.copyWith(fontSize: 16),
        leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.primary),
        rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.primary),
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        todayTextStyle: AppStyles.menuLabelStyle.copyWith(
          color: AppColors.primaryDark,
        ),
        selectedTextStyle: AppStyles.menuLabelStyle.copyWith(
          color: AppColors.white,
        ),
        defaultTextStyle: AppStyles.menuLabelStyle,
        weekendTextStyle: AppStyles.menuLabelStyle.copyWith(
          color: AppColors.primaryDark,
        ),
        outsideTextStyle: AppStyles.menuLabelStyle.copyWith(
          color: AppColors.grey,
        ),
        markerDecoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
      ),
      availableGestures: AvailableGestures.all,
      selectedDayPredicate: (day) => isSameDay(day, date),
      onDaySelected: onDaySelected,
      firstDay: DateTime(date.year, date.month - 3, 1),
      lastDay: DateTime(date.year, date.month + 3, 31),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          if (events.isEmpty) return null;

          final hasEvents = events.any((e) => e is EventModel);
          final hasChecklist = events.any((e) => e is ChecklistModel);

          if (hasEvents && hasChecklist) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 2),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            );
          } else if (hasEvents) {
            return Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            );
          } else if (hasChecklist) {
            return Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.grey,
                shape: BoxShape.circle,
              ),
            );
          }
          return null;
        },
      ),
      eventLoader: (day) {
        final events = _getEventsForDay(day);
        final checklistItems = _getChecklistItemsForDay(day);
        return [...events, ...checklistItems];
      },
    );
  }

  Widget _buildTimeline(
    List<EventModel> events,
    List<ChecklistModel> checklistItems,
  ) {
    if (events.isEmpty && checklistItems.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text("No events or tasks for this day"),
      );
    }

    return ListView(
      children: [
        if (events.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "Events",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          ...events.map((event) => _buildEventTile(event)).toList(),
        ],
        if (checklistItems.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "Tasks",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.grey,
              ),
            ),
          ),
          ...checklistItems.map((item) => _buildChecklistTile(item)).toList(),
        ],
      ],
    );
  }

  Widget _buildEventTile(EventModel event) {
    return TimelineTile(
      alignment: TimelineAlign.center,
      beforeLineStyle: const LineStyle(color: AppColors.primary, thickness: 2),
      afterLineStyle: const LineStyle(color: AppColors.primary, thickness: 2),
      indicatorStyle: IndicatorStyle(
        width: AppStyles.iconSize + 6,
        color: AppColors.primaryDark,
        iconStyle: IconStyle(
          iconData: Icons.circle,
          color: AppColors.white,
          fontSize: 12,
        ),
      ),
      startChild: Padding(
        padding: const EdgeInsets.only(right: 8, top: 4),
        child: Text(
          event.time,
          style: AppStyles.subtitleStyle.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.text,
          ),
        ),
      ),
      endChild: _buildEventCard(event),
    );
  }

  Widget _buildChecklistTile(ChecklistModel item) {
    return TimelineTile(
      alignment: TimelineAlign.center,
      beforeLineStyle: const LineStyle(color: AppColors.grey, thickness: 2),
      afterLineStyle: const LineStyle(color: AppColors.grey, thickness: 2),
      indicatorStyle: IndicatorStyle(
        width: AppStyles.iconSize + 6,
        color: item.isCompleted ? AppColors.primaryDark : AppColors.grey,
        iconStyle: IconStyle(
          iconData: Icons.circle,
          color: AppColors.white,
          fontSize: 12,
        ),
      ),
      startChild: Padding(
        padding: const EdgeInsets.only(right: 8, top: 4),
        child: Text(
          item.date,
          style: AppStyles.subtitleStyle.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.grey,
          ),
        ),
      ),
      endChild: _buildChecklistCard(item),
    );
  }

  Widget _buildEventCard(EventModel event) {
    return Container(
      margin: const EdgeInsets.only(right: 0, top: 4, bottom: 4, left: 20),
      padding: const EdgeInsets.all(AppStyles.smallPadding + 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppStyles.borderRadius),
        border: Border.all(color: AppColors.primary, width: 1),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.07), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(event.name, style: AppStyles.titleStyle.copyWith(fontSize: 16)),
          if (event.subTitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              event.subTitle,
              style: AppStyles.subtitleStyle.copyWith(
                fontSize: 14,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChecklistCard(ChecklistModel item) {
    return Container(
      margin: const EdgeInsets.only(right: 0, top: 4, bottom: 4, left: 20),
      padding: const EdgeInsets.all(AppStyles.smallPadding + 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppStyles.borderRadius),
        border: Border.all(
          color: item.isCompleted ? AppColors.primary : AppColors.grey,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(color: AppColors.grey.withOpacity(0.07), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.note,
              style: AppStyles.subtitleStyle.copyWith(
                fontSize: 14,
                color: item.isCompleted ? AppColors.grey : AppColors.text,
                decoration:
                    item.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          Icon(
            item.isCompleted
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: item.isCompleted ? AppColors.primary : AppColors.grey,
            size: 20,
          ),
        ],
      ),
    );
  }
}
