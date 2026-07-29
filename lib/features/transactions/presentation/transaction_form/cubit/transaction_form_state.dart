part of 'transaction_form_cubit.dart';

enum FormStatus { initial, saving, success, failure }

class TransactionFormState extends Equatable {
  const TransactionFormState({this.status = FormStatus.initial, this.failure});

  final FormStatus status;
  final Failure? failure;

  @override
  List<Object?> get props => [status, failure];
}
