import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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
  TransactionLocalDataSourceImpl(this.preferences);
  final SharedPreferences preferences;
  static const _key = 'finflow_transactions_v1';
  static const _seededKey = 'finflow_seeded_v1';

  @override
  Future<List<TransactionModel>> getTransactions() async {
    final raw = preferences.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((item) => TransactionModel.fromJson(item as Map<String, dynamic>))
        .toList();
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
    AppCategory category, [
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
        category: category,
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
      'Зарплата',
      125000,
      TransactionType.income,
      AppCategory.salary,
      'Основная работа',
    );
    add(
      month,
      4,
      'Аренда квартиры',
      42000,
      TransactionType.expense,
      AppCategory.rent,
    );
    add(
      month,
      7,
      'Супермаркет',
      7800 + month * 190,
      TransactionType.expense,
      AppCategory.groceries,
    );
    add(
      month,
      11,
      'Проездной',
      2400,
      TransactionType.expense,
      AppCategory.transport,
    );
    add(
      month,
      15,
      'Кофе с друзьями',
      1800,
      TransactionType.expense,
      AppCategory.cafe,
    );
    add(
      month,
      18,
      'Музыка и кино',
      990,
      TransactionType.expense,
      AppCategory.subscriptions,
    );
    add(
      month,
      22,
      'Развлечения',
      4200 + month * 250,
      TransactionType.expense,
      AppCategory.entertainment,
    );
    add(
      month,
      25,
      'Перевод семье',
      6000,
      TransactionType.expense,
      AppCategory.transfers,
    );
  }
  add(0, 9, 'Аптека', 3600, TransactionType.expense, AppCategory.health);
  add(
    0,
    20,
    'Большая закупка',
    19500,
    TransactionType.expense,
    AppCategory.groceries,
    'Запасы на месяц',
  );
  return values;
}
