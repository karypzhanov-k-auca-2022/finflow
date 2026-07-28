import 'package:intl/intl.dart';

final _currency = NumberFormat.currency(
  locale: 'en_US',
  symbol: r'$',
  decimalDigits: 0,
);
final _date = DateFormat('d MMMM', 'en_US');
final _month = DateFormat('MMMM yyyy', 'en_US');

String formatMoney(num value) => _currency.format(value);
String formatDate(DateTime value) => _date.format(value);
String formatMonth(DateTime value) => _month.format(value);
