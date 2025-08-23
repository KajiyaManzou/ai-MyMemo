import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../models/category.dart';

class CategoryEditScreen extends StatefulWidget {
  final Category? category;

  const CategoryEditScreen({super.key, this.category});

  bool get isEditing => category != null;

  @override
  State<CategoryEditScreen> createState() => _CategoryEditScreenState();
}

class _CategoryEditScreenState extends State<CategoryEditScreen> {
  late final TextEditingController _nameController;
  Color _selectedColor = Colors.blue;
  bool _isLoading = false;
  String? _nameError;

  static final List<Color> _defaultColors = Category.defaultColors;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _selectedColor = widget.category?.color ?? Colors.blue;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'カテゴリーを編集' : '新しいカテゴリー'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmDelete,
              tooltip: 'カテゴリーを削除',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // カテゴリー名入力
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'カテゴリー名',
                hintText: 'カテゴリー名を入力してください',
                errorText: _nameError,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.category),
              ),
              textInputAction: TextInputAction.done,
              onChanged: _onNameChanged,
              enabled: !_isLoading,
            ),
            
            const SizedBox(height: 24),
            
            // 色選択
            Text(
              'カテゴリー色',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            
            // カラーパレット
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _defaultColors.map((color) {
                final isSelected = color.value == _selectedColor.value;
                return GestureDetector(
                  onTap: _isLoading ? null : () => _onColorSelected(color),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 3,
                            )
                          : Border.all(
                              color: Colors.grey.withOpacity(0.3),
                              width: 1,
                            ),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            color: _getContrastColor(color),
                            size: 24,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 32),
            
            // プレビュー
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'プレビュー',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: _selectedColor,
                        radius: 16,
                        child: Icon(
                          Icons.category,
                          color: _getContrastColor(_selectedColor),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _nameController.text.trim().isEmpty
                              ? 'カテゴリー名'
                              : _nameController.text.trim(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: _nameController.text.trim().isEmpty
                                ? Colors.grey
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // 保存ボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading || _nameController.text.trim().isEmpty || _nameError != null
                    ? null
                    : _saveCategory,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.isEditing ? '更新' : '作成'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getContrastColor(Color color) {
    final brightness = ThemeData.estimateBrightnessForColor(color);
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }

  void _onNameChanged(String value) {
    setState(() {
      _nameError = _validateName(value.trim());
    });
  }

  void _onColorSelected(Color color) {
    setState(() {
      _selectedColor = color;
    });
  }

  String? _validateName(String name) {
    if (name.isEmpty) {
      return 'カテゴリー名を入力してください';
    }
    if (name.length > 20) {
      return 'カテゴリー名は20文字以内で入力してください';
    }

    final categoryProvider = context.read<CategoryProvider>();
    if (categoryProvider.isCategoryNameExists(name, excludeId: widget.category?.id)) {
      return 'このカテゴリー名は既に存在します';
    }

    return null;
  }

  void _saveCategory() async {
    final name = _nameController.text.trim();
    final validationError = _validateName(name);
    
    if (validationError != null) {
      setState(() {
        _nameError = validationError;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final categoryProvider = context.read<CategoryProvider>();
      
      if (widget.isEditing) {
        // 更新
        final updatedCategory = widget.category!.copyWith(
          name: name,
          color: _selectedColor,
        );
        await categoryProvider.updateCategory(updatedCategory);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('カテゴリーを更新しました'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // 新規作成
        final newCategory = Category(
          name: name,
          color: _selectedColor,
          createdAt: DateTime.now(),
        );
        await categoryProvider.addCategory(newCategory);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('カテゴリーを作成しました'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存に失敗しました: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
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

  void _confirmDelete() {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('カテゴリーを削除'),
        content: Text('「${widget.category!.name}」を削除してもよろしいですか？\n\n削除後、このカテゴリーが設定されたメモはカテゴリーなしになります。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('削除'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        _deleteCategory();
      }
    });
  }

  void _deleteCategory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<CategoryProvider>().deleteCategory(widget.category!.id!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('「${widget.category!.name}」を削除しました'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('削除に失敗しました: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
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