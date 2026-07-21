import '../../../../core/error/result.dart';
import '../entities/category.dart';

abstract interface class CategoryRepository {
  Stream<void> get onCategoriesChanged;
  Future<Result<List<Category>>> getCategories();
  Future<Result<Category>> saveCategory(Category category);
  Future<Result<void>> deleteCategory(String id);
  Future<Result<void>> clear();
  Future<Result<void>> reseed();
}
