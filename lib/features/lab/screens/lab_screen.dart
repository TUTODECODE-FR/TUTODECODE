import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/responsive/responsive.dart';
import '../../core/providers/shell_provider.dart';
import '../../core/widgets/tdc_widgets.dart';

// ─── Laboratoire Interactif — Refactorisé pour le Shell Persistant ────────────────
class LabScreen extends StatefulWidget {
  const LabScreen({super.key});
  @override State<LabScreen> createState() => _LabScreenState();
}

class _LabScreenState extends State<LabScreen> {
  int _selected = 0;

  static const _labs = [
    _LabMeta('Ping & Traceroute', Icons.radar, Color(0xFF10B981)),
    _LabMeta('Resolution DNS', Icons.dns, Color(0xFF6366F1)),
    _LabMeta('TCP Handshake', Icons.handshake, Color(0xFF3B82F6)),
    _LabMeta('Requete HTTP', Icons.http, Color(0xFFF59E0B)),
    _LabMeta('Diagnostic Port', Icons.lan, Color(0xFFEC4899)),
    _LabMeta('Master GPO', Icons.admin_panel_settings, Color(0xFFF97316)),
    _LabMeta('RAID/Disques', Icons.storage, Color(0xFF8B5CF6)),
    _LabMeta('SQL Injection', Icons.bug_report, Color(0xFFFACC15)),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShellProvider>().updateShell(
        title: 'Laboratoire',
        showBackButton: false,
        actions: [],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = TdcBreakpoints.isMobile(context);
    return Column(
      children: [
        if (isMobile) _buildMobileTabs(context),
        Expanded(
          child: Row(
            children: [
              if (!isMobile) _buildSidebar(context),
              Expanded(
                child: Container(
                  color: TdcColors.bg,
                  child: _buildContent(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileTabs(BuildContext context) {
    return Container(
      height: 60,
      color: TdcColors.surface,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _labs.length,
        itemBuilder: (context, i) {
          final lab = _labs[i];
          final sel = _selected == i;
          return GestureDetector(
            onTap: () => setState(() => _selected = i),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: sel ? lab.color.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: sel ? lab.color.withOpacity(0.3) : TdcColors.border.withOpacity(0.5)),
              ),
              child: Center(
                child: Row(children: [
                  Icon(lab.icon, size: 14, color: sel ? lab.color : TdcColors.textMuted),
                  const SizedBox(width: 8),
                  Text(lab.title, style: TextStyle(color: sel ? lab.color : TdcColors.textSecondary, fontSize: 12, fontWeight: sel ? FontWeight.bold : FontWeight.normal)),
                ]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: TdcColors.surface,
        border: Border(right: BorderSide(color: TdcColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text('SIMULATIONS', style: TextStyle(color: TdcColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _labs.length,
              itemBuilder: (context, i) {
                final lab = _labs[i];
                final sel = _selected == i;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: InkWell(
                    onTap: () => setState(() => _selected = i),
                    borderRadius: TdcRadius.md,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: sel ? lab.color.withOpacity(0.1) : Colors.transparent,
                        borderRadius: TdcRadius.md,
                        border: Border.all(color: sel ? lab.color.withOpacity(0.3) : Colors.transparent),
                      ),
                      child: Row(children: [
                        Icon(lab.icon, color: sel ? lab.color : TdcColors.textMuted, size: 20),
                        const SizedBox(width: 12),
                        Expanded(child: Text(lab.title, style: TextStyle(color: sel ? lab.color : TdcColors.textSecondary, fontSize: 13, fontWeight: sel ? FontWeight.bold : FontWeight.normal))),
                        if (sel) Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: lab.color)),
                      ]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selected) {
      case 0: return const PingSimulator();
      case 1: return const DnsSimulator();
      case 2: return const TcpSimulator();
      case 3: return const HttpSimulator();
      case 4: return const PortSimulator();
      case 5: return const GpoSimulator();
      case 6: return const DiskSimulator();
      case 7: return const SqlInjectionSimulator();
      default: return Center(child: Text('Simulation ${_labs[_selected].title} en cours de migration...', style: const TextStyle(color: Colors.white)));
    }
  }
}

class _LabMeta {
  final String title;
  final IconData icon;
  final Color color;
  const _LabMeta(this.title, this.icon, this.color);
}

class _PingLog { final int seq; final String host; final int ms; final bool ok; _PingLog({required this.seq, required this.host, required this.ms, required this.ok}); }

// ═══════════════════════════════════════════════════════════════════════════════
// 1. PING SIMULATOR
// ═══════════════════════════════════════════════════════════════════════════════
class PingSimulator extends StatefulWidget {
  const PingSimulator({super.key});
  @override State<PingSimulator> createState() => _PingSimulatorState();
}

class _PingSimulatorState extends State<PingSimulator> {
  final _controller = TextEditingController(text: '8.8.8.8');
  final _logs = <_PingLog>[];
  bool _running = false;
  double _packetPos = -1; // -1: hidden, 0: host, 1: remote

  void _start() {
    if (_running) return;
    setState(() { _running = true; _logs.clear(); });
    _runLoop();
  }

  Future<void> _runLoop() async {
    for (int i = 0; i < 4; i++) {
      if (!mounted) return;
      
      // Request
      setState(() => _packetPos = 0);
      await Future.delayed(const Duration(milliseconds: 50));
      setState(() => _packetPos = 1);
      await Future.delayed(const Duration(milliseconds: 300));

      final ok = Random().nextDouble() > 0.1;
      final ms = ok ? (10 + Random().nextInt(40)) : 0;

      // Response
      if (ok) {
        setState(() => _packetPos = 1);
        await Future.delayed(const Duration(milliseconds: 50));
        setState(() => _packetPos = 0);
        await Future.delayed(const Duration(milliseconds: 300));
      } else {
        setState(() => _packetPos = -2); // Collision/Drop
        await Future.delayed(const Duration(milliseconds: 400));
      }

      if (!mounted) return;
      setState(() { 
        _logs.add(_PingLog(seq: i + 1, host: _controller.text, ms: ms, ok: ok)); 
        _packetPos = -1; 
      });
      await Future.delayed(const Duration(milliseconds: 400));
    }
    if (mounted) setState(() => _running = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabHeader('Ping ICMP', 'Vérification de la connectivité réseau et délai (RTT).', const Color(0xFF10B981)),
        const SizedBox(height: 32),
        _buildVisualPath(),
        const SizedBox(height: 32),
        _buildInputRow(),
        const SizedBox(height: 24),
        _buildTerminal(),
      ],
    );
  }

  Widget _buildVisualPath() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: TdcColors.surface,
        borderRadius: TdcRadius.md,
        border: Border.all(color: TdcColors.border),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [TdcColors.surface, TdcColors.surfaceAlt.withOpacity(0.5)],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Connection Line
          Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 100),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.withOpacity(0.2), Colors.blue, Colors.blue.withOpacity(0.2)],
              ),
            ),
          ),
          // Local Host
          Positioned(
            left: 40,
            child: Column(
              children: [
                const Icon(Icons.laptop_chromebook, color: Colors.blue, size: 40),
                const SizedBox(height: 4),
                const Text('VOTRE PC', style: TextStyle(color: TdcColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // Remote Host
          Positioned(
            right: 40,
            child: Column(
              children: [
                const Icon(Icons.dns, color: TdcColors.success, size: 40),
                const SizedBox(height: 4),
                Text(_controller.text, style: const TextStyle(color: TdcColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // Packet
          if (_packetPos >= 0)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: 80 + (MediaQuery.of(context).size.width - 450) * _packetPos,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: TdcColors.accent,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: TdcColors.accent.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)],
                ),
                child: const Center(child: Icon(Icons.mail, size: 8, color: Colors.white)),
              ),
            ),
          // Error
          if (_packetPos == -2)
            const Center(child: Icon(Icons.flash_off, color: TdcColors.danger, size: 32)),
        ],
      ),
    );
  }

  Widget _buildInputRow() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            style: const TextStyle(color: TdcColors.textPrimary, fontFamily: 'monospace'),
            decoration: InputDecoration(
              hintText: 'Cible (IP ou Domaine)',
              prefixIcon: const Icon(Icons.radar, size: 18),
              filled: true,
              fillColor: TdcColors.surface,
              border: OutlineInputBorder(borderRadius: TdcRadius.md, borderSide: BorderSide.none),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: _running ? null : _start,
          icon: _running ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.play_arrow),
          label: const Text('Lancer le Test'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: TdcRadius.md),
          ),
        ),
      ],
    );
  }

  Widget _buildTerminal() {
    return Expanded(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1117),
          borderRadius: TdcRadius.md,
          border: Border.all(color: TdcColors.border),
        ),
        child: ListView.builder(
          itemCount: _logs.length,
          itemBuilder: (context, i) {
            final l = _logs[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                l.ok 
                  ? '64 bytes from ${l.host}: icmp_seq=${l.seq} time=${l.ms} ms' 
                  : 'PING: transmit failed. Request timeout for icmp_seq ${l.seq}',
                style: TextStyle(
                  color: l.ok ? const Color(0xFF00FF41) : TdcColors.danger, 
                  fontFamily: 'monospace', 
                  fontSize: 13
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLabHeader(String title, String desc, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 4, height: 28, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(color: TdcColors.textPrimary, fontSize: 26, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Text(desc, style: const TextStyle(color: TdcColors.textSecondary, fontSize: 14)),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 2. DNS SIMULATOR
// ═══════════════════════════════════════════════════════════════════════════════
class DnsSimulator extends StatefulWidget {
  const DnsSimulator({super.key});
  @override State<DnsSimulator> createState() => _DnsSimulatorState();
}

class _DnsSimulatorState extends State<DnsSimulator> {
  final _ctrl = TextEditingController(text: 'google.com');
  final _steps = <String>[];
  bool _running = false;
  int _activeNode = -1;

  Future<void> _resolve() async {
    setState(() { _steps.clear(); _running = true; });
    final s = [
      "➡ PC : 'Quelle est l'IP de ${_ctrl.text} ?'",
      "🔍 Résolveur récursif : Vérifie son cache local... (Miss)",
      "🌐 Vers Root Server (.) : 'Où est le TLD .${_ctrl.text.split('.').last} ?'",
      "⬅ Root Server : 'Allez voir les serveurs .${_ctrl.text.split('.').last}'",
      "🌐 Vers Serveur TLD (.${_ctrl.text.split('.').last}) : 'IP de ${_ctrl.text} ?'",
      "⬅ Serveur TLD : 'Allez voir le serveur autoritaire de ${_ctrl.text}'",
      "🌐 Vers Serveur Autoritaire : 'Donne moi l\'IP finale !'",
      "🎯 Serveur Autoritaire : 'L\'IP est 142.250.201.142'",
      "✅ Résolveur : Enregistre en cache et répond au PC.",
    ];
    for (int i = 0; i < s.length; i++) {
        await Future.delayed(const Duration(milliseconds: 700));
        if (!mounted) return;
        setState(() { 
          _steps.add(s[i]); 
          _activeNode = (i % 4); 
        });
    }
    setState(() => _running = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabHeader('Résolution DNS', 'Comprendre la hiérarchie et la récursivité du DNS.', const Color(0xFF6366F1)),
        const SizedBox(height: 32),
        _buildHierarchyVisual(),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                style: const TextStyle(color: TdcColors.textPrimary, fontFamily: 'monospace'),
                decoration: InputDecoration(
                  hintText: 'Domaine à résoudre', 
                  prefixIcon: const Icon(Icons.dns, size: 18),
                  filled: true,
                  fillColor: TdcColors.surface,
                  border: OutlineInputBorder(borderRadius: TdcRadius.md, borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _running ? null : _resolve,
              icon: _running ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.play_arrow),
              label: const Text('Résoudre'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: TdcRadius.md),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(color: TdcColors.surface, borderRadius: TdcRadius.md, border: Border.all(color: TdcColors.border)),
            child: ListView.builder(
              itemCount: _steps.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 500),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.subdirectory_arrow_right, size: 14, color: TdcColors.accent),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_steps[i], style: TextStyle(color: (i == _steps.length - 1) ? TdcColors.success : TdcColors.textSecondary, fontFamily: 'monospace', fontSize: 13))),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHierarchyVisual() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _node(0, 'CLIENT', Icons.laptop, Colors.blue),
        _node(1, 'RÉSOLVEUR', Icons.router, Colors.orange),
        _node(2, 'ROOT/TLD', Icons.cloud, Colors.purple),
        _node(3, 'AUTH', Icons.storage, Colors.green),
      ],
    );
  }

  Widget _node(int id, String label, IconData icon, Color color) {
    final active = _activeNode == id;
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: active ? color.withOpacity(0.2) : TdcColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: active ? color : TdcColors.border, width: 2),
            boxShadow: active ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10)] : null,
          ),
          child: Icon(icon, color: active ? color : TdcColors.textMuted, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: active ? color : TdcColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildLabHeader(String title, String desc, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 4, height: 28, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(color: TdcColors.textPrimary, fontSize: 26, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Text(desc, style: const TextStyle(color: TdcColors.textSecondary, fontSize: 14)),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 3. TCP SIMULATOR
// ═══════════════════════════════════════════════════════════════════════════════
class TcpSimulator extends StatefulWidget {
  const TcpSimulator({super.key});
  @override State<TcpSimulator> createState() => _TcpSimulatorState();
}

class _TcpSimulatorState extends State<TcpSimulator> {
  final _controller = TextEditingController(text: '192.168.1.1:80');
  final _logs = <String>[];
  bool _running = false;
  int _step = 0; // 0: initial, 1: SYN, 2: SYN-ACK, 3: ACK, 4: Data, 5: FIN, 6: FIN-ACK, 7: ACK

  Future<void> _startHandshake() async {
    if (_running) return;
    setState(() { _running = true; _logs.clear(); _step = 0; });

    // Step 1: SYN
    _addLog('Client ➡ Server: SYN (Sequence: 0)');
    setState(() => _step = 1);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    // Step 2: SYN-ACK
    _addLog('Server ➡ Client: SYN-ACK (Sequence: 0, Acknowledge: 1)');
    setState(() => _step = 2);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    // Step 3: ACK
    _addLog('Client ➡ Server: ACK (Acknowledge: 1)');
    setState(() => _step = 3);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    _addLog('✅ Connexion TCP établie !');
    setState(() => _step = 4); // Indicate connection established
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    // Step 4: FIN (Client initiates close)
    _addLog('Client ➡ Server: FIN');
    setState(() => _step = 5);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    // Step 5: ACK
    _addLog('Server ➡ Client: ACK');
    setState(() => _step = 6);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    // Step 6: FIN (Server)
    _addLog('Server ➡ Client: FIN');
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    // Step 7: ACK
    _addLog('Client ➡ Server: ACK');
    setState(() => _step = 7);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    _addLog('❌ Connexion TCP fermée.');
    setState(() => _running = false);
  }

  void _addLog(String message) {
    if (mounted) {
      setState(() {
        _logs.add(message);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabHeader('TCP Handshake', 'Visualisation de l\'établissement et de la fermeture d\'une connexion TCP.', const Color(0xFF3B82F6)),
        const SizedBox(height: 32),
        _buildVisualHandshake(),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: TdcColors.textPrimary, fontFamily: 'monospace'),
                decoration: InputDecoration(
                  hintText: 'Cible (IP:Port)',
                  prefixIcon: const Icon(Icons.handshake, size: 18),
                  filled: true,
                  fillColor: TdcColors.surface,
                  border: OutlineInputBorder(borderRadius: TdcRadius.md, borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _running ? null : _startHandshake,
              icon: _running ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.play_arrow),
              label: const Text('Lancer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: TdcRadius.md),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1117),
              borderRadius: TdcRadius.md,
              border: Border.all(color: TdcColors.border),
            ),
            child: ListView.builder(
              itemCount: _logs.length,
              itemBuilder: (context, i) {
                final log = _logs[i];
                Color color = TdcColors.textSecondary;
                if (log.contains('✅')) color = TdcColors.success;
                if (log.contains('❌')) color = TdcColors.danger;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(log, style: TextStyle(color: color, fontFamily: 'monospace')),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVisualHandshake() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: TdcColors.surface,
        borderRadius: TdcRadius.md,
        border: Border.all(color: TdcColors.border),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(left: 40, child: _entity('CLIENT', Icons.laptop, Colors.blue)),
          Positioned(right: 40, child: _entity('SERVEUR', Icons.dns, Colors.purple)),
          if (_step >= 1) _animatedPacket('SYN', Colors.blue, _step == 1),
          if (_step >= 2) _animatedPacket('SYN-ACK', Colors.purple, _step == 2, reversed: true),
          if (_step >= 3) _animatedPacket('ACK', Colors.green, _step == 3),
        ],
      ),
    );
  }

  Widget _entity(String n, IconData i, Color c) => Column(children: [Icon(i, size: 40, color: c), const SizedBox(height: 4), Text(n, style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.bold))]);

  Widget _animatedPacket(String label, Color color, bool active, {bool reversed = false}) {
      return AnimatedPositioned(
          duration: const Duration(milliseconds: 500),
          left: reversed ? (active ? 80 : MediaQuery.of(context).size.width - 200) : (active ? MediaQuery.of(context).size.width - 200 : 80),
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
              child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
      );
  }

  Widget _buildLabHeader(String title, String desc, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Container(width: 4, height: 28, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))), const SizedBox(width: 16), Text(title, style: const TextStyle(color: TdcColors.textPrimary, fontSize: 26, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 8),
        Text(desc, style: const TextStyle(color: TdcColors.textSecondary, fontSize: 14)),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 4. HTTP SIMULATOR
// ═══════════════════════════════════════════════════════════════════════════════
class HttpSimulator extends StatefulWidget {
  const HttpSimulator({super.key});
  @override State<HttpSimulator> createState() => _HttpSimulatorState();
}

class _HttpSimulatorState extends State<HttpSimulator> {
  final _urlCtrl = TextEditingController(text: 'https://api.tutodecode.io/v1/status');
  final _methodCtrl = TextEditingController(text: 'GET');
  final _headerCtrl = TextEditingController(text: 'Content-Type: application/json\nAuthorization: Bearer TDC_TOKEN');
  final _bodyCtrl = TextEditingController(text: '{\n  "action": "check_uptime"\n}');
  
  String _response = '';
  bool _loading = false;
  int _flowStep = 0; // 0: idle, 1: sending, 2: server_processing, 3: receiving

  Future<void> _sendRequest() async {
    if (_loading) return;
    setState(() { _loading = true; _response = ''; _flowStep = 1; });

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _flowStep = 2);

    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() => _flowStep = 3);

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    setState(() {
      _response = 'HTTP/1.1 200 OK\n'
                  'Date: ${DateTime.now().toUtc()}\n'
                  'Content-Type: application/json\n'
                  'Server: Cloudflare\n'
                  'Connection: keep-alive\n\n'
                  '{\n'
                  '  "status": "online",\n'
                  '  "service": "TdcApi",\n'
                  '  "version": "2.1.0",\n'
                  '  "latency": "42ms"\n'
                  '}';
      _loading = false;
      _flowStep = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabHeader('Requête HTTP', 'Structure et cycle d\'une requête REST API.', const Color(0xFFF59E0B)),
        const SizedBox(height: 24),
        _buildVisualFlow(),
        const SizedBox(height: 24),
        _buildInputForm(),
        const SizedBox(height: 24),
        if (_response.isNotEmpty || _loading) _buildResponseArea(),
      ],
    );
  }

  Widget _buildVisualFlow() {
    return Container(
      height: 100,
      decoration: BoxDecoration(color: TdcColors.surface, borderRadius: TdcRadius.md, border: Border.all(color: TdcColors.border)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _flowNode('CLIENT', Icons.laptop, _flowStep == 1),
          const Icon(Icons.arrow_forward_ios, size: 16, color: TdcColors.textMuted),
          _flowNode('INTERNET', Icons.cloud, _flowStep == 2),
          const Icon(Icons.arrow_forward_ios, size: 16, color: TdcColors.textMuted),
          _flowNode('SERVEUR', Icons.storage, _flowStep == 3),
        ],
      ),
    );
  }

  Widget _flowNode(String label, IconData icon, bool active) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: active ? const Color(0xFFF59E0B) : TdcColors.textMuted, size: 32),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: active ? const Color(0xFFF59E0B) : TdcColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildInputForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: TdcColors.surface, borderRadius: TdcRadius.md, border: Border.all(color: TdcColors.border)),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 80,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(color: TdcColors.bg, borderRadius: TdcRadius.sm),
                child: Text(_methodCtrl.text, style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _urlCtrl,
                  style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
                  decoration: const InputDecoration(border: InputBorder.none, hintText: 'URL de l\'API'),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _loading ? null : _sendRequest,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
                child: Text(_loading ? '...' : 'ENVOYER'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResponseArea() {
    return Expanded(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: TdcRadius.md, border: Border.all(color: TdcColors.border)),
        child: _loading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF59E0B)))
          : SingleChildScrollView(child: Text(_response, style: const TextStyle(color: Color(0xFFFFD700), fontFamily: 'monospace', fontSize: 12))),
      ),
    );
  }

  Widget _buildLabHeader(String title, String desc, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 4, height: 28, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(color: TdcColors.textPrimary, fontSize: 26, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Text(desc, style: const TextStyle(color: TdcColors.textSecondary, fontSize: 14)),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 5. PORT SCANNER
// ═══════════════════════════════════════════════════════════════════════════════
class PortSimulator extends StatefulWidget {
  const PortSimulator({super.key});
  @override State<PortSimulator> createState() => _PortSimulatorState();
}

class _PortSimulatorState extends State<PortSimulator> {
  final _targetCtrl = TextEditingController(text: '192.168.1.100');
  final Map<int, String> _knownPorts = {
    21: 'FTP', 22: 'SSH', 23: 'Telnet', 25: 'SMTP',
    53: 'DNS', 80: 'HTTP', 443: 'HTTPS', 3306: 'MySQL',
    3389: 'RDP', 5432: 'PostgreSQL', 8080: 'HTTP-Alt'
  };
  
  final Map<int, bool?> _results = {};
  bool _scanning = false;
  double _progress = 0;

  Future<void> _startScan() async {
    if (_scanning) return;
    setState(() { _scanning = true; _results.clear(); _progress = 0; });

    final portsToScan = _knownPorts.keys.toList();
    for (int i = 0; i < portsToScan.length; i++) {
      final p = portsToScan[i];
      setState(() => _results[p] = null); // Scanning...
      await Future.delayed(Duration(milliseconds: 200 + Random().nextInt(300)));
      if (!mounted) return;
      
      setState(() {
        _results[p] = Random().nextDouble() > 0.4;
        _progress = (i + 1) / portsToScan.length;
      });
    }
    setState(() => _scanning = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabHeader('Diagnostic de Port', 'Détection des services ouverts sur une cible réseau.', const Color(0xFFEC4899)),
        const SizedBox(height: 24),
        _buildControls(),
        const SizedBox(height: 24),
        if (_scanning) _buildProgressBar(),
        const SizedBox(height: 12),
        Expanded(child: _buildPortGrid()),
      ],
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: TdcColors.surface, borderRadius: TdcRadius.md, border: Border.all(color: TdcColors.border)),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _targetCtrl,
              decoration: const InputDecoration(hintText: 'IP Cible', prefixIcon: Icon(Icons.lan)),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _scanning ? null : _startScan,
            icon: const Icon(Icons.search),
            label: const Text('Scanner'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEC4899)),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: _progress, backgroundColor: TdcColors.border, color: const Color(0xFFEC4899), minHeight: 8),
        ),
        const SizedBox(height: 4),
        Text('${(_progress * 100).toInt()}% complété', style: const TextStyle(color: TdcColors.textMuted, fontSize: 10)),
      ],
    );
  }

  Widget _buildPortGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.4),
      itemCount: _knownPorts.length,
      itemBuilder: (context, i) {
        final entry = _knownPorts.entries.elementAt(i);
        final status = _results[entry.key];
        return Container(
          decoration: BoxDecoration(
            color: TdcColors.surface,
            borderRadius: TdcRadius.md,
            border: Border.all(color: status == null ? TdcColors.border : (status ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5))),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${entry.key}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(entry.value, style: const TextStyle(color: TdcColors.textMuted, fontSize: 10)),
              const SizedBox(height: 4),
              if (status == null && _results.containsKey(entry.key))
                const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFEC4899)))
              else if (status == true)
                const Text('OUVERT', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold))
              else if (status == false)
                const Text('FERMÉ', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold))
              else
                const Text('EN ATTENTE', style: TextStyle(color: TdcColors.textMuted, fontSize: 10)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLabHeader(String title, String desc, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Container(width: 4, height: 28, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))), const SizedBox(width: 16), Text(title, style: const TextStyle(color: TdcColors.textPrimary, fontSize: 26, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 8),
        Text(desc, style: const TextStyle(color: TdcColors.textSecondary, fontSize: 14)),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 6. GPO SIMULATOR
// ═══════════════════════════════════════════════════════════════════════════════
class GpoSimulator extends StatefulWidget {
  const GpoSimulator({super.key});
  @override State<GpoSimulator> createState() => _GpoSimulatorState();
}

class _GpoSimulatorState extends State<GpoSimulator> {
  final List<GpoSetting> _settings = [
    GpoSetting('Désactiver l\'Invite de commandes', 'Empêche l\'accès à cmd.exe et aux scripts batch.', false),
    GpoSetting('Bloquer le Panneau de configuration', 'Empêche l\'ouverture de Control.exe et des Paramètres.', false),
    GpoSetting('Forcer le Papier peint bureau', 'Applique une image spécifique sans changement possible.', false),
    GpoSetting('Supprimer "Exécuter" du menu Démarrer', 'Retire le raccourci Win+R et l\'option de menu.', false),
    GpoSetting('Désactiver le Gestionnaire des tâches', 'Empêche Ctrl+Shift+Esc pour voir les processus.', false),
  ];

  final List<String> _logs = [];
  bool _applying = false;

  void _applyGpo() async {
    setState(() { _applying = true; _logs.clear(); });
    _addLog('Initialisation de la propagation GPO...');
    await Future.delayed(const Duration(milliseconds: 600));

    for (var s in _settings) {
      if (s.isEnabled) {
        _addLog('Application : ${s.title}...');
        await Future.delayed(const Duration(milliseconds: 400));
      }
    }
    
    _addLog('Mise à jour de la base de registre (gpupdate /force)...');
    await Future.delayed(const Duration(milliseconds: 800));
    _addLog('✅ Stratégies appliquées avec succès.');
    setState(() => _applying = false);
  }

  void _addLog(String msg) {
    if (mounted) setState(() => _logs.add(msg));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabHeader('Master GPO', 'Simulation de l\'application de stratégies de groupe Active Directory.', const Color(0xFFF97316)),
        const SizedBox(height: 24),
        Expanded(
          child: Row(
            children: [
              Expanded(flex: 3, child: _buildSettingsList()),
              const SizedBox(width: 24),
              Expanded(flex: 2, child: _buildStatusPanel()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsList() {
    return Container(
      decoration: BoxDecoration(color: TdcColors.surface, borderRadius: TdcRadius.md, border: Border.all(color: TdcColors.border)),
      child: ListView.separated(
        itemCount: _settings.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: TdcColors.border),
        itemBuilder: (context, i) {
          final s = _settings[i];
          return CheckboxListTile(
            title: Text(s.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: Text(s.desc, style: const TextStyle(color: TdcColors.textMuted, fontSize: 11)),
            value: s.isEnabled,
            activeColor: const Color(0xFFF97316),
            onChanged: _applying ? null : (val) => setState(() => s.isEnabled = val ?? false),
          );
        },
      ),
    );
  }

  Widget _buildStatusPanel() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _applying ? null : _applyGpo,
          icon: const Icon(Icons.sync),
          label: const Text('Appliquer (gpupdate)'),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF97316), minimumSize: const Size(double.infinity, 50)),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: TdcRadius.md, border: Border.all(color: TdcColors.border)),
            child: ListView.builder(
              itemCount: _logs.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('> ${_logs[i]}', style: const TextStyle(color: Color(0xFFCBD5E1), fontFamily: 'monospace', fontSize: 11)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabHeader(String title, String desc, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Container(width: 4, height: 28, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))), const SizedBox(width: 16), Text(title, style: const TextStyle(color: TdcColors.textPrimary, fontSize: 26, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 8),
        Text(desc, style: const TextStyle(color: TdcColors.textSecondary, fontSize: 14)),
    ]);
  }
}

class GpoSetting {
  final String title;
  final String desc;
  bool isEnabled;
  GpoSetting(this.title, this.desc, this.isEnabled);
}

// ═══════════════════════════════════════════════════════════════════════════════
// 7. RAID SIMULATOR
// ═══════════════════════════════════════════════════════════════════════════════
class DiskSimulator extends StatefulWidget {
  const DiskSimulator({super.key});
  @override State<DiskSimulator> createState() => _DiskSimulatorState();
}

class _DiskSimulatorState extends State<DiskSimulator> {
  int _raidLevel = 1;
  late List<DiskState> _disks;
  String _status = 'Opérationnel';
  Color _statusColor = Colors.green;
  bool _rebuilding = false;

  @override
  void initState() {
    super.initState();
    _initRaid();
  }

  void _initRaid() {
    int count = (_raidLevel == 5) ? 3 : (_raidLevel == 6 ? 4 : 2);
    _disks = List.generate(count, (i) => DiskState(i, 'Disk $i', true));
    _checkHealth();
  }

  void _toggleDisk(int i) {
    if (_rebuilding) return;
    setState(() {
      _disks[i].isHealthy = !_disks[i].isHealthy;
      _checkHealth();
    });
  }

  void _checkHealth() {
    int failed = _disks.where((d) => !d.isHealthy).length;
    if (failed == 0) {
      _status = 'Optimal'; _statusColor = Colors.green;
    } else if (_raidLevel == 1 && failed == 1) {
      _status = 'Dégradé (Miroir actif)'; _statusColor = Colors.orange;
    } else if (_raidLevel == 5 && failed == 1) {
      _status = 'Dégradé (Parité active)'; _statusColor = Colors.orange;
    } else if (_raidLevel == 6 && failed <= 2) {
      _status = 'Dégradé (Double Parité)'; _statusColor = Colors.orange;
    } else {
      _status = 'PANNE CRITIQUE (Perte de données)'; _statusColor = Colors.red;
    }
  }

  void _rebuild() async {
    if (_statusColor != Colors.orange || _rebuilding) return;
    setState(() => _rebuilding = true);
    for (var d in _disks) {
      if (!d.isHealthy) {
        await Future.delayed(const Duration(milliseconds: 1500));
        d.isHealthy = true;
      }
    }
    setState(() { _rebuilding = false; _checkHealth(); });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabHeader('RAID & Tolérance aux pannes', 'Simulation des niveaux RAID et résistance aux pannes matérielles.', const Color(0xFF8B5CF6)),
        const SizedBox(height: 24),
        _buildRaidSelector(),
        const SizedBox(height: 32),
        _buildStatusHeader(),
        const SizedBox(height: 32),
        Expanded(child: _buildDiskLayout()),
        if (_statusColor == Colors.orange) _buildRebuildButton(),
      ],
    );
  }

  Widget _buildRaidSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [1, 5, 6].map((l) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text('RAID $l'),
            selected: _raidLevel == l,
            onSelected: (val) { if (val) setState(() { _raidLevel = l; _initRaid(); }); },
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _statusColor.withOpacity(0.1), borderRadius: TdcRadius.md, border: Border.all(color: _statusColor.withOpacity(0.3))),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: _statusColor),
          const SizedBox(width: 12),
          Text('Statut : $_status', style: TextStyle(color: _statusColor, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildDiskLayout() {
    return Center(
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        children: _disks.map((d) => _buildDiskWidget(d)).toList(),
      ),
    );
  }

  Widget _buildDiskWidget(DiskState d) {
    return GestureDetector(
      onTap: () => _toggleDisk(d.id),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: d.isHealthy ? TdcColors.surface : Colors.red.withOpacity(0.1),
              borderRadius: TdcRadius.md,
              border: Border.all(color: d.isHealthy ? TdcColors.border : Colors.red),
              boxShadow: d.isHealthy ? null : [BoxShadow(color: Colors.red.withOpacity(0.2), blurRadius: 10)],
            ),
            child: Icon(Icons.storage, size: 48, color: d.isHealthy ? Colors.blue : Colors.red),
          ),
          const SizedBox(height: 8),
          Text(d.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(d.isHealthy ? 'Sain' : 'Échec', style: TextStyle(color: d.isHealthy ? Colors.green : Colors.red, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildRebuildButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: ElevatedButton.icon(
        onPressed: _rebuilding ? null : _rebuild,
        icon: _rebuilding ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.build),
        label: Text(_rebuilding ? 'Reconstruction en cours...' : 'Remplacer le disque défectueux'),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: const Size(double.infinity, 50)),
      ),
    );
  }

  Widget _buildLabHeader(String title, String desc, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Container(width: 4, height: 28, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))), const SizedBox(width: 16), Text(title, style: const TextStyle(color: TdcColors.textPrimary, fontSize: 26, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 8),
        Text(desc, style: const TextStyle(color: TdcColors.textSecondary, fontSize: 14)),
    ]);
  }
}

class DiskState {
  final int id;
  final String name;
  bool isHealthy;
  DiskState(this.id, this.name, this.isHealthy);
}

// ═══════════════════════════════════════════════════════════════════════════════
// 8. SQL INJECTION SIMULATOR
// ═══════════════════════════════════════════════════════════════════════════════
class SqlInjectionSimulator extends StatefulWidget {
  const SqlInjectionSimulator({super.key});
  @override State<SqlInjectionSimulator> createState() => _SqlInjectionSimulatorState();
}

class _SqlInjectionSimulatorState extends State<SqlInjectionSimulator> {
  final _idCtrl = TextEditingController(text: "1' OR '1'='1");
  bool _isSecure = false;
  bool _loading = false;
  final List<Map<String, String>> _results = [];
  String _query = '';

  void _attemptLogin() async {
    setState(() { _loading = true; _results.clear(); _query = ''; });
    await Future.delayed(const Duration(milliseconds: 800));

    String input = _idCtrl.text;
    if (_isSecure) {
      // Prepared Statement Simulation
      _query = "SELECT * FROM users WHERE id = ?";
      if (input == "1") {
        _results.add({'id': '1', 'user': 'Admin', 'role': 'Superuser'});
      }
    } else {
      // Vulnerable String Concatenation Simulation
      _query = "SELECT * FROM users WHERE id = '$input'";
      if (input.contains("' OR '1'='1")) {
        _results.addAll([
          {'id': '1', 'user': 'Admin', 'role': 'Superuser'},
          {'id': '2', 'user': 'User_7', 'role': 'Guest'},
          {'id': '3', 'user': 'Dev_X', 'role': 'Moderator'},
        ]);
      } else if (input == "1") {
        _results.add({'id': '1', 'user': 'Admin', 'role': 'Superuser'});
      }
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabHeader('Injection SQL', 'Simulation d\'une vulnérabilité par contournement de filtre.', const Color(0xFFFACC15)),
        const SizedBox(height: 24),
        _buildConfigBar(),
        const SizedBox(height: 24),
        _buildTerminalQuery(),
        const SizedBox(height: 24),
        if (_results.isNotEmpty || (_query.isNotEmpty && _results.isEmpty && !_loading)) _buildResultsTable(),
      ],
    );
  }

  Widget _buildConfigBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: TdcColors.surface, borderRadius: TdcRadius.md, border: Border.all(color: TdcColors.border)),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _idCtrl,
                  decoration: const InputDecoration(labelText: 'ID Utilisateur', hintText: "Ex: 1' OR '1'='1", prefixIcon: Icon(Icons.person)),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _loading ? null : _attemptLogin,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFACC15), foregroundColor: Colors.black),
                child: const Text('EXÉCUTER'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Mode Sécurisé (Requêtes Préparées)', style: TextStyle(fontSize: 13)),
            value: _isSecure,
            activeColor: TdcColors.success,
            onChanged: (val) => setState(() => _isSecure = val),
          ),
        ],
      ),
    );
  }

  Widget _buildTerminalQuery() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: TdcRadius.md, border: Border.all(color: TdcColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('REQUÊTE GÉNÉRÉE :', style: TextStyle(color: TdcColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(_query.isEmpty ? '-- En attente d\'exécution --' : _query, style: TextStyle(color: _isSecure ? Colors.blue : Colors.redAccent, fontFamily: 'monospace', fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildResultsTable() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(color: TdcColors.surface, borderRadius: TdcRadius.md, border: Border.all(color: TdcColors.border)),
        child: _results.isEmpty 
          ? const Center(child: Text('Aucun résultat trouvé.', style: TextStyle(color: TdcColors.textMuted)))
          : ListView.separated(
              itemCount: _results.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: TdcColors.border),
              itemBuilder: (context, i) {
                final r = _results[i];
                return ListTile(
                  leading: const CircleAvatar(backgroundColor: Color(0xFFFACC15), child: Icon(Icons.person, color: Colors.black, size: 16)),
                  title: Text(r['user']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('ID: ${r['id']} | Role: ${r['role']}'),
                  trailing: const Icon(Icons.check_circle, color: Colors.green, size: 16),
                );
              },
            ),
      ),
    );
  }

  Widget _buildLabHeader(String title, String desc, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Container(width: 4, height: 28, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))), const SizedBox(width: 16), Text(title, style: const TextStyle(color: TdcColors.textPrimary, fontSize: 26, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 8),
        Text(desc, style: const TextStyle(color: TdcColors.textSecondary, fontSize: 14)),
    ]);
  }
}
