import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get_it/get_it.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/user_preferences_service.dart';
import '../../../domain/entities/note_entity.dart';
import '../../bloc/notes/notes_bloc.dart';
import '../../widgets/note_card.dart';
import '../editor/note_editor_page.dart';
import '../ai/ocr_scanner_page.dart';
import '../ai/voice_note_page.dart';
import 'package:noteflow_app/generated/l10n.dart' as localization;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class SearchPageWrapper extends StatelessWidget {
  const SearchPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the existing NotesBloc from parent BlocProvider
    return const SearchPage();
  }
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  String _searchQuery = '';
  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _loadSearchHistory() {
    setState(() {
      _recentSearches = UserPreferencesService.instance.searchHistory;
    });
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
    });
    
    if (query.trim().isNotEmpty) {
      // Save to search history
      UserPreferencesService.instance.addSearchHistory(query.trim()).then((_) {
        _loadSearchHistory();
      });
      
      context.read<NotesBloc>().add(SearchNotesEvent(
        query: query.trim(),
        userId: 'user_1',
      ));
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _isSearching = false;
    });
  }

  void _openOCR() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const OCRScannerPage(),
      ),
    );
  }

  void _openVoiceNote() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const VoiceNotePage(),
      ),
    );
  }

  void _openAIHelp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI助手功能即将推出...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Search Header
            Container(
              padding: EdgeInsets.all(16.w),
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: _performSearch,
                    onSubmitted: _performSearch,
                    decoration: InputDecoration(
                      hintText: localization.S.of(context).searchNotes,
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 24.sp,
                        color: AppColors.primary,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              onPressed: _clearSearch,
                              icon: Icon(
                                Icons.clear_rounded,
                                size: 20.sp,
                              ),
                            )
                          : null,
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                    ),
                    style: AppTextStyles.bodyLarge,
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // Quick Actions
                  Text(
                    localization.S.of(context).quickActions,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  
                  SizedBox(height: 12.h),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQuickActionButton(
                        icon: Icons.document_scanner_rounded,
                        label: localization.S.of(context).ocrScan,
                        color: AppColors.primary,
                        onTap: _openOCR,
                      ),
                      _buildQuickActionButton(
                        icon: Icons.mic_rounded,
                        label: localization.S.of(context).voiceNote,
                        color: AppColors.secondary,
                        onTap: _openVoiceNote,
                      ),
                      // _buildQuickActionButton(
                      //   icon: Icons.auto_awesome_rounded,
                      //   label: localization.S.of(context).aiHelp,
                      //   color: AppColors.accent,
                      //   onTap: _openAIHelp,
                      // ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: _isSearching 
                  ? BlocBuilder<NotesBloc, NotesState>(
                      builder: (context, state) {
                        if (state is NotesSearching) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is NotesSearchResults) {
                          return _buildSearchResults(state.results);
                        } else if (state is NotesSearchEmpty) {
                          return _buildEmptySearchState();
                        } else if (state is NotesError) {
                          return _buildErrorState(state.message);
                        } else {
                          return _buildDefaultContent();
                        }
                      },
                    ) 
                  : _buildDefaultContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80.w,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32.sp,
              color: color,
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultContent() {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        // Recent Searches
        if (_recentSearches.isNotEmpty) ...[
          Text(
            localization.S.of(context).recentSearches,
            style: AppTextStyles.titleMedium,
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _recentSearches.map((search) {
              return GestureDetector(
                onTap: () {
                  _searchController.text = search;
                  _performSearch(search);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.history_rounded,
                        size: 16.sp,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        search,
                        style: AppTextStyles.bodySmall,
                      ),
                      SizedBox(width: 4.w),
                      GestureDetector(
                        onTap: () {
                          UserPreferencesService.instance.removeSearchHistory(search).then((_) {
                            _loadSearchHistory();
                          });
                        },
                        child: Icon(
                          Icons.close_rounded,
                          size: 14.sp,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 32.h),
        ],

        // Tips
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 20.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    localization.S.of(context).searchTips,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                localization.S.of(context).searchTipsDetails,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(List<NoteEntity> results) {
    if (results.isEmpty) {
      return _buildEmptySearchState();
    }
    
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              'Found ${results.length} note${results.length == 1 ? '' : 's'}',
              style: AppTextStyles.titleMedium,
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12.h,
            crossAxisSpacing: 12.w,
            childCount: results.length,
            itemBuilder: (context, index) {
              return NoteCard(
                note: results[index],
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => NoteEditorPageWrapper(
                        note: results[index],
                        isNewNote: false,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: 100.h),
        ),
      ],
    );
  }

  Widget _buildEmptySearchState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64.sp,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          SizedBox(height: 16.h),
          Text(
            localization.S.of(context).noNotesFound,
            style: AppTextStyles.titleMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            localization.S.of(context).tryDifferentKeywords,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64.sp,
            color: Colors.red,
          ),
          SizedBox(height: 16.h),
          Text(
            'Search Error',
            style: AppTextStyles.titleMedium.copyWith(
              color: Colors.red,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}