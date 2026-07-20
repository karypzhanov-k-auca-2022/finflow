import 'package:flutter/material.dart';
import '../../features/transactions/domain/entities/transaction.dart';

extension AppCategoryX on AppCategory {
  String get label => switch (this) {
    AppCategory.salary => 'Зарплата',
    AppCategory.groceries => 'Продукты',
    AppCategory.transport => 'Транспорт',
    AppCategory.rent => 'Аренда',
    AppCategory.cafe => 'Кафе',
    AppCategory.subscriptions => 'Подписки',
    AppCategory.health => 'Здоровье',
    AppCategory.entertainment => 'Развлечения',
    AppCategory.transfers => 'Переводы',
  };

  IconData get icon => switch (this) {
    AppCategory.salary => Icons.payments_outlined,
    AppCategory.groceries => Icons.shopping_basket_outlined,
    AppCategory.transport => Icons.directions_bus_outlined,
    AppCategory.rent => Icons.home_outlined,
    AppCategory.cafe => Icons.local_cafe_outlined,
    AppCategory.subscriptions => Icons.subscriptions_outlined,
    AppCategory.health => Icons.favorite_outline,
    AppCategory.entertainment => Icons.movie_outlined,
    AppCategory.transfers => Icons.swap_horiz,
  };

  Color get color => Colors.primaries[index % Colors.primaries.length].shade400;
}
