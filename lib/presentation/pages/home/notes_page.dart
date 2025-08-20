import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../widgets/note_card.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  bool _isGridView = false;
  final ScrollController _scrollController = ScrollController();

  // Mock data - replace with actual data from state management
  final List<MockNote> _pinnedNotes = [
    MockNote(
      id: '1',
      title: 'Meeting Notes',
      content: 'Discuss project timeline and deliverables...',
      tags: ['work', 'meeting'],
      isPinned: true,
      color: AppColors.noteCategoryColors[0],
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    MockNote(
      id: '2',
      title: 'Shopping List',
      content: 'Milk, Eggs, Bread, Apples...',
      tags: ['personal'],
      isPinned: true,
      color: AppColors.noteCategoryColors[1],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  final List<MockNote> _recentNotes = [
    MockNote(
      id: '3',
      title: 'Book Ideas',
      content: 'A collection of interesting book concepts and story ideas that came to mind during my morning walk...',
      tags: ['creative', 'writing'],
      color: AppColors.noteCategoryColors[2],
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    MockNote(
      id: '4',
      title: 'Recipe: Pasta Carbonara',
      content: 'Ingredients: Spaghetti, eggs, bacon, parmesan cheese, black pepper...',
      tags: ['food', 'recipe'],
      color: AppColors.noteCategoryColors[3],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    MockNote(
      id: '5',
      title: 'Travel Plans',
      content: 'Japan trip itinerary - Tokyo, Kyoto, Osaka. Cherry blossom season planning...',
      tags: ['travel', 'japan'],
      color: AppColors.noteCategoryColors[4],
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    MockNote(
      id: '6',
      title: 'Workout Routine',
      content: 'Monday: Chest and Triceps, Tuesday: Back and Biceps, Wednesday: Legs...',
      tags: ['fitness', 'health'],
      color: AppColors.noteCategoryColors[5],
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _createNewNote() {
    // TODO: Navigate to note editor
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create new note - TODO: Navigate to editor')),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            pinned: false,
            snap: true,
            elevation: 0,
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NoteFlow',
                        style: AppTextStyles.appBarTitle,
                      ),
                      Text(
                        'Good morning! ☀️',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: _showFilterOptions,
                icon: Icon(
                  Icons.tune_rounded,
                  size: 24.sp,
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _isGridView = !_isGridView),
                icon: Icon(
                  _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                  size: 24.sp,
                ),
              ),
            ],
          ),

          // Pinned Notes Section
          if (_pinnedNotes.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
                child: Row(
                  children: [
                    Icon(
                      Icons.push_pin_rounded,
                      size: 18.sp,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Pinned',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 120.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  itemCount: _pinnedNotes.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 200.w,
                      margin: EdgeInsets.only(right: 12.w),
                      child: NoteCard(
                        note: _pinnedNotes[index],
                        isCompact: true,
                        onTap: () {
                          // TODO: Open note editor
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],

          // Recent Notes Section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
              child: Text(
                'Recent Notes',
                style: AppTextStyles.titleMedium,
              ),
            ),
          ),

          // Notes Grid/List
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            sliver: _isGridView
                ? SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12.h,
                    crossAxisSpacing: 12.w,
                    childCount: _recentNotes.length,
                    itemBuilder: (context, index) {
                      return NoteCard(
                        note: _recentNotes[index],
                        onTap: () {
                          // TODO: Open note editor
                        },
                      );
                    },
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: NoteCard(
                            note: _recentNotes[index],
                            isListView: true,
                            onTap: () {
                              // TODO: Open note editor
                            },
                          ),
                        );
                      },
                      childCount: _recentNotes.length,
                    ),
                  ),
          ),

          // Bottom padding for FAB
          SliverToBoxAdapter(
            child: SizedBox(height: 100.h),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewNote,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: Icon(Icons.add_rounded, size: 24.sp),
        label: Text(
          'New Note',
          style: AppTextStyles.buttonText.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter & Sort',
            style: AppTextStyles.titleLarge,
          ),
          SizedBox(height: 16.h),
          // TODO: Add filter options
          ListTile(
            leading: const Icon(Icons.schedule_rounded),
            title: const Text('Recently Modified'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today_rounded),
            title: const Text('Created Date'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.label_rounded),
            title: const Text('By Tags'),
            onTap: () => Navigator.pop(context),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}

// Mock data model - replace with actual domain entity
class MockNote {
  final String id;
  final String title;
  final String content;
  final List<String> tags;
  final bool isPinned;
  final Color color;
  final DateTime createdAt;

  MockNote({
    required this.id,
    required this.title,
    required this.content,
    required this.tags,
    this.isPinned = false,
    required this.color,
    required this.createdAt,
  });
}