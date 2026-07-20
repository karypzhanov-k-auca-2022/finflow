import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../budgets/domain/usecases/budget_use_cases.dart';
import '../../../transactions/domain/usecases/transaction_use_cases.dart';

enum SettingsActionStatus { idle, working, success, failure }

class SettingsActionState extends Equatable {
  const SettingsActionState({
    this.status = SettingsActionStatus.idle,
    this.message = '',
  });
  final SettingsActionStatus status;
  final String message;
  @override
  List<Object?> get props => [status, message];
}

class SettingsCubit extends Cubit<SettingsActionState> {
  SettingsCubit(this.transactions, this.budgets)
    : super(const SettingsActionState());
  final TransactionUseCases transactions;
  final BudgetUseCases budgets;

  Future<void> clearData() async {
    emit(const SettingsActionState(status: SettingsActionStatus.working));
    final transactionResult = await transactions.clear();
    final budgetResult = await budgets.clear();
    final failed = transactionResult.fold(
      (failure) => failure.message,
      (_) => budgetResult.fold((failure) => failure.message, (_) => null),
    );
    emit(
      SettingsActionState(
        status: failed == null
            ? SettingsActionStatus.success
            : SettingsActionStatus.failure,
        message: failed ?? 'Данные очищены',
      ),
    );
  }

  Future<void> seedData() async {
    emit(const SettingsActionState(status: SettingsActionStatus.working));
    final transactionResult = await transactions.reseed();
    final budgetResult = await budgets.reseed();
    final failed = transactionResult.fold(
      (failure) => failure.message,
      (_) => budgetResult.fold((failure) => failure.message, (_) => null),
    );
    emit(
      SettingsActionState(
        status: failed == null
            ? SettingsActionStatus.success
            : SettingsActionStatus.failure,
        message: failed ?? 'Демо-данные восстановлены',
      ),
    );
  }
}
