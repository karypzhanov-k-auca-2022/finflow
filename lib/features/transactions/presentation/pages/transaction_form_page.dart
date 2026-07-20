import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/dependency_injection.dart';
import '../../../../core/error/result.dart';
import '../../../../core/utils/formatters.dart';
import '../../../categories/data/datasources/category_local_data_source.dart';
import '../../../categories/domain/usecases/category_use_cases.dart';
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
  List<Category> availableCategories = defaultCategoryModels;
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
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final res = await getIt<CategoryUseCases>().load();
    if (res is Success<List<Category>> && mounted) {
      setState(() {
        availableCategories = res.data;
        if (!availableCategories.any((c) => c.id == category.id)) {
          availableCategories = [...availableCategories, category];
        }
      });
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
            content: Text(state.failure?.message ?? 'Не удалось сохранить'),
          ),
        );
      }
      if (state.status == FormStatus.success) {
        saved = true;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Транзакция сохранена')));
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
                title: const Text('Выйти без сохранения?'),
                content: const Text('Внесённые изменения будут потеряны.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('Остаться'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: const Text('Выйти'),
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
            widget.transaction == null ? 'Новая транзакция' : 'Редактирование',
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
                    labelText: 'Название',
                    prefixIcon: Icon(Icons.edit_outlined),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Введите название'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: amount,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Сумма',
                    prefixIcon: Icon(Icons.currency_ruble),
                  ),
                  validator: (value) {
                    final parsed = double.tryParse(
                      (value ?? '').replaceAll(',', '.'),
                    );
                    return parsed == null || parsed <= 0
                        ? 'Введите положительную сумму'
                        : null;
                  },
                ),
                const SizedBox(height: 14),
                SegmentedButton<TransactionType>(
                  segments: const [
                    ButtonSegment(
                      value: TransactionType.expense,
                      icon: Icon(Icons.arrow_upward),
                      label: Text('Расход'),
                    ),
                    ButtonSegment(
                      value: TransactionType.income,
                      icon: Icon(Icons.arrow_downward),
                      label: Text('Доход'),
                    ),
                  ],
                  selected: {type},
                  onSelectionChanged: (values) => setState(() {
                    type = values.first;
                    if (type == TransactionType.income) {
                      category = availableCategories.firstWhere(
                        (c) => c.id == 'salary',
                        orElse: () => availableCategories.first,
                      );
                    } else if (category.id == 'salary') {
                      category = availableCategories.firstWhere(
                        (c) => c.id == 'groceries',
                        orElse: () => availableCategories.first,
                      );
                    }
                    dirty = true;
                  }),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<Category>(
                        initialValue: availableCategories.any((c) => c.id == category.id)
                            ? availableCategories.firstWhere((c) => c.id == category.id)
                            : category,
                        decoration: const InputDecoration(
                          labelText: 'Категория',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        items: availableCategories
                            .where(
                              (val) => type == TransactionType.income
                                  ? val.id == 'salary' || val.id == 'transfers'
                                  : val.id != 'salary',
                            )
                            .map(
                              (val) => DropdownMenuItem(
                                value: val,
                                child: Text(val.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              category = value;
                              dirty = true;
                            });
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      tooltip: 'Создать категорию',
                      onPressed: () => _showAddCategoryDialog(context),
                    ),
                  ],
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
                      labelText: 'Дата',
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
                    labelText: 'Заметка (необязательно)',
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
                          ? 'Сохраняем…'
                          : 'Сохранить',
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

  Future<void> _showAddCategoryDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final created = await showDialog<Category>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Новая категория'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Название категории'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () async {
              final text = nameController.text.trim();
              if (text.isEmpty) return;
              final newCat = Category(
                id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
                name: text,
                iconCodePoint: Icons.category_outlined.codePoint,
                colorValue: 0xFF2196F3,
              );
              await getIt<CategoryUseCases>().save(newCat);
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext, newCat);
              }
            },
            child: const Text('Создать'),
          ),
        ],
      ),
    );

    if (created != null && mounted) {
      await _loadCategories();
      setState(() {
        category = created;
        dirty = true;
      });
    }
  }

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
