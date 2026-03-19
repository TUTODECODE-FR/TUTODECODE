import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutodecode/core/providers/settings_provider.dart';
import 'package:tutodecode/features/courses/providers/courses_provider.dart';
import 'package:tutodecode/core/theme/app_theme.dart';
import 'package:tutodecode/core/responsive/responsive.dart';
import 'package:tutodecode/features/ghost_ai/service/ollama_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  OllamaStatus? _status;
  bool _checking = false;
  final TextEditingController _hostController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _hostController.text = settings.ollamaUrl;
    _checkOllama();
  }

  Future<void> _checkOllama() async {
    setState(() => _checking = true);
    final status = await OllamaService.checkStatus();
    setState(() {
      _status = status;
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final courses = context.watch<CoursesProvider>();

    return Scaffold(
      backgroundColor: TdcColors.bg,
      appBar: AppBar(
        title: const Text('Paramètres & Transparence'),
        backgroundColor: TdcColors.bg,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(TdcAdaptive.padding(context, TdcSpacing.xl)),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNetworkSection(settings, courses),
                const SizedBox(height: TdcSpacing.lg),
                _buildAISection(settings),
                const SizedBox(height: TdcSpacing.lg),
                _buildPrivacySection(settings, courses),
                const SizedBox(height: TdcSpacing.lg),
                _buildPersonalizationSection(settings),
                const SizedBox(height: TdcSpacing.lg),
                _buildAboutSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(TdcSpacing.lg),
      decoration: BoxDecoration(
        color: TdcColors.surface,
        borderRadius: TdcRadius.lg,
        border: Border.all(color: TdcColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: TdcColors.accent, size: 20),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TdcColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildNetworkSection(SettingsProvider settings, CoursesProvider courses) {
    return _buildSection(
      title: 'Gestion de la Transparence Réseau',
      icon: Icons.lan,
      children: [
        _buildSwitchTile(
          title: 'Mode Hors-ligne Global',
          subtitle: 'Coupe toute tentative de connexion (màj incluses)',
          value: settings.offlineMode,
          onChanged: settings.setOfflineMode,
        ),
        const SizedBox(height: 12),
        _buildSwitchTile(
          title: 'Mises à jour de sécurité',
          subtitle: 'Autoriser la vérification des correctifs critiques',
          value: settings.securityUpdates,
          onChanged: settings.offlineMode ? null : settings.setSecurityUpdates,
        ),
        const SizedBox(height: 12),
        _buildSwitchTile(
          title: 'Annonce de nouveaux cours',
          subtitle: 'Être informé des nouvelles fonctionnalités',
          value: settings.contentUpdates,
          onChanged: settings.offlineMode ? null : settings.setContentUpdates,
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: (settings.offlineMode || courses.isUpdating) ? null : () async {
            final scaffold = ScaffoldMessenger.of(context);
            scaffold.showSnackBar(const SnackBar(content: Text('Vérification des mises à jour...')));
            final count = await courses.checkForUpdates();
            scaffold.hideCurrentSnackBar();
            if (count > 0) {
              scaffold.showSnackBar(SnackBar(
                content: Text('$count nouveaux modules téléchargés !'),
                backgroundColor: TdcColors.success,
              ));
            } else if (courses.errorMessage != null) {
              scaffold.showSnackBar(SnackBar(
                content: Text(courses.errorMessage!),
                backgroundColor: TdcColors.danger,
              ));
            } else {
              scaffold.showSnackBar(const SnackBar(content: Text('Déjà à jour.')));
            }
          },
          icon: courses.isUpdating 
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.sync, size: 18),
          label: Text(courses.isUpdating ? 'Synchronisation...' : 'Vérifier maintenant'),
        ),
      ],
    );
  }

  Widget _buildAISection(SettingsProvider settings) {
    return _buildSection(
      title: 'Configuration de l\'IA Locale (Ghost AI)',
      icon: Icons.psychology,
      children: [
        TextField(
          controller: _hostController,
          decoration: const InputDecoration(
            labelText: 'Adresse du serveur Ollama',
            hintText: 'http://localhost:11434',
          ),
          onSubmitted: (val) => settings.setOllamaUrl(val),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: settings.ollamaModel,
                decoration: const InputDecoration(labelText: 'Sélecteur de modèle'),
                items: (_status?.models ?? [settings.ollamaModel]).map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (val) => val != null ? settings.setOllamaModel(val) : null,
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: (_status?.running ?? false) ? TdcColors.success.withOpacity(0.1) : TdcColors.danger.withOpacity(0.1),
                borderRadius: TdcRadius.sm,
              ),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 10, color: (_status?.running ?? false) ? TdcColors.success : TdcColors.danger),
                  const SizedBox(width: 8),
                  Text((_status?.running ?? false) ? 'Connecté' : 'Hors-ligne', style: TextStyle(color: (_status?.running ?? false) ? TdcColors.success : TdcColors.danger, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: settings.tutorPersonality,
          decoration: const InputDecoration(labelText: 'Personnalité du tuteur'),
          items: const [
            DropdownMenuItem(value: 'Direct', child: Text('Direct (Donne la réponse)')),
            DropdownMenuItem(value: 'Socratique', child: Text('Socratique (Guide sans donner la solution)')),
          ],
          onChanged: (val) => val != null ? settings.setTutorPersonality(val) : null,
        ),
      ],
    );
  }

  Widget _buildPrivacySection(SettingsProvider settings, CoursesProvider courses) {
    return _buildSection(
      title: 'Données et Vie Privée (Le Nettoyeur)',
      icon: Icons.cleaning_services,
      children: [
        _buildActionTile(
          title: 'Nettoyage du Cache',
          subtitle: 'Effacer l\'historique des discussions locales',
          icon: Icons.delete_sweep,
          onTap: () async {
            await settings.clearChatHistory();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Historique effacé.')));
          },
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          title: 'Réinitialisation de la progression',
          subtitle: 'Repartir de zéro (21 cours)',
          icon: Icons.restart_alt,
          danger: true,
          onTap: () async {
            final confirm = await _showConfirmDialog('Réinitialiser la progression ?');
            if (confirm) {
              await settings.resetProgress();
              await courses.reload();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Progression réinitialisée.')));
            }
          },
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          title: 'Export des données',
          subtitle: 'Sauvegarder votre progression en .json',
          icon: Icons.file_download,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exportation en cours...')));
          },
        ),
      ],
    );
  }

  Widget _buildPersonalizationSection(SettingsProvider settings) {
    return _buildSection(
      title: 'Personnalisation de l\'Atelier',
      icon: Icons.palette,
      children: [
        const Text('Style du Terminal', style: TextStyle(fontWeight: FontWeight.bold)),
        Slider(
          value: settings.terminalFontSize,
          min: 10,
          max: 24,
          divisions: 14,
          label: '${settings.terminalFontSize.round()}px',
          onChanged: settings.setTerminalFontSize,
        ),
        const SizedBox(height: 16),
        ListTile(
          title: const Text('Thème de l\'application'),
          trailing: DropdownButton<String>(
            value: settings.appTheme,
            items: const [
              DropdownMenuItem(value: 'Clair', child: Text('Clair')),
              DropdownMenuItem(value: 'Sombre', child: Text('Sombre')),
              DropdownMenuItem(value: 'System', child: Text('Automatique')),
            ],
            onChanged: (val) => val != null ? settings.setAppTheme(val) : null,
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return _buildSection(
      title: 'Identité de l\'Association',
      icon: Icons.business,
      children: [
        const Text('TUTO DECODE - Association Loi 1901', style: TextStyle(fontWeight: FontWeight.bold)),
        const Text('Structure à but non lucratif dédiée à l\'éducation numérique.'),
        TextButton(onPressed: () {}, child: const Text('Visiter tutodecode.org')),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: () {}, child: const Text('Lire la Security Policy')),
        const SizedBox(height: 12),
        const Text('Licence : AGPL-3.0', style: TextStyle(color: TdcColors.textSecondary)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: TdcColors.surfaceAlt, borderRadius: TdcRadius.sm),
          child: const Row(
            children: [
              Icon(Icons.verified, color: TdcColors.success, size: 16),
              SizedBox(width: 8),
              Expanded(child: Text('Signature : v1.0.2-official-asso-release', style: TextStyle(fontFamily: 'monospace', fontSize: 11))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({required String title, required String subtitle, required bool value, required ValueChanged<bool>? onChanged}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: TdcColors.textSecondary)),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  Widget _buildActionTile({required String title, required String subtitle, required IconData icon, required VoidCallback onTap, bool danger = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: TdcRadius.md,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: TdcColors.surfaceAlt, borderRadius: TdcRadius.md),
        child: Row(
          children: [
            Icon(icon, color: danger ? TdcColors.danger : TdcColors.accent),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: danger ? TdcColors.danger : TdcColors.textPrimary)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: TdcColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18),
          ],
        ),
      ),
    );
  }

  Future<bool> _showConfirmDialog(String title) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(title),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirmer', style: TextStyle(color: TdcColors.danger))),
            ],
          ),
        ) ??
        false;
  }
}
