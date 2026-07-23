import 'package:finflow/core/widgets/state_views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('LoadingView displays progress indicator and semantics label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LoadingView(label: 'Test Loading'),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.bySemanticsLabel('Test Loading'), findsOneWidget);
  });

  testWidgets('EmptyState displays title, message, and action button', (tester) async {
    bool clicked = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmptyState(
            title: 'No Data',
            message: 'Please add items',
            action: ElevatedButton(
              onPressed: () => clicked = true,
              child: const Text('Add Item'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('No Data'), findsOneWidget);
    expect(find.text('Please add items'), findsOneWidget);
    expect(find.text('Add Item'), findsOneWidget);

    await tester.tap(find.text('Add Item'));
    expect(clicked, isTrue);
  });

  testWidgets('ErrorState displays title, message, and triggers retry callback', (tester) async {
    bool retried = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorState(
            message: 'Network error',
            onRetry: () => retried = true,
          ),
        ),
      ),
    );

    expect(find.text('Failed to load data'), findsOneWidget);
    expect(find.text('Network error'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    expect(retried, isTrue);
  });
}
