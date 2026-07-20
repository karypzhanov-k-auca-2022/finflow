import 'dart:async';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/utils/logger_mixin.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_data_source.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl with LoggerMixin implements CategoryRepository {
  CategoryRepositoryImpl({required this.local});
  final CategoryLocalDataSource local;

  final _changeController = StreamController<void>.broadcast();

  @override
  Stream<void> get onCategoriesChanged => _changeController.stream;

  @override
  Future<Result<List<Category>>> getCategories() async {
    try {
      final models = await local.getCategories();
      return Success(models);
    } catch (e, stack) {
      logError('Failed to get categories', e, stack);
      return const Error(CacheFailure('Не удалось загрузить категории'));
    }
  }

  @override
  Future<Result<Category>> saveCategory(Category category) async {
    if (category.name.trim().isEmpty) {
      return const Error(ValidationFailure('Укажите название категории'));
    }
    try {
      final model = CategoryModel.fromEntity(category);
      await local.saveCategory(model);
      _changeController.add(null);
      return Success(category);
    } catch (e, stack) {
      logError('Failed to save category', e, stack);
      return const Error(CacheFailure('Не удалось сохранить категорию'));
    }
  }

  @override
  Future<Result<void>> deleteCategory(String id) async {
    try {
      await local.deleteCategory(id);
      _changeController.add(null);
      return const Success(null);
    } catch (e, stack) {
      logError('Failed to delete category', e, stack);
      return const Error(CacheFailure('Не удалось удалить категорию'));
    }
  }

  @override
  Future<Result<void>> reseed() async {
    try {
      await local.reseed();
      _changeController.add(null);
      return const Success(null);
    } catch (e, stack) {
      logError('Failed to reseed categories', e, stack);
      return const Error(CacheFailure());
    }
  }
}
