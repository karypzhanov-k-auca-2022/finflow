import 'package:flutter/material.dart';

/// A subtle, theme-aware backdrop shared by every application route.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark
        ? const _BackgroundColors(
            top: Color(0xFF121018),
            bottom: Color(0xFF191522),
            primaryGlow: Color(0x8A342557),
            secondaryGlow: Color(0x52263755),
          )
        : const _BackgroundColors(
            top: Color(0xFFF9F7FF),
            bottom: Color(0xFFF2F4FA),
            primaryGlow: Color(0x70E7DEFF),
            secondaryGlow: Color(0x52DDE8FF),
          );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors.top, colors.bottom],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(-0.9, -1.0),
            radius: 1.05,
            colors: [colors.primaryGlow, Colors.transparent],
            stops: const [0, 1],
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(1.0, 0.55),
              radius: 1.15,
              colors: [colors.secondaryGlow, Colors.transparent],
              stops: const [0, 1],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _BackgroundColors {
  const _BackgroundColors({
    required this.top,
    required this.bottom,
    required this.primaryGlow,
    required this.secondaryGlow,
  });

  final Color top;
  final Color bottom;
  final Color primaryGlow;
  final Color secondaryGlow;
}
