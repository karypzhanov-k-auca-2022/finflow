import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/category_use_cases.dart';

part 'categories_bloc.freezed.dart';

sealed class CategoriesEvent extends Equatable {
  const CategoriesEvent();
  @override
  List<Object?> get props => [];
}

final class CategoriesRequested extends CategoriesEvent {
  const CategoriesRequested();
}

final class CategorySaved extends CategoriesEvent {
  const CategorySaved(this.category);
  final Category category;
  @override
  List<Object?> get props => [category];
}

final class CategoryDeleted extends CategoriesEvent {
  const CategoryDeleted(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

enum CategoriesStatus { initial, loading, success, failure }

@freezed
abstract class CategoriesState with _$CategoriesState {
  const factory CategoriesState({
    @Default(CategoriesStatus.initial) CategoriesStatus status,
    @Default([]) List<Category> categories,
    Failure? failure,
  }) = _CategoriesState;
}

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
