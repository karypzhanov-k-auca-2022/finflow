import 'package:finflow/core/theme/app_theme.dart';
import 'package:finflow/core/widgets/app_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the light background palette', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const AppBackground(child: SizedBox.expand()),
      ),
    );

    final decoration = _baseDecoration(tester);
    final gradient = decoration.gradient! as LinearGradient;

    expect(gradient.colors, const [Color(0xFFF9F7FF), Color(0xFFF2F4FA)]);
  });

  testWidgets('renders the dark background palette', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const AppBackground(child: SizedBox.expand()),
      ),
    );

    final decoration = _baseDecoration(tester);
    final gradient = decoration.gradient! as LinearGradient;

    expect(gradient.colors, const [Color(0xFF121018), Color(0xFF191522)]);
  });
}

BoxDecoration _baseDecoration(WidgetTester tester) {
  final boxes = tester.widgetList<DecoratedBox>(find.byType(DecoratedBox));
  return boxes
      .map((box) => box.decoration)
      .whereType<BoxDecoration>()
      .firstWhere((decoration) => decoration.gradient is LinearGradient);
}
