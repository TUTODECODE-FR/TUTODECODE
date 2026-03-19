// ============================================================
// main.dart — Point d'entrée de TUTODECODE
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';

// Screens
import 'features/home/screens/home_screen.dart';
import 'features/courses/screens/chapter_screen.dart';
import 'features/courses/screens/cheat_sheet_screen.dart';
import 'features/courses/screens/cheat_sheet_detail_screen.dart';
import 'features/tools/screens/toolbox_screen.dart';
import 'features/tools/screens/ip_calc_screen.dart';
import 'features/tools/screens/script_screen.dart';
import 'features/tools/screens/hardware_screen.dart';
import 'features/tools/screens/survival_screen.dart';
import 'features/tools/screens/glossary_screen.dart';
import 'features/ghost_ai/screens/ai_chat_screen.dart';
import 'features/ghost_ai/screens/ai_config_screen.dart';
import 'features/netkit/screens/netkit_screen.dart';
import 'features/home/screens/dashboard_screen.dart';
import 'features/tools/screens/switch_config_screen.dart';
import 'features/tools/screens/vpn_guide_screen.dart';
import 'features/tools/screens/gpo_guide_screen.dart';
import 'features/roadmap/screens/roadmap_screen.dart';
import 'features/lab/screens/lab_screen.dart';
import 'features/admin/screens/admin_screen.dart';
import 'features/legal/screens/legal_screen.dart';
import 'features/settings/screens/settings_screen.dart'; // To be moved later if needed

// Providers
import 'features/courses/providers/courses_provider.dart';
import 'widgets/app_shell.dart';
import 'core/providers/shell_provider.dart';
import 'core/providers/settings_provider.dart';

// Theme & Navigation
import 'core/theme/app_theme.dart';
import 'core/navigation/nav_keys.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TutoDeCodeApp());
}

class TutoDeCodeApp extends StatelessWidget {
  const TutoDeCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CoursesProvider()),
        ChangeNotifierProvider(create: (_) => ShellProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) => MaterialApp(
          title: 'TUTODECODE',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          themeMode: settings.themeMode,
          navigatorKey: AppNavigator.key,
          navigatorObservers: [AppNavigator.observer],
          initialRoute: '/',
          builder: (context, child) => AppShell(child: child!),
          onGenerateRoute: (settings) {
            return PageRouteBuilder(
              settings: settings,
              pageBuilder: (context, animation, secondaryAnimation) {
                switch (settings.name) {
                  case '/':                     return HomeScreen();
                  case '/chapter':              return ChapterScreen();
                  case '/ai':                   return const AIChatScreen();
                  case '/ai-config':            return const AIConfigScreen();
                  case '/netkit':               return const NetKitScreen();
                  case '/roadmap':              return RoadmapScreen();
                  case '/lab':                  return LabScreen();
                  case '/cheat-sheets':         return CheatSheetScreen();
                  case '/cheat-sheets/details':
                    final entry = settings.arguments as CheatSheetEntry;
                    return CheatSheetDetailScreen(entry: entry);
                  case '/tools':                return const ToolboxScreen();
                  case '/tools/ip-calc':        return const IPCalcScreen();
                  case '/tools/scripts':        return ScriptScreen();
                  case '/tools/hardware':       return const HardwareScreen();
                  case '/tools/survival':       return const SurvivalScreen();
                  case '/tools/glossary':       return const GlossaryScreen();
                  case '/dashboard':            return const DashboardScreen();
                  case '/tools/switch-config':  return const SwitchConfigScreen();
                  case '/tools/vpn-guide':      return const VpnGuideScreen();
                  case '/tools/gpo-guide':      return const GpoGuideScreen();
                  case '/admin':                return AdminScreen();
                  case '/legal':                return LegalScreen();
                  case '/settings':             return const SettingsScreen();
                  default:                      return HomeScreen();
                }
              },
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeThroughTransition(
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  fillColor: TdcColors.bg,
                  child: child,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
