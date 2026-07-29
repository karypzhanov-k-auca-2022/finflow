import 'package:intl/intl.dart';

String get _locale => Intl.getCurrentLocale();

String formatMoney(num value) => NumberFormat.simpleCurrency(
  locale: _locale,
  decimalDigits: 0,
).format(value);

String formatDate(DateTime value) =>
    DateFormat('d MMMM', _locale).format(value);

String formatMonth(DateTime value) =>
    DateFormat('MMMM yyyy', _locale).format(value);
