import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/dependency_injection.dart';
import '../../../../core/error/result.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../../transactions/domain/usecases/transaction_use_cases.dart';
import '../../../transactions/presentation/widgets/transaction_tile.dart';
import '../../domain/entities/budget.dart';

class BudgetDetailsSheet extends StatelessWidget {
  const BudgetDetailsSheet({
    super.key,
    required this.budget,
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  final Budget budget;
  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = budget.isExceeded
        ? scheme.error
        : budget.isWarning
        ? Colors.orange
        : scheme.primary;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          // Header Card
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: category.color.withValues(alpha: 0.15),
                      child: Icon(category.icon, color: category.color, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            '${formatMoney(budget.spent)} of ${formatMoney(budget.limit)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    IconButton.outlined(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      tooltip: 'Edit limit',
                    ),
                    const SizedBox(width: 8),
                    IconButton.outlined(
                      onPressed: onDelete,
                      icon: Icon(Icons.delete_outline, color: scheme.error, size: 20),
                      tooltip: 'Delete budget',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: budget.progress.clamp(0, 1),
                  minHeight: 12,
                  borderRadius: BorderRadius.circular(8),
                  color: color,
                ),
                const SizedBox(height: 8),
                Text(
                  budget.isExceeded
                      ? 'Limit exceeded by ${formatMoney(budget.spent - budget.limit)}'
                      : budget.isWarning
                      ? 'More than 80% of budget used'
                      : 'Remaining ${formatMoney(budget.limit - budget.spent)}',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Transactions List Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Category Transactions',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),

          // List of Category Transactions
          Expanded(
            child: FutureBuilder<Result<TransactionsResult>>(
              future: getIt<TransactionUseCases>().load(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingView();
                }

                final result = snapshot.data;
                if (result == null || result is Error<TransactionsResult>) {
                  return const Center(child: Text('Failed to load transactions'));
                }

                final all = (result as Success<TransactionsResult>).data.transactions;
                final categoryTxList = all.where((tx) {
                  return tx.category.id == budget.categoryId &&
                      tx.type == TransactionType.expense &&
                      tx.date.month == budget.month &&
                      tx.date.year == budget.year;
                }).toList();

                if (categoryTxList.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No expense transactions found for this category in this month.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  controller: scrollController,
                  itemCount: categoryTxList.length,
                  itemBuilder: (context, index) {
                    final tx = categoryTxList[index];
                    return TransactionTile(
                      transaction: tx,
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/transactions/${tx.id}/edit');
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
