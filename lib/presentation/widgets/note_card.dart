import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/note_entity.dart';

class NoteCard extends StatelessWidget {
  final NoteEntity note;
  final bool isCompact;
  final bool isListView;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const NoteCard({
    super.key,
    required this.note,
    this.isCompact = false,
    this.isListView = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: _getNoteColor().withOpacity(0.15),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: _getNoteColor().withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isListView ? _buildListViewContent(context) : _buildCardContent(context),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 12.w : 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with pin and actions
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  note.title,
                  style: isCompact 
                      ? AppTextStyles.titleSmall
                      : AppTextStyles.titleMedium,
                  maxLines: isCompact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (note.isPinned) ...[
                SizedBox(width: 8.w),
                Icon(
                  Icons.push_pin_rounded,
                  size: 16.sp,
                  color: AppColors.primary,
                ),
              ],
            ],
          ),
          
          if (!isCompact) ...[
            SizedBox(height: 8.h),
            
            // Content preview
            Text(
              note.content,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            
            SizedBox(height: 12.h),
          ] else ...[
            SizedBox(height: 4.h),
          ],
          
          // Tags and metadata
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6.w,
                  runSpacing: 4.h,
                  children: note.tags.take(isCompact ? 1 : 3).map((tag) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getNoteColor().withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '#$tag',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: _getNoteColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (!isCompact) ...[
                SizedBox(width: 8.w),
                Text(
                  _formatDate(note.createdAt ?? DateTime.now()),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListViewContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Color indicator
          Container(
            width: 4.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: _getNoteColor(),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          
          SizedBox(width: 16.w),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and pin
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        note.title,
                        style: AppTextStyles.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (note.isPinned) ...[
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.push_pin_rounded,
                        size: 16.sp,
                        color: AppColors.primary,
                      ),
                    ],
                  ],
                ),
                
                SizedBox(height: 4.h),
                
                // Content preview
                Text(
                  note.content,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                SizedBox(height: 8.h),
                
                // Tags and date
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 6.w,
                        children: note.tags.take(2).map((tag) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: _getNoteColor().withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              '#$tag',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: _getNoteColor(),
                                fontSize: 10.sp,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Text(
                      _formatDate(note.createdAt ?? DateTime.now()),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getNoteColor() {
    if (note.color != null) {
      return Color(note.color!);
    }
    // Default colors based on color index or fallback
    final colors = AppColors.noteCategoryColors;
    final index = note.id.hashCode % colors.length;
    return colors[index];
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}