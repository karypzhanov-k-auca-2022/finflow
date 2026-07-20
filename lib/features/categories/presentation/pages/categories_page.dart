import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/state_views.dart';
import '../../data/datasources/category_local_data_source.dart';
import '../bloc/categories_bloc.dart';
import '../widgets/add_category_bottom_sheet.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Категории'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'categories_fab',
        onPressed: () => showAddCategoryBottomSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Новая категория'),
      ),
      body: BlocBuilder<CategoriesBloc, CategoriesState>(
        builder: (context, state) => switch (state.status) {
          CategoriesStatus.initial ||
          CategoriesStatus.loading => const LoadingView(),
          CategoriesStatus.failure => ErrorState(
            message: state.failure?.message ?? 'Не удалось загрузить категории',
            onRetry: () => context.read<CategoriesBloc>().add(
              const CategoriesRequested(),
            ),
          ),
          CategoriesStatus.success when state.categories.isEmpty => EmptyState(
            title: 'Нет категорий',
            message: 'Создайте первую категорию для учёта финансов.',
            action: FilledButton(
              onPressed: () => showAddCategoryBottomSheet(context),
              child: const Text('Создать категорию'),
            ),
          ),
          CategoriesStatus.success => ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: state.categories.length,
            itemBuilder: (context, index) {
              final cat = state.categories[index];
              final isDefault = defaultCategoryModels.any((d) => d.id == cat.id);
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: cat.color.withValues(alpha: .15),
                    child: Icon(cat.icon, color: cat.color),
                  ),
                  title: Text(
                    cat.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: isDefault
                      ? Text(
                          'Системная категория',
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        tooltip: 'Редактировать',
                        onPressed: () => showAddCategoryBottomSheet(
                          context,
                          category: cat,
                        ),
                      ),
                      if (!isDefault)
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          tooltip: 'Удалить',
                          onPressed: () async {
                            final confirm = await showConfirmation(
                              context,
                              title: 'Удалить категорию?',
                              message: 'Категория «${cat.name}» будет удалена.',
                            );
                            if (confirm && context.mounted) {
                              context.read<CategoriesBloc>().add(
                                CategoryDeleted(cat.id),
                              );
                            }
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        },
      ),
    );
  }
}
