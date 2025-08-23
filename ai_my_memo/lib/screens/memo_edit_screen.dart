import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/memo.dart';
import '../models/category.dart';
import '../providers/memo_provider.dart';
import '../providers/category_provider.dart';

class MemoEditScreen extends StatefulWidget {
  final Memo? memo;
  
  const MemoEditScreen({
    super.key,
    this.memo,
  });

  @override
  State<MemoEditScreen> createState() => _MemoEditScreenState();
}

class _MemoEditScreenState extends State<MemoEditScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _titleFocusNode = FocusNode();
  final _contentFocusNode = FocusNode();
  
  bool _isLoading = false;
  bool _hasChanges = false;
  Category? _selectedCategory;
  
  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupListeners();
    
    // CategoryProviderのカテゴリーをロード
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
      _setupCategorySelection();
    });
  }

  void _initializeData() {
    if (widget.memo != null) {
      _titleController.text = widget.memo!.title;
      _contentController.text = widget.memo!.content;
    }
  }

  void _setupCategorySelection() {
    if (widget.memo?.categoryId != null) {
      final categoryProvider = context.read<CategoryProvider>();
      _selectedCategory = categoryProvider.getCategoryById(widget.memo!.categoryId!);
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

  bool get _isEditing => widget.memo != null;
  
  bool get _canSave {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    return title.isNotEmpty || content.isNotEmpty;
  }

  String get _screenTitle => _isEditing ? 'メモを編集' : '新しいメモ';

  Future<void> _saveMemo() async {
    if (!_canSave) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final title = _titleController.text.trim();
      final content = _contentController.text.trim();
      
      final now = DateTime.now();
      final memoProvider = context.read<MemoProvider>();

      if (_isEditing) {
        final updatedMemo = widget.memo!.copyWith(
          title: title.isEmpty ? 'タイトルなし' : title,
          content: content,
          categoryId: _selectedCategory?.id,
          updatedAt: now,
        );
        await memoProvider.updateMemo(updatedMemo);
      } else {
        final newMemo = Memo(
          title: title.isEmpty ? 'タイトルなし' : title,
          content: content,
          categoryId: _selectedCategory?.id,
          createdAt: now,
          updatedAt: now,
        );
        await memoProvider.addMemo(newMemo);
      }

      setState(() {
        _hasChanges = false;
      });

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存に失敗しました: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteMemo() async {
    if (!_isEditing) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('メモを削除'),
        content: const Text('このメモを削除しますか？この操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final memoProvider = context.read<MemoProvider>();
        await memoProvider.deleteMemo(widget.memo!.id!);
        
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('削除に失敗しました: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('変更を保存'),
        content: const Text('変更が保存されていません。保存しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('保存しない'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('保存する'),
          ),
        ],
      ),
    );

    if (shouldSave == true) {
      await _saveMemo();
      return false;
    }

    return shouldSave == false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && mounted) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_screenTitle),
          actions: [
            if (_isEditing)
              IconButton(
                onPressed: _isLoading ? null : _deleteMemo,
                icon: const Icon(Icons.delete),
                tooltip: '削除',
              ),
            IconButton(
              onPressed: _canSave && !_isLoading ? _saveMemo : null,
              icon: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
              tooltip: '保存',
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                focusNode: _titleFocusNode,
                decoration: const InputDecoration(
                  labelText: 'タイトル',
                  hintText: 'メモのタイトルを入力',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                onSubmitted: (_) {
                  _contentFocusNode.requestFocus();
                },
                maxLength: 100,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              
              // カテゴリー選択
              Consumer<CategoryProvider>(
                builder: (context, categoryProvider, child) {
                  return InkWell(
                    onTap: _isLoading ? null : () => _showCategorySelector(categoryProvider),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.category,
                            color: _selectedCategory != null 
                                ? _selectedCategory!.displayColor 
                                : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedCategory?.name ?? 'カテゴリーを選択',
                              style: TextStyle(
                                color: _selectedCategory != null 
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Colors.grey,
                              ),
                            ),
                          ),
                          if (_selectedCategory != null)
                            IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: _isLoading ? null : () => _clearCategory(),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              
              Expanded(
                child: TextField(
                  controller: _contentController,
                  focusNode: _contentFocusNode,
                  decoration: const InputDecoration(
                    labelText: '内容',
                    hintText: 'メモの内容を入力',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  enabled: !_isLoading,
                ),
              ),
              const SizedBox(height: 16),
              if (_hasChanges)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit,
                        size: 16,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '変更があります',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        floatingActionButton: _canSave && !_isLoading
            ? FloatingActionButton(
                onPressed: _saveMemo,
                tooltip: '保存',
                heroTag: "memo_edit_save_button",
                child: const Icon(Icons.save),
              )
            : null,
      ),
    );
  }

  void _showCategorySelector(CategoryProvider categoryProvider) {
    showModalBottomSheet<Category>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'カテゴリーを選択',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (categoryProvider.categories.isEmpty)
              const Center(
                child: Text(
                  'カテゴリーがありません\nカテゴリー管理から作成してください',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...categoryProvider.categories.map((category) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: category.displayColor,
                    radius: 16,
                    child: Icon(
                      Icons.category,
                      color: _getContrastColor(category.displayColor),
                      size: 16,
                    ),
                  ),
                  title: Text(category.name),
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                      _hasChanges = true;
                    });
                    Navigator.pop(context, category);
                  },
                );
              }),
          ],
        ),
      ),
    );
  }

  void _clearCategory() {
    setState(() {
      _selectedCategory = null;
      _hasChanges = true;
    });
  }

  Color _getContrastColor(Color color) {
    final brightness = ThemeData.estimateBrightnessForColor(color);
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }
}