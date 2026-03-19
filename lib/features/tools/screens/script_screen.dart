import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tutodecode/core/theme/app_theme.dart';
import 'package:tutodecode/core/providers/shell_provider.dart';
import 'package:tutodecode/core/widgets/tdc_widgets.dart';

class ScriptEntry {
  final String title, description, code, language, category;
  ScriptEntry({required this.title, required this.description, required this.code, required this.language, required this.category});
}

class ScriptScreen extends StatefulWidget {
  const ScriptScreen({super.key});
  @override State<ScriptScreen> createState() => _ScriptScreenState();
}

class _ScriptScreenState extends State<ScriptScreen> {
  String _selectedCat = "TOUT";
  final List<ScriptEntry> _scripts = [
    ScriptEntry(category: 'SYSTÈME', title: 'Reset Stack Réseau', description: 'Réinit Winsock/IP/DNS.', language: 'BATCH', code: 'netsh winsock reset\nnetsh int ip reset\nipconfig /flushdns'),
    ScriptEntry(category: 'SYSTÈME', title: 'Check Santé Disque', description: 'Statut SMART via WMI.', language: 'POWERSHELL', code: 'Get-WmiObject -namespace root\\wmi -class MSStorageDriver_FailurePredictStatus'),
    ScriptEntry(category: 'CRYPTOGRAPHIE', title: 'Chiffrer AES-256', description: 'OpenSSL enc.', language: 'BASH', code: 'openssl enc -aes-256-cbc -salt -in file.txt -out file.enc'),
    ScriptEntry(category: 'CRYPTOGRAPHIE', title: 'Générer Mdp Fort', description: 'Random logic.', language: 'BASH', code: 'openssl rand -base64 32'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShellProvider>().updateShell(title: 'Bibliothèque Scripts', showBackButton: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _scripts.where((s) => _selectedCat == "TOUT" || s.category == _selectedCat).toList();
    return Column(children: [
      _filter(),
      Expanded(child: ListView.builder(padding: const EdgeInsets.all(20), itemCount: filtered.length, itemBuilder: (context, i) => _card(filtered[i]))),
    ]);
  }

  Widget _filter() {
    final cats = ["TOUT", "SYSTÈME", "CRYPTOGRAPHIE"];
    return Container(
      height: 54, color: TdcColors.surface,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: cats.length,
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(cats[i], style: const TextStyle(fontSize: 11)),
            selected: _selectedCat == cats[i],
            onSelected: (_) => setState(() => _selectedCat = cats[i]),
          ),
        ),
      ),
    );
  }

  Widget _card(ScriptEntry s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: TdcColors.surface, borderRadius: TdcRadius.md, border: Border.all(color: TdcColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(s.title, style: const TextStyle(color: TdcColors.textPrimary, fontWeight: FontWeight.bold)),
          TdcStatusBadge(label: s.language, color: Colors.blue),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: TdcColors.bg, borderRadius: TdcRadius.sm, border: Border.all(color: TdcColors.border)),
          child: Row(children: [
            Expanded(child: Text(s.code, style: const TextStyle(color: TdcColors.success, fontFamily: 'monospace', fontSize: 12))),
            IconButton(icon: const Icon(Icons.copy, size: 18), onPressed: () { Clipboard.setData(ClipboardData(text: s.code)); }),
          ]),
        ),
      ]),
    );
  }
}
