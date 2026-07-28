import 'package:flutter/material.dart';
import '../../features/categories/domain/entities/category.dart';

extension CategoryX on Category {
  /// Returns a complementary container background color based on the category color.
  Color get containerColor => color.withValues(alpha: 0.15);

  /// Checks if the category matches a given search query.
  bool matches(String query) {
    if (query.trim().isEmpty) return true;
    return name.toLowerCase().contains(query.trim().toLowerCase());
  }
}
