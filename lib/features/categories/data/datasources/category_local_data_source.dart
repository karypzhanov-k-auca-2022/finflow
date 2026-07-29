import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category_model.dart';

abstract interface class CategoryLocalDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<void> saveCategory(CategoryModel category);
  Future<void> deleteCategory(String id);
  Future<void> clear();
  Future<void> seedIfNeeded();
  Future<void> reseed();
}

const List<CategoryModel> defaultCategoryModels = [
  CategoryModel(
    id: 'salary',
    name: 'Salary',
    iconCodePoint: 0xe481, // Icons.payments_outlined
    colorValue: 0xFF009688, // Teal
  ),
  CategoryModel(
    id: 'groceries',
    name: 'Groceries',
    iconCodePoint: 0xe59a, // Icons.shopping_basket_outlined
    colorValue: 0xFFFF9800, // Orange
  ),
  CategoryModel(
    id: 'transport',
    name: 'Transport',
    iconCodePoint: 0xe1d5, // Icons.directions_bus_outlined
    colorValue: 0xFF2196F3, // Blue
  ),
  CategoryModel(
    id: 'rent',
    name: 'Rent',
    iconCodePoint: 0xe318, // Icons.home_outlined
    colorValue: 0xFF9C27B0, // Purple
  ),
  CategoryModel(
    id: 'cafe',
    name: 'Cafe',
    iconCodePoint: 0xe380, // Icons.local_cafe_outlined
    colorValue: 0xFFFFC107, // Amber
  ),
  CategoryModel(
    id: 'subscriptions',
    name: 'Subscriptions',
    iconCodePoint: 0xe616, // Icons.subscriptions_outlined
    colorValue: 0xFFF44336, // Red
  ),
  CategoryModel(
    id: 'health',
    name: 'Health',
    iconCodePoint: 0xe25b, // Icons.favorite_outline
    colorValue: 0xFFE91E63, // Pink
  ),
  CategoryModel(
    id: 'entertainment',
    name: 'Entertainment',
    iconCodePoint: 0xe404, // Icons.movie_outlined
    colorValue: 0xFF3F51B5, // Indigo
  ),
  CategoryModel(
    id: 'transfers',
    name: 'Transfers',
    iconCodePoint: 0xe627, // Icons.swap_horiz
    colorValue: 0xFF00BCD4, // Cyan
  ),
];

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  CategoryLocalDataSourceImpl(this.preferences);
  final SharedPreferences preferences;
  static const _key = 'finflow_categories_v1';
  static const _seededKey = 'finflow_categories_seeded_v2';

  @override
  Future<List<CategoryModel>> getCategories() async {
    final raw = preferences.getString(_key);
    if (raw == null || raw.isEmpty) {
      return List<CategoryModel>.from(defaultCategoryModels);
    }
    final list = jsonDecode(raw) as List<dynamic>;
    if (list.isEmpty) return List<CategoryModel>.from(defaultCategoryModels);
    return list
        .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> _write(List<CategoryModel> values) async {
    final ok = await preferences.setString(
      _key,
      jsonEncode(values.map((e) => e.toJson()).toList()),
    );
    if (!ok) throw const FormatException('Could not persist categories');
  }

  @override
  Future<void> saveCategory(CategoryModel category) async {
    final values = await getCategories();
    final index = values.indexWhere((item) => item.id == category.id);
    if (index == -1) {
      values.add(category);
    } else {
      values[index] = category;
    }
    await _write(values);
  }

  @override
  Future<void> deleteCategory(String id) async {
    final values = await getCategories()
      ..removeWhere((item) => item.id == id);
    await _write(values);
  }

  @override
  Future<void> clear() => preferences.remove(_key);

  @override
  Future<void> seedIfNeeded() async {
    if (!(preferences.getBool(_seededKey) ?? false)) await reseed();
  }

  @override
  Future<void> reseed() async {
    await _write(defaultCategoryModels);
    await preferences.setBool(_seededKey, true);
  }
}
