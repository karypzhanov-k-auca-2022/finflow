import 'package:intl/intl.dart';

final _currency = NumberFormat.currency(
  locale: 'ru_RU',
  symbol: '₽',
  decimalDigits: 0,
);
final _date = DateFormat('d MMMM', 'ru_RU');
final _month = DateFormat('LLLL yyyy', 'ru_RU');

String formatMoney(num value) => _currency.format(value);
String formatDate(DateTime value) => _date.format(value);
String formatMonth(DateTime value) => _month.format(value);
