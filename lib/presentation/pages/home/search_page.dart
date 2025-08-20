import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  String _searchQuery = '';

  // Mock search history
  final List<String> _recentSearches = [
    'meeting notes',
    'project ideas',
    'travel plans',
    'recipe',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
    });
    // TODO: Implement actual search functionality
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _isSearching = false;
    });
  }

  void _openOCR() {
    // TODO: Open OCR scanner
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OCR Scanner - TODO')),
    );
  }

  void _openVoiceNote() {
    // TODO: Open voice note recorder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voice Note - TODO')),
    );
  }

  void _openAIHelp() {
    // TODO: Open AI assistant
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI Help - TODO')),
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
                      hintText: 'Search your notes...',
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
                    'Quick Actions',
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
                        label: 'OCR\nScan',
                        color: AppColors.primary,
                        onTap: _openOCR,
                      ),
                      _buildQuickActionButton(
                        icon: Icons.mic_rounded,
                        label: 'Voice\nNote',
                        color: AppColors.secondary,
                        onTap: _openVoiceNote,
                      ),
                      _buildQuickActionButton(
                        icon: Icons.auto_awesome_rounded,
                        label: 'AI\nHelp',
                        color: AppColors.accent,
                        onTap: _openAIHelp,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: _isSearching ? _buildSearchResults() : _buildDefaultContent(),
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
            'Recent Searches',
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
                    'Search Tips',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                '• Search by keywords, tags, or content\n'
                '• Use quotes for exact phrases\n'
                '• Search by date: "last week", "yesterday"\n'
                '• Use OCR to search text in images',
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

  Widget _buildSearchResults() {
    // TODO: Implement actual search results
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_rounded,
            size: 64.sp,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          SizedBox(height: 16.h),
          Text(
            'Searching for "$_searchQuery"',
            style: AppTextStyles.titleMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Search functionality coming soon...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}