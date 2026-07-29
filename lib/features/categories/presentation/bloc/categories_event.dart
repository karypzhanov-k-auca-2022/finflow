part of 'categories_bloc.dart';

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
