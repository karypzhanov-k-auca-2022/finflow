import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_spacing.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/extensions/l10n_x.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../../core/utils/category_x.dart';
import '../../../../categories/data/datasources/category_local_data_source.dart';
import '../../../../categories/presentation/bloc/categories_bloc.dart';
import '../../../../categories/presentation/widgets/add_category_bottom_sheet.dart';
import '../../../domain/entities/transaction.dart';
import '../cubit/transaction_form_cubit.dart';

class TransactionFormPage extends StatefulWidget {
  const TransactionFormPage({super.key, this.transaction});

  final FinanceTransaction? transaction;

  @override
  State<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage>
    with RestorationMixin {
  final formKey = GlobalKey<FormState>();
  late final RestorableTextEditingController title;
  late final RestorableTextEditingController amount;
  late final RestorableTextEditingController note;
  late final RestorableInt typeIndex;
  late final RestorableString categoryId;
  late final RestorableDateTime date;
  bool _listenersAttached = false;
  bool dirty = false;
  bool saved = false;

  @override
  String? get restorationId => widget.transaction == null
      ? 'new_transaction_form'
      : 'edit_transaction_${widget.transaction!.id}';

  @override
  void initState() {
    super.initState();
    final item = widget.transaction;
    title = RestorableTextEditingController(text: item?.title ?? '');
    amount = RestorableTextEditingController(
      text: item == null ? '' : item.amount.toStringAsFixed(0),
    );
    note = RestorableTextEditingController(text: item?.note ?? '');
    typeIndex = RestorableInt((item?.type ?? TransactionType.expense).index);
    categoryId = RestorableString(item?.category.id ?? 'groceries');
    date = RestorableDateTime(_notAfterToday(item?.date ?? DateTime.now()));
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(title, 'title');
    registerForRestoration(amount, 'amount');
    registerForRestoration(note, 'note');
    registerForRestoration(typeIndex, 'type');
    registerForRestoration(categoryId, 'category');
    registerForRestoration(date, 'date');
    final allowedDate = _notAfterToday(date.value);
    if (allowedDate != date.value) date.value = allowedDate;
    if (!_listenersAttached) {
      title.value.addListener(markDirty);
      amount.value.addListener(markDirty);
      note.value.addListener(markDirty);
      _listenersAttached = true;
    }
  }

  void markDirty() {
    if (!dirty && mounted) setState(() => dirty = true);
  }

  @override
  void dispose() {
    title.dispose();
    amount.dispose();
    note.dispose();
    typeIndex.dispose();
    categoryId.dispose();
    date.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocListener<TransactionFormCubit, TransactionFormState>(
        listener: (context, state) {
          if (state.status == FormStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.failure?.message ?? context.l10n.failedToSave,
                ),
              ),
            );
          }
          if (state.status == FormStatus.success) {
            HapticFeedback.lightImpact();
            saved = true;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.transactionSaved)),
            );
            context.pop();
          }
        },
        child: PopScope(
          canPop: !dirty || saved,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop || saved || !dirty) return;
            final leave =
                await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: Text(context.l10n.exitWithoutSaving),
                    content: Text(context.l10n.changesWillBeLost),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: Text(context.l10n.stay),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: Text(context.l10n.exit),
                      ),
                    ],
                  ),
                ) ??
                false;
            if (leave && context.mounted) {
              saved = true;
              context.pop();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                widget.transaction == null
                    ? context.l10n.newTransaction
                    : context.l10n.edit,
              ),
            ),
            body: SafeArea(child: _buildResponsiveForm(context)),
          ),
        ),
      );

  Widget _buildResponsiveForm(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final contentWidth = math.min(constraints.maxWidth - 32, 920.0);
      final isWide = contentWidth >= 680;
      final fieldWidth = isWide ? (contentWidth - 14) / 2 : contentWidth;
      final categoriesState = context.watch<CategoriesBloc>().state;
      final categories = categoriesState.categories.isNotEmpty
          ? categoriesState.categories
          : defaultCategoryModels;
      final transactionType = TransactionType.values[typeIndex.value];
      final filtered = categories
          .where(
            (value) => transactionType == TransactionType.income
                ? value.id == 'salary' || value.id == 'transfers'
                : value.id != 'salary',
          )
          .toList();
      if (filtered.isNotEmpty &&
          !filtered.any((value) => value.id == categoryId.value)) {
        categoryId.value = filtered.first.id;
      }

      Widget field(Widget child, {bool fullWidth = false}) =>
          SizedBox(width: fullWidth ? contentWidth : fieldWidth, child: child);

      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 952),
          child: Form(
            key: formKey,
            child: ListView(
              restorationId: 'transaction_form_scroll',
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                AppSpacing.large,
                AppSpacing.large,
                AppSpacing.large,
                MediaQuery.viewInsetsOf(context).bottom + AppSpacing.large,
              ),
              children: [
                Wrap(
                  spacing: AppSpacing.mediumLarge,
                  runSpacing: AppSpacing.mediumLarge,
                  children: [
                    field(
                      TextFormField(
                        key: const Key('transaction_title_field'),
                        controller: title.value,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          labelText: context.l10n.title,
                          prefixIcon: const Icon(Icons.edit_outlined),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? context.l10n.enterTitle
                            : null,
                      ),
                    ),
                    field(
                      TextFormField(
                        key: const Key('transaction_amount_field'),
                        controller: amount.value,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: context.l10n.amount,
                          prefixIcon: const Icon(Icons.currency_ruble),
                        ),
                        validator: (value) {
                          final parsed = double.tryParse(
                            (value ?? '').replaceAll(',', '.'),
                          );
                          return parsed == null || parsed <= 0
                              ? context.l10n.enterPositiveAmount
                              : null;
                        },
                      ),
                    ),
                    field(
                      SegmentedButton<TransactionType>(
                        segments: [
                          ButtonSegment(
                            value: TransactionType.expense,
                            icon: const Icon(Icons.arrow_upward),
                            label: Text(context.l10n.expense),
                          ),
                          ButtonSegment(
                            value: TransactionType.income,
                            icon: const Icon(Icons.arrow_downward),
                            label: Text(context.l10n.income),
                          ),
                        ],
                        selected: {transactionType},
                        onSelectionChanged: (values) {
                          final selected = values.first;
                          setState(() {
                            typeIndex.value = selected.index;
                            final matches = categories.where(
                              (value) => selected == TransactionType.income
                                  ? value.id == 'salary' ||
                                        value.id == 'transfers'
                                  : value.id != 'salary',
                            );
                            if (matches.isNotEmpty &&
                                !matches.any(
                                  (value) => value.id == categoryId.value,
                                )) {
                              categoryId.value = matches.first.id;
                            }
                            dirty = true;
                          });
                        },
                      ),
                    ),
                    field(
                      DropdownButtonFormField<String>(
                        key: ValueKey(transactionType),
                        isExpanded: true,
                        initialValue: categoryId.value,
                        decoration: InputDecoration(
                          labelText: context.l10n.category,
                          prefixIcon: const Icon(Icons.category_outlined),
                        ),
                        items: [
                          ...filtered.map(
                            (value) => DropdownMenuItem(
                              value: value.id,
                              child: Row(
                                children: [
                                  Icon(
                                    value.icon,
                                    color: value.color,
                                    size: 20,
                                  ),
                                  const SizedBox(width: AppSpacing.small),
                                  Flexible(
                                    child: Text(
                                      value.localizedName(context),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: '__add_new__',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                const SizedBox(width: AppSpacing.small),
                                Flexible(
                                  child: Text(
                                    '+ ${context.l10n.createCategory}',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (value) async {
                          if (value == null) return;
                          if (value == '__add_new__') {
                            final created = await showAddCategoryBottomSheet(
                              context,
                            );
                            if (created != null && mounted) {
                              setState(() {
                                categoryId.value = created.id;
                                dirty = true;
                              });
                            }
                          } else {
                            setState(() {
                              categoryId.value = value;
                              dirty = true;
                            });
                          }
                        },
                      ),
                    ),
                    field(
                      InkWell(
                        key: const Key('transaction_date_field'),
                        borderRadius: BorderRadius.circular(14),
                        onTap: () async {
                          final today = DateUtils.dateOnly(DateTime.now());
                          final selected = await showDatePicker(
                            context: context,
                            initialDate: _notAfterToday(date.value),
                            firstDate: DateTime(2020),
                            lastDate: today,
                          );
                          if (selected != null) {
                            setState(() {
                              date.value = selected;
                              dirty = true;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: context.l10n.date,
                            prefixIcon: const Icon(
                              Icons.calendar_today_outlined,
                            ),
                          ),
                          child: Text(formatDate(date.value)),
                        ),
                      ),
                    ),
                    field(
                      TextFormField(
                        controller: note.value,
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          labelText: context.l10n.noteOptional,
                          alignLabelWithHint: true,
                          prefixIcon: const Icon(Icons.notes),
                        ),
                      ),
                    ),
                    field(
                      BlocBuilder<TransactionFormCubit, TransactionFormState>(
                        builder: (context, state) => FilledButton.icon(
                          onPressed: state.status == FormStatus.saving
                              ? null
                              : () => submit(categories),
                          icon: state.status == FormStatus.saving
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.check),
                          label: Text(
                            state.status == FormStatus.saving
                                ? context.l10n.saving
                                : context.l10n.save,
                          ),
                        ),
                      ),
                      fullWidth: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  void submit(List<Category> categories) {
    FocusScope.of(context).unfocus();
    if (!(formKey.currentState?.validate() ?? false)) return;
    final now = DateTime.now();
    final old = widget.transaction;
    final selectedCategory = categories.firstWhere(
      (value) => value.id == categoryId.value,
      orElse: () => defaultCategoryModels.first,
    );
    context.read<TransactionFormCubit>().submit(
      FinanceTransaction(
        id: old?.id ?? 'tx-${now.microsecondsSinceEpoch}',
        title: title.value.text.trim(),
        amount: double.parse(amount.value.text.replaceAll(',', '.')),
        type: TransactionType.values[typeIndex.value],
        category: selectedCategory,
        date: _notAfterToday(date.value),
        note: note.value.text.trim(),
        createdAt: old?.createdAt ?? now,
        updatedAt: now,
      ),
    );
  }

  DateTime _notAfterToday(DateTime value) {
    final today = DateUtils.dateOnly(DateTime.now());
    return value.isAfter(today) ? today : value;
  }
}
