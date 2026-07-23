import 'package:bloc_test/bloc_test.dart';
import 'package:finflow/features/categories/data/datasources/category_local_data_source.dart';
import 'package:finflow/features/categories/domain/entities/category.dart';
import 'package:finflow/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:finflow/features/categories/presentation/pages/categories_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCategoriesBloc
    extends MockBloc<CategoriesEvent, CategoriesState>
    implements CategoriesBloc {}

void main() {
  late MockCategoriesBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(const CategoriesRequested());
  });

  setUp(() {
    mockBloc = MockCategoriesBloc();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<CategoriesBloc>.value(
        value: mockBloc,
        child: const CategoriesPage(),
      ),
    );
  }

  testWidgets('renders loading progress indicator', (tester) async {
    whenListen(
      mockBloc,
      const Stream<CategoriesState>.empty(),
      initialState: const CategoriesState(status: CategoriesStatus.loading),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders empty state when no categories are present', (tester) async {
    whenListen(
      mockBloc,
      const Stream<CategoriesState>.empty(),
      initialState: const CategoriesState(
        status: CategoriesStatus.success,
        categories: [],
      ),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text('No categories'), findsOneWidget);
    expect(find.text('Create category'), findsOneWidget);
  });

  testWidgets('renders category list items correctly', (tester) async {
    final categories = defaultCategoryModels;
    whenListen(
      mockBloc,
      const Stream<CategoriesState>.empty(),
      initialState: CategoriesState(
        status: CategoriesStatus.success,
        categories: categories,
      ),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Transport'), findsOneWidget);
  });

  testWidgets('tapping delete shows confirmation dialog', (tester) async {
    const testCat = Category(
      id: 'custom_cat',
      name: 'Custom Category',
      iconCodePoint: 57793,
      colorValue: 0xFF2196F3,
    );

    whenListen(
      mockBloc,
      const Stream<CategoriesState>.empty(),
      initialState: const CategoriesState(
        status: CategoriesStatus.success,
        categories: [testCat],
      ),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text('Custom Category'), findsOneWidget);

    final deleteIcon = find.byIcon(Icons.delete_outline);
    expect(deleteIcon, findsOneWidget);
    await tester.tap(deleteIcon);
    await tester.pumpAndSettle();

    expect(find.text('Delete category?'), findsOneWidget);
    expect(find.text('Category "Custom Category" will be deleted.'), findsOneWidget);
  });
}
