// ============================================================
// app_shell.dart — Coquille responsive persistante
// ── Desktop : sidebar fixe à gauche + contenu
// ── Tablet  : sidebar escamotable (drawer) + contenu plein
// ── Mobile  : drawer + BottomNavigationBar
// ============================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/responsive/responsive.dart';
import '../features/courses/providers/courses_provider.dart';
import '../features/ghost_ai/service/ollama_service.dart';
import '../core/providers/shell_provider.dart';
import '../core/navigation/nav_keys.dart';

class AppShell extends StatefulWidget {
  final Widget child;

  const AppShell({
    super.key,
    required this.child,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  OllamaStatus? _aiStatus;

  @override
  void initState() {
    super.initState();
    _checkAI();
  }

  Future<void> _checkAI() async {
    final s = await OllamaService.checkStatus();
    if (mounted) setState(() => _aiStatus = s);
  }

  // ── Items de navigation ───────────────────────────────────
  // Note: Icônes harmonisées (smart_toy pour IA partout)
  List<_NavItem> get _navItems => [
    const _NavItem(Icons.home_filled,  'Accueil',     '/'),
    const _NavItem(Icons.build,        'Outils',   '/tools'),
    const _NavItem(Icons.description,  'Cheat Sheets', '/cheat-sheets'),
    const _NavItem(Icons.network_check, 'NetKit',      '/netkit'),
    const _NavItem(Icons.smart_toy,    'Chat IA',      '/ai'),
    const _NavItem(Icons.settings,     'Paramètres',   '/settings'),
    const _NavItem(Icons.map,          'Roadmap',      '/roadmap'),
    const _NavItem(Icons.science,      'Laboratoire',  '/lab'),
  ];

  // ── Petites icônes de statut IA ───────────────────────────
  Widget _aiDot() {
    if (_aiStatus == null) {
      return SizedBox(
        width: 8, height: 8,
        child: CircularProgressIndicator(strokeWidth: 1.5, color: TdcColors.textMuted),
      );
    }
    return Container(
      width: 8, height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _aiStatus!.running ? TdcColors.success : TdcColors.danger,
        boxShadow: [BoxShadow(
          color: (_aiStatus!.running ? TdcColors.success : TdcColors.danger).withOpacity(0.5),
          blurRadius: 4,
        )],
      ),
    );
  }

  Widget _buildBreadcrumbs(BuildContext context, String activeRoute) {
    final Map<String, String> routeNames = {
      '/': 'Accueil',
      '/tools': 'Outils',
      '/cheat-sheets': 'Cheat Sheets',
      '/netkit': 'NetKit',
      '/ai': 'Chat IA',
      '/ai-config': 'Config IA',
      '/roadmap': 'Roadmap',
      '/lab': 'Laboratoire',
      '/dashboard': 'Diagnostic',
      '/tools/scripts': 'Scripts',
      '/tools/hardware': 'Matériel',
      '/tools/survival': 'SOS Dépannage',
      '/tools/glossary': 'Glossaire',
      '/chapter': 'Cours',
      '/settings': 'Paramètres',
    };

    final items = routeNames.entries
        .where((e) => activeRoute.startsWith(e.key) && e.key != '/')
        .toList();
    
    items.sort((a, b) => a.key.length.compareTo(b.key.length));

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => AppNavigator.pushReplacementNamed('/'),
          child: const Text('Accueil', 
            style: TextStyle(color: TdcColors.textMuted, fontSize: 13, fontWeight: FontWeight.w500)),
        ),
        if (items.isNotEmpty) ...items.map((item) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.chevron_right, size: 14, color: TdcColors.textMuted.withOpacity(0.5)),
            ),
            Text(item.value, 
              style: TextStyle(
                color: item.key == activeRoute ? TdcColors.accent : TdcColors.textSecondary,
                fontSize: 13,
                fontWeight: item.key == activeRoute ? FontWeight.bold : FontWeight.w500,
              )),
          ],
        )).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ShellProvider, CoursesProvider>(
      builder: (context, shell, courses, _) {
        return ResponsiveBuilder(
          builder: (ctx, type) {
            if (type.isDesktop) return _buildDesktop(ctx, shell);
            if (type.isTablet) return _buildTablet(ctx, shell);
            return _buildMobile(ctx, shell);
          },
        );
      },
    );
  }

  Widget _buildDesktop(BuildContext context, ShellProvider shell) {
    return Scaffold(
      backgroundColor: TdcColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildDesktopHeader(context, shell),
            Expanded(
              child: Row(
                children: [
                  _buildSidebar(context, width: 240, activeRoute: shell.activeRoute),
                  Expanded(child: widget.child),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopHeader(BuildContext context, ShellProvider shell) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: TdcColors.surface.withOpacity(0.5),
        border: Border(bottom: BorderSide(color: TdcColors.border.withOpacity(0.5))),
      ),
      child: Row(
        children: [
          if (shell.showBackButton) ...[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: TdcColors.accent, size: 18),
              onPressed: shell.onBack ?? () => AppNavigator.pop(),
              tooltip: 'Retour',
            ),
            const SizedBox(width: 8),
          ],
          _buildBreadcrumbs(context, shell.activeRoute),
          const Spacer(),
          _buildGlobalSearchTrigger(context),
          const SizedBox(width: 16),
          if (shell.actions != null) ...shell.actions!,
        ],
      ),
    );
  }

  Widget _buildGlobalSearchTrigger(BuildContext context) {
    return Container(
      width: 200,
      height: 36,
      decoration: BoxDecoration(
        color: TdcColors.bg.withOpacity(0.5),
        borderRadius: TdcRadius.md,
        border: Border.all(color: TdcColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showGlobalSearch(context),
          borderRadius: TdcRadius.md,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(Icons.search, size: 16, color: TdcColors.textMuted),
                const SizedBox(width: 8),
                const Expanded(child: Text('Rechercher...', style: TextStyle(color: TdcColors.textMuted, fontSize: 13))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: TdcColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: TdcColors.border),
                  ),
                  child: const Text('⌘K', style: TextStyle(color: TdcColors.textMuted, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showGlobalSearch(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _GlobalSearchDialog(navItems: _navItems),
    );
  }

  Widget _buildTablet(BuildContext context, ShellProvider shell) {
    return Scaffold(
      backgroundColor: TdcColors.bg,
      drawer: Drawer(
        backgroundColor: TdcColors.surface,
        width: 260,
        child: SafeArea(child: _buildSidebar(context, width: 260, insideDrawer: true, activeRoute: shell.activeRoute)),
      ),
      appBar: _buildAppBar(context, shell),
      body: widget.child,
    );
  }

  Widget _buildMobile(BuildContext context, ShellProvider shell) {
    final mobileItems = _navItems.take(4).toList();
    final activeIndex = mobileItems.indexWhere((i) => i.route == shell.activeRoute);

    return Scaffold(
      backgroundColor: TdcColors.bg,
      drawer: Drawer(
        backgroundColor: TdcColors.surface,
        child: SafeArea(child: _buildSidebar(context, width: double.infinity, insideDrawer: true, activeRoute: shell.activeRoute)),
      ),
      appBar: _buildAppBar(context, shell),
      body: widget.child,
      bottomNavigationBar: _buildBottomNav(context, mobileItems, activeIndex, shell.activeRoute),
      floatingActionButton: FloatingActionButton(
        mini: true,
        onPressed: () => AppNavigator.pushNamed('/ai'),
        backgroundColor: const Color(0xFF2D2060),
        child: const Icon(Icons.smart_toy, color: TdcColors.warning, size: 20),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ShellProvider shell) {
    return AppBar(
      backgroundColor: TdcColors.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Row(children: [
        if (shell.showBackButton)
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: TdcColors.accent, size: 18),
            onPressed: shell.onBack ?? () => AppNavigator.pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        if (shell.showBackButton) const SizedBox(width: 12),
        const Icon(Icons.code, color: TdcColors.accent, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(shell.title,
              style: const TextStyle(
                color: TdcColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis),
        ),
      ]),
      actions: [
        if (shell.actions != null) ...shell.actions!,
        GestureDetector(
          onTap: () => AppNavigator.pushNamed('/ai-config'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(children: [
              Icon(Icons.memory, size: 16, color: _aiStatus?.running == true ? TdcColors.success : TdcColors.textMuted),
              const SizedBox(width: 4),
              _aiDot(),
            ]),
          ),
        ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: TdcColors.border),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, List<_NavItem> items, int activeIndex, String activeRoute) {
    return Container(
      decoration: BoxDecoration(
        color: TdcColors.surface,
        border: const Border(top: BorderSide(color: TdcColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: items.asMap().entries.map((e) {
            final item = e.value;
            final isActive = item.route == activeRoute;
            return Expanded(
              child: InkWell(
                onTap: () {
                  if (!isActive) AppNavigator.pushNamed(item.route);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item.icon,
                          size: 22,
                          color: isActive ? TdcColors.accent : TdcColors.textMuted),
                      const SizedBox(height: 4),
                      Text(item.label,
                          style: TextStyle(
                            fontSize: 10,
                            color: isActive ? TdcColors.accent : TdcColors.textMuted,
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          )),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, {required double width, bool insideDrawer = false, required String activeRoute}) {
    return Consumer<CoursesProvider>(
      builder: (context, prov, _) {
        return Container(
          width: width,
          height: double.infinity,
          decoration: BoxDecoration(
            color: TdcColors.surface.withOpacity(0.8),
            border: insideDrawer ? null : Border(right: BorderSide(color: TdcColors.border.withOpacity(0.5))),
          ),
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(TdcSpacing.md, TdcSpacing.lg, TdcSpacing.md, TdcSpacing.md),
                    child: Row(children: [
                      Image.asset('assets/logo.png', width: 32, height: 32),
                      const SizedBox(width: TdcSpacing.sm),
                      const Text('TutoDeCode',
                          style: TextStyle(
                            color: TdcColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          )),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: TdcSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Progression',
                                style: TextStyle(color: TdcColors.textMuted, fontSize: 11)),
                            Text('${(prov.overallProgress * 100).toInt()}%',
                                style: const TextStyle(color: TdcColors.accent, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: prov.overallProgress,
                            minHeight: 4,
                            backgroundColor: TdcColors.surfaceAlt,
                            valueColor: const AlwaysStoppedAnimation(TdcColors.accent),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('${prov.completedCount} sur ${prov.totalChaptersCount} chapitres',
                            style: const TextStyle(color: TdcColors.textMuted, fontSize: 10)),
                      ],
                    ),
                  ),
                  const SizedBox(height: TdcSpacing.lg),
                  const Divider(color: TdcColors.border, height: 1),
                  const SizedBox(height: TdcSpacing.sm),
                  ..._navItems.map((item) => _buildNavItem(context, item, insideDrawer, activeRoute)),
                  const Expanded(child: SizedBox()),
                  const Divider(color: TdcColors.border, height: 1),
                  Padding(
                    padding: const EdgeInsets.all(TdcSpacing.md),
                    child: InkWell(
                      onTap: () {
                        if (insideDrawer) Navigator.pop(context);
                        AppNavigator.pushNamed('/ai-config');
                      },
                      borderRadius: TdcRadius.md,
                      child: Container(
                        padding: const EdgeInsets.all(TdcSpacing.sm + 2),
                        decoration: BoxDecoration(
                          color: TdcColors.surfaceAlt,
                          borderRadius: TdcRadius.md,
                          border: Border.all(color: TdcColors.border),
                        ),
                        child: Row(children: [
                          Icon(Icons.memory, size: 16,
                              color: _aiStatus?.running == true ? TdcColors.success : TdcColors.textMuted),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _aiStatus == null
                                      ? 'Vérification…'
                                      : (_aiStatus!.running ? 'Ollama actif' : 'Ollama hors-ligne'),
                                  style: const TextStyle(color: TdcColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  _aiStatus?.running == true
                                      ? '${_aiStatus!.models.length} modèle(s)'
                                      : 'Cliquer pour configurer',
                                  style: const TextStyle(color: TdcColors.textMuted, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(BuildContext context, _NavItem item, bool insideDrawer, String activeRoute) {
    final isActive = (item.route == '/' && activeRoute == '/') || 
                    (item.route != '/' && activeRoute.startsWith(item.route));
    return _HoverNavItem(
      item: item,
      isActive: isActive,
      onTap: () {
        if (insideDrawer) Navigator.pop(context);
        if (!isActive) AppNavigator.pushNamed(item.route);
      },
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  final Widget? trailing;
  const _NavItem(this.icon, this.label, this.route, {this.trailing});
}

class _HoverNavItem extends StatefulWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _HoverNavItem({required this.item, required this.isActive, required this.onTap});

  @override
  State<_HoverNavItem> createState() => _HoverNavItemState();
}

class _HoverNavItemState extends State<_HoverNavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isActive;
    return Tooltip(
      message: widget.item.label,
      waitDuration: const Duration(milliseconds: 800),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(horizontal: TdcSpacing.sm, vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: TdcSpacing.md, vertical: TdcSpacing.sm + 2),
            decoration: BoxDecoration(
              color: isActive
                  ? TdcColors.accent
                  : _hovered
                       ? TdcColors.surfaceHover
                      : Colors.transparent,
              borderRadius: TdcRadius.sm,
              border: Border.all(
                color: isActive
                    ? Colors.transparent
                    : _hovered
                        ? TdcColors.border
                        : Colors.transparent,
              ),
            ),
            child: Row(children: [
              Icon(
                widget.item.icon,
                size: 18,
                color: isActive
                    ? Colors.white
                    : _hovered
                        ? TdcColors.textPrimary
                        : TdcColors.textSecondary,
              ),
              const SizedBox(width: TdcSpacing.sm),
              Expanded(
                child: Text(
                  widget.item.label,
                  style: TextStyle(
                    color: isActive
                        ? Colors.white
                        : _hovered
                            ? TdcColors.textPrimary
                            : TdcColors.textSecondary,
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              if (widget.item.trailing != null) widget.item.trailing!,
            ]),
          ),
        ),
      ),
    );
  }
}

class _GlobalSearchDialog extends StatefulWidget {
  final List<_NavItem> navItems;
  const _GlobalSearchDialog({required this.navItems});

  @override
  State<_GlobalSearchDialog> createState() => _GlobalSearchDialogState();
}

class _GlobalSearchDialogState extends State<_GlobalSearchDialog> {
  String _query = '';
  
  // Simulation de données de commandes (doit correspondre à cheat_sheet_screen.dart)
  final _commands = [
    {'cmd': 'ipconfig /flushdns', 'desc': 'Vider le cache DNS'},
    {'cmd': 'sfc /scannow', 'desc': 'Réparer les fichiers système'},
    {'cmd': 'gpupdate /force', 'desc': 'Forcer les GPO'},
    {'cmd': 'sudo purge', 'desc': 'Vider la RAM (Mac)'},
    {'cmd': 'journalctl -xe', 'desc': 'Logs Linux'},
    {'cmd': 'docker system prune', 'desc': 'Nettoyage Docker'},
    {'cmd': 'nmap -sV', 'desc': 'Scan de ports'},
  ];

  @override
  Widget build(BuildContext context) {
    final filteredPages = widget.navItems
        .where((i) => i.label.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    
    final filteredCmds = _commands
        .where((c) => c['cmd']!.toLowerCase().contains(_query.toLowerCase()) || 
                     c['desc']!.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600,
        decoration: BoxDecoration(
          color: TdcColors.surface,
          borderRadius: TdcRadius.lg,
          border: Border.all(color: TdcColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 40)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                autofocus: true,
                style: const TextStyle(color: TdcColors.textPrimary),
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                  hintText: 'Pages, cours ou commandes...',
                  prefixIcon: Icon(Icons.search, color: TdcColors.accent),
                  border: InputBorder.none,
                ),
              ),
            ),
            const Divider(height: 1),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 500),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (_query.isNotEmpty && filteredPages.isNotEmpty) ...[
                      _sectionHeader('PAGES'),
                      ...filteredPages.map((item) => _buildResultRow(
                        icon: item.icon,
                        title: item.label,
                        subtitle: item.route,
                        onTap: () {
                          AppNavigator.pop();
                          AppNavigator.pushNamed(item.route);
                        },
                      )),
                    ],
                    if (_query.isNotEmpty && filteredCmds.isNotEmpty) ...[
                      _sectionHeader('COMMANDES CHEAT SHEET'),
                      ...filteredCmds.map((c) => _buildResultRow(
                        icon: Icons.terminal,
                        title: c['desc']!,
                        subtitle: c['cmd']!,
                        onTap: () {
                          AppNavigator.pop();
                          AppNavigator.pushNamed('/cheat-sheets');
                        },
                      )),
                    ],
                    if (_query.isNotEmpty && filteredPages.isEmpty && filteredCmds.isEmpty)
                      const Padding(padding: EdgeInsets.all(32), child: Text('Aucun résultat trouvé', style: TextStyle(color: TdcColors.textMuted))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(title, style: const TextStyle(color: TdcColors.accent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
    );
  }

  Widget _buildResultRow({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: TdcColors.surfaceAlt, borderRadius: TdcRadius.sm),
        child: Icon(icon, size: 16, color: TdcColors.textSecondary),
      ),
      title: Text(title, style: const TextStyle(color: TdcColors.textPrimary, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(color: TdcColors.textMuted, fontSize: 11)),
      onTap: onTap,
    );
  }
}
