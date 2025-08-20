import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Mock events - replace with actual data
  final Map<DateTime, List<Event>> _events = {
    DateTime.utc(2024, 1, 15): [
      Event('Team Meeting', 'Project discussion', '10:00 AM'),
      Event('Note: Review feedback', 'Check client responses', '2:00 PM'),
    ],
    DateTime.utc(2024, 1, 16): [
      Event('Doctor Appointment', 'Annual checkup', '9:00 AM'),
    ],
    DateTime.utc(2024, 1, 20): [
      Event('Project Deadline', 'Submit final proposal', '11:59 PM'),
    ],
  };

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            pinned: false,
            snap: true,
            elevation: 0,
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              'Calendar',
              style: AppTextStyles.appBarTitle,
            ),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime.now();
                    _selectedDay = DateTime.now();
                    _selectedEvents.value = _getEventsForDay(_selectedDay!);
                  });
                },
                icon: Icon(Icons.today_rounded, size: 24.sp),
              ),
              IconButton(
                onPressed: () {
                  // TODO: Add new event
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Add event - TODO')),
                  );
                },
                icon: Icon(Icons.add_rounded, size: 24.sp),
              ),
            ],
          ),

          // Calendar
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TableCalendar<Event>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                eventLoader: _getEventsForDay,
                startingDayOfWeek: StartingDayOfWeek.monday,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  weekendTextStyle: AppTextStyles.bodyMedium,
                  holidayTextStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 3,
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  formatButtonShowsNext: false,
                  formatButtonDecoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  formatButtonTextStyle: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                  ),
                  titleTextStyle: AppTextStyles.titleMedium,
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                      _selectedEvents.value = _getEventsForDay(selectedDay);
                    });
                  }
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),
            ),
          ),

          // Today's Events Header
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
              child: Text(
                _selectedDay != null && isSameDay(_selectedDay!, DateTime.now())
                    ? "Today's Events"
                    : 'Events for ${_selectedDay?.day}/${_selectedDay?.month}',
                style: AppTextStyles.titleMedium,
              ),
            ),
          ),

          // Events List
          ValueListenableBuilder<List<Event>>(
            valueListenable: _selectedEvents,
            builder: (context, events, _) {
              if (events.isEmpty) {
                return SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.w),
                    padding: EdgeInsets.all(32.w),
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_busy_rounded,
                          size: 48.sp,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No events for this day',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final event = events[index];
                    return Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        leading: Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            event.title.contains('Note:')
                                ? Icons.edit_note_rounded
                                : Icons.event_rounded,
                            color: AppColors.primary,
                            size: 20.sp,
                          ),
                        ),
                        title: Text(
                          event.title,
                          style: AppTextStyles.titleSmall,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (event.description.isNotEmpty) ...[
                              SizedBox(height: 4.h),
                              Text(
                                event.description,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                            SizedBox(height: 4.h),
                            Text(
                              event.time,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          // TODO: Open event details or edit
                        },
                      ),
                    );
                  },
                  childCount: events.length,
                ),
              );
            },
          ),

          // Bottom padding
          SliverToBoxAdapter(
            child: SizedBox(height: 100.h),
          ),
        ],
      ),
    );
  }
}

class Event {
  final String title;
  final String description;
  final String time;

  Event(this.title, this.description, this.time);

  @override
  String toString() => title;
}