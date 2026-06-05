import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        surface:          AppColors.surface,
        primary:          AppColors.cyan,
        secondary:        AppColors.green,
        tertiary:         AppColors.orange,
        onSurface:        AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline:          AppColors.outline,
        outlineVariant:   AppColors.outlineVariant,
      ),
      textTheme: GoogleFonts.soraTextTheme().copyWith(
        bodyLarge:   GoogleFonts.hankenGrotesk(color: AppColors.onSurface, fontSize: 16),
        bodyMedium:  GoogleFonts.hankenGrotesk(color: AppColors.onSurfaceVariant, fontSize: 14),
        bodySmall:   GoogleFonts.hankenGrotesk(color: AppColors.onSurfaceVariant, fontSize: 12),
        labelLarge:  GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w700, letterSpacing: 1.5, color: AppColors.onSurfaceVariant, fontSize: 12),
        labelMedium: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w700, letterSpacing: 1.2, color: AppColors.onSurfaceVariant, fontSize: 11),
        labelSmall:  GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w500, letterSpacing: 1.0, color: AppColors.onSurfaceVariant, fontSize: 10),
      ).apply(bodyColor: AppColors.onSurface, displayColor: AppColors.onSurface),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: GoogleFonts.sora(
          fontSize: 20, fontWeight: FontWeight.w700,
          letterSpacing: -0.5, color: AppColors.onSurface,
        ),
        iconTheme: const IconThemeData(color: AppColors.onSurfaceVariant),
      ),
      cardTheme: CardTheme(
        color: AppColors.surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.outlineVariant.withOpacity(0.6), width: 1),
        ),
      ),
    );
  }
}
