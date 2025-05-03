import 'package:event_planner/shared/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timeline_tile/timeline_tile.dart';

class Calenader extends StatefulWidget {
  const Calenader({super.key});

  @override
  State<Calenader> createState() => _CalenaderState();
}

class _CalenaderState extends State<Calenader> {
  DateTime date = DateTime.now();
  final List<Event> _events = [
   Event(
    date: DateTime(2025, 5, 21, 13, 0),
    title: 'Club Meeting',
  ),
  Event(
    date: DateTime(2025, 5, 21, 15, 0),
    title: 'Team Workshop',
  ),
  
  // New 2025 event
  Event(
    date: DateTime(2025, 5, 21, 14, 0),
    title: '2025 Planning Session',
  ),
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

    return Column(
      children: [
        _buildCalendar(),
        const SizedBox(height: 20),
        _buildTimeline(dailyEvents),
      ],
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      focusedDay: date,
      locale: 'en_US',
      rowHeight: 43,
      headerStyle: const HeaderStyle(formatButtonVisible: false),
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

    return Expanded(
      child: ListView.separated(
        
        itemCount: events.length,
        separatorBuilder: (context, index) => const SizedBox(height: 1),
        itemBuilder: (context, index) {
          final event = events[index];
          return TimelineTile(
    alignment: TimelineAlign.center, 
    beforeLineStyle: const LineStyle(color: AppColors.primary, thickness: 2),
    afterLineStyle: const LineStyle(color: AppColors.primary, thickness: 2),
    indicatorStyle: IndicatorStyle(
      width: 30,
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
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    endChild: _buildEventCard(event),
  );
        },
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    return Container(
      margin: const EdgeInsets.only(right: 16, top: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${event.date.hour}:${event.date.minute.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class Event {
  final DateTime date;
  final String title;

  Event({
    required this.date,
    required this.title,
  });
}