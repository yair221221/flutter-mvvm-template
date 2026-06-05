import 'package:flutter/material.dart';

/// Liquid Neon design tokens — maps exactly to the DESIGN.md spec.
class AppColors {
  AppColors._();

  // ── Backgrounds ────────────────────────────────────────────────────────────
  static const background          = Color(0xFF0E0E10);
  static const surface             = Color(0xFF131315);
  static const surfaceContainerLow = Color(0xFF1C1B1D);
  static const surfaceContainer    = Color(0xFF201F21);
  static const surfaceContainerHigh= Color(0xFF2A2A2C);
  static const surfaceBright       = Color(0xFF39393B);

  // ── Neon accents ───────────────────────────────────────────────────────────
  static const cyan    = Color(0xFF00F0FF); // primary-container — electric blue
  static const cyanDim = Color(0xFF00DBE9); // primary-fixed-dim
  static const green   = Color(0xFF00EE70); // secondary-container — lime green
  static const orange  = Color(0xFFFFB599); // tertiary-fixed-dim — hot orange

  // ── On-colors ─────────────────────────────────────────────────────────────
  static const onSurface        = Color(0xFFE5E1E4);
  static const onSurfaceVariant = Color(0xFFB9CACB);
  static const outline          = Color(0xFF849495);
  static const outlineVariant   = Color(0xFF3B494B);

  // ── Category-specific glows ────────────────────────────────────────────────
  static const shortVideoGlow  = Color(0xFFFF4560); // red
  static const socialGlow      = Color(0xFFFF7043); // deep orange
  static const gamingGlow      = Color(0xFFFFAB00); // amber
  static const neutralGlow     = Color(0xFF78909C); // steel
  static const educationGlow   = Color(0xFF00EE70); // green
  static const readingGlow     = Color(0xFF00F0FF); // cyan
  static const mindfulnessGlow = Color(0xFFCE93D8); // purple
  static const productivityGlow= Color(0xFF40C4FF); // light blue

  // ── Gradient helpers ───────────────────────────────────────────────────────
  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D47A1), Color(0xFF7B1FA2), Color(0xFF006064)],
    stops: [0.0, 0.5, 1.0],
  );

  static const cyanGradient = LinearGradient(
    colors: [Color(0xFF00DBE9), Color(0xFF00F0FF)],
  );

  static const greenGradient = LinearGradient(
    colors: [Color(0xFF00C853), Color(0xFF00EE70)],
  );
}
