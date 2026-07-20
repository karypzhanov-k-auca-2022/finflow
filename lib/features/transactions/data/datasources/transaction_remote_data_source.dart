import 'package:dio/dio.dart';
import '../models/transaction_model.dart';

abstract interface class TransactionRemoteDataSource {
  Future<List<TransactionModel>> getTransactions();
  Future<void> saveTransaction(
    TransactionModel transaction, {
    required bool isNew,
  });
  Future<void> deleteTransaction(String id);
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  TransactionRemoteDataSourceImpl(this.dio);
  final Dio dio;

  @override
  Future<List<TransactionModel>> getTransactions() async {
    final response = await dio.get<List<dynamic>>('/transactions');
    return (response.data ?? [])
        .map((item) => TransactionModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveTransaction(
    TransactionModel transaction, {
    required bool isNew,
  }) async {
    if (isNew) {
      await dio.post<void>('/transactions', data: transaction.toJson());
    } else {
      await dio.put<void>(
        '/transactions/${transaction.id}',
        data: transaction.toJson(),
      );
    }
  }

  @override
  Future<void> deleteTransaction(String id) =>
      dio.delete<void>('/transactions/$id');
}
