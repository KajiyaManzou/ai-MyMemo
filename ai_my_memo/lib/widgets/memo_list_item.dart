import 'package:flutter/material.dart';
import '../models/memo.dart';

class MemoListItem extends StatelessWidget {
  final Memo memo;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;

  const MemoListItem({
    super.key,
    required this.memo,
    this.onTap,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 4.0,
        vertical: 4.0,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      memo.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (memo.isFavorite)
                    Icon(
                      Icons.favorite,
                      color: Colors.red[300],
                      size: 20,
                    ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: onFavoriteToggle,
                    icon: Icon(
                      memo.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: memo.isFavorite ? Colors.red[300] : Colors.grey,
                      size: 20,
                    ),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    tooltip: memo.isFavorite ? 'お気に入りから削除' : 'お気に入りに追加',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (memo.content.isNotEmpty)
                Text(
                  memo.preview,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    memo.formattedUpdatedAt,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                  const Spacer(),
                  if (memo.hasCategory)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'カテゴリー',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}