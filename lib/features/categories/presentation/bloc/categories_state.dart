part of 'categories_bloc.dart';

enum CategoriesStatus { initial, loading, success, failure }

@freezed
abstract class CategoriesState with _$CategoriesState {
  const factory CategoriesState({
    @Default(CategoriesStatus.initial) CategoriesStatus status,
    @Default([]) List<Category> categories,
    Failure? failure,
  }) = _CategoriesState;
}
