import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/services/note_color_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/note_entity.dart';
import '../editor/note_editor_page.dart';
import 'package:get_it/get_it.dart';

class VoiceNotePage extends StatefulWidget {
  const VoiceNotePage({super.key});

  @override
  State<VoiceNotePage> createState() => _VoiceNotePageState();
}

class _VoiceNotePageState extends State<VoiceNotePage>
    with TickerProviderStateMixin {
  final AIService _aiService = AIService();
  
  bool _isListening = false;
  bool _isRecording = false;
  String _recognizedText = '';
  String _statusText = '点击开始录音';
  
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  Timer? _recordingTimer;
  int _recordingDuration = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _aiService.initialize();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  Future<void> _startListening() async {
    if (_isListening) return;

    setState(() {
      _isListening = true;
      _statusText = '正在听取...';
      _recognizedText = '';
    });

    _pulseController.repeat(reverse: true);
    _waveController.repeat();

    try {
      await _aiService.startListening(
        localeId: 'zh_CN',
        onResult: (text) {
          setState(() {
            _recognizedText = text;
            // 根据是否还在监听状态来决定显示文本
            if (_isListening) {
              _statusText = '正在识别语音...';
            }
          });
        },
        onError: (error) {
          setState(() {
            _statusText = '语音识别错误: $error';
            _isListening = false;
          });
          _stopListening();
        },
      );

      // Auto stop after 30 seconds
      Timer(const Duration(seconds: 30), () {
        if (_isListening) {
          _stopListening();
        }
      });
    } catch (e) {
      setState(() {
        _statusText = '启动语音识别失败: $e';
      });
      _stopListening();
    }
  }

  Future<void> _stopListening() async {
    if (!_isListening) return;

    setState(() {
      _isListening = false;
      _statusText = _recognizedText.isNotEmpty ? '识别完成' : '未识别到语音';
    });

    _pulseController.stop();
    _waveController.stop();

    await _aiService.stopListening();
  }

  Future<void> _startRecording() async {
    if (_isRecording) return;

    try {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/voice_${DateTime.now().millisecondsSinceEpoch}.aac';
      
      final success = await _aiService.startRecording(filePath: filePath);
      if (success) {
        setState(() {
          _isRecording = true;
          _statusText = '正在录音...';
          _recordingDuration = 0;
        });

        _pulseController.repeat(reverse: true);
        
        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _recordingDuration++;
          });
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('无法开始录音，请检查麦克风权限')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('录音失败: $e')),
      );
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    setState(() {
      _isRecording = false;
      _statusText = '录音完成';
    });

    _pulseController.stop();
    _recordingTimer?.cancel();

    final filePath = await _aiService.stopRecording();
    if (filePath != null) {
      // TODO: Handle the recorded file
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('录音已保存: $filePath')),
      );
    }
  }

  void _createNoteFromText() {
    if (_recognizedText.isNotEmpty) {
      final noteContent = _recognizedText!.trim();
      final colorService = GetIt.instance<NoteColorService>();
      final note = NoteEntity(
        id: const Uuid().v4(),
        title: '语音识别笔记',
        content: noteContent,
        color: colorService.getNewNoteColor(),
        tags: [],
        isPinned: false,
        userId: AppConstants.userIdKey,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => NoteEditorPageWrapper(
            isNewNote: true,
            note: note,
          ),
        ),
      );
      
      // TODO: Pass the recognized text to the editor
    }
  }

  void _clearText() {
    setState(() {
      _recognizedText = '';
      _statusText = '点击开始录音';
      _recordingDuration = 0;
    });
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '语音笔记',
          style: AppTextStyles.appBarTitle,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          if (_recognizedText.isNotEmpty)
            IconButton(
              onPressed: _clearText,
              icon: const Icon(Icons.clear_rounded),
              tooltip: '清除',
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              // Status and Timer
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  children: [
                    Text(
                      _statusText,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: _isListening || _isRecording 
                            ? AppColors.primary 
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (_isRecording) ...[
                      SizedBox(height: 8.h),
                      Text(
                        _formatDuration(_recordingDuration),
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(height: 32.h),

              // Recording Button
              Center(
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: (_isListening || _isRecording) ? _pulseAnimation.value : 1.0,
                      child: GestureDetector(
                        onTap: () {
                          if (_isListening) {
                            _stopListening();
                          } else if (_isRecording) {
                            _stopRecording();
                          } else {
                            _startListening();
                          }
                        },
                        child: Container(
                          width: 120.w,
                          height: 120.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                (_isListening || _isRecording) ? AppColors.primary : AppColors.secondary,
                                (_isListening || _isRecording) ? AppColors.secondary : AppColors.primary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            (_isListening || _isRecording) ? Icons.stop_rounded : Icons.mic_rounded,
                            size: 48.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 32.h),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: (_isListening || _isRecording) ? null : _startListening,
                    icon: Icon(Icons.mic_rounded, size: 18.sp),
                    label: const Text('语音转文字'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: (_isListening || _isRecording) ? null : _startRecording,
                    icon: Icon(Icons.fiber_manual_record_rounded, size: 18.sp),
                    label: const Text('录音'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // Recognized Text
              if (_recognizedText.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '识别结果:',
                      style: AppTextStyles.titleMedium,
                    ),
                    ElevatedButton.icon(
                      onPressed: _createNoteFromText,
                      icon: Icon(Icons.note_add_rounded, size: 16.sp),
                      label: const Text('创建笔记'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Expanded(
                  child: Container(
                    width: double.infinity,
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
                        _recognizedText,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // Welcome State
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100.w,
                          height: 100.w,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(50.r),
                          ),
                          child: Icon(
                            Icons.mic_rounded,
                            size: 50.sp,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Text(
                          '智能语音笔记',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          '语音转文字或录音保存\n支持中英文识别',
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