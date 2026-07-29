import 'package:flutter/material.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../../core/utils/category_x.dart';
import '../../../../../core/widgets/currency_text.dart';
import '../../../domain/entities/transaction.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.transaction, this.onTap});
  final FinanceTransaction transaction;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final income = transaction.type == TransactionType.income;
    return ListTile(
      key: ValueKey(transaction.id),
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: transaction.category.color.withValues(alpha: .16),
        child: Icon(
          transaction.category.icon,
          color: transaction.category.color,
        ),
      ),
      title: Text(
        transaction.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${transaction.category.localizedName(context)} • ${formatDate(transaction.date)}',
      ),
      trailing: CurrencyText(
        income ? transaction.amount : -transaction.amount,
        color: income ? Colors.green : Theme.of(context).colorScheme.onSurface,
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}
