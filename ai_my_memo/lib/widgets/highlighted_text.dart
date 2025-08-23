import 'package:flutter/material.dart';

class HighlightedText extends StatelessWidget {
  final String text;
  final String searchQuery;
  final TextStyle? style;
  final TextStyle? highlightStyle;
  final int? maxLines;
  final TextOverflow? overflow;

  const HighlightedText({
    super.key,
    required this.text,
    required this.searchQuery,
    this.style,
    this.highlightStyle,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    if (searchQuery.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    final List<TextSpan> spans = [];
    final String lowerText = text.toLowerCase();
    final String lowerQuery = searchQuery.toLowerCase();
    
    int start = 0;
    int index = lowerText.indexOf(lowerQuery);
    
    final TextStyle defaultHighlightStyle = highlightStyle ??
        TextStyle(
          backgroundColor: Colors.yellow.withValues(alpha: 0.6),
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        );

    while (index != -1) {
      // マッチしない部分を追加
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: style,
        ));
      }
      
      // ハイライト部分を追加
      spans.add(TextSpan(
        text: text.substring(index, index + searchQuery.length),
        style: defaultHighlightStyle,
      ));
      
      start = index + searchQuery.length;
      index = lowerText.indexOf(lowerQuery, start);
    }
    
    // 残りの部分を追加
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: style,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}