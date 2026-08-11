import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/extensions/l10n_x.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/utils/category_x.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../categories/data/datasources/category_local_data_source.dart';
import '../../../../categories/presentation/bloc/categories_bloc.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/usecases/transaction_use_cases.dart';

class TransactionFiltersPage extends StatefulWidget {
  const TransactionFiltersPage({super.key, required this.initialFilter});

  final TransactionFilter initialFilter;

  @override
  State<TransactionFiltersPage> createState() => _TransactionFiltersPageState();
}

class _TransactionFiltersPageState extends State<TransactionFiltersPage> {
  late TransactionFilter draft;

  @override
  void initState() {
    super.initState();
    draft = widget.initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = context.watch<CategoriesBloc>().state;
    final categories = <Category>[
      ...(categoryState.categories.isNotEmpty
          ? categoryState.categories
          : defaultCategoryModels),
    ];
    if (draft.category != null &&
        !categories.any((value) => value.id == draft.category!.id)) {
      categories.insert(0, draft.category!);
    }

    return Scaffold(
      key: const Key('transaction_filters_page'),
      appBar: AppBar(title: Text(context.l10n.filtersAndSorting)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.large,
            AppSpacing.medium,
            AppSpacing.large,
            AppSpacing.pageBottom,
          ),
          children: [
            SegmentedButton<TransactionType?>(
              segments: [
                ButtonSegment(value: null, label: Text(context.l10n.all)),
                ButtonSegment(
                  value: TransactionType.income,
                  label: Text(context.l10n.income),
                ),
                ButtonSegment(
                  value: TransactionType.expense,
                  label: Text(context.l10n.expenses),
                ),
              ],
              selected: {draft.type},
              onSelectionChanged: (value) => setState(
                () => draft = draft.copyWith(
                  type: value.first,
                  clearType: value.first == null,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.mediumLarge),
            DropdownButtonFormField<Category?>(
              initialValue: draft.category,
              decoration: InputDecoration(labelText: context.l10n.category),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(context.l10n.allCategories),
                ),
                ...categories.map(
                  (value) => DropdownMenuItem(
                    value: value,
                    child: Text(value.localizedName(context)),
                  ),
                ),
              ],
              onChanged: (value) => setState(
                () => draft = draft.copyWith(
                  category: value,
                  clearCategory: value == null,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.mediumLarge),
            DropdownButtonFormField<TransactionPeriod>(
              initialValue: draft.period,
              decoration: InputDecoration(
                labelText: context.l10n.period,
                prefixIcon: const Icon(Icons.date_range),
              ),
              items: [
                DropdownMenuItem(
                  value: TransactionPeriod.all,
                  child: Text(context.l10n.allTime),
                ),
                DropdownMenuItem(
                  value: TransactionPeriod.month,
                  child: Text(context.l10n.currentMonth),
                ),
                DropdownMenuItem(
                  value: TransactionPeriod.threeMonths,
                  child: Text(context.l10n.threeMonths),
                ),
                DropdownMenuItem(
                  value: TransactionPeriod.sixMonths,
                  child: Text(context.l10n.sixMonths),
                ),
                DropdownMenuItem(
                  value: TransactionPeriod.year,
                  child: Text(context.l10n.year),
                ),
                DropdownMenuItem(
                  value: TransactionPeriod.customRange,
                  child: Text(context.l10n.selectRange),
                ),
              ],
              onChanged: _selectPeriod,
            ),
            if (draft.period == TransactionPeriod.customRange) ...[
              const SizedBox(height: AppSpacing.small),
              OutlinedButton.icon(
                onPressed: _selectCustomRange,
                icon: const Icon(Icons.edit_calendar),
                label: Text(
                  draft.from != null && draft.to != null
                      ? '${formatDate(draft.from!)} — ${formatDate(draft.to!)}'
                      : context.l10n.selectDateRange,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.mediumLarge),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<TransactionSort>(
                    initialValue: draft.sort,
                    decoration: InputDecoration(labelText: context.l10n.sortBy),
                    items: [
                      DropdownMenuItem(
                        value: TransactionSort.date,
                        child: Text(context.l10n.date),
                      ),
                      DropdownMenuItem(
                        value: TransactionSort.amount,
                        child: Text(context.l10n.amount),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => draft = draft.copyWith(sort: value)),
                  ),
                ),
                const SizedBox(width: AppSpacing.medium),
                IconButton.filledTonal(
                  onPressed: () => setState(
                    () => draft = draft.copyWith(
                      direction: draft.direction == SortDirection.ascending
                          ? SortDirection.descending
                          : SortDirection.ascending,
                    ),
                  ),
                  icon: Icon(
                    draft.direction == SortDirection.ascending
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                  ),
                  tooltip: context.l10n.direction,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.extraLarge),
            FilledButton(
              key: const Key('apply_transaction_filters'),
              onPressed: () => Navigator.pop(context, draft),
              child: Text(context.l10n.apply),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectPeriod(TransactionPeriod? value) async {
    if (value == null) return;
    if (value == TransactionPeriod.customRange) {
      final selected = await _pickDateRange();
      if (selected == null || !mounted) return;
      setState(
        () => draft = draft.copyWith(
          period: TransactionPeriod.customRange,
          from: selected.start,
          to: selected.end,
        ),
      );
      return;
    }
    setState(
      () =>
          draft = draft.copyWith(period: value, clearFrom: true, clearTo: true),
    );
  }

  Future<void> _selectCustomRange() async {
    final selected = await _pickDateRange();
    if (selected == null || !mounted) return;
    setState(
      () => draft = draft.copyWith(
        period: TransactionPeriod.customRange,
        from: selected.start,
        to: selected.end,
      ),
    );
  }

  Future<DateTimeRange?> _pickDateRange() => showDateRangePicker(
    context: context,
    firstDate: DateTime(2020),
    lastDate: DateTime.now().add(const Duration(days: 365)),
    initialDateRange: draft.from != null && draft.to != null
        ? DateTimeRange(start: draft.from!, end: draft.to!)
        : null,
  );
}
