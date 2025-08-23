import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/note_entity.dart';
import '../../bloc/notes/notes_bloc.dart';
import '../editor/note_editor_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class CalendarPageWrapper extends StatelessWidget {
  const CalendarPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the existing NotesBloc from parent BlocProvider
    return const CalendarPage();
  }
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<NoteEntity>> _notesMap = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadNotesForDate(_selectedDay!);
  }

  List<NoteEntity> _getNotesForDay(DateTime day) {
    final dateKey = DateTime(day.year, day.month, day.day);
    return _notesMap[dateKey] ?? [];
  }

  void _loadNotesForDate(DateTime date) {
    context.read<NotesBloc>().add(
      LoadNotesByDateEvent(date: date, userId: 'user_1'),
    );
  }

  void _createNoteForDate(DateTime date) {
    final note = NoteEntity(
      id: const Uuid().v4(),
      title: '',
      content: '',
      tags: [],
      isPinned: false,
      userId: 'user_1',
      createdAt: date,
      updatedAt: date,
    );
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteEditorPageWrapper(
          note: note,
          isNewNote: true,
        ),
      ),
    ).then((_) {
      // Refresh notes after returning from editor
      _loadNotesForDate(_selectedDay!);
    });
  }

  void _buildNotesMap(List<NoteEntity> notes) {
    _notesMap.clear();
    for (final note in notes) {
      final createdAt = note.createdAt ?? DateTime.now();
      final dateKey = DateTime(createdAt.year, createdAt.month, createdAt.day);
      
      if (_notesMap[dateKey] == null) {
        _notesMap[dateKey] = [];
      }
      _notesMap[dateKey]!.add(note);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
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
              '日历',
              style: AppTextStyles.appBarTitle,
            ),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime.now();
                    _selectedDay = DateTime.now();
                  });
                  _loadNotesForDate(DateTime.now());
                },
                icon: Icon(Icons.today_rounded, size: 24.sp),
              ),
              IconButton(
                onPressed: () {
                  if (_selectedDay != null) {
                    _createNoteForDate(_selectedDay!);
                  }
                },
                icon: Icon(Icons.add_rounded, size: 24.sp),
              ),
            ],
          ),

          // Load notes for calendar
          BlocListener<NotesBloc, NotesState>(
            listener: (context, state) {
              if (state is NotesLoaded) {
                _buildNotesMap(state.notes);
              } else if (state is NotesCalendarLoaded) {
                _buildNotesMap(state.allNotes);
              }
            },
            child: SliverToBoxAdapter(child: Container()),
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
              child: TableCalendar<NoteEntity>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                eventLoader: _getNotesForDay,
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
                    });
                    _loadNotesForDate(selectedDay);
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
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                  // Load notes for the new month
                  context.read<NotesBloc>().add(
                    LoadNotesEvent(userId: 'user_1'),
                  );
                },
              ),
            ),
          ),

          // Today's Notes Header
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
              child: Text(
                _selectedDay != null && isSameDay(_selectedDay!, DateTime.now())
                    ? "今日笔记"
                    : '${_selectedDay?.day}/${_selectedDay?.month}的笔记',
                style: AppTextStyles.titleMedium,
              ),
            ),
          ),

          // Notes List
          BlocBuilder<NotesBloc, NotesState>(
            builder: (context, state) {
              if (state is NotesLoading) {
                return SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.all(32.w),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }
              
              if (state is NotesError) {
                return SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.w),
                    padding: EdgeInsets.all(32.w),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48.sp,
                          color: Colors.red,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          '加载笔记失败',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.red,
                          ),
                        ),
                        Text(
                          state.message,
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              final notes = state is NotesLoaded 
                  ? state.notes 
                  : state is NotesCalendarLoaded 
                      ? state.filteredNotes 
                      : <NoteEntity>[];
              
              if (notes.isEmpty) {
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
                          '这天没有笔记',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        TextButton.icon(
                          onPressed: () {
                            if (_selectedDay != null) {
                              _createNoteForDate(_selectedDay!);
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('创建笔记'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final note = notes[index];
                    return Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: note.color != null 
                            ? Color(note.color!).withOpacity(0.05)
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: note.color != null 
                              ? Color(note.color!).withOpacity(0.3)
                              : Colors.transparent,
                        ),
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
                            color: note.color != null 
                                ? Color(note.color!).withOpacity(0.3)
                                : AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            note.isPinned
                                ? Icons.push_pin_rounded
                                : Icons.edit_note_rounded,
                            color: note.color != null 
                                ? Color(note.color!)
                                : AppColors.primary,
                            size: 20.sp,
                          ),
                        ),
                        title: Text(
                          note.title.isEmpty ? '无标题笔记' : note.title,
                          style: AppTextStyles.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (note.content.isNotEmpty) ...[
                              SizedBox(height: 4.h),
                              Text(
                                note.previewText,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Text(
                                  '${(note.createdAt ?? DateTime.now()).hour.toString().padLeft(2, '0')}:${(note.createdAt ?? DateTime.now()).minute.toString().padLeft(2, '0')}',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (note.tags.isNotEmpty) ...[
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Wrap(
                                      spacing: 4.w,
                                      children: note.tags.take(2).map((tag) => Container(
                                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                        decoration: BoxDecoration(
                                          color: AppColors.secondary.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                        child: Text(
                                          '#$tag',
                                          style: AppTextStyles.labelSmall.copyWith(
                                            color: AppColors.secondary,
                                            fontSize: 10.sp,
                                          ),
                                        ),
                                      )).toList(),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => NoteEditorPageWrapper(
                                note: note,
                                isNewNote: false,
                              ),
                            ),
                          ).then((_) {
                            // Refresh notes after returning from editor
                            _loadNotesForDate(_selectedDay!);
                          });
                        },
                      ),
                    );
                  },
                  childCount: notes.length,
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