import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/extensions/l10n_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/category_x.dart';
import '../bloc/categories_bloc.dart';
import '../widgets/add_category_bottom_sheet.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.categoriesTitle)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'categories_fab',
        onPressed: () => showAddCategoryBottomSheet(context),
        icon: const Icon(Icons.add),
        label: Text(context.l10n.newCategory),
      ),
      body: BlocBuilder<CategoriesBloc, CategoriesState>(
        builder: (context, state) => switch (state.status) {
          CategoriesStatus.initial ||
          CategoriesStatus.loading => const LoadingView(),
          CategoriesStatus.failure => ErrorState(
            message:
                state.failure?.message ?? context.l10n.failedToLoadCategories,
            onRetry: () =>
                context.read<CategoriesBloc>().add(const CategoriesRequested()),
          ),
          CategoriesStatus.success when state.categories.isEmpty => EmptyState(
            title: context.l10n.noCategories,
            message: context.l10n.noCategoriesMessage,
            action: FilledButton(
              onPressed: () => showAddCategoryBottomSheet(context),
              child: Text(context.l10n.createCategory),
            ),
          ),
          CategoriesStatus.success => ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.large,
              AppSpacing.small,
              AppSpacing.large,
              AppSpacing.pageBottom,
            ),
            itemCount: state.categories.length,
            itemBuilder: (context, index) {
              final cat = state.categories[index];
              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.small),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: cat.color.withValues(alpha: .15),
                    child: Icon(cat.icon, color: cat.color),
                  ),
                  title: Text(
                    cat.localizedName(context),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        tooltip: context.l10n.edit,
                        onPressed: () =>
                            showAddCategoryBottomSheet(context, category: cat),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        tooltip: context.l10n.delete,
                        onPressed: () async {
                          final confirm = await showConfirmation(
                            context,
                            title: context.l10n.deleteCategoryQuestion,
                            message: context.l10n.categoryWillBeDeleted(
                              cat.localizedName(context),
                            ),
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
