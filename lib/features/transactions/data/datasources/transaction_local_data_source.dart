import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../categories/data/datasources/category_local_data_source.dart';
import '../../../categories/data/models/category_model.dart';
import '../models/transaction_model.dart';
import '../../domain/entities/transaction.dart';

abstract interface class TransactionLocalDataSource {
  Future<List<TransactionModel>> getTransactions([String? userId]);
  Future<void> saveTransaction(TransactionModel transaction, [String? userId]);
  Future<void> deleteTransaction(String id, [String? userId]);
  Future<void> clear([String? userId]);
  Future<void> seedIfNeeded([String? userId]);
  Future<void> reseed([String? userId]);
}

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  TransactionLocalDataSourceImpl(this.preferences, [this.categoryDataSource]);
  final SharedPreferences preferences;
  final CategoryLocalDataSource? categoryDataSource;

  String _getKey(String? userId) {
    if (userId == null || userId.isEmpty || userId == 'guest') {
      return 'finflow_transactions_guest_v1';
    }
    return 'finflow_transactions_user_$userId';
  }

  String _getSeededKey(String? userId) {
    if (userId == null || userId.isEmpty || userId == 'guest') {
      return 'finflow_seeded_guest_v2';
    }
    return 'finflow_seeded_user_$userId';
  }

  @override
  Future<List<TransactionModel>> getTransactions([String? userId]) async {
    await seedIfNeeded(userId);
    final key = _getKey(userId);
    final raw = preferences.getString(key);
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
      await _write(transactions, userId);
    }

    return transactions;
  }

  Future<void> _write(List<TransactionModel> values, [String? userId]) async {
    final key = _getKey(userId);
    final ok = await preferences.setString(
      key,
      jsonEncode(values.map((e) => e.toJson()).toList()),
    );
    if (!ok) throw const FormatException('Could not persist transactions');
  }

  @override
  Future<void> saveTransaction(TransactionModel transaction, [String? userId]) async {
    final values = await getTransactions(userId);
    final index = values.indexWhere((item) => item.id == transaction.id);
    if (index == -1) {
      values.add(transaction);
    } else {
      values[index] = transaction;
    }
    await _write(values, userId);
  }

  @override
  Future<void> deleteTransaction(String id, [String? userId]) async {
    final values = await getTransactions(userId)
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
    final isGuest = userId == null || userId.isEmpty || userId == 'guest';
    if (isGuest) {
      await _write(_demoTransactions(), userId);
    } else {
      // New registered users start with a clean account
      await _write([], userId);
    }
    await preferences.setBool(_getSeededKey(userId), true);
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
