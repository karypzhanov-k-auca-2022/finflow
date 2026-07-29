import 'package:bloc_test/bloc_test.dart';
import 'package:finflow/core/error/failure.dart';
import 'package:finflow/core/error/result.dart';
import 'package:finflow/features/categories/data/datasources/category_local_data_source.dart';
import 'package:finflow/features/categories/domain/repositories/category_repository.dart';
import 'package:finflow/features/categories/domain/usecases/category_use_cases.dart';
import 'package:finflow/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {
  @override
  Stream<void> get onCategoriesChanged => const Stream<void>.empty();
}

void main() {
  late MockCategoryRepository repository;
  late CategoryUseCases useCases;
  final testCategory = defaultCategoryModels.first;

  setUpAll(() {
    registerFallbackValue(testCategory);
  });

  setUp(() {
    repository = MockCategoryRepository();
    useCases = CategoryUseCases(repository);
  });

  blocTest<CategoriesBloc, CategoriesState>(
    'successfully loads categories',
    build: () {
      when(
        () => repository.getCategories(),
      ).thenAnswer((_) async => Success([testCategory]));
      return CategoriesBloc(useCases);
    },
    act: (bloc) => bloc.add(const CategoriesRequested()),
    expect: () => [
      isA<CategoriesState>().having(
        (s) => s.status,
        'status',
        CategoriesStatus.loading,
      ),
      isA<CategoriesState>()
          .having((s) => s.status, 'status', CategoriesStatus.success)
          .having((s) => s.categories, 'categories', [testCategory]),
    ],
  );

  blocTest<CategoriesBloc, CategoriesState>(
    'emits failure state on category load error',
    build: () {
      when(
        () => repository.getCategories(),
      ).thenAnswer((_) async => const Error(CacheFailure()));
      return CategoriesBloc(useCases);
    },
    act: (bloc) => bloc.add(const CategoriesRequested()),
    expect: () => [
      isA<CategoriesState>().having(
        (s) => s.status,
        'status',
        CategoriesStatus.loading,
      ),
      isA<CategoriesState>().having(
        (s) => s.status,
        'status',
        CategoriesStatus.failure,
      ),
    ],
  );

  blocTest<CategoriesBloc, CategoriesState>(
    'saves category and reloads list',
    build: () {
      when(
        () => repository.saveCategory(any()),
      ).thenAnswer((_) async => Success(testCategory));
      when(
        () => repository.getCategories(),
      ).thenAnswer((_) async => Success([testCategory]));
      return CategoriesBloc(useCases);
    },
    act: (bloc) => bloc.add(CategorySaved(testCategory)),
    expect: () => [
      isA<CategoriesState>().having(
        (s) => s.status,
        'status',
        CategoriesStatus.loading,
      ),
      isA<CategoriesState>()
          .having((s) => s.status, 'status', CategoriesStatus.success)
          .having((s) => s.categories, 'categories', [testCategory]),
    ],
  );

  blocTest<CategoriesBloc, CategoriesState>(
    'deletes category and reloads list',
    build: () {
      when(
        () => repository.deleteCategory(any()),
      ).thenAnswer((_) async => const Success(null));
      when(
        () => repository.getCategories(),
      ).thenAnswer((_) async => const Success([]));
      return CategoriesBloc(useCases);
    },
    act: (bloc) => bloc.add(const CategoryDeleted('cat_1')),
    expect: () => [
      isA<CategoriesState>().having(
        (s) => s.status,
        'status',
        CategoriesStatus.loading,
      ),
      isA<CategoriesState>()
          .having((s) => s.status, 'status', CategoriesStatus.success)
          .having((s) => s.categories, 'categories', isEmpty),
    ],
  );
}
