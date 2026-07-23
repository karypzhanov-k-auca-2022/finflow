import 'package:finflow/core/error/failure.dart';
import 'package:finflow/core/error/result.dart';
import 'package:finflow/features/categories/data/datasources/category_local_data_source.dart';
import 'package:finflow/features/categories/data/repositories/category_repository_impl.dart';
import 'package:finflow/features/categories/domain/entities/category.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;
  late CategoryLocalDataSource localDataSource;
  late CategoryRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    localDataSource = CategoryLocalDataSourceImpl(prefs);
    repository = CategoryRepositoryImpl(local: localDataSource);
  });

  group('CategoryRepositoryImpl', () {
    test('returns default categories on first launch', () async {
      final result = await repository.getCategories();
      expect(result, isA<Success<List<Category>>>());
      final categories = (result as Success<List<Category>>).data;
      expect(categories.length, defaultCategoryModels.length);
      expect(categories.first.id, 'salary');
    });

    test('saves a new category and returns it in the category list', () async {
      const newCategory = Category(
        id: 'tech',
        name: 'Electronics',
        iconCodePoint: 57793,
        colorValue: 0xFF2196F3,
      );

      final saveResult = await repository.saveCategory(newCategory);
      expect(saveResult, isA<Success<Category>>());

      final getResult = await repository.getCategories();
      final categories = (getResult as Success<List<Category>>).data;
      expect(categories.any((c) => c.id == 'tech'), isTrue);
    });

    test('returns ValidationFailure if category name is empty', () async {
      const emptyNameCategory = Category(
        id: 'invalid',
        name: '   ',
        iconCodePoint: 57793,
        colorValue: 0xFF2196F3,
      );

      final result = await repository.saveCategory(emptyNameCategory);
      expect(result, isA<Error<Category>>());
      expect((result as Error<Category>).failure, isA<ValidationFailure>());
    });

    test('deletes category by id', () async {
      const newCategory = Category(
        id: 'to_delete',
        name: 'To Delete',
        iconCodePoint: 57793,
        colorValue: 0xFF2196F3,
      );

      await repository.saveCategory(newCategory);
      final deleteResult = await repository.deleteCategory('to_delete');
      expect(deleteResult, isA<Success<void>>());

      final getResult = await repository.getCategories();
      final categories = (getResult as Success<List<Category>>).data;
      expect(categories.any((c) => c.id == 'to_delete'), isFalse);
    });
  });
}
