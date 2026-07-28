import '../../features/transactions/domain/entities/transaction.dart';
import 'package:intl/intl.dart';

abstract class CsvExporter {
  static String exportTransactions(List<FinanceTransaction> transactions) {
    final buffer = StringBuffer();
    // CSV Header
    buffer.writeln('ID,Title,Amount,Type,Category,Date,Note');

    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    for (final tx in transactions) {
      final id = _escapeCsvField(tx.id);
      final title = _escapeCsvField(tx.title);
      final amount = tx.amount.toStringAsFixed(2);
      final type = tx.type.name;
      final category = _escapeCsvField(tx.category.name);
      final date = dateFormat.format(tx.date);
      final note = _escapeCsvField(tx.note);

      buffer.writeln('$id,$title,$amount,$type,$category,$date,$note');
    }

    return buffer.toString();
  }

  static String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      final escaped = field.replaceAll('"', '""');
      return '"$escaped"';
    }
    return field;
  }
}
