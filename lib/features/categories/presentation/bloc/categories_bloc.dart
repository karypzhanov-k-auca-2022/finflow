import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/category_use_cases.dart';

part 'categories_bloc.freezed.dart';
part 'categories_event.dart';
part 'categories_state.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  CategoriesBloc(this.useCases) : super(const CategoriesState()) {
    on<CategoriesRequested>(_onLoad);
    on<CategorySaved>(_onSave);
    on<CategoryDeleted>(_onDelete);

    _subscription = useCases.onCategoriesChanged.listen((_) {
      add(const CategoriesRequested());
    });
  }

  final CategoryUseCases useCases;
  late final StreamSubscription<void> _subscription;

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }

  Future<void> _onLoad(
    CategoriesRequested event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(state.copyWith(status: CategoriesStatus.loading));
    final result = await useCases.load();
    result.fold(
      (failure) => emit(
        state.copyWith(status: CategoriesStatus.failure, failure: failure),
      ),
      (data) => emit(
        state.copyWith(status: CategoriesStatus.success, categories: data),
      ),
    );
  }

  Future<void> _onSave(
    CategorySaved event,
    Emitter<CategoriesState> emit,
  ) async {
    final result = await useCases.save(event.category);
    result.fold(
      (failure) => emit(
        state.copyWith(status: CategoriesStatus.failure, failure: failure),
      ),
      (_) => add(const CategoriesRequested()),
    );
  }

  Future<void> _onDelete(
    CategoryDeleted event,
    Emitter<CategoriesState> emit,
  ) async {
    final result = await useCases.delete(event.id);
    result.fold(
      (failure) => emit(
        state.copyWith(status: CategoriesStatus.failure, failure: failure),
      ),
      (_) => add(const CategoriesRequested()),
    );
  }
}
