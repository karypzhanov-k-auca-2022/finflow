import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/formatters.dart';
import '../../../categories/data/datasources/category_local_data_source.dart';
import '../../../categories/presentation/bloc/categories_bloc.dart';
import '../../../categories/presentation/widgets/add_category_bottom_sheet.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/transaction_form_cubit.dart';

class TransactionFormPage extends StatefulWidget {
  const TransactionFormPage({super.key, this.transaction});
  final FinanceTransaction? transaction;
  @override
  State<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController title;
  late final TextEditingController amount;
  late final TextEditingController note;
  late TransactionType type;
  late Category category;
  late DateTime date;
  bool dirty = false;
  bool saved = false;

  @override
  void initState() {
    super.initState();
    final item = widget.transaction;
    title = TextEditingController(text: item?.title ?? '');
    amount = TextEditingController(
      text: item == null ? '' : item.amount.toStringAsFixed(0),
    );
    note = TextEditingController(text: item?.note ?? '');
    type = item?.type ?? TransactionType.expense;
    category = item?.category ?? defaultCategoryModels.firstWhere((c) => c.id == 'groceries');
    date = item?.date ?? DateTime.now();
    title.addListener(markDirty);
    amount.addListener(markDirty);
    note.addListener(markDirty);
  }

  void markDirty() {
    if (!dirty && mounted) setState(() => dirty = true);
  }

  @override
  void dispose() {
    title.dispose();
    amount.dispose();
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocListener<TransactionFormCubit, TransactionFormState>(
    listener: (context, state) {
      if (state.status == FormStatus.failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
           content: Text(state.failure?.message ?? 'Failed to save'),
          ),
        );
      }
      if (state.status == FormStatus.success) {
        saved = true;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Transaction saved')));
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
                title: const Text('Exit without saving?'),
                content: const Text('Changes will be lost.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('Stay'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: const Text('Exit'),
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
            widget.transaction == null ? 'New transaction' : 'Edit',
          ),
        ),
        body: SafeArea(
          child: Form(
            key: formKey,
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              children: [
                TextFormField(
                  controller: title,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    prefixIcon: Icon(Icons.edit_outlined),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter title'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: amount,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixIcon: Icon(Icons.currency_ruble),
                  ),
                  validator: (value) {
                    final parsed = double.tryParse(
                      (value ?? '').replaceAll(',', '.'),
                    );
                    return parsed == null || parsed <= 0
                        ? 'Enter a positive amount'
                        : null;
                  },
                ),
                const SizedBox(height: 14),
                BlocBuilder<CategoriesBloc, CategoriesState>(
                  builder: (context, catState) {
                    final categoriesList = catState.categories.isNotEmpty
                        ? catState.categories
                        : defaultCategoryModels;
                    return SegmentedButton<TransactionType>(
                      segments: const [
                        ButtonSegment(
                          value: TransactionType.expense,
                          icon: Icon(Icons.arrow_upward),
                          label: Text('Expense'),
                        ),
                        ButtonSegment(
                          value: TransactionType.income,
                          icon: Icon(Icons.arrow_downward),
                          label: Text('Income'),
                        ),
                      ],
                      selected: {type},
                      onSelectionChanged: (values) => setState(() {
                        type = values.first;
                        if (type == TransactionType.income) {
                          category = categoriesList.firstWhere(
                            (c) => c.id == 'salary',
                            orElse: () => categoriesList.first,
                          );
                        } else if (category.id == 'salary') {
                          category = categoriesList.firstWhere(
                            (c) => c.id == 'groceries',
                            orElse: () => categoriesList.first,
                          );
                        }
                        dirty = true;
                      }),
                    );
                  },
                ),
                const SizedBox(height: 14),
                BlocBuilder<CategoriesBloc, CategoriesState>(
                  builder: (context, catState) {
                    final categoriesList = catState.categories.isNotEmpty
                        ? catState.categories
                        : defaultCategoryModels;

                    final filtered = categoriesList.where(
                      (val) => type == TransactionType.income
                          ? val.id == 'salary' || val.id == 'transfers'
                          : val.id != 'salary',
                    ).toList();

                    final selectedCat = filtered.any((c) => c.id == category.id)
                        ? filtered.firstWhere((c) => c.id == category.id)
                        : (filtered.isNotEmpty ? filtered.first : category);

                    const addNewSentinel = Category(
                      id: '__add_new__',
                      name: '+ Create category',
                      iconCodePoint: 0xe047,
                      colorValue: 0xFF2196F3,
                    );

                    return Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<Category>(
                            key: ValueKey(type),
                            initialValue: selectedCat,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              prefixIcon: Icon(Icons.category_outlined),
                            ),
                            items: [
                              ...filtered.map(
                                (val) => DropdownMenuItem(
                                  value: val,
                                  child: Row(
                                    children: [
                                      Icon(val.icon, color: val.color, size: 20),
                                      const SizedBox(width: 8),
                                      Text(val.name),
                                    ],
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: addNewSentinel,
                                child: const Row(
                                  children: [
                                    Icon(Icons.add_circle_outline, color: Colors.blue, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                    '+ Create category',
                                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            onChanged: (value) async {
                              if (value == null) return;
                              if (value.id == '__add_new__') {
                                final created = await showAddCategoryBottomSheet(context);
                                if (created != null && mounted) {
                                  setState(() {
                                    category = created;
                                    dirty = true;
                                  });
                                }
                              } else {
                                setState(() {
                                  category = value;
                                  dirty = true;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 14),
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () async {
                    final selected = await showDatePicker(
                      context: context,
                      initialDate: date,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (selected != null) {
                      setState(() {
                        date = selected;
                        dirty = true;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    child: Text(formatDate(date)),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: note,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.notes),
                  ),
                ),
                const SizedBox(height: 24),
                BlocBuilder<TransactionFormCubit, TransactionFormState>(
                  builder: (context, state) => FilledButton.icon(
                    onPressed: state.status == FormStatus.saving
                        ? null
                        : submit,
                    icon: state.status == FormStatus.saving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                    label: Text(
                      state.status == FormStatus.saving
                          ? 'Saving…'
                          : 'Save',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  void submit() {
    FocusScope.of(context).unfocus();
    if (!(formKey.currentState?.validate() ?? false)) return;
    final now = DateTime.now();
    final old = widget.transaction;
    context.read<TransactionFormCubit>().submit(
      FinanceTransaction(
        id: old?.id ?? 'tx-${now.microsecondsSinceEpoch}',
        title: title.text.trim(),
        amount: double.parse(amount.text.replaceAll(',', '.')),
        type: type,
        category: category,
        date: date,
        note: note.text.trim(),
        createdAt: old?.createdAt ?? now,
        updatedAt: now,
      ),
    );
  }
}
