import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/category.dart';
import '../bloc/categories_bloc.dart';

const List<Color> presetCategoryColors = [
  Color(0xFF009688), // Teal
  Color(0xFFFF9800), // Orange
  Color(0xFF2196F3), // Blue
  Color(0xFF9C27B0), // Purple
  Color(0xFFFFC107), // Amber
  Color(0xFFF44336), // Red
  Color(0xFFE91E63), // Pink
  Color(0xFF3F51B5), // Indigo
  Color(0xFF00BCD4), // Cyan
  Color(0xFF4CAF50), // Green
  Color(0xFFFF5722), // Deep Orange
  Color(0xFF795548), // Brown
];

const List<IconData> presetCategoryIcons = [
  Icons.shopping_basket_outlined,
  Icons.payments_outlined,
  Icons.directions_bus_outlined,
  Icons.home_outlined,
  Icons.local_cafe_outlined,
  Icons.subscriptions_outlined,
  Icons.favorite_outline,
  Icons.movie_outlined,
  Icons.swap_horiz,
  Icons.fitness_center,
  Icons.work_outline,
  Icons.pets,
  Icons.flight,
  Icons.school,
  Icons.restaurant,
  Icons.sports_esports,
  Icons.build_outlined,
  Icons.medical_services_outlined,
  Icons.local_gas_station_outlined,
  Icons.card_giftcard_outlined,
];

Future<Category?> showAddCategoryBottomSheet(
  BuildContext context, {
  Category? category,
}) {
  return showModalBottomSheet<Category>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => AddCategoryBottomSheet(category: category),
  );
}

class AddCategoryBottomSheet extends StatefulWidget {
  const AddCategoryBottomSheet({super.key, this.category});
  final Category? category;

  @override
  State<AddCategoryBottomSheet> createState() => _AddCategoryBottomSheetState();
}

class _AddCategoryBottomSheetState extends State<AddCategoryBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late Color _selectedColor;
  late IconData _selectedIcon;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _selectedColor = widget.category?.color ?? presetCategoryColors.first;
    _selectedIcon = widget.category?.icon ?? presetCategoryIcons.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing ? 'Редактировать категорию' : 'Новая категория',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                autofocus: !isEditing,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Название категории',
                  prefixIcon: Icon(Icons.label_outlined),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Введите название категории'
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                'Цвет',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: presetCategoryColors.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final color = presetCategoryColors[index];
                    final isSelected = color == _selectedColor;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 3)
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 20)
                            : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Иконка',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 140,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: presetCategoryIcons.length,
                  itemBuilder: (context, index) {
                    final icon = presetCategoryIcons[index];
                    final isSelected = icon.codePoint == _selectedIcon.codePoint;
                    return InkWell(
                      onTap: () => setState(() => _selectedIcon = icon),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _selectedColor.withValues(alpha: .2)
                              : Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(color: _selectedColor, width: 2)
                              : null,
                        ),
                        child: Icon(
                          icon,
                          color: isSelected ? _selectedColor : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.check),
                label: Text(isEditing ? 'Сохранить' : 'Создать категорию'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final name = _nameController.text.trim();
    final newCategory = Category(
      id: widget.category?.id ?? 'cat_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      iconCodePoint: _selectedIcon.codePoint,
      colorValue: _selectedColor.toARGB32(),
    );

    context.read<CategoriesBloc>().add(CategorySaved(newCategory));
    Navigator.pop(context, newCategory);
  }
}
