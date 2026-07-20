import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/budget_model.dart';

abstract interface class BudgetLocalDataSource {
  Future<List<BudgetModel>> getBudgets();
  Future<void> saveBudget(BudgetModel budget);
  Future<void> deleteBudget(String id);
  Future<void> clear();
  Future<void> seedIfNeeded();
  Future<void> reseed();
}

class BudgetLocalDataSourceImpl implements BudgetLocalDataSource {
  BudgetLocalDataSourceImpl(this.preferences);
  final SharedPreferences preferences;
  static const _key = 'finflow_budgets_v1';
  static const _seededKey = 'finflow_budget_seeded_v1';

  @override
  Future<List<BudgetModel>> getBudgets() async {
    final raw = preferences.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    return (jsonDecode(raw) as List<dynamic>)
        .map((item) => BudgetModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> _write(List<BudgetModel> values) async {
    final ok = await preferences.setString(
      _key,
      jsonEncode(values.map((e) => e.toJson()).toList()),
    );
    if (!ok) throw const FormatException('Could not persist budgets');
  }

  @override
  Future<void> saveBudget(BudgetModel budget) async {
    final values = await getBudgets();
    final index = values.indexWhere((item) => item.id == budget.id);
    if (index < 0) {
      values.add(budget);
    } else {
      values[index] = budget;
    }
    await _write(values);
  }

  @override
  Future<void> deleteBudget(String id) async {
    final values = await getBudgets()
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
    final now = DateTime.now();
    await _write([
      BudgetModel(
        id: 'budget-groceries',
        categoryId: 'groceries',
        limit: 24000,
        month: now.month,
        year: now.year,
      ),
      BudgetModel(
        id: 'budget-cafe',
        categoryId: 'cafe',
        limit: 5000,
        month: now.month,
        year: now.year,
      ),
      BudgetModel(
        id: 'budget-entertainment',
        categoryId: 'entertainment',
        limit: 3500,
        month: now.month,
        year: now.year,
      ),
      BudgetModel(
        id: 'budget-transport',
        categoryId: 'transport',
        limit: 4500,
        month: now.month,
        year: now.year,
      ),
    ]);
    await preferences.setBool(_seededKey, true);
  }
}
