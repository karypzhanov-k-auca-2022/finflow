import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/budget_model.dart';

abstract interface class BudgetLocalDataSource {
  Future<List<BudgetModel>> getBudgets([String? userId]);
  Future<void> saveBudget(BudgetModel budget, [String? userId]);
  Future<void> deleteBudget(String id, [String? userId]);
  Future<void> clear([String? userId]);
  Future<void> seedIfNeeded([String? userId]);
  Future<void> reseed([String? userId]);
}

class BudgetLocalDataSourceImpl implements BudgetLocalDataSource {
  BudgetLocalDataSourceImpl(this.preferences);
  final SharedPreferences preferences;

  String _getKey(String? userId) {
    if (userId == null || userId.isEmpty || userId == 'guest') {
      return 'finflow_budgets_guest_v1';
    }
    return 'finflow_budgets_user_$userId';
  }

  String _getSeededKey(String? userId) {
    if (userId == null || userId.isEmpty || userId == 'guest') {
      return 'finflow_budget_seeded_guest_v2';
    }
    return 'finflow_budget_seeded_user_$userId';
  }

  @override
  Future<List<BudgetModel>> getBudgets([String? userId]) async {
    await seedIfNeeded(userId);
    final key = _getKey(userId);
    final raw = preferences.getString(key);
    if (raw == null || raw.isEmpty) return [];
    return (jsonDecode(raw) as List<dynamic>)
        .map((item) => BudgetModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> _write(List<BudgetModel> values, [String? userId]) async {
    final key = _getKey(userId);
    final ok = await preferences.setString(
      key,
      jsonEncode(values.map((e) => e.toJson()).toList()),
    );
    if (!ok) throw const FormatException('Could not persist budgets');
  }

  @override
  Future<void> saveBudget(BudgetModel budget, [String? userId]) async {
    final values = await getBudgets(userId);
    final index = values.indexWhere((item) => item.id == budget.id);
    if (index < 0) {
      values.add(budget);
    } else {
      values[index] = budget;
    }
    await _write(values, userId);
  }

  @override
  Future<void> deleteBudget(String id, [String? userId]) async {
    final values = await getBudgets(userId)
      ..removeWhere((item) => item.id == id);
    await _write(values, userId);
  }

  @override
  Future<void> clear([String? userId]) => preferences.remove(_getKey(userId));

  @override
  Future<void> seedIfNeeded([String? userId]) async {
    final seededKey = _getSeededKey(userId);
    if (!(preferences.getBool(seededKey) ?? false)) {
      await reseed(userId);
    }
  }

  @override
  Future<void> reseed([String? userId]) async {
    final now = DateTime.now();
    final isGuest = userId == null || userId.isEmpty || userId == 'guest';
    if (isGuest) {
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
      ], userId);
    } else {
      // New registered users start with clean budgets
      await _write([], userId);
    }
    await preferences.setBool(_getSeededKey(userId), true);
  }
}
