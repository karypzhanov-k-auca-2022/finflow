import 'package:finflow/features/categories/domain/entities/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Category categoryWithIcon(int iconCodePoint) => Category(
    id: 'test',
    name: 'Test',
    iconCodePoint: iconCodePoint,
    colorValue: 0xFF000000,
  );

  test('maps legacy and current category icon values to const icons', () {
    expect(categoryWithIcon(0xe59a).icon, Icons.shopping_basket_outlined);
    expect(categoryWithIcon(0xf37e).icon, Icons.shopping_basket_outlined);
  });

  test('uses a safe fallback for an unsupported category icon value', () {
    expect(categoryWithIcon(12345).icon, Icons.category_outlined);
  });
}
