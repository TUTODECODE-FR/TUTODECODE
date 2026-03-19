import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tokens de design unifiés pour TutoDeCode.
/// Toujours utiliser ces constantes, jamais de Color() inline dans les widgets.
abstract class TdcColors {
  // Fonds
  static const bg         = Color(0xFF0D0F1A); // fond principal de l'app
  static const surface    = Color(0xFF161925); // cartes, sidebars, panels
  static const surfaceAlt = Color(0xFF1E212D); // éléments dans une surface (inputs, tags)
  static const surfaceHover = Color(0xFF22263A); // hover state

  // Bordures
  static const border       = Color(0xFF2A2D3E);
  static const borderSubtle = Color(0xFF1E212D);
  static const borderAccent = Color(0xFF4F52C8); // bordure accent au hover

  // Accents
  static const accent     = Color(0xFF6366F1); // indigo — couleur primaire
  static const accentDim  = Color(0x1A6366F1); // indigo 10% opacité
  static const accentGlow = Color(0x336366F1); // indigo 20% — glow
  static const success    = Color(0xFF10B981); // vert — OK, complété
  static const warning    = Color(0xFFF59E0B); // ambre — attention
  static const danger     = Color(0xFFEF4444); // rouge — erreur
  static const info       = Color(0xFF3B82F6); // bleu — info

  // Niveaux de cours
  static const levelBeginner     = Color(0xFF10B981); // vert
  static const levelIntermediate = Color(0xFF6366F1); // indigo
  static const levelAdvanced     = Color(0xFFF59E0B); // orange

  // Texte
  static const textPrimary   = Colors.white;
  static const textSecondary = Color(0xFF8B9EB7);
  static const textMuted     = Color(0xFF4B5568);
}

abstract class TdcSpacing {
  static const xs  = 4.0;
  static const sm  = 8.0;
  static const md  = 16.0;
  static const lg  = 24.0;
  static const xl  = 32.0;
  static const xxl = 48.0;
}

abstract class TdcRadius {
  static const sm = BorderRadius.all(Radius.circular(8));
  static const md = BorderRadius.all(Radius.circular(12));
  static const lg = BorderRadius.all(Radius.circular(16));
  static const xl = BorderRadius.all(Radius.circular(24));
}

// Max width pour le contenu desktop (évite le texte trop étalé)
const double kDesktopContentMaxWidth = 1100.0;
const double kPanelMaxWidth          = 920.0;

/// Thème Material principal de l'application.
ThemeData buildAppTheme() {
  final base = ThemeData(useMaterial3: true, brightness: Brightness.dark);
  
  // Police Inter de Google Fonts pour tout le thème
  final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
    bodyColor: TdcColors.textPrimary,
    displayColor: TdcColors.textPrimary,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: TdcColors.bg,
    primaryColor: TdcColors.accent,
    textTheme: textTheme.copyWith(
      displayLarge: textTheme.displayLarge?.copyWith(color: TdcColors.textPrimary, fontWeight: FontWeight.bold),
      titleLarge:   textTheme.titleLarge?.copyWith(color: TdcColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
      titleMedium:  textTheme.titleMedium?.copyWith(color: TdcColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
      bodyLarge:    textTheme.bodyLarge?.copyWith(color: TdcColors.textPrimary, fontSize: 15),
      bodyMedium:   textTheme.bodyMedium?.copyWith(color: TdcColors.textSecondary, fontSize: 14),
      bodySmall:    textTheme.bodySmall?.copyWith(color: TdcColors.textMuted, fontSize: 12),
      labelSmall:   textTheme.labelSmall?.copyWith(color: TdcColors.textMuted, fontSize: 11, letterSpacing: 1.2),
    ),

    colorScheme: ColorScheme.dark(
      primary: TdcColors.accent,
      secondary: TdcColors.success,
      surface: TdcColors.surface,
      error: TdcColors.danger,
      onPrimary: Colors.white,
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
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      textStyle: GoogleFonts.inter(color: TdcColors.textSecondary, fontSize: 12),
      waitDuration: const Duration(milliseconds: 500),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: TdcColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: TdcRadius.md),
        padding: const EdgeInsets.symmetric(horizontal: TdcSpacing.lg, vertical: TdcSpacing.md),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
      ).copyWith(
        mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click),
        overlayColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.hovered)) return Colors.white.withValues(alpha: 0.1);
          return null;
        }),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: TdcColors.textPrimary,
        side: const BorderSide(color: TdcColors.border),
        shape: const RoundedRectangleBorder(borderRadius: TdcRadius.md),
        padding: const EdgeInsets.symmetric(horizontal: TdcSpacing.lg, vertical: TdcSpacing.md),
      ).copyWith(
        mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: TdcColors.accent,
      ).copyWith(
        mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click),
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
        borderSide: const BorderSide(color: TdcColors.accent, width: 1.5),
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
  );
}
