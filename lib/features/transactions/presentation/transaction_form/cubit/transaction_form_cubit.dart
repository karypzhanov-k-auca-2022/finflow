import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/error/failure.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/usecases/transaction_use_cases.dart';

part 'transaction_form_state.dart';

class TransactionFormCubit extends Cubit<TransactionFormState> {
  TransactionFormCubit(this.useCases) : super(const TransactionFormState());
  final TransactionUseCases useCases;

  Future<void> submit(FinanceTransaction transaction) async {
    if (state.status == FormStatus.saving) return;
    emit(const TransactionFormState(status: FormStatus.saving));
    final result = await useCases.save(transaction);
    result.fold(
      (failure) => emit(
        TransactionFormState(status: FormStatus.failure, failure: failure),
      ),
      (_) => emit(const TransactionFormState(status: FormStatus.success)),
    );
  }
}
