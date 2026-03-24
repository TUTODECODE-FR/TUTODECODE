import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================
// TUTO DECODE - THEME PROFESSIONNEL "DEEP OCEAN TECH"
// Palette unique et reconnaissable pour l'identité de marque
// ============================================================

abstract class TdcColors {
  // FONDS - Deep Ocean Palette
  static const bg = Color(0xFF080A0F);
  static const surface = Color(0xFF0F1218);
  static const surfaceAlt = Color(0xFF161B24);
  static const surfaceHover = Color(0xFF1E2530);
  static const surfaceElevated = Color(0xFF252D3A);

  // ACCENT PRINCIPAL - Turquoise Néon (Signature)
  static const accent = Color(0xFF00D9C0);
  static const accentDim = Color(0x1A00D9C0);
  static const accentGlow = Color(0x4000D9C0);
  static const accentBright = Color(0xFF5CFFE8);

  // ACCENTS SECONDAIRES
  static const coral = Color(0xFFFF6B6B);
  static const coralDim = Color(0x1AFF6B6B);
  static const electric = Color(0xFF448AFF);
  static const electricDim = Color(0x1A448AFF);
  static const cosmos = Color(0xFFB388FF);
  static const cosmosDim = Color(0x1AB388FF);

  // STATUTS
  static const success = Color(0xFF00E676);
  static const successDim = Color(0x1A00E676);
  static const warning = Color(0xFFFFB74D);
  static const warningDim = Color(0x1AFFB74D);
  static const danger = Color(0xFFFF5252);
  static const dangerDim = Color(0x1AFF5252);
  static const info = Color(0xFF64B5F6);
  static const infoDim = Color(0x1A64B5F6);

  // CATÉGORIES SPÉCIALISÉES
  static const network = Color(0xFF2962FF);
  static const networkDim = Color(0x1A2962FF);
  static const security = Color(0xFFFF4081);
  static const securityDim = Color(0x1AFF4081);
  static const system = Color(0xFF00BFA5);
  static const systemDim = Color(0x1A00BFA5);
  static const cloud = Color(0xFF00B0FF);
  static const cloudDim = Color(0x1A00B0FF);
  static const crypto = Color(0xFFFFAB40);
  static const cryptoDim = Color(0x1AFFAB40);

  // NIVEAUX
  static const levelBeginner = Color(0xFF69F0AE);
  static const levelIntermediate = Color(0xFF00D9C0);
  static const levelAdvanced = Color(0xFFFFAB40);
  static const levelExpert = Color(0xFFFF5252);

  // BORDURES
  static const border = Color(0xFF252D3A);
  static const borderSubtle = Color(0xFF1A202C);
  static const borderAccent = Color(0xFF00D9C0);
  static const borderFocus = Color(0xFF3D4852);

  // TEXTE
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xFF8B9DC3);
  static const textTertiary = Color(0xFF5C6B7F);
  static const textMuted = Color(0xFF3D4852);
  static const textAccent = Color(0xFF00D9C0);
}

abstract class TdcSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

abstract class TdcRadius {
  static const sm = BorderRadius.all(Radius.circular(8));
  static const md = BorderRadius.all(Radius.circular(12));
  static const lg = BorderRadius.all(Radius.circular(16));
  static const xl = BorderRadius.all(Radius.circular(24));
}

const double kDesktopContentMaxWidth = 1100.0;
const double kPanelMaxWidth = 920.0;

ThemeData buildAppTheme() {
  final base = ThemeData(useMaterial3: true, brightness: Brightness.dark);
  final textTheme = GoogleFonts.interTextTheme(base.textTheme);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: TdcColors.bg,
    primaryColor: TdcColors.accent,
    textTheme: textTheme.copyWith(
      displayLarge: textTheme.displayLarge?.copyWith(color: TdcColors.textPrimary, fontWeight: FontWeight.bold),
      titleLarge: textTheme.titleLarge?.copyWith(color: TdcColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
      titleMedium: textTheme.titleMedium?.copyWith(color: TdcColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
      bodyLarge: textTheme.bodyLarge?.copyWith(color: TdcColors.textPrimary, fontSize: 15),
      bodyMedium: textTheme.bodyMedium?.copyWith(color: TdcColors.textSecondary, fontSize: 14),
      bodySmall: textTheme.bodySmall?.copyWith(color: TdcColors.textMuted, fontSize: 12),
      labelSmall: textTheme.labelSmall?.copyWith(color: TdcColors.textMuted, fontSize: 11, letterSpacing: 1.2),
    ),
    colorScheme: const ColorScheme.dark(
      primary: TdcColors.accent,
      secondary: TdcColors.coral,
      surface: TdcColors.surface,
      error: TdcColors.danger,
      onPrimary: TdcColors.bg,
      onSurface: TdcColors.textPrimary,
    ),
    cardTheme: CardThemeData(
      color: TdcColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: TdcRadius.lg,
        side: const BorderSide(color: TdcColors.border),
      ),
      elevation: 0,
      margin: EdgeInsets.zero,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: TdcColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        color: TdcColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: TdcColors.textSecondary),
    ),
    dividerTheme: const DividerThemeData(
      color: TdcColors.border,
      thickness: 1,
      space: 1,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: TdcColors.surfaceAlt,
        borderRadius: TdcRadius.sm,
        border: Border.all(color: TdcColors.border),
      ),
      textStyle: GoogleFonts.inter(color: TdcColors.textSecondary, fontSize: 12),
      waitDuration: const Duration(milliseconds: 500),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: TdcColors.accent,
        foregroundColor: TdcColors.bg,
        elevation: 4,
        shadowColor: TdcColors.accentGlow,
        shape: const RoundedRectangleBorder(borderRadius: TdcRadius.md),
        padding: const EdgeInsets.symmetric(horizontal: TdcSpacing.lg, vertical: TdcSpacing.md),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: TdcColors.textPrimary,
        side: const BorderSide(color: TdcColors.border),
        shape: const RoundedRectangleBorder(borderRadius: TdcRadius.md),
        padding: const EdgeInsets.symmetric(horizontal: TdcSpacing.lg, vertical: TdcSpacing.md),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: TdcColors.accent,
      ),
    ),
    iconTheme: const IconThemeData(color: TdcColors.textSecondary, size: 20),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: TdcColors.surfaceAlt,
      contentPadding: const EdgeInsets.symmetric(horizontal: TdcSpacing.md, vertical: TdcSpacing.sm + 2),
      border: OutlineInputBorder(
        borderRadius: TdcRadius.md,
        borderSide: const BorderSide(color: TdcColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: TdcRadius.md,
        borderSide: const BorderSide(color: TdcColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: TdcRadius.md,
        borderSide: const BorderSide(color: TdcColors.accent, width: 2),
      ),
      hintStyle: const TextStyle(color: TdcColors.textMuted),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.all(TdcColors.border),
      trackColor: WidgetStateProperty.all(Colors.transparent),
      radius: const Radius.circular(4),
      thickness: WidgetStateProperty.all(5),
      thumbVisibility: WidgetStateProperty.all(true),
    ),
    listTileTheme: const ListTileThemeData(
      textColor: TdcColors.textPrimary,
      iconColor: TdcColors.textSecondary,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: TdcColors.surfaceAlt,
      labelStyle: GoogleFonts.inter(color: TdcColors.textSecondary, fontSize: 12),
      side: const BorderSide(color: TdcColors.border),
      shape: const RoundedRectangleBorder(borderRadius: TdcRadius.sm),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return TdcColors.accent;
        return TdcColors.surfaceElevated;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return TdcColors.accentDim;
        return TdcColors.surfaceAlt;
      }),
      trackOutlineColor: WidgetStateProperty.all(TdcColors.border),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: TdcColors.accent,
      linearTrackColor: TdcColors.surfaceElevated,
    ),
  );
}
