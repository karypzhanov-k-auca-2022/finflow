import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../categories/data/datasources/category_local_data_source.dart';
import '../../../categories/data/models/category_model.dart';
import '../models/transaction_model.dart';
import '../../domain/entities/transaction.dart';

abstract interface class TransactionLocalDataSource {
  Future<List<TransactionModel>> getTransactions();
  Future<void> saveTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);
  Future<void> clear();
  Future<void> seedIfNeeded();
  Future<void> reseed();
}

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  TransactionLocalDataSourceImpl(this.preferences, [this.categoryDataSource]);
  final SharedPreferences preferences;
  final CategoryLocalDataSource? categoryDataSource;
  static const _key = 'finflow_transactions_v1';
  static const _seededKey = 'finflow_seeded_v2';

  @override
  Future<List<TransactionModel>> getTransactions() async {
    final raw = preferences.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    
    List<CategoryModel> categories = defaultCategoryModels;
    if (categoryDataSource != null) {
      try {
        categories = await categoryDataSource!.getCategories();
      } catch (_) {}
    }

    var needsMigration = false;
    final transactions = list.map((item) {
      final jsonMap = item as Map<String, dynamic>;
      if (jsonMap['category'] is String) {
        needsMigration = true;
      }
      return TransactionModel.fromJson(jsonMap, categories);
    }).toList();

    if (needsMigration) {
      await _write(transactions);
    }

    return transactions;
  }

  Future<void> _write(List<TransactionModel> values) async {
    final ok = await preferences.setString(
      _key,
      jsonEncode(values.map((e) => e.toJson()).toList()),
    );
    if (!ok) throw const FormatException('Could not persist transactions');
  }

  @override
  Future<void> saveTransaction(TransactionModel transaction) async {
    final values = await getTransactions();
    final index = values.indexWhere((item) => item.id == transaction.id);
    if (index == -1) {
      values.add(transaction);
    } else {
      values[index] = transaction;
    }
    await _write(values);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final values = await getTransactions()
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
    await _write(_demoTransactions());
    await preferences.setBool(_seededKey, true);
  }
}

CategoryModel _getCat(String id) {
  return defaultCategoryModels.firstWhere(
    (c) => c.id == id,
    orElse: () => defaultCategoryModels.first,
  );
}

List<TransactionModel> _demoTransactions() {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, 1);
  final values = <TransactionModel>[];
  var id = 0;
  void add(
    int offset,
    int day,
    String title,
    double amount,
    TransactionType type,
    String categoryId, [
    String note = '',
  ]) {
    final effectiveDay = offset == 0 && day > now.day ? now.day : day;
    final date = DateTime(start.year, start.month - offset, effectiveDay);
    final stamp = DateTime(2025, 1, 1).add(Duration(minutes: id));
    values.add(
      TransactionModel(
        id: 'demo-${id++}',
        title: title,
        amount: amount,
        type: type,
        category: _getCat(categoryId),
        date: date,
        note: note,
        createdAt: stamp,
        updatedAt: stamp,
      ),
    );
  }

  for (var month = 0; month < 6; month++) {
    add(
      month,
      2,
      'Salary',
      125000,
      TransactionType.income,
      'salary',
      'Main job',
    );
    add(
      month,
      4,
      'Apartment rent',
      42000,
      TransactionType.expense,
      'rent',
    );
    add(
      month,
      7,
      'Supermarket',
      7800 + month * 190,
      TransactionType.expense,
      'groceries',
    );
    add(
      month,
      11,
      'Transport pass',
      2400,
      TransactionType.expense,
      'transport',
    );
    add(
      month,
      15,
      'Coffee with friends',
      1800,
      TransactionType.expense,
      'cafe',
    );
    add(
      month,
      18,
      'Music and movies',
      990,
      TransactionType.expense,
      'subscriptions',
    );
    add(
      month,
      22,
      'Entertainment',
      4200 + month * 250,
      TransactionType.expense,
      'entertainment',
    );
    add(
      month,
      25,
      'Transfer to family',
      6000,
      TransactionType.expense,
      'transfers',
    );
  }
  add(0, 9, 'Pharmacy', 3600, TransactionType.expense, 'health');
  add(
    0,
    20,
  'Big grocery shop',
    19500,
    TransactionType.expense,
    'groceries',
  'Supplies for the month',
  );
  return values;
}
