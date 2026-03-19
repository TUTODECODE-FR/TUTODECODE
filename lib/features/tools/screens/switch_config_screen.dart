import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/shell_provider.dart';
import '../../../core/widgets/tdc_widgets.dart';

class SwitchCommand {
  final String brand, category, description, command;
  const SwitchCommand({required this.brand, required this.category, required this.description, required this.command});
}

class SwitchConfigScreen extends StatefulWidget {
  const SwitchConfigScreen({super.key});
  @override State<SwitchConfigScreen> createState() => _SwitchConfigScreenState();
}

class _SwitchConfigScreenState extends State<SwitchConfigScreen> {
  String _brand = 'CISCO';
  String _cat = 'TOUT';

  final List<SwitchCommand> _commands = [
    SwitchCommand(brand: 'CISCO', category: 'INIT', description: 'Mode privilégié', command: 'enable'),
    SwitchCommand(brand: 'CISCO', category: 'VLAN', description: 'Créer VLAN 10', command: 'vlan 10\nname DATA'),
    SwitchCommand(brand: 'HP/ARUBA', category: 'INIT', description: 'Configuration', command: 'configure'),
    SwitchCommand(brand: 'DELL', category: 'ROUTING', description: 'IP sur VLAN', command: 'interface vlan 10\nip address 192.168.10.1/24'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShellProvider>().updateShell(title: 'Config Switch L3', showBackButton: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _commands.where((c) => c.brand == _brand && (_cat == 'TOUT' || c.category == _cat)).toList();
    return Column(children: [
      _filters(),
      Expanded(child: ListView.builder(padding: const EdgeInsets.all(20), itemCount: filtered.length, itemBuilder: (context, i) => _tile(filtered[i]))),
    ]);
  }

  Widget _filters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: TdcColors.surface,
      child: Column(children: [
        Row(children: ['CISCO', 'HP/ARUBA', 'DELL'].map((b) => Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(b), selected: _brand == b, onSelected: (_) => setState(() => _brand = b)))).toList()),
        const SizedBox(height: 8),
        Row(children: ['TOUT', 'INIT', 'VLAN', 'ROUTING'].map((c) => Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(c), selected: _cat == c, onSelected: (_) => setState(() => _cat = c)))).toList()),
      ]),
    );
  }

  Widget _tile(SwitchCommand c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: TdcColors.surface, borderRadius: TdcRadius.md, border: Border.all(color: TdcColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(c.description, style: const TextStyle(color: TdcColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: TdcColors.bg, borderRadius: TdcRadius.sm),
          child: Row(children: [
            Expanded(child: Text(c.command, style: const TextStyle(color: TdcColors.accent, fontFamily: 'monospace', fontSize: 13))),
            IconButton(icon: const Icon(Icons.copy, size: 18), onPressed: () => Clipboard.setData(ClipboardData(text: c.command))),
          ]),
        ),
      ]),
    );
  }
}
