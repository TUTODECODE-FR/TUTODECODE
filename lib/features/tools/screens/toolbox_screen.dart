import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutodecode/core/theme/app_theme.dart';
import 'package:tutodecode/core/widgets/tdc_widgets.dart';
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
                'Multi-Tools Sécurisés',
                'Diagnostic réseau/système/stockage avec sandbox et logs (sans commandes arbitraires).',
                Icons.security,
                const Color(0xFF22C55E),
                '/tools/safe-tools',
              ),
              _buildToolCard(
                context,
                1,
                'Calculateur IP',
                'Calculez vos sous-réseaux, masques et plages d\'adresses rapidement.',
                Icons.settings_ethernet,
                TdcColors.accent,
                '/tools/ip-calc',
              ),
              _buildToolCard(
                context,
                2,
                'Guides de Survie',
                'Fiches de secours pour résoudre les pannes critiques (Windows, Mac, Linux).',
                Icons.medication,
                const Color(0xFFEF4444),
                '/tools/survival',
              ),
              _buildToolCard(
                context,
                3,
                'Glossaire Tech',
                'Définitions simples et claires pour comprendre tout le jargon informatique.',
                Icons.menu_book,
                const Color(0xFF8B5CF6),
                '/tools/glossary',
              ),
              _buildToolCard(
                context,
                4,
                'Scripts Utiles',
                'Bibliothèque de scripts Batch, PowerShell et Bash pour automatiser vos tâches.',
                Icons.terminal,
                const Color(0xFF10B981),
                '/tools/scripts',
              ),
              _buildToolCard(
                context,
                5,
                'Référence Matérielle',
                'Codes de bips BIOS, liste des ports communs et connectique.',
                Icons.memory,
                const Color(0xFFF59E0B),
                '/tools/hardware',
              ),
              _buildToolCard(
                context,
                6,
                'Générateur de MDP',
                'Créez des mots de passe ultra-sécurisés et personnalisés en un clic.',
                Icons.password,
                const Color(0xFF6366F1),
                '/tools/password-gen',
              ),
              _buildToolCard(
                context,
                7,
                'Convertisseur de Données',
                'Convertissez vos unités de stockage (Octets, Mo, Go) sans erreur.',
                Icons.analytics,
                const Color(0xFFEC4899),
                '/tools/data-converter',
              ),
              _buildToolCard(
                context,
                8,
                'Encodeur Base64',
                'Encodez et décodez instantanément vos textes en Base64.',
                Icons.code,
                const Color(0xFF14B8A6),
                '/tools/base64',
              ),
              _buildToolCard(
                context,
                9,
                'Générateur de Hash',
                'Générez des empreintes MD5, SHA-1 et SHA-256 en toute simplicité.',
                Icons.fingerprint,
                const Color(0xFFEF4444),
                '/tools/hash',
              ),
              _buildToolCard(
                context,
                10,
                'Calculateur Chmod',
                'Calculez et convertissez les permissions Unix (755, rwxr-xr-x).',
                Icons.rule,
                const Color(0xFF3B82F6),
                '/tools/chmod',
              ),
              _buildToolCard(
                context,
                11,
                'Formateur JSON',
                'Validez, formatez et minifiez votre code JSON instantanément.',
                Icons.settings_overscan,
                const Color(0xFFFACC15),
                '/tools/json',
              ),
              _buildToolCard(
                context,
                12,
                'ASCII / Hex / Bin',
                'Convertisseur universel entre texte, hexadécimal, binaire et décimal.',
                Icons.swap_horiz,
                const Color(0xFF6366F1),
                '/tools/ascii',
              ),
              _buildToolCard(
                context,
                13,
                'Calculateur RAID',
                'Calculez la capacité utile et la tolérance aux pannes de vos serveurs.',
                Icons.storage,
                const Color(0xFF10B981),
                '/tools/raid',
              ),
              _buildToolCard(
                context,
                14,
                'Codes HTTP',
                'Explorateur complet des codes d\'état HTTP et conseils de dépannage.',
                Icons.http,
                const Color(0xFFF43F5E),
                '/tools/http-status',
              ),
              _buildToolCard(
                context,
                15,
                'Annuaire des Ports',
                'Référence rapide des ports TCP/UDP les plus courants par service.',
                Icons.lan,
                const Color(0xFF8B5CF6),
                '/tools/ports',
              ),
              _buildToolCard(
                context,
                16,
                'Débit & Télécharg.',
                'Calculez le temps de transfert selon la vitesse et la taille de vos fichiers.',
                Icons.speed,
                const Color(0xFFF59E0B),
                '/tools/bandwidth',
              ),
              _buildToolCard(
                context,
                17,
                'Expression Cron',
                'Décodez et testez vos expressions de planification système (Cron).',
                Icons.schedule,
                const Color(0xFF14B8A6),
                '/tools/cron',
              ),
              _buildToolCard(
                context,
                18,
                'Niveaux Syslog',
                'Référence des sévérités RFC 5424 pour le filtrage des logs serveur.',
                Icons.list_alt,
                const Color(0xFFEF4444),
                '/tools/syslog',
              ),
              _buildToolCard(
                context,
                19,
                'Aide-émémoire Archivage',
                'Commandes rapides pour tar, rsync et zip (sauvegarde et transfert).',
                Icons.inventory_2,
                const Color(0xFFF59E0B),
                '/tools/archive',
              ),
              _buildToolCard(
                context,
                20,
                'Assistant SSH',
                'Guide de configuration ~/.ssh/config et bonnes pratiques de sécurité.',
                Icons.terminal,
                const Color(0xFF3B82F6),
                '/tools/ssh',
              ),
              _buildToolCard(
                context,
                21,
                'Référence DNS',
                'Types d\'enregistrements DNS (A, MX, TXT, etc.) et leur utilité.',
                Icons.dns,
                const Color(0xFF8B5CF6),
                '/tools/dns',
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
