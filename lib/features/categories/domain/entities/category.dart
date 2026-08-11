import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.colorValue,
  });

  final String id;
  final String name;
  final int iconCodePoint;
  final int colorValue;

  IconData get icon => switch (iconCodePoint) {
    0xe481 || 0xf266 => Icons.payments_outlined,
    0xe59a || 0xf37e => Icons.shopping_basket_outlined,
    0xe1d5 || 0xefc4 => Icons.directions_bus_outlined,
    0xe318 || 0xf107 => Icons.home_outlined,
    0xe380 || 0xf175 => Icons.local_cafe_outlined,
    0xe616 || 0xf3fb => Icons.subscriptions_outlined,
    0xe25b || 0xe25c => Icons.favorite_outline,
    0xe404 || 0xf1f5 => Icons.movie_outlined,
    0xe627 || 0xe625 => Icons.swap_horiz,
    0xe28d => Icons.fitness_center,
    0xe6f4 => Icons.work_outline,
    0xe4a1 => Icons.pets,
    0xe297 => Icons.flight,
    0xe559 => Icons.school,
    0xe532 => Icons.restaurant,
    0xe5e8 => Icons.sports_esports,
    0xef06 => Icons.build_outlined,
    0xf1be => Icons.medical_services_outlined,
    0xf17c => Icons.local_gas_station_outlined,
    0xef2d => Icons.card_giftcard_outlined,
    _ => Icons.category_outlined,
  };
  Color get color => Color(colorValue);
  String get label => name;

  @override
  List<Object?> get props => [id, name, iconCodePoint, colorValue];
}
