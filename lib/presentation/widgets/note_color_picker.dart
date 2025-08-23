import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class NoteColorPicker extends StatefulWidget {
  final int? selectedColor;
  final Function(int?) onColorChanged;
  final String title;
  final bool showDefaultOption;

  const NoteColorPicker({
    super.key,
    this.selectedColor,
    required this.onColorChanged,
    this.title = '选择颜色',
    this.showDefaultOption = true,
  });

  @override
  State<NoteColorPicker> createState() => _NoteColorPickerState();
}

class _NoteColorPickerState extends State<NoteColorPicker> {
  int? _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.selectedColor;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
          child: Text(
            widget.title,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        _buildColorGrid(),
      ],
    );
  }

  Widget _buildColorGrid() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          // Default option
          if (widget.showDefaultOption) ...[
            _buildDefaultColorTile(),
            SizedBox(height: 12.h),
          ],
          
          // Color grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1,
            ),
            itemCount: AppColors.noteCategoryColors.length,
            itemBuilder: (context, index) {
              final color = AppColors.noteCategoryColors[index];
              final colorValue = color.value;
              final isSelected = _selectedColor == colorValue;
              
              return _buildColorTile(
                color: color,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedColor = colorValue;
                  });
                  widget.onColorChanged(colorValue);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultColorTile() {
    final isSelected = _selectedColor == null;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedColor = null;
        });
        widget.onColorChanged(null);
      },
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        height: 44.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected 
                ? AppColors.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 28.w,
              height: 28.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey.shade300,
                    Colors.grey.shade100,
                  ],
                ),
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: Colors.grey.shade400,
                  width: 0.5,
                ),
              ),
              child: Icon(
                Icons.palette_outlined,
                size: 16.sp,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                '默认颜色',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected 
                      ? AppColors.primary
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                size: 20.sp,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorTile({
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected 
                ? AppColors.primary
                : Colors.black.withOpacity(0.1),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isSelected
            ? Center(
                child: Container(
                  width: 20.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check,
                    size: 14.sp,
                    color: AppColors.primary,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

// 颜色选择器对话框组件
class NoteColorPickerDialog extends StatefulWidget {
  final int? initialColor;
  final String title;
  final bool showDefaultOption;

  const NoteColorPickerDialog({
    super.key,
    this.initialColor,
    this.title = '选择笔记颜色',
    this.showDefaultOption = true,
  });

  @override
  State<NoteColorPickerDialog> createState() => _NoteColorPickerDialogState();
}

class _NoteColorPickerDialogState extends State<NoteColorPickerDialog> {
  int? _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.title,
        style: AppTextStyles.titleMedium,
      ),
      contentPadding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 16.h),
      content: SizedBox(
        width: double.maxFinite,
        child: NoteColorPicker(
          selectedColor: _selectedColor,
          onColorChanged: (color) {
            setState(() {
              _selectedColor = color;
            });
          },
          title: '',
          showDefaultOption: widget.showDefaultOption,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _selectedColor),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('确定'),
        ),
      ],
    );
  }
}

// 颜色工具类
class NoteColorUtils {
  static Color getColorFromValue(int? colorValue) {
    if (colorValue == null) return Colors.white;
    return Color(colorValue);
  }

  static String getColorName(int? colorValue) {
    if (colorValue == null) return '默认颜色';
    
    final index = AppColors.noteCategoryColors.indexWhere(
      (c) => c.value == colorValue,
    );
    
    if (index >= 0) {
      final colorNames = [
        '红色', '粉色', '紫色', '深紫色', '靛蓝',
        '蓝色', '浅蓝', '青色', '青绿', '绿色',
        '浅绿', '柠檬', '黄色', '琥珀', '橙色', '深橙'
      ];
      return index < colorNames.length ? colorNames[index] : '自定义颜色';
    }
    
    return '自定义颜色';
  }

  static bool isLightColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5;
  }

  static Color getContrastColor(Color color) {
    return isLightColor(color) ? Colors.black : Colors.white;
  }
}