import 'package:event_planner/shared/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../../shared/styles/styles.dart';
import '../../models/Event.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime date = DateTime.now();
  final List<Event> _events = [
    Event(date: DateTime(2025, 5, 21, 13, 0), title: 'Club Meeting'),
    Event(date: DateTime(2025, 5, 21, 15, 0), title: 'Team Workshop'),
    Event(date: DateTime(2025, 5, 21, 14, 0), title: '2025 Planning Session'),
  ];

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      date = selectedDay;
    });
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events.where((event) => isSameDay(event.date, day)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dailyEvents = _getEventsForDay(date);

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
              child: _buildTimeline(dailyEvents),
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
      ),
      availableGestures: AvailableGestures.all,
      selectedDayPredicate: (day) => isSameDay(day, date),
      onDaySelected: onDaySelected,
      firstDay: DateTime(date.year, date.month - 3, 1),
      lastDay: DateTime(date.year, date.month + 3, 31),
      eventLoader: (day) => _getEventsForDay(day).map((e) => e.title).toList(),
    );
  }

  Widget _buildTimeline(List<Event> events) {
    if (events.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text("No events for this day"),
      );
    }

    return ListView.separated(
      itemCount: events.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final event = events[index];
        return TimelineTile(
          alignment: TimelineAlign.center,
          beforeLineStyle: const LineStyle(
            color: AppColors.primary,
            thickness: 2,
          ),
          afterLineStyle: const LineStyle(
            color: AppColors.primary,
            thickness: 2,
          ),
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
              '${event.date.hour}:${event.date.minute.toString().padLeft(2, '0')}',
              style: AppStyles.subtitleStyle.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.text,
              ),
            ),
          ),
          endChild: _buildEventCard(event),
        );
      },
    );
  }

  Widget _buildEventCard(Event event) {
    return Container(
      margin: const EdgeInsets.only(right: 16, top: 4, bottom: 4),
      padding: const EdgeInsets.all(AppStyles.smallPadding + 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppStyles.borderRadius),
        border: Border.all(color: AppColors.primary, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.07),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(event.title, style: AppStyles.titleStyle.copyWith(fontSize: 16)),
          const SizedBox(height: 4),
          Text(
            '${event.date.hour}:${event.date.minute.toString().padLeft(2, '0')}',
            style: AppStyles.subtitleStyle.copyWith(
              fontSize: 14,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
