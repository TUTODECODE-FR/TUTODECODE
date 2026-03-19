import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/tdc_widgets.dart';
import '../../../core/providers/shell_provider.dart';

class GpoEntry {
  final String title;
  final String path;
  final String description;
  final String impact;
  final String category;
  final String technicalNote;

  GpoEntry({
    required this.title,
    required this.path,
    required this.description,
    required this.impact,
    required this.category,
    this.technicalNote = '',
  });
}

class GpoGuideScreen extends StatefulWidget {
  const GpoGuideScreen({super.key});

  @override
  State<GpoGuideScreen> createState() => _GpoGuideScreenState();
}

class _GpoGuideScreenState extends State<GpoGuideScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _filter = '';
  String _selectedCategory = 'TOUT';

  final List<GpoEntry> _entries = [
    // --- SÉCURITÉ ---
    GpoEntry(
      title: 'Désactiver PowerShell v2 (Obsolète)',
      path: 'Configuration ordinateur > Modèles d\'administration > Composants Windows > Windows PowerShell > Désactiver PowerShell v2',
      description: 'Force l\'utilisation des versions récentes de PowerShell pour bénéficier de la journalisation avancée.',
      impact: 'Sécurité',
      category: 'SÉCURITÉ',
      technicalNote: 'PowerShell v2 permet de bypasser les politiques de restriction d\'exécution.',
    ),
    GpoEntry(
      title: 'Désactiver SMBv1 (WannaCry Prevention)',
      path: 'Configuration ordinateur > Modèles d\'administration > Réseau > Station de travail Lanman > Activer SMB 1.0 (Désactivé)',
      description: 'Désactive le protocole obsolète et vulnérable SMBv1 pour prévenir les attaques par mouvement latéral.',
      impact: 'Sécurité Critique',
      category: 'SÉCURITÉ',
      technicalNote: 'Indispendable pour bloquer les ransomwares anciens utilisant EternalBlue.',
    ),
    GpoEntry(
      title: 'Désactiver l\'installation de périphériques non approuvés',
      path: 'Configuration ordinateur > Modèles d\'administration > Système > Installation de périphériques > Restrictions d\'installation de périphériques',
      description: 'Empêche l\'installation de nouveaux périphériques matériels non autorisés (ex: clés USB Wi-Fi tierces).',
      impact: 'Sécurité',
      category: 'SÉCURITÉ',
      technicalNote: 'Utile pour prévenir l\'exfiltration de données via des périphériques de stockage ou réseaux non contrôlés.',
    ),
    GpoEntry(
      title: 'Interdire les comptes Microsoft (Postes joints au domaine)',
      path: 'Configuration ordinateur > Paramètres Windows > Paramètres de sécurité > Stratégies locales > Options de sécurité > Comptes : bloquer les comptes Microsoft',
      description: 'Force l\'utilisation des comptes du domaine AD uniquement, empêchant la connexion via un compte personnel.',
      impact: 'Sécurité',
      category: 'SÉCURITÉ',
      technicalNote: 'Assure que toutes les sessions sont auditées par le contrôleur de domaine.',
    ),
    GpoEntry(
      title: 'Configuration de LAPS (Legacy)',
      path: 'Configuration ordinateur > Modèles d\'administration > LAPS',
      description: 'Gère les mots de passe des administrateurs locaux de manière unique et aléatoire.',
      impact: 'Sécurité Critique',
      category: 'SÉCURITÉ',
      technicalNote: 'Nécessite l\'installation de l\'extension client LAPS sur les postes.',
    ),
    GpoEntry(
      title: 'Restreindre l\'accès à l\'invite de commande',
      path: 'Configuration utilisateur > Modèles d\'administration > Système > Empêcher l\'accès à l\'invite de commandes',
      description: 'Empêche les utilisateurs non-administrateurs d\'exécuter cmd.exe et les scripts batch.',
      impact: 'Haut',
      category: 'SÉCURITÉ',
      technicalNote: 'Option "Traiter également l\'exécution de scripts de commandes" recommandée sur Oui.',
    ),
    GpoEntry(
      title: 'Verrouillage automatique de session (Inactivité)',
      path: 'Configuration ordinateur > Paramètres Windows > Paramètres de sécurité > Stratégies locales > Options de sécurité > Ouverture de session interactive : limite d\'inactivité de la machine',
      description: 'Verrouille automatiquement le poste après un délai défini (ex: 900 secondes).',
      impact: 'Sécurité',
      category: 'SÉCURITÉ',
      technicalNote: 'Crucial pour la conformité RGPD et la sécurité physique des bureaux.',
    ),

    // --- RÉSEAU ---
    GpoEntry(
      title: 'Blocage du protocole LLMNR',
      path: 'Configuration ordinateur > Modèles d\'administration > Réseau > Client DNS > Désactiver la résolution de noms multidiffusion',
      description: 'Empêche la résolution de noms via LLMNR pour bloquer les attaques de type MiTM (Responder).',
      impact: 'Haut',
      category: 'RÉSEAU',
      technicalNote: 'Coupler avec la désactivation de NetBIOS sur TCP/IP via DHCP.',
    ),
    GpoEntry(
      title: 'Désactiver le WPAD (Web Proxy Auto-Discovery)',
      path: 'Configuration utilisateur > Modèles d\'administration > Composants Windows > Internet Explorer > Désactiver la détection de proxy automatique',
      description: 'Empêche les attaquants de rediriger le trafic web via un faux fichier PAC.',
      impact: 'Sécurité',
      category: 'RÉSEAU',
      technicalNote: 'Source majeure de fuite d\'identifiants NTLM.',
    ),
    GpoEntry(
      title: 'Restriction du trafic RPC non chiffré',
      path: 'Configuration ordinateur > Paramètres Windows > Paramètres de sécurité > Stratégies locales > Options de sécurité > Client réseau Microsoft : signer numériquement les communications (toujours)',
      description: 'Force le chiffrement et la signature des communications RPC pour éviter l\'interception.',
      impact: 'Sécurité Réseau',
      category: 'RÉSEAU',
      technicalNote: 'Peut impacter la compatibilité avec de très vieux systèmes (Windows 2000/XP).',
    ),

    // --- INTERFACE ---
    GpoEntry(
      title: 'Désactiver Windows Store (Entreprise)',
      path: 'Configuration ordinateur > Modèles d\'administration > Composants Windows > Store > Désactiver l\'application Store',
      description: 'Empêche l\'installation d\'applications tierces non validées par l\'IT.',
      impact: 'Contrôle',
      category: 'INTERFACE',
    ),
    GpoEntry(
      title: "Forcer un fond d'écran corporatif (Lockscreen/Wallpaper)",
      path: 'Configuration utilisateur > Modèles d\'administration > Bureau > Bureau > Papier peint du Bureau',
      description: 'Standardise l\'apparence visuelle des postes de travail.',
      impact: 'Esthétique',
      category: 'INTERFACE',
      technicalNote: 'L\'image doit être accessible via un partage réseau (UNC) lisible par "Utilisateurs du domaine".',
    ),
    GpoEntry(
      title: 'Supprimer "Exécuter" du menu Démarrer',
      path: 'Configuration utilisateur > Modèles d\'administration > Menu Démarrer et barre des tâches',
      description: 'Limite les vecteurs d\'exécution rapide pour les utilisateurs basiques.',
      impact: 'Support',
      category: 'INTERFACE',
    ),

    // --- SYSTÈME ---
    GpoEntry(
      title: 'Configuration WSUS / Windows Update',
      path: 'Configuration ordinateur > Modèles d\'administration > Composants Windows > Windows Update',
      description: 'Définit le serveur de mise à jour local et les horaires d\'installation.',
      impact: 'Stabilité',
      category: 'SYSTÈME',
      technicalNote: 'Indispensable pour garder le parc à jour sans saturer la bande passante internet.',
    ),
    GpoEntry(
      title: 'Configuration du fuseau horaire (GMT)',
      path: 'Configuration ordinateur > Modèles d\'administration > Système > Service de temps Windows > Fuseau horaire',
      description: 'Force l\'utilisation du fuseau horaire correct sur tous les postes pour la synchronisation des logs.',
      impact: 'Maintenance',
      category: 'SYSTÈME',
      technicalNote: 'Essentiel pour la corrélation d\'événements lors d\'incidents de sécurité.',
    ),
    GpoEntry(
      title: 'Déploiement d\'imprimantes IP',
      path: 'Configuration ordinateur > Préférences > Paramètres de configuration > Imprimantes',
      description: 'Déploie les pilotes et files d\'attente d\'impression automatiquement.',
      impact: 'Productivité',
      category: 'SYSTÈME',
    ),
    GpoEntry(
      title: 'Mapper des lecteurs réseau (Via Préférences)',
      path: 'Configuration utilisateur > Préférences > Paramètres Windows > Mappages de lecteurs',
      description: 'Connecte automatiquement les dossiers partages (Z:, S:, etc.) selon les groupes AD.',
      impact: 'Productivité',
      category: 'SYSTÈME',
      technicalNote: 'Utilisez le ciblage au niveau de l\'élément (Item-level targeting) pour la précision.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShellProvider>().updateShell(
        title: 'GPO Master Guide',
        showBackButton: true,
        actions: [],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _entries.where((e) {
      final matchesSearch = e.title.toLowerCase().contains(_filter.toLowerCase()) || 
                          e.description.toLowerCase().contains(_filter.toLowerCase());
      final matchesCat = _selectedCategory == 'TOUT' || e.category == _selectedCategory;
      return matchesSearch && matchesCat;
    }).toList();

    // Tri par catégorie puis par titre
    filtered.sort((a, b) {
      int catComp = a.category.compareTo(b.category);
      if (catComp != 0) return catComp;
      return a.title.compareTo(b.title);
    });

    return Column(
      children: [
        _buildHeader(),
        _buildFilters(),
        Expanded(
          child: filtered.isEmpty 
            ? const TdcEmptyState(icon: Icons.search_off, title: 'Aucune GPO trouvée')
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: filtered.length,
                itemBuilder: (context, index) => _buildGpoCard(filtered[index]),
              ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: TdcColors.surface.withValues(alpha: 0.3),
        border: Border(bottom: BorderSide(color: TdcColors.border.withValues(alpha: 0.5))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: TdcColors.accent.withValues(alpha: 0.1),
                  borderRadius: TdcRadius.md,
                ),
                child: const Icon(Icons.admin_panel_settings, color: TdcColors.accent, size: 24),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Référence GPO Windows Server',
                      style: TextStyle(color: TdcColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Chemins et configurations essentiels pour durcir et gérer votre parc AD.',
                      style: TextStyle(color: TdcColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _filter = v),
            style: const TextStyle(color: TdcColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Rechercher une stratégie (ex: SMB, DNS, Bureau)...',
              prefixIcon: const Icon(Icons.search, color: TdcColors.accent),
              filled: true,
              fillColor: TdcColors.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              border: OutlineInputBorder(borderRadius: TdcRadius.md, borderSide: BorderSide(color: TdcColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: TdcRadius.md, borderSide: BorderSide(color: TdcColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: TdcRadius.md, borderSide: BorderSide(color: TdcColors.accent)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final categories = ['TOUT', 'SÉCURITÉ', 'RÉSEAU', 'INTERFACE', 'SYSTÈME'];
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, i) {
          final cat = categories[i];
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8, top: 12, bottom: 12),
            child: InkWell(
              onTap: () => setState(() => _selectedCategory = cat),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? TdcColors.accent : TdcColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? TdcColors.accent : TdcColors.border),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    color: isSelected ? Colors.white : TdcColors.textSecondary,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGpoCard(GpoEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TdcCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TdcStatusBadge(
                  label: entry.category,
                  color: _getCategoryColor(entry.category),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: entry.impact.contains('Critique') ? TdcColors.danger.withValues(alpha: 0.1) : TdcColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    entry.impact,
                    style: TextStyle(
                      color: entry.impact.contains('Critique') ? TdcColors.danger : TdcColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              entry.title,
              style: const TextStyle(color: TdcColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              entry.description,
              style: const TextStyle(color: TdcColors.textSecondary, fontSize: 14, height: 1.4),
            ),
            if (entry.technicalNote.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: TdcColors.info.withValues(alpha: 0.05),
                  borderRadius: TdcRadius.sm,
                  border: Border(left: BorderSide(color: TdcColors.info, width: 3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, size: 16, color: TdcColors.info),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.technicalNote,
                        style: const TextStyle(color: TdcColors.info, fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            const Text('CHEMIN DE CONFIGURATION', style: TextStyle(color: TdcColors.textMuted, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TdcColors.bg,
                borderRadius: TdcRadius.md,
                border: Border.all(color: TdcColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.folder_open, size: 16, color: TdcColors.textMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SelectableText(
                      entry.path,
                      style: const TextStyle(color: TdcColors.textSecondary, fontSize: 11, fontFamily: 'monospace'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: entry.path));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Chemin copié !')),
                        );
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        child: const Icon(Icons.copy, size: 16, color: TdcColors.accent),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String cat) {
    switch (cat) {
      case 'SÉCURITÉ': return TdcColors.danger;
      case 'INTERFACE': return const Color(0xFF8B5CF6);
      case 'SYSTÈME': return const Color(0xFF10B981);
      case 'RÉSEAU': return TdcColors.accent;
      default: return TdcColors.textMuted;
    }
  }
}
