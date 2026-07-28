import 'package:flutter_test/flutter_test.dart';
import 'package:finflow/core/utils/csv_exporter.dart';
import '../helpers.dart';

void main() {
  group('CsvExporter', () {
    test('exports empty list with header only', () {
      final csv = CsvExporter.exportTransactions([]);
      expect(csv.trim(), 'ID,Title,Amount,Type,Category,Date,Note');
    });

    test('exports list of transactions correctly', () {
      final tx1 = transaction(
        id: 'tx1',
        title: 'Supermarket',
        amount: 2500.50,
        note: 'Weekly food',
        date: DateTime(2026, 7, 28, 14, 30, 0),
      );

      final csv = CsvExporter.exportTransactions([tx1]);
      final lines = csv.trim().split('\n');

      expect(lines.length, 2);
      expect(lines[0], 'ID,Title,Amount,Type,Category,Date,Note');
      expect(lines[1], 'tx1,Supermarket,2500.50,expense,Groceries,2026-07-28 14:30:00,Weekly food');
    });

    test('escapes special characters (commas, quotes, newlines)', () {
      final tx = transaction(
        id: 'tx2',
        title: 'Groceries, "Special"',
        amount: 100.00,
        note: 'Line 1\nLine 2',
      );

      final csv = CsvExporter.exportTransactions([tx]);
      expect(csv, contains('"Groceries, ""Special"""'));
      expect(csv, contains('"Line 1\nLine 2"'));
    });
  });
}
