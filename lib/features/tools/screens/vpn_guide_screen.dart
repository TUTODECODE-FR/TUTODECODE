import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/shell_provider.dart';
import '../../../core/widgets/tdc_widgets.dart';

class VpnGuideScreen extends StatefulWidget {
  const VpnGuideScreen({super.key});
  @override State<VpnGuideScreen> createState() => _VpnGuideScreenState();
}

class _VpnGuideScreenState extends State<VpnGuideScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShellProvider>().updateShell(
        title: 'Guides VPN',
        showBackButton: true,
        actions: [],
      );
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: TdcColors.surface,
          child: TabBar(
            controller: _tab,
            indicatorColor: TdcColors.accent,
            labelColor: TdcColors.accent,
            unselectedLabelColor: TdcColors.textMuted,
            tabs: const [
              Tab(icon: Icon(Icons.link, size: 20), text: 'Tailscale'),
              Tab(icon: Icon(Icons.hub, size: 20), text: 'ZeroTier'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [
              _buildGuide([
                _step(1, 'Compte', 'Créez un compte sur tailscale.com (SSO Google/GitHub).', Icons.person_add),
                _step(2, 'Installation', 'Installez le client sur vos machines.', Icons.download),
                _step(3, 'Auth', 'Connectez-vous avec le même compte.', Icons.login),
                _step(4, 'IP', 'Utilisez l\'IP 100.x.x.x pour le contrôle à distance.', Icons.content_copy),
              ], 'Architecture Mesh VPN sécurisée basée sur WireGuard® (Zéro config port).'),
              _buildGuide([
                _step(1, 'Network ID', 'Créez un réseau sur my.zerotier.com.', Icons.lan),
                _step(2, 'Join', 'Rejoignez le réseau avec l\'ID (16 chars).', Icons.add_link),
                _step(3, 'Auth', 'Autorisez chaque membre dans le panel web.', Icons.verified_user),
                _step(4, 'IP', 'Utilisez l\'IP assignée (ex: 10.x.x.x).', Icons.check_circle),
              ], 'Réseau virtuel Layer 2 avec routage personnalisé.'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGuide(List<Widget> steps, String tip) {
    return TdcPageWrapper(
      child: ListView(
        children: [
          ...steps,
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: TdcColors.accent.withValues(alpha: 0.1), borderRadius: TdcRadius.md, border: Border.all(color: TdcColors.accent.withValues(alpha: 0.2))),
            child: Row(children: [const Icon(Icons.tips_and_updates, color: TdcColors.accent, size: 20), const SizedBox(width: 12), Expanded(child: Text(tip, style: const TextStyle(color: TdcColors.textPrimary, fontSize: 13)))]),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _step(int n, String title, String desc, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: TdcColors.surface, borderRadius: TdcRadius.md, border: Border.all(color: TdcColors.border)),
      child: Row(children: [
        Container(width: 28, height: 28, decoration: const BoxDecoration(shape: BoxShape.circle, color: TdcColors.bg), child: Center(child: Text('$n', style: const TextStyle(color: TdcColors.accent, fontWeight: FontWeight.bold)))),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(icon, size: 14, color: TdcColors.textMuted), const SizedBox(width: 6), Text(title, style: const TextStyle(color: TdcColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15))]),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(color: TdcColors.textSecondary, fontSize: 13)),
        ])),
      ]),
    );
  }
}
