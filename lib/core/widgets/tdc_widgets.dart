// ============================================================
// tdc_widgets.dart — Composants UI réutilisables TutoDeCode
// Hover states, curseurs, animations macOS-ready
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────
// TdcCard — Carte avec hover state animé
// Usage: TdcCard(onTap: () {}, child: ...)
// ─────────────────────────────────────────────────────────────
class TdcCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final bool showHoverBorder;
  final double borderRadius;

  const TdcCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.showHoverBorder = true,
    this.borderRadius = 12,
  });

  @override
  State<TdcCard> createState() => _TdcCardState();
}

class _TdcCardState extends State<TdcCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: widget.padding ?? const EdgeInsets.all(TdcSpacing.lg),
          decoration: BoxDecoration(
            color: _hovered && widget.onTap != null
                ? TdcColors.surfaceHover
                : TdcColors.surface,
            borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius)),
            border: Border.all(
              color: _hovered && widget.showHoverBorder && widget.onTap != null
                  ? TdcColors.accent.withValues(alpha: 0.5)
                  : TdcColors.border,
              width: _hovered && widget.onTap != null ? 1.5 : 1,
            ),
            boxShadow: _hovered && widget.onTap != null
                ? [BoxShadow(color: TdcColors.accent.withValues(alpha: 0.08), blurRadius: 16, spreadRadius: 0)]
                : null,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TdcSectionTitle — En-tête de section uniformisé
// ─────────────────────────────────────────────────────────────
class TdcSectionTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;
  final double? fontSize;

  const TdcSectionTitle(this.text, {super.key, this.trailing, this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: TdcColors.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: TdcColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: fontSize ?? 17,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TdcStatusBadge — Badge de statut coloré
// ─────────────────────────────────────────────────────────────
class TdcStatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const TdcStatusBadge({super.key, required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: TdcRadius.sm,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 4),
          ],
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TdcInfoRow — Ligne label/valeur uniformisée
// ─────────────────────────────────────────────────────────────
class TdcInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final bool copyable;

  const TdcInfoRow({super.key, required this.label, required this.value, this.icon, this.copyable = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: TdcColors.textMuted),
            const SizedBox(width: 10),
          ],
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(color: TdcColors.textMuted, fontSize: 13)),
          ),
          Flexible(
            flex: 3,
            child: MouseRegion(
              cursor: copyable ? SystemMouseCursors.click : MouseCursor.defer,
              child: GestureDetector(
                onTap: copyable ? () {
                  // Copy handled externally
                } : null,
                child: Text(
                  value,
                  style: const TextStyle(
                    color: TdcColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TdcFadeSlide — Animation d'entrée fade + slide vers le haut
// Usage: TdcFadeSlide(delay: 100ms, child: MyWidget())
// ─────────────────────────────────────────────────────────────
class TdcFadeSlide extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final double offsetY;

  const TdcFadeSlide({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offsetY = 20,
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: delay)
        .fadeIn(duration: const Duration(milliseconds: 350), curve: Curves.easeOut)
        .slideY(begin: offsetY / 100, end: 0, duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
  }
}

// ─────────────────────────────────────────────────────────────
// TdcEmptyState — État vide standardisé
// ─────────────────────────────────────────────────────────────
class TdcEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const TdcEmptyState({super.key, required this.icon, required this.title, this.subtitle, this.action});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: TdcColors.surfaceAlt,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: TdcColors.textMuted),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(color: TdcColors.textSecondary, fontSize: 16, fontWeight: FontWeight.bold)),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle!, style: const TextStyle(color: TdcColors.textMuted, fontSize: 13), textAlign: TextAlign.center),
          ],
          if (action != null) ...[const SizedBox(height: 20), action!],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TdcPageWrapper — Wrapper desktop avec largeur max et centrage
// Usage: Wrap your page content with this for proper desktop layout
// ─────────────────────────────────────────────────────────────
class TdcScreenWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const TdcPageWrapper({
    super.key,
    required this.child,
    this.maxWidth = kDesktopContentMaxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(TdcSpacing.xl),
          child: child,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TdcKeyboardShortcut — Affiche un tag de raccourci clavier
// ─────────────────────────────────────────────────────────────
class TdcKeyboardShortcut extends StatelessWidget {
  final String keys;
  const TdcKeyboardShortcut(this.keys, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: TdcColors.surfaceAlt,
        borderRadius: TdcRadius.sm,
        border: Border.all(color: TdcColors.border),
      ),
      child: Text(keys, style: const TextStyle(color: TdcColors.textMuted, fontSize: 10, fontFamily: 'monospace')),
    );
  }
}
