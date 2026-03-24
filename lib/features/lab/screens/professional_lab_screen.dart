// ============================================================
// Professional Lab Screen - Laboratoires de simulation ultra-professionnels
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:tutodecode/core/theme/app_theme.dart';
import 'package:tutodecode/core/providers/shell_provider.dart';
import 'package:tutodecode/features/lab/simulators/network_simulator.dart';
import 'package:tutodecode/features/lab/simulators/security_simulator.dart';
import 'package:tutodecode/features/lab/simulators/system_simulator.dart';
import 'package:tutodecode/features/lab/simulators/cloud_simulator.dart';
import 'package:tutodecode/features/lab/simulators/cryptography_simulator.dart';
import 'package:tutodecode/features/lab/widgets/lab_widgets.dart';

class ProfessionalLabScreen extends StatefulWidget {
  const ProfessionalLabScreen({super.key});

  @override
  State<ProfessionalLabScreen> createState() => _ProfessionalLabScreenState();
}

class _ProfessionalLabScreenState extends State<ProfessionalLabScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedIndex = _tabController.index;
        });
      }
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShellProvider>().updateShell(
        title: 'Laboratoires Professionnels',
        showBackButton: true,
        actions: [],
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1A),
        image: DecorationImage(
          image: const AssetImage('assets/images/grid_bg.png'), // Assuming it's there or just a fallback
          repeat: ImageRepeat.repeat,
          opacity: 0.1,
          onError: (_, __) => const Color(0xFF0F0F1A),
        ),
      ),
      child: Column(
        children: [
          // Premium Glass Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: LabGlassContainer(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blue.withOpacity(0.3)),
                        ),
                        child: Icon(Icons.science, color: Colors.blue.shade400, size: 32),
                      ).animate().scale(delay: 200.ms, duration: 400.ms, curve: Curves.easeOutBack),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'SIMULATION CORE',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ).animate().fadeIn(delay: 100.ms),
                            const Text(
                              'Laboratoires de Simulation',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                              ),
                            ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1, end: 0),
                            Text(
                              'Environnements professionnels ultra-réalistes pour l\'expertise technique',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 14,
                              ),
                            ).animate().fadeIn(delay: 300.ms),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _buildHeaderStat('SERVEURS', '12 ACTIVE', Colors.green),
                      const SizedBox(width: 16),
                      _buildHeaderStat('MENACES', '2 DETECTÉES', Colors.red),
                      const SizedBox(width: 16),
                      _buildHeaderStat('UPTIME', '99.9%', Colors.blue),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Modern Tab Switcher
          Container(
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.6),
                    Colors.purple.withOpacity(0.6),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.4),
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(child: Text('RÉSEAU')),
                Tab(child: Text('SÉCURITÉ')),
                Tab(child: Text('SYSTÈME')),
                Tab(child: Text('CLOUD')),
                Tab(child: Text('CRYPTO')),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 16),
          
          // Simulation content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSimulationWrapper(const NetworkSimulator()),
                _buildSimulationWrapper(const SecuritySimulator()),
                _buildSimulationWrapper(const SystemSimulator()),
                _buildSimulationWrapper(const CloudSimulator()),
                _buildSimulationWrapper(const CryptographySimulator()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulationWrapper(Widget simulator) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: LabGlassContainer(
        padding: EdgeInsets.zero,
        child: simulator,
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color, blurRadius: 4, spreadRadius: 1),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              color: color.withOpacity(0.7),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
