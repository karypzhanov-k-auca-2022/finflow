import 'package:flutter/material.dart';
import '../extensions/l10n_x.dart';
import '../../features/categories/domain/entities/category.dart';

extension CategoryX on Category {
  /// Returns a complementary container background color based on the category color.
  Color get containerColor => color.withValues(alpha: 0.15);

  String localizedName(BuildContext context) => switch (id) {
    'salary' => context.l10n.categorySalary,
    'groceries' => context.l10n.categoryGroceries,
    'transport' => context.l10n.categoryTransport,
    'rent' => context.l10n.categoryRent,
    'cafe' => context.l10n.categoryCafe,
    'subscriptions' => context.l10n.categorySubscriptions,
    'health' => context.l10n.categoryHealth,
    'entertainment' => context.l10n.categoryEntertainment,
    'transfers' => context.l10n.categoryTransfers,
    _ => name,
  };

  /// Checks if the category matches a given search query.
  bool matches(String query) {
    if (query.trim().isEmpty) return true;
    return name.toLowerCase().contains(query.trim().toLowerCase());
  }
}
