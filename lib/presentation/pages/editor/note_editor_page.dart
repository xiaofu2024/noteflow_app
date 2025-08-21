import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/note_entity.dart';
import '../../bloc/notes/notes_bloc.dart';

class NoteEditorPage extends StatefulWidget {
  final NoteEntity? note;
  final bool isNewNote;

  const NoteEditorPage({
    super.key,
    this.note,
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
    return BlocProvider(
      create: (context) => GetIt.instance<NotesBloc>(),
      child: NoteEditorPage(note: note, isNewNote: isNewNote),
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

  final List<int> _colorOptions = [
    0xFFE91E63,
    0xFF4CAF50,
    0xFF2196F3,
    0xFFFF9800,
    0xFF9C27B0,
    0xFF009688,
    0xFFFFC107,
    0xFFFFFFFF, // White
    0xFFFFEBEE, // Pink
    0xFFE3F2FD, // Blue
    0xFFE8F5E8, // Green
    0xFFFFF3E0, // Orange
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupListeners();
  }

  void _initializeControllers() {
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _titleFocusNode = FocusNode();
    _contentFocusNode = FocusNode();

    if (widget.note != null) {
      _tags = List.from(widget.note!.tags);
      _isPinned = widget.note!.isPinned;
      _selectedColor = widget.note!.color;
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
      final newNote = NoteEntity(
        id: const Uuid().v4(),
        title: title.isEmpty ? '无标题' : title,
        content: content,
        tags: _tags,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPinned: _isPinned,
        isEncrypted: false,
        color: _selectedColor,
        userId: 'user_1', // TODO: Get from user session
        isFavorite: false,
        attachments: [],
      );
      
      notesBloc.add(CreateNoteEvent(newNote));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('添加成功！')),
      );
    } else {
      final updatedNote = widget.note!.copyWith(
        title: title.isEmpty ? '无标题' : title,
        content: content,
        tags: _tags,
        updatedAt: DateTime.now(),
        isPinned: _isPinned,
        color: _selectedColor,
      );
      
      notesBloc.add(UpdateNoteEvent(updatedNote));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('更新成功！')),
      );
    }

    Navigator.of(context).pop();
  }

  void _deleteNote() {
    if (!widget.isNewNote && widget.note != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('删除笔记'),
          content: const Text('确定要删除这条笔记吗？此操作无法撤销。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                context.read<NotesBloc>().add(DeleteNoteEvent(widget.note!.id));
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Close editor
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

  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '选择笔记颜色',
              style: AppTextStyles.titleMedium,
            ),
            SizedBox(height: 16.h),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
              ),
              itemCount: _colorOptions.length,
              itemBuilder: (context, index) {
                final color = _colorOptions[index];
                final isSelected = _selectedColor == color;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                      _hasChanges = true;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(color),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.grey.shade300,
                        width: isSelected ? 3 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check_rounded,
                            color: AppColors.primary,
                            size: 24.sp,
                          )
                        : null,
                  ),
                );
              },
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
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
    // Always use a very light version of the selected color as background
    // to prevent dark backgrounds that make text unreadable
    final hsl = HSLColor.fromColor(selectedColor);
    
    // Ensure the background is always light by setting high lightness and low saturation
    return hsl.withLightness(0.97).withSaturation(0.1).toColor();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotesBloc, NotesState>(
      listener: (context, state) {
        if (state is NotesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
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
              : Theme.of(context).colorScheme.background,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back_rounded,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            actions: [
              IconButton(
                onPressed: _togglePin,
                icon: Icon(
                  _isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                  color: _isPinned ? AppColors.primary : Theme.of(context).colorScheme.onBackground,
                ),
              ),
              IconButton(
                onPressed: _showColorPicker,
                icon: Icon(
                  Icons.palette_outlined,
                  color: Theme.of(context).colorScheme.onBackground,
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
                        ),
                        decoration: InputDecoration(
                          hintText: '标题',
                          hintStyle: AppTextStyles.titleLarge.copyWith(
                            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
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
                          style: AppTextStyles.bodyMedium,
                          decoration: InputDecoration(
                            hintText: '开始写下你的想法...',
                            hintStyle: AppTextStyles.bodyMedium.copyWith(
                              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
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