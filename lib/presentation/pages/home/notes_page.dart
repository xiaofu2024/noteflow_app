import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get_it/get_it.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/user_preferences_service.dart';
import '../../bloc/notes/notes_bloc.dart';
import '../../widgets/note_card.dart';
import '../editor/note_editor_page.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class NotesPageWrapper extends StatelessWidget {
  const NotesPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.instance<NotesBloc>()..add(LoadNotesEvent()),
      child: const NotesPage(),
    );
  }
}

class _NotesPageState extends State<NotesPage> {
  bool _isGridView = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _createNewNote() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NoteEditorPageWrapper(isNewNote: true),
      ),
    ).then((_) {
      // Refresh notes when returning from editor
      context.read<NotesBloc>().add(LoadNotesEvent(userId: 'user_1'));
    });
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (modalContext) => BlocProvider.value(
        value: context.read<NotesBloc>(),
        child: const FilterBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: BlocBuilder<NotesBloc, NotesState>(
        builder: (context, state) {
          if (state is NotesLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (state is NotesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64.sp,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Error loading notes',
                    style: AppTextStyles.titleLarge,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    state.message,
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<NotesBloc>().add(LoadNotesEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          if (state is NotesLoaded) {
            final pinnedNotes = state.notes.where((note) => note.isPinned).toList();
            final recentNotes = state.notes.where((note) => !note.isPinned).toList();
            
            return CustomScrollView(
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
                if (pinnedNotes.isNotEmpty) ...[
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
                            '置顶',
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
                        itemCount: pinnedNotes.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 200.w,
                            margin: EdgeInsets.only(right: 12.w),
                            child: NoteCard(
                              note: pinnedNotes[index],
                              isCompact: true,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => NoteEditorPageWrapper(
                                      note: pinnedNotes[index],
                                      isNewNote: false,
                                    ),
                                  ),
                                ).then((_) {
                                  context.read<NotesBloc>().add(LoadNotesEvent(userId: 'user_1'));
                                });
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
                      '最近笔记',
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
                          childCount: recentNotes.length,
                          itemBuilder: (context, index) {
                            return NoteCard(
                              note: recentNotes[index],
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => NoteEditorPageWrapper(
                                      note: recentNotes[index],
                                      isNewNote: false,
                                    ),
                                  ),
                                ).then((_) {
                                  context.read<NotesBloc>().add(LoadNotesEvent(userId: 'user_1'));
                                });
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
                                  note: recentNotes[index],
                                  isListView: true,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => NoteEditorPageWrapper(
                                          note: recentNotes[index],
                                          isNewNote: false,
                                        ),
                                      ),
                                    ).then((_) {
                                      context.read<NotesBloc>().add(LoadNotesEvent(userId: 'user_1'));
                                    });
                                  },
                                ),
                              );
                            },
                            childCount: recentNotes.length,
                          ),
                        ),
                ),
      
                // Bottom padding for FAB
                SliverToBoxAdapter(
                  child: SizedBox(height: 100.h),
                ),
              ],
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewNote,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: Icon(Icons.add_rounded, size: 24.sp),
        label: Text(
          '',
          style: AppTextStyles.buttonText.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  NotesSortType _selectedSort = NotesSortType.updatedAt;
  bool _sortAscending = false;
  bool _showOnlyPinned = false;
  bool _showOnlyFavorites = false;

  @override
  void initState() {
    super.initState();
    // Initialize with default values, will be updated in didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get current sort and filter state from bloc
    final bloc = context.read<NotesBloc>();
    if (mounted) {
      setState(() {
        _selectedSort = bloc.currentSortType;
        _sortAscending = bloc.sortAscending;
      });
    }
  }

  void _applySorting(NotesSortType sortType) {
    setState(() {
      if (_selectedSort == sortType) {
        _sortAscending = !_sortAscending;
      } else {
        _selectedSort = sortType;
        _sortAscending = sortType == NotesSortType.title;
      }
    });

    context.read<NotesBloc>().add(SortNotesEvent(
      sortType: _selectedSort,
      ascending: _sortAscending,
    ));
  }

  void _applyFilter() {
    final filter = NotesFilter(
      showPinned: _showOnlyPinned ? true : null,
      showFavorites: _showOnlyFavorites ? true : null,
    );

    context.read<NotesBloc>().add(FilterNotesEvent(filter));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),

          Text(
            '过滤和排序',
            style: AppTextStyles.titleLarge,
          ),
          SizedBox(height: 24.h),

          // Sort Section
          Text(
            '排序方式',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 12.h),

          _buildSortTile(
            title: '最近修改',
            subtitle: '按更新时间排序',
            icon: Icons.schedule_rounded,
            sortType: NotesSortType.updatedAt,
          ),
          _buildSortTile(
            title: '创建时间',
            subtitle: '按创建日期排序',
            icon: Icons.calendar_today_rounded,
            sortType: NotesSortType.createdAt,
          ),
          _buildSortTile(
            title: '标题',
            subtitle: '按标题字母序排序',
            icon: Icons.sort_by_alpha_rounded,
            sortType: NotesSortType.title,
          ),
          _buildSortTile(
            title: '置顶优先',
            subtitle: '置顶笔记在前',
            icon: Icons.push_pin_rounded,
            sortType: NotesSortType.isPinned,
          ),

          SizedBox(height: 24.h),

          // Filter Section
          Text(
            '过滤选项',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 12.h),

          _buildFilterSwitch(
            title: '仅显示置顶',
            icon: Icons.push_pin_rounded,
            value: _showOnlyPinned,
            onChanged: (value) {
              setState(() => _showOnlyPinned = value);
              _applyFilter();
            },
          ),
          _buildFilterSwitch(
            title: '仅显示收藏',
            icon: Icons.favorite_rounded,
            value: _showOnlyFavorites,
            onChanged: (value) {
              setState(() => _showOnlyFavorites = value);
              _applyFilter();
            },
          ),

          SizedBox(height: 16.h),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _showOnlyPinned = false;
                      _showOnlyFavorites = false;
                      _selectedSort = NotesSortType.updatedAt;
                      _sortAscending = false;
                    });
                    
                    context.read<NotesBloc>().add(const FilterNotesEvent(NotesFilter()));
                    context.read<NotesBloc>().add(const SortNotesEvent(
                      sortType: NotesSortType.updatedAt,
                      ascending: false,
                    ));
                  },
                  child: const Text('重置'),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('完成'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required NotesSortType sortType,
  }) {
    final isSelected = _selectedSort == sortType;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : null,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: isSelected ? AppColors.primary : null,
          fontWeight: isSelected ? FontWeight.w600 : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: isSelected
          ? Icon(
              _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
              color: AppColors.primary,
              size: 16.sp,
            )
          : null,
      onTap: () => _applySorting(sortType),
    );
  }

  Widget _buildFilterSwitch({
    required String title,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(
        icon,
        color: value ? AppColors.primary : null,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: value ? AppColors.primary : null,
          fontWeight: value ? FontWeight.w600 : null,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }
}

