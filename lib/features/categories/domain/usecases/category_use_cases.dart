import '../../../../core/error/result.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class CategoryUseCases {
  const CategoryUseCases(this.repository);
  final CategoryRepository repository;

  Stream<void> get onCategoriesChanged => repository.onCategoriesChanged;

  Future<Result<List<Category>>> load() => repository.getCategories();
  Future<Result<Category>> save(Category category) =>
      repository.saveCategory(category);
  Future<Result<void>> delete(String id) => repository.deleteCategory(id);
  Future<Result<void>> clear() => repository.clear();
  Future<Result<void>> reseed() => repository.reseed();
}
