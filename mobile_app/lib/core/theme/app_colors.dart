import 'package:flutter/material.dart';

/// Blue Hour HQ Official Design System Colour Tokens
/// Inspired by Linear, Raycast, Stripe Dashboard & Apple HIG.
class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // Brand Primary Palette
  // ---------------------------------------------------------------------------
  static const Color deepNavy = Color(0xFF10172A);
  static const Color midnightBlue = Color(0xFF172554);
  static const Color electricBlue = Color(0xFF3B82F6);
  static const Color indigo = Color(0xFF6366F1);
  static const Color violetAccent = Color(0xFF8B5CF6);
  static const Color cyanAccent = Color(0xFF06B6D4);

  // ---------------------------------------------------------------------------
  // Light Theme Tokens
  // ---------------------------------------------------------------------------
  static const Color lightBackground = Color(0xFFF7F8FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightElevatedSurface = Color(0xFFF1F5F9);
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightBorder = Color(0xFFE5E7EB);

  // ---------------------------------------------------------------------------
  // Dark Theme Tokens
  // ---------------------------------------------------------------------------
  static const Color darkBackground = Color(0xFF0B1020);
  static const Color darkSurface = Color(0xFF151D30);
  static const Color darkElevatedSurface = Color(0xFF1D2940);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF263554);

  // ---------------------------------------------------------------------------
  // Semantic Status Colours
  // ---------------------------------------------------------------------------
  static const Color success = Color(0xFF16A34A);
  static const Color successSoft = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ---------------------------------------------------------------------------
  // Signature Gradients
  // ---------------------------------------------------------------------------
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [electricBlue, indigo],
  );

  static const LinearGradient executiveHeroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF10172A),
      Color(0xFF172554),
      Color(0xFF1E3A8A),
    ],
  );

  static const LinearGradient darkCardGlowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF19243D),
      Color(0xFF131B2E),
    ],
  );
}

