import 'package:flutter/material.dart';

class AppTheme {
  static const Color seed = Color(0xFF8E5CFF);

  static ThemeData get dark => _build(Brightness.dark);
  static ThemeData get light => _build(Brightness.light);

  static ThemeData _build(Brightness b) {
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: b);
    final isDark = b == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? const Color(0xFF0E0B16) : const Color(0xFFF7F4FF),
      appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0, backgroundColor: Colors.transparent),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withOpacity(0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      sliderTheme: const SliderThemeData(trackHeight: 4, thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7)),
    );
  }
}

/// Simple responsive helpers built on MediaQuery.
class Responsive {
  static const double mobile = 600;
  static const double desktop = 1000;
  static bool isMobile(BuildContext c) => MediaQuery.sizeOf(c).width < mobile;
  static bool isDesktop(BuildContext c) => MediaQuery.sizeOf(c).width >= desktop;
  static double hPad(BuildContext c) => isMobile(c) ? 16 : (isDesktop(c) ? 32 : 24);
}

String formatDuration(Duration d) {
  final m = d.inMinutes.remainder(60).toString().padLeft(1, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$m:$s';
}
