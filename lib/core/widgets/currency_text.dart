import 'package:flutter/material.dart';
import '../utils/formatters.dart';

class CurrencyText extends StatelessWidget {
  const CurrencyText(this.value, {super.key, this.style, this.color});

  final num value;
  final TextStyle? style;
  final Color? color;

  @override
  Widget build(BuildContext context) => Text(
    formatMoney(value),
    style: style?.copyWith(color: color) ?? TextStyle(color: color),
  );
}
