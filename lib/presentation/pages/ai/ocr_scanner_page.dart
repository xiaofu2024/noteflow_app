import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:noteflow_app/core/constants/app_constants.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/ai_service.dart';
import '../../../core/services/note_color_service.dart';
import '../../../core/services/vip_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/note_entity.dart';
import '../editor/note_editor_page.dart';
import '../../widgets/vip_limit_dialog.dart';
import 'package:get_it/get_it.dart';

class OCRScannerPage extends StatefulWidget {
  const OCRScannerPage({super.key});

  @override
  State<OCRScannerPage> createState() => _OCRScannerPageState();
}

class _OCRScannerPageState extends State<OCRScannerPage> {
  final AIService _aiService = AIService();
  final VipManager _vipManager = VipManager();
  File? _selectedImage;
  String? _recognizedText;
  bool _isProcessing = false;

  Future<void> _pickImageFromCamera() async {
    // Check VIP limit first
    final canUse = await _vipManager.canUseOCR();
    if (!mounted) return;
    if (!await VipLimitDialog.checkOcrLimit(context, canUse)) {
      return;
    }

    setState(() {
      _isProcessing = true;
      _recognizedText = null;
      _selectedImage = null;
    });

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        setState(() {
          _selectedImage = file;
        });

        final text = await _aiService.recognizeTextFromImage(imageFile: file);
        setState(() {
          _recognizedText = text;
        });
        
        // Record OCR usage
        await _vipManager.recordOCRUsage();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('拍照失败: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    // Check VIP limit first
    final canUse = await _vipManager.canUseOCR();
    if (!mounted) return;
    if (!await VipLimitDialog.checkOcrLimit(context, canUse)) {
      return;
    }

    setState(() {
      _isProcessing = true;
      _recognizedText = null;
      _selectedImage = null;
    });

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        setState(() {
          _selectedImage = file;
        });

        final text = await _aiService.recognizeTextFromImage(imageFile: file);
        setState(() {
          _recognizedText = text;
        });
        
        // Record OCR usage
        await _vipManager.recordOCRUsage();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('选择图片失败: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _createNoteFromText() async {
    if (_recognizedText != null && _recognizedText!.isNotEmpty) {
      // Check VIP limit for note creation
      final canCreate = await _vipManager.canCreateNote();
      if (!mounted) return;
      if (!await VipLimitDialog.checkNoteCreateLimit(context, canCreate)) {
        return;
      }
      final noteContent = _recognizedText!.trim();
      final colorService = GetIt.instance<NoteColorService>();
      final note = NoteEntity(
        id: const Uuid().v4(),
        title: 'OCR识别笔记',
        content: noteContent,
        tags: [],
        isPinned: false,
        color: colorService.getNewNoteColor(),
        userId: AppConstants.userIdKey,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => NoteEditorPageWrapper(
            note: note,
            isNewNote: true,
          ),
        ),
      );
      
      // Record note creation
      await _vipManager.recordNoteCreation();
    }
  }

  void _copyToClipboard() {
    if (_recognizedText != null && _recognizedText!.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _recognizedText!.trim()));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('文本已复制到剪贴板')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'OCR文字识别',
          style: AppTextStyles.appBarTitle,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _pickImageFromCamera,
                      icon: Icon(Icons.camera_alt_rounded, size: 20.sp),
                      label: const Text('拍照识别'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _pickImageFromGallery,
                      icon: Icon(Icons.photo_library_rounded, size: 20.sp),
                      label: const Text('选择图片'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // Image Preview
              if (_selectedImage != null) ...[
                Text(
                  '选择的图片:',
                  style: AppTextStyles.titleMedium,
                ),
                SizedBox(height: 12.h),
                Container(
                  height: 200.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
              ],

              // Processing Indicator
              if (_isProcessing) ...[
                Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        '正在识别文字...',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
              ],

              // Recognized Text
              if (_recognizedText != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '识别结果:',
                      style: AppTextStyles.titleMedium,
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _copyToClipboard,
                          icon: Icon(
                            Icons.copy_rounded,
                            size: 20.sp,
                            color: AppColors.primary,
                          ),
                          tooltip: '复制文本',
                        ),
                        IconButton(
                          onPressed: _createNoteFromText,
                          icon: Icon(
                            Icons.note_add_rounded,
                            size: 20.sp,
                            color: AppColors.primary,
                          ),
                          tooltip: '创建笔记',
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        _recognizedText!.isEmpty ? '未识别到文字内容' : _recognizedText!,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                  ),
                ),
              ] else if (!_isProcessing && _selectedImage == null) ...[
                // Welcome State
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120.w,
                          height: 120.w,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(60.r),
                          ),
                          child: Icon(
                            Icons.document_scanner_rounded,
                            size: 60.sp,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Text(
                          '智能文字识别',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          '拍照或选择图片，快速提取文字内容\n支持中英文混合识别',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}