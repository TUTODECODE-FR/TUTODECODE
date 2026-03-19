import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutodecode/core/theme/app_theme.dart';
import 'package:tutodecode/core/widgets/tdc_widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tutodecode/core/providers/shell_provider.dart';

class ToolboxScreen extends StatefulWidget {
  const ToolboxScreen({super.key});

  @override
  State<ToolboxScreen> createState() => _ToolboxScreenState();
}

class _ToolboxScreenState extends State<ToolboxScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShellProvider>().updateShell(
        title: 'Boîte à Outils',
        showBackButton: false,
        actions: [],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return TdcPageWrapper(
      child: ListView( // Changed to ListView for smoother scrolling
        children: [
          const Text(
            'Outils de Diagnostic & Support',
            style: TextStyle(color: TdcColors.textPrimary, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Utilitaires essentiels pour vos interventions sur site ou à distance, 100% hors-ligne.',
            style: TextStyle(color: TdcColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 32),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : (MediaQuery.of(context).size.width > 600 ? 2 : 1),
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 1.2,
            children: [
              _buildToolCard(
                context,
                0,
                'Calculateur IP',
                'Calculez vos sous-réseaux, masques et plages d\'adresses rapidement.',
                Icons.settings_ethernet,
                TdcColors.accent,
                '/tools/ip-calc',
              ),
              _buildToolCard(
                context,
                1,
                'Guides de Survie',
                'Fiches de secours pour résoudre les pannes critiques (Windows, Mac, Linux).',
                Icons.medication,
                const Color(0xFFEF4444),
                '/tools/survival',
              ),
              _buildToolCard(
                context,
                2,
                'Glossaire Tech',
                'Définitions simples et claires pour comprendre tout le jargon informatique.',
                Icons.menu_book,
                const Color(0xFF8B5CF6),
                '/tools/glossary',
              ),
              _buildToolCard(
                context,
                3,
                'Scripts Utiles',
                'Bibliothèque de scripts Batch, PowerShell et Bash pour automatiser vos tâches.',
                Icons.terminal,
                const Color(0xFF10B981),
                '/tools/scripts',
              ),
              _buildToolCard(
                context,
                4,
                'Référence Matérielle',
                'Codes de bips BIOS, liste des ports communs et connectique.',
                Icons.memory,
                const Color(0xFFF59E0B),
                '/tools/hardware',
              ),
              _buildToolCard(
                context,
                5,
                'Configuration Switch L3',
                'Commandes essentielles pour configurer vos switches de Niveau 3 (VLAN, OSPF, etc.).',
                Icons.settings_ethernet,
                TdcColors.accent,
                '/tools/switch-l3',
              ),
              _buildToolCard(
                context,
                6,
                'Guides VPN',
                'Étape par étape : configurez Tailscale ou ZeroTier pour l\'accès à distance.',
                Icons.vpn_lock,
                const Color(0xFF6366F1),
                '/tools/vpn-guides',
              ),
              _buildToolCard(
                context,
                7,
                'GPO Master Guide',
                'Toutes les stratégies cruciales pour contrôler et sécuriser votre parc Windows.',
                Icons.admin_panel_settings,
                const Color(0xFFEF4444),
                '/tools/gpo',
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, int index, String title, String desc, IconData icon, Color color, String route) {
    return TdcFadeSlide(
      delay: Duration(milliseconds: 60 * index),
      child: TdcCard(
        onTap: () => Navigator.pushNamed(context, route),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: TdcRadius.md,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const Spacer(),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(color: TdcColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              desc,
              style: const TextStyle(color: TdcColors.textSecondary, fontSize: 13, height: 1.4),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
