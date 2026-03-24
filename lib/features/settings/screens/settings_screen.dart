import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_selector/file_selector.dart';
import 'package:tutodecode/core/providers/settings_provider.dart';
import 'package:tutodecode/features/courses/providers/courses_provider.dart';
import 'package:tutodecode/core/theme/app_theme.dart';
import 'package:tutodecode/core/responsive/responsive.dart';
import 'package:tutodecode/features/ghost_ai/service/ollama_service.dart';
import 'package:tutodecode/core/services/backup_service.dart';
import './security_diagnostic_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  OllamaStatus? _status;
  bool _checking = false;
  final TextEditingController _hostController = TextEditingController();
  final BackupService _backup = BackupService();

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
                _buildSecurityDiagnosticLink(),
                const SizedBox(height: TdcSpacing.lg),
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
          title: 'Mode Zéro Réseau (Ultra Sécurité)',
          subtitle: 'Bloque toute requête HTTP (GitHub + Ollama inclus) sur toutes les plateformes',
          value: settings.zeroNetworkMode,
          onChanged: settings.setZeroNetworkMode,
        ),
        const SizedBox(height: 12),
        _buildSwitchTile(
          title: 'Mode Hors-ligne Global',
          subtitle: 'Coupe toute tentative de connexion (màj incluses)',
          value: settings.offlineMode,
          onChanged: settings.zeroNetworkMode ? null : settings.setOfflineMode,
        ),
        const SizedBox(height: 12),
        _buildSwitchTile(
          title: 'Mises à jour de sécurité',
          subtitle: 'Autoriser la vérification des correctifs critiques',
          value: settings.securityUpdates,
          onChanged: (settings.offlineMode || settings.zeroNetworkMode) ? null : settings.setSecurityUpdates,
        ),
        const SizedBox(height: 12),
        _buildSwitchTile(
          title: 'Annonce de nouveaux cours',
          subtitle: 'Vérifie le dépôt officiel au démarrage et propose de télécharger les modules de cours (aucune donnée personnelle envoyée)',
          value: settings.contentUpdates,
          onChanged: (settings.offlineMode || settings.zeroNetworkMode) ? null : settings.setContentUpdates,
        ),
        if (!settings.contentUpdates) ...[
          const SizedBox(height: 8),
          const Text(
            'Note : désactiver cette option peut être contre-productif (vous risquez de manquer des corrections ou du contenu). '
            'La vérification est en lecture seule et ne transmet aucune donnée personnelle.',
            style: TextStyle(color: TdcColors.warning, fontSize: 12, height: 1.3),
          ),
        ],
        if (settings.zeroNetworkMode) ...[
          const SizedBox(height: 8),
          const Text(
            'Réseau désactivé : aucune synchronisation et aucune IA distante/locale via HTTP ne pourra fonctionner.',
            style: TextStyle(color: TdcColors.warning, fontSize: 12, height: 1.3),
          ),
        ],
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: (settings.offlineMode || settings.zeroNetworkMode || courses.isUpdating) ? null : () async {
            final scaffold = ScaffoldMessenger.of(context);
            scaffold.showSnackBar(const SnackBar(content: Text('Vérification des mises à jour...')));
            final updates = await courses.listAvailableUpdates();
            scaffold.hideCurrentSnackBar();

            if (!mounted) return;
            if (updates.isEmpty) {
              scaffold.showSnackBar(const SnackBar(content: Text('Déjà à jour.')));
              return;
            }

            final shouldDownload = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: TdcColors.surface,
                title: const Text('Mises à jour disponibles', style: TextStyle(color: TdcColors.textPrimary)),
                content: SizedBox(
                  width: 560,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Aperçu des modules détectés. Aucune donnée personnelle n’est envoyée (lecture seule GitHub).',
                        style: TextStyle(color: TdcColors.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: updates.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final u = updates[i];
                            final isNew = (u.localSha == null || u.localSha!.isEmpty);
                            final sizeLabel = u.remoteSize != null ? '${(u.remoteSize! / 1024).toStringAsFixed(1)} KB' : '—';
                            return ListTile(
                              dense: true,
                              title: Text(u.fileName, style: const TextStyle(color: TdcColors.textPrimary, fontSize: 13)),
                              subtitle: Text('${isNew ? 'Nouveau' : 'Màj'} • Taille: $sizeLabel', style: const TextStyle(color: TdcColors.textMuted, fontSize: 11)),
                              trailing: IconButton(
                                icon: const Icon(Icons.compare_arrows, size: 18),
                                tooltip: 'Voir les changements (Diff)',
                                onPressed: () async {
                                  final diff = await courses.diffUpdate(u.fileName);
                                  if (diff != null && mounted) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Changements: ${u.fileName}'),
                                        content: SingleChildScrollView(
                                          child: ListBody(
                                            children: [
                                              _diffRow('ID', diff.localId, diff.remoteId),
                                              _diffRow('Titre', diff.localTitle, diff.remoteTitle),
                                              _diffRow('Chapitres', diff.localChapters?.toString(), diff.remoteChapters?.toString()),
                                              const SizedBox(height: 12),
                                              const Text('Voulez-vous accepter ces changements ?', style: TextStyle(fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer'))],
                                      ),
                                    );
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context, true),
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Télécharger'),
                  ),
                ],
              ),
            );

            if (shouldDownload != true) return;
            scaffold.showSnackBar(const SnackBar(content: Text('Téléchargement des modules...')));
            final count = await courses.checkForUpdates();
            scaffold.hideCurrentSnackBar();
            if (count > 0) {
              scaffold.showSnackBar(SnackBar(
                content: Text('$count module(s) téléchargé(s) !'),
                backgroundColor: TdcColors.success,
              ));
            } else if (courses.errorMessage != null) {
              scaffold.showSnackBar(SnackBar(
                content: Text(courses.errorMessage!),
                backgroundColor: TdcColors.danger,
              ));
            } else {
              scaffold.showSnackBar(const SnackBar(content: Text('Aucune mise à jour téléchargée.')));
            }
          },
          icon: courses.isUpdating 
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.sync, size: 18),
          label: Text(courses.isUpdating ? 'Synchronisation...' : 'Vérifier maintenant'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: (settings.zeroNetworkMode) ? null : () async {
            final candidates = await courses.listRollbackCandidates();
            if (!mounted) return;
            if (candidates.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Aucun module à restaurer (pas de backup).')),
              );
              return;
            }
            final selected = await showDialog<String?>(
              context: context,
              builder: (context) {
                var selected = candidates.first;
                return StatefulBuilder(
                  builder: (context, setState) => AlertDialog(
                    backgroundColor: TdcColors.surface,
                    title: const Text('Restaurer un module', style: TextStyle(color: TdcColors.textPrimary)),
                    content: DropdownButtonFormField<String>(
                      value: selected,
                      decoration: const InputDecoration(labelText: 'Module'),
                      items: candidates.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setState(() => selected = v ?? selected),
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Annuler')),
                      ElevatedButton(onPressed: () => Navigator.pop(context, selected), child: const Text('Restaurer')),
                    ],
                  ),
                );
              },
            );
            if (selected == null) return;
            final ok = await courses.rollbackModule(selected);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(ok ? 'Module restauré: $selected' : 'Restauration impossible'),
                backgroundColor: ok ? TdcColors.success : TdcColors.danger,
              ),
            );
          },
          icon: const Icon(Icons.history, size: 18),
          label: const Text('Revenir à une version précédente'),
        ),
        const SizedBox(height: 12),
        _buildModuleManagementSection(courses),
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
          subtitle: 'Exporter progression + réglages en fichier chiffré (AES) avec mot de passe',
          icon: Icons.file_download,
          onTap: _exportEncryptedBackup,
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          title: 'Import des données',
          subtitle: 'Restaurer progression + réglages depuis une sauvegarde chiffrée',
          icon: Icons.file_upload,
          onTap: _importEncryptedBackup,
        ),
      ],
    );
  }

  Future<void> _exportEncryptedBackup() async {
    final password = await _promptPassword(
      title: 'Mot de passe de sauvegarde',
      confirm: true,
    );
    if (password == null || password.isEmpty) return;

    final now = DateTime.now();
    final stamp = '${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final location = await getSaveLocation(suggestedName: 'TUTODECODE-backup-$stamp.tdc');
    if (location == null) return;

    final bytes = await _backup.exportEncrypted(password: password);
    final xfile = XFile.fromData(
      bytes,
      mimeType: 'application/octet-stream',
      name: location.path.split('/').last,
    );
    await xfile.saveTo(location.path);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sauvegarde exportée (chiffrée).')),
    );
  }

  Future<void> _importEncryptedBackup() async {
    final file = await openFile(acceptedTypeGroups: [
      const XTypeGroup(label: 'TutoDeCode Backup', extensions: ['tdc']),
    ]);
    if (file == null) return;

    const maxBackupBytes = 10 * 1024 * 1024;
    final fileSize = await file.length();
    if (fileSize <= 0 || fileSize > maxBackupBytes) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fichier de sauvegarde invalide (taille).'), backgroundColor: TdcColors.danger),
      );
      return;
    }

    final password = await _promptPassword(
      title: 'Mot de passe de sauvegarde',
      confirm: false,
    );
    if (password == null || password.isEmpty) return;

    try {
      final bytes = await file.readAsBytes();
      await _backup.importEncrypted(bytes: bytes, password: password);

      if (!mounted) return;
      final settings = context.read<SettingsProvider>();
      final courses = context.read<CoursesProvider>();
      await settings.reload();
      await courses.reload();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sauvegarde restaurée.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import impossible: $e'), backgroundColor: TdcColors.danger),
      );
    }
  }

  Future<String?> _promptPassword({required String title, required bool confirm}) async {
    final c1 = TextEditingController();
    final c2 = TextEditingController();
    return showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TdcColors.surface,
        title: Text(title, style: const TextStyle(color: TdcColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: c1,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mot de passe'),
            ),
            if (confirm)
              TextField(
                controller: c2,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirmer'),
              ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              final p1 = c1.text;
              final p2 = c2.text;
              if (confirm && p1 != p2) return;
              Navigator.pop(context, p1);
            },
            child: const Text('OK'),
          ),
        ],
      ),
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

  Widget _buildSecurityDiagnosticLink() {
    return _buildActionTile(
      title: 'Diagnostic de Sécurité',
      subtitle: 'Journaux locaux, état des hôtes et validation des modules',
      icon: Icons.shield,
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SecurityDiagnosticScreen())),
    );
  }

  Widget _buildModuleManagementSection(CoursesProvider courses) {
    final external = courses.courses.where((c) => c.keywords.contains('EXTERNAL')).toList();
    if (external.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Modules Installés', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: TdcColors.textMuted)),
        const SizedBox(height: 8),
        ...external.map((c) {
          final fileName = '${c.id}.json';
          return ListTile(
            dense: true,
            title: Text(c.title, style: const TextStyle(fontSize: 13)),
            subtitle: Text('ID: ${c.id}', style: const TextStyle(fontSize: 11)),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: TdcColors.danger),
              onPressed: () async {
                final ok = await _showConfirmDialog('Supprimer le module ${c.title} ?');
                if (ok) await courses.deleteModule(fileName);
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _diffRow(String label, String? oldVal, String? newVal) {
    final changed = oldVal != newVal;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: TdcColors.textMuted)),
          Row(
            children: [
              Expanded(child: Text(oldVal ?? '(néant)', style: const TextStyle(fontSize: 12, decoration: TextDecoration.lineThrough))),
              const Icon(Icons.arrow_forward, size: 12),
              Expanded(child: Text(newVal ?? '(supprimé)', style: TextStyle(fontSize: 12, color: changed ? Colors.green : null, fontWeight: changed ? FontWeight.bold : null))),
            ],
          ),
        ],
      ),
    );
  }
}
