import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/user_preferences_service.dart';
import '../../../core/services/note_color_service.dart';
import '../../../domain/entities/note_entity.dart';
import '../../bloc/notes/notes_bloc.dart';
import '../../widgets/note_color_picker.dart';

class NoteEditorPage extends StatefulWidget {
  final NoteEntity? noteParam;
  final bool isNewNote;

  const NoteEditorPage({
    super.key,
    this.noteParam,
    this.isNewNote = true,
  });

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class NoteEditorPageWrapper extends StatelessWidget {
  final NoteEntity? note;
  final bool isNewNote;

  const NoteEditorPageWrapper({
    super.key,
    this.note,
    this.isNewNote = true,
  });

  @override
  Widget build(BuildContext context) {
    // Editor page needs its own BlocProvider since it's navigated via push
    // and is not in the MainNavigationPage widget tree
    return BlocProvider.value(
      value: GetIt.instance<NotesBloc>(),
      child: NoteEditorPage(noteParam: note, isNewNote: isNewNote),
    );
  }
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late FocusNode _titleFocusNode;
  late FocusNode _contentFocusNode;
  
  List<String> _tags = [];
  bool _isPinned = false;
  int? _selectedColor;
  bool _hasChanges = false;
  late NoteColorService _colorService;

  @override
  void initState() {
    super.initState();
    _colorService = GetIt.instance<NoteColorService>();
    _initializeControllers();
    _setupListeners();
  }

  void _initializeControllers() {
    _titleController = TextEditingController(text: widget.noteParam?.title ?? '');
    _contentController = TextEditingController(text: widget.noteParam?.content ?? '');
    _titleFocusNode = FocusNode();
    _contentFocusNode = FocusNode();

    if (widget.noteParam != null) {
      _tags = List.from(widget.noteParam!.tags);
      _isPinned = widget.noteParam!.isPinned;
      _selectedColor = widget.noteParam!.color;
    } else {
      // Auto-focus title for new notes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _titleFocusNode.requestFocus();
      });
    }
  }

  void _setupListeners() {
    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('笔记内容不能为空')),
      );
      return;
    }

    final notesBloc = context.read<NotesBloc>();
    
    if (widget.isNewNote) {
      // 确定笔记颜色：用户选择 > 默认颜色 > 随机颜色
      int noteColor = _selectedColor ?? _colorService.getNewNoteColor();
      
      final newNote = NoteEntity(
        id: const Uuid().v4(),
        title: title.isEmpty ? '无标题' : title,
        content: content,
        tags: _tags,
        createdAt: widget.noteParam?.createdAt ?? DateTime.now(),
        updatedAt: widget.noteParam?.updatedAt ?? DateTime.now(),
        isPinned: _isPinned,
        isEncrypted: false,
        color: noteColor,
        userId: 'user_1', // TODO: Get from user session
        isFavorite: false,
        attachments: [],
      );
      
      notesBloc.add(CreateNoteEvent(newNote));
    } else {
      final updatedNote = widget.noteParam!.copyWith(
        title: title.isEmpty ? '无标题' : title,
        content: content,
        tags: _tags,
        updatedAt: DateTime.now(),
        isPinned: _isPinned,
        color: _selectedColor,
      );
      
      notesBloc.add(UpdateNoteEvent(updatedNote));
    }

    // Don't navigate immediately, let BlocListener handle it
    setState(() {
      _hasChanges = false;
    });
  }

  void _deleteNote() {
    if (!widget.isNewNote && widget.noteParam != null) {
      final notesBloc = context.read<NotesBloc>();
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('删除笔记'),
          content: const Text('确定要删除这条笔记吗？此操作无法撤销。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
                notesBloc.add(DeleteNoteEvent(widget.noteParam!.id));
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('删除'),
            ),
          ],
        ),
      );
    }
  }

  void _togglePin() {
    setState(() {
      _isPinned = !_isPinned;
      _hasChanges = true;
    });
  }

  Future<void> _showColorPicker() async {
    final selectedColor = await showDialog<int?>(
      context: context,
      builder: (context) => NoteColorPickerDialog(
        initialColor: _selectedColor,
        title: '选择笔记颜色',
        showDefaultOption: true,
      ),
    );

    if (selectedColor != _selectedColor) {
      setState(() {
        _selectedColor = selectedColor;
        _hasChanges = true;
      });
      
      // Save the color preference for this note if it's not a new note
      if (!widget.isNewNote && widget.noteParam != null) {
        await _colorService.setNoteColor(widget.noteParam!.id, selectedColor);
      }
    }
  }

  void _showTagSuggestions() {
    if (_tags.isNotEmpty) {
      final firstTag = _tags.first;
      final suggestedColor = _colorService.getSuggestedColorForTag(firstTag);
      
      if (suggestedColor != null && suggestedColor != _selectedColor) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '建议使用${NoteColorUtils.getColorName(suggestedColor)}标签"$firstTag"',
            ),
            action: SnackBarAction(
              label: '应用',
              onPressed: () {
                setState(() {
                  _selectedColor = suggestedColor;
                  _hasChanges = true;
                });
              },
            ),
          ),
        );
      }
    }
  }

  void _addTag() {
    showDialog(
      context: context,
      builder: (context) {
        final tagController = TextEditingController();
        return AlertDialog(
          title: const Text('添加标签'),
          content: TextField(
            controller: tagController,
            decoration: const InputDecoration(
              hintText: '输入标签名称',
              prefixIcon: Icon(Icons.tag),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                final tag = tagController.text.trim();
                if (tag.isNotEmpty && !_tags.contains(tag)) {
                  setState(() {
                    _tags.add(tag);
                    _hasChanges = true;
                  });
                  
                  // Show color suggestion for the new tag
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _showTagSuggestions();
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('添加'),
            ),
          ],
        );
      },
    );
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
      _hasChanges = true;
    });
  }

  Color _getSafeBackgroundColor(Color selectedColor) {
    final brightness = Theme.of(context).brightness;
    final hsl = HSLColor.fromColor(selectedColor);
    
    if (brightness == Brightness.dark) {
      // 夜间模式：使用深色版本，但保持可读性
      return hsl.withLightness(0.15).withSaturation(0.3).toColor();
    } else {
      // 日间模式：使用浅色版本
      return hsl.withLightness(0.95).withSaturation(0.2).toColor();
    }
  }

  double get _userFontSize {
    try {
      return GetIt.instance<UserPreferencesService>().fontSize;
    } catch (e) {
      return 14.0; // fallback to default
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotesBloc, NotesState>(
      listener: (context, state) {
        if (state is NotesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('操作失败: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is NoteDeleted) {
          // Close editor page
          Navigator.of(context).pop();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('笔记已删除'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is NoteCreated) {
          // Close editor page and show success message
          Navigator.of(context).pop();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('添加成功！'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is NoteUpdated) {
          // Close editor page and show success message
          Navigator.of(context).pop();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('更新成功！'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      child: WillPopScope(
        onWillPop: () async {
          if (_hasChanges) {
            final shouldSave = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('保存更改'),
                content: const Text('是否保存对笔记的更改？'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('不保存'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('保存'),
                  ),
                ],
              ),
            );
            
            if (shouldSave == true) {
              _saveNote();
              return false; // Don't pop immediately, let save handle it
            }
          }
          return true;
        },
        child: Scaffold(
          backgroundColor: _selectedColor != null 
              ? _getSafeBackgroundColor(Color(_selectedColor!))
              : Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back_rounded,
                color: _selectedColor != null 
                    ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87)
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            actions: [
              IconButton(
                onPressed: _togglePin,
                icon: Icon(
                  _isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                  color: _isPinned 
                      ? AppColors.primary 
                      : (_selectedColor != null 
                          ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87)
                          : Theme.of(context).colorScheme.onSurface),
                ),
              ),
              IconButton(
                onPressed: _showColorPicker,
                icon: Icon(
                  Icons.palette_outlined,
                  color: _selectedColor != null 
                      ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87)
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
              if (!widget.isNewNote)
                IconButton(
                  onPressed: _deleteNote,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                  ),
                ),
              IconButton(
                onPressed: _saveNote,
                icon: Icon(
                  Icons.check_rounded,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title input
                      TextField(
                        controller: _titleController,
                        focusNode: _titleFocusNode,
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: (_userFontSize + 6).sp,
                        ),
                        decoration: InputDecoration(
                          hintText: '标题',
                          hintStyle: AppTextStyles.titleLarge.copyWith(
                            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                            fontSize: (_userFontSize + 6).sp,
                          ),
                          border: InputBorder.none,
                        ),
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _contentFocusNode.requestFocus(),
                      ),
                      
                      SizedBox(height: 8.h),
                      
                      // Tags section
                      if (_tags.isNotEmpty) ...[
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 4.h,
                          children: [
                            ..._tags.map((tag) => Chip(
                              label: Text(
                                '#$tag',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              deleteIcon: Icon(
                                Icons.close_rounded,
                                size: 16.sp,
                              ),
                              onDeleted: () => _removeTag(tag),
                            )),
                            GestureDetector(
                              onTap: _addTag,
                              child: Chip(
                                label: Icon(
                                  Icons.add_rounded,
                                  size: 16.sp,
                                  color: AppColors.primary,
                                ),
                                backgroundColor: AppColors.primary.withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                      ] else ...[
                        GestureDetector(
                          onTap: _addTag,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.tag,
                                  size: 16.sp,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  '添加标签',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                      ],
                      
                      // Content input
                      Expanded(
                        child: TextField(
                          controller: _contentController,
                          focusNode: _contentFocusNode,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: _userFontSize.sp,
                          ),
                          decoration: InputDecoration(
                            hintText: '开始写下你的想法...',
                            hintStyle: AppTextStyles.bodyMedium.copyWith(
                              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                              fontSize: _userFontSize.sp,
                            ),
                            border: InputBorder.none,
                          ),
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}