// ============================================================
// home_screen.dart — Page d'accueil responsive TutoDeCode
// ── Desktop  : sidebar + grille 3 cols + panneau droit
// ── Tablet   : drawer + grille 2 cols + panneau droit
// ── Mobile   : BottomNav + liste verticale + panneau accordéon
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../courses/providers/courses_provider.dart';
import '../../courses/data/course_repository.dart';
import 'package:tutodecode/core/theme/app_theme.dart';
import 'package:tutodecode/core/responsive/responsive.dart';
import 'package:tutodecode/core/widgets/tdc_widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../ghost_ai/service/ollama_service.dart';
import 'package:tutodecode/core/providers/shell_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  OllamaStatus? _aiStatus;

  @override
  void initState() {
    super.initState();
    _checkAI();
    // Configure shell on entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShellProvider>().updateShell(
        title: 'Accueil',
        showBackButton: false,
        actions: [],
      );
    });
  }

  Future<void> _checkAI() async {
    final s = await OllamaService.checkStatus();
    if (mounted) setState(() => _aiStatus = s);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CoursesProvider>(builder: (context, prov, _) {
      if (!prov.loaded) {
        return Container(
          color: TdcColors.bg,
          child: const Center(child: CircularProgressIndicator(color: TdcColors.accent)),
        );
      }

      return ResponsiveBuilder(
        builder: (ctx, type) {
          if (type.isDesktop) return _buildDesktopBody(ctx, prov);
          if (type.isTablet)  return _buildTabletBody(ctx, prov);
          return _buildMobileBody(ctx, prov);
        },
      );
    });
  }

  // ════════════════════════════════════════════════════════
  // DESKTOP : contenu + panneau droit (300px)
  // ════════════════════════════════════════════════════════
  Widget _buildDesktopBody(BuildContext context, CoursesProvider prov) {
    return TdcPageWrapper(
      child: SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMainHeader(context, prov),
                  SizedBox(height: TdcAdaptive.space(context, TdcSpacing.xl)),
                  _buildSectionHeader(context, prov),
                  SizedBox(height: TdcAdaptive.space(context, TdcSpacing.md)),
                  _buildCourseGrid(context, prov, crossAxisCount: 3),
                ],
              ),
            ),
            SizedBox(width: TdcAdaptive.space(context, TdcSpacing.xl)),
            SizedBox(
              width: TdcAdaptive.space(context, 300),
              child: Column(children: [
                _buildAIPanel(context),
                SizedBox(height: TdcAdaptive.space(context, TdcSpacing.md)),
                _buildToolsPanel(context),
                SizedBox(height: TdcAdaptive.space(context, TdcSpacing.md)),
                _buildProgressPanel(prov),
                SizedBox(height: TdcAdaptive.space(context, TdcSpacing.xl)),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // TABLET : grille 2 colonnes, panneau droit replié en bas
  // ════════════════════════════════════════════════════════
  Widget _buildTabletBody(BuildContext context, CoursesProvider prov) {
    return TdcPageWrapper(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMainHeader(context, prov),
            SizedBox(height: TdcAdaptive.space(context, TdcSpacing.xl)),
            _buildSectionHeader(context, prov),
            SizedBox(height: TdcAdaptive.space(context, TdcSpacing.md)),
            _buildCourseGrid(context, prov, crossAxisCount: 2),
            SizedBox(height: TdcAdaptive.space(context, TdcSpacing.xl)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildAIPanel(context)),
                SizedBox(width: TdcAdaptive.space(context, TdcSpacing.md)),
                Expanded(child: _buildProgressPanel(prov)),
              ],
            ),
            SizedBox(height: TdcAdaptive.space(context, TdcSpacing.md)),
            _buildToolsPanel(context),
            SizedBox(height: TdcAdaptive.space(context, TdcSpacing.xl)),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // MOBILE : liste en colonne, accordéon pour les outils
  // ════════════════════════════════════════════════════════
  Widget _buildMobileBody(BuildContext context, CoursesProvider prov) {
    return TdcPageWrapper(
      padding: EdgeInsets.all(TdcAdaptive.padding(context, TdcSpacing.md)),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMobileHeader(context, prov),
            SizedBox(height: TdcAdaptive.space(context, TdcSpacing.lg)),
            _buildProgressBar(prov),
            SizedBox(height: TdcAdaptive.space(context, TdcSpacing.lg)),
            Row(children: [
              Icon(Icons.menu_book, color: TdcColors.textPrimary, size: TdcAdaptive.icon(context, 18)),
              SizedBox(width: TdcAdaptive.space(context, TdcSpacing.sm)),
              Text('Mes parcours',
                  style: TextStyle(
                    color: TdcColors.textPrimary, 
                    fontSize: TdcText.h3(context), 
                    fontWeight: FontWeight.bold)),
            ]),
            SizedBox(height: TdcAdaptive.space(context, TdcSpacing.md)),
            _buildCourseGrid(context, prov, crossAxisCount: 1),
            SizedBox(height: TdcAdaptive.space(context, TdcSpacing.lg)),
            _buildMobileQuickActions(context),
            SizedBox(height: TdcAdaptive.space(context, 80)),
          ],
        ),
      ),
    );
  }

  Widget _buildMainHeader(BuildContext context, CoursesProvider prov) {
    return Row(
      children: [
        Image.asset('assets/logo.png', width: TdcAdaptive.icon(context, 48), height: TdcAdaptive.icon(context, 48)),
        SizedBox(width: TdcAdaptive.space(context, TdcSpacing.md)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bienvenue sur TutoDeCode',
                  style: TextStyle(color: TdcColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
              const SizedBox(height: 4),
              const Text('Continuez votre apprentissage informatique local et sécurisé.',
                  style: TextStyle(color: TdcColors.textSecondary, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileHeader(BuildContext context, CoursesProvider prov) {
    return Row(
      children: [
        Image.asset('assets/logo.png', width: TdcAdaptive.icon(context, 38), height: TdcAdaptive.icon(context, 38)),
        SizedBox(width: TdcAdaptive.space(context, 12)),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('TutoDeCode', style: TextStyle(color: TdcColors.textPrimary, fontSize: TdcText.h2(context), fontWeight: FontWeight.bold)),
            Text('Apprentissage local', style: TextStyle(color: TdcColors.textSecondary, fontSize: TdcText.caption(context))),
          ]),
        ),
      ],
    );
  }

  Widget _buildProgressBar(CoursesProvider prov) {
    return Container(
      padding: EdgeInsets.all(TdcAdaptive.padding(context, TdcSpacing.md)),
      decoration: BoxDecoration(color: TdcColors.surface, borderRadius: TdcRadius.lg, border: Border.all(color: TdcColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Progression globale', style: TextStyle(color: TdcColors.textPrimary, fontWeight: FontWeight.bold, fontSize: TdcText.body(context))),
            Text('${(prov.overallProgress * 100).toInt()}%', style: TextStyle(color: TdcColors.accent, fontWeight: FontWeight.bold, fontSize: TdcText.h2(context))),
          ]),
          SizedBox(height: TdcAdaptive.space(context, 10)),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: prov.overallProgress,
              minHeight: TdcAdaptive.space(context, 8),
              backgroundColor: TdcColors.surfaceAlt,
              valueColor: const AlwaysStoppedAnimation(TdcColors.accent),
            ),
          ),
          SizedBox(height: TdcAdaptive.space(context, 6)),
          Text('${prov.completedCount} sur ${prov.totalChaptersCount} chapitres', style: TextStyle(color: TdcColors.textMuted, fontSize: TdcText.caption(context))),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, CoursesProvider prov) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Icon(Icons.menu_book, color: TdcColors.textPrimary, size: TdcAdaptive.icon(context, 20)),
          SizedBox(width: TdcAdaptive.space(context, TdcSpacing.sm)),
          Text('Parcours informatiques', style: TextStyle(color: TdcColors.textPrimary, fontSize: TdcText.h2(context), fontWeight: FontWeight.bold)),
          SizedBox(width: TdcAdaptive.space(context, TdcSpacing.sm)),
          IconButton(
            icon: Icon(Icons.refresh, size: TdcAdaptive.icon(context, 18), color: TdcColors.textSecondary),
            tooltip: 'Actualiser les modules externes',
            onPressed: () => prov.reload(),
          ),
        ]),
        Row(children: [
          SizedBox(
            width: TdcAdaptive.space(context, 120),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: prov.totalChaptersCount > 0 ? prov.completedCount / prov.totalChaptersCount : 0.0,
                minHeight: TdcAdaptive.space(context, 5),
                backgroundColor: TdcColors.surfaceAlt,
                valueColor: const AlwaysStoppedAnimation(TdcColors.accent),
              ),
            ),
          ),
          SizedBox(width: TdcAdaptive.space(context, TdcSpacing.sm)),
          Text('${prov.completedCount}/${prov.totalChaptersCount}', style: TextStyle(color: TdcColors.textSecondary, fontSize: TdcText.label(context))),
        ]),
      ],
    );
  }

  Widget _buildCourseGrid(BuildContext context, CoursesProvider prov, {required int crossAxisCount}) {
    final courses = prov.courses;
    final double itemHeight = crossAxisCount == 1 ? TdcAdaptive.space(context, 100) : TdcAdaptive.space(context, 195);
      
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: itemHeight,
        crossAxisSpacing: TdcAdaptive.space(context, 12),
        mainAxisSpacing: TdcAdaptive.space(context, 12),
      ),
      itemCount: courses.length,
      itemBuilder: (context, i) => _buildCourseCard(context, courses[i], i, prov, crossAxisCount == 1)
          .animate(delay: Duration(milliseconds: 100 + (i * 50)))
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
    );
  }

  Widget _buildCourseCard(BuildContext context, Course course, int index, CoursesProvider prov, bool horizontal) {
    final color = _levelColor(course.level);
    final done = prov.courseCompletedCount(course.id);
    final total = course.chapters.length;
    final progress = total > 0 ? done / total : 0.0;
    final icon = _courseIcon(course);
    final iconColor = _courseIconColor(course);

    return TdcFadeSlide(
      delay: Duration(milliseconds: 50 * index),
      child: TdcCard(
        onTap: () => _openCourseSheet(context, course, prov),
        padding: EdgeInsets.all(TdcAdaptive.padding(context, TdcSpacing.md)),
        child: horizontal
            ? _buildHorizontalCard(context, course, icon, iconColor, color, done, total, progress)
            : _buildVerticalCard(context, course, icon, iconColor, color, done, total, progress),
      ),
    );
  }

  Widget _buildVerticalCard(BuildContext context, Course course, IconData icon, Color iconColor, Color color, int done, int total, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.all(TdcAdaptive.padding(context, 10)),
              decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.12), borderRadius: TdcRadius.sm),
              child: Icon(icon, color: iconColor, size: TdcAdaptive.icon(context, 22)),
            ),
            if (course.keywords.contains('EXTERNAL'))
              const TdcStatusBadge(label: 'Module Externe', color: TdcColors.accent, icon: Icons.extension)
            else if (done == total && total > 0)
              const TdcStatusBadge(label: 'Terminé', color: TdcColors.success, icon: Icons.check_circle),
          ],
        ),
        const Spacer(),
        Text(course.title, style: TextStyle(color: TdcColors.textPrimary, fontSize: TdcText.body(context), fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
        SizedBox(height: TdcAdaptive.space(context, 5)),
        Text('${course.category.toUpperCase()} · $total chapitres', style: TextStyle(color: TdcColors.textMuted, fontSize: TdcText.caption(context), letterSpacing: 0.3)),
        SizedBox(height: TdcAdaptive.space(context, 8)),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress, minHeight: TdcAdaptive.space(context, 3),
            backgroundColor: TdcColors.surfaceAlt,
            valueColor: AlwaysStoppedAnimation(done > 0 ? TdcColors.success : TdcColors.surfaceAlt),
          ),
        ),
        SizedBox(height: TdcAdaptive.padding(context, TdcSpacing.sm)),
        Row(children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: TdcAdaptive.padding(context, 7), vertical: TdcAdaptive.padding(context, 3)),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(5)),
            child: Text(_levelLabel(course.level), style: TextStyle(color: color, fontSize: TdcText.label(context), fontWeight: FontWeight.w600)),
          ),
          SizedBox(width: TdcAdaptive.space(context, TdcSpacing.sm)),
          Text(course.duration, style: TextStyle(color: TdcColors.textMuted, fontSize: TdcText.label(context))),
          const Spacer(),
          Icon(Icons.chevron_right, color: TdcColors.textMuted, size: TdcAdaptive.icon(context, 16)),
        ]),
      ],
    );
  }

  Widget _buildHorizontalCard(BuildContext context, Course course, IconData icon, Color iconColor, Color color, int done, int total, double progress) {
    return Row(
      children: [
        Container(
          width: TdcAdaptive.icon(context, 52), 
          height: TdcAdaptive.icon(context, 52),
          decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.12), borderRadius: TdcRadius.md),
          child: Icon(icon, color: iconColor, size: TdcAdaptive.icon(context, 26)),
        ),
        SizedBox(width: TdcAdaptive.space(context, TdcSpacing.md)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(course.title, style: TextStyle(color: TdcColors.textPrimary, fontSize: TdcText.body(context), fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
              SizedBox(height: TdcAdaptive.space(context, 4)),
              Text('${course.category.toUpperCase()} · $total chapitres', style: TextStyle(color: TdcColors.textMuted, fontSize: TdcText.caption(context))),
              SizedBox(height: TdcAdaptive.space(context, 6)),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress, minHeight: TdcAdaptive.space(context, 3),
                  backgroundColor: TdcColors.surfaceAlt,
                  valueColor: AlwaysStoppedAnimation(done > 0 ? TdcColors.success : TdcColors.surfaceAlt),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: TdcAdaptive.space(context, TdcSpacing.sm)),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: TdcAdaptive.padding(context, 7), vertical: TdcAdaptive.padding(context, 3)),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(5)),
            child: Text(_levelLabel(course.level), style: TextStyle(color: color, fontSize: TdcText.label(context), fontWeight: FontWeight.w600)),
          ),
          SizedBox(height: TdcAdaptive.space(context, 6)),
          Icon(Icons.chevron_right, color: TdcColors.textMuted, size: TdcAdaptive.icon(context, 18)),
        ]),
      ],
    );
  }

  Widget _buildMobileQuickActions(BuildContext context) {
    final actions = _getTools(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Outils & Services', style: TextStyle(color: TdcColors.textPrimary, fontWeight: FontWeight.bold, fontSize: TdcText.h3(context))),
        SizedBox(height: TdcAdaptive.space(context, TdcSpacing.md)),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: TdcAdaptive.space(context, TdcSpacing.sm),
          mainAxisSpacing: TdcAdaptive.space(context, TdcSpacing.sm),
          childAspectRatio: 2.8,
          children: actions.map((t) => _buildToolButton(context, t)).toList(),
        ),
      ],
    );
  }

  void _openCourseSheet(BuildContext context, Course course, CoursesProvider prov) {
    showModalBottomSheet(
      context: context,
      backgroundColor: TdcColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(TdcAdaptive.space(context, 20)))),
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        builder: (_, ctrl) => ListView(
          controller: ctrl,
          padding: EdgeInsets.all(TdcAdaptive.padding(context, TdcSpacing.lg)),
          children: [
            Center(child: Container(width: TdcAdaptive.space(context, 40), height: TdcAdaptive.space(context, 4), decoration: BoxDecoration(color: TdcColors.border, borderRadius: BorderRadius.circular(2)))),
            SizedBox(height: TdcAdaptive.space(context, TdcSpacing.md)),
            Text(course.title, style: TextStyle(color: TdcColors.textPrimary, fontSize: TdcText.h2(context), fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text(course.description, style: TextStyle(color: TdcColors.textSecondary, fontSize: TdcText.bodySmall(context), height: 1.5)),
            SizedBox(height: TdcAdaptive.space(context, TdcSpacing.lg)),
            const Divider(color: TdcColors.border),
            SizedBox(height: TdcAdaptive.space(context, TdcSpacing.sm)),
            ...course.chapters.asMap().entries.map((e) {
              final ch = e.value;
              final isDone = prov.completed.contains('${course.id}:${ch.id}');
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 2),
                leading: Container(
                  width: TdcAdaptive.icon(context, 32), 
                  height: TdcAdaptive.icon(context, 32),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: isDone ? TdcColors.success.withValues(alpha: 0.15) : TdcColors.surfaceAlt, border: Border.all(color: isDone ? TdcColors.success : TdcColors.border)),
                  child: Center(
                    child: isDone
                        ? Icon(Icons.check, size: TdcAdaptive.icon(context, 15), color: TdcColors.success)
                        : Text('${e.key + 1}', style: TextStyle(color: TdcColors.textMuted, fontSize: TdcText.label(context), fontWeight: FontWeight.bold)),
                  ),
                ),
                title: Text(ch.title, style: TextStyle(color: TdcColors.textPrimary, fontSize: TdcText.body(context))),
                subtitle: Text(ch.duration, style: TextStyle(color: TdcColors.textMuted, fontSize: TdcText.bodySmall(context))),
                trailing: Icon(Icons.play_arrow, color: TdcColors.accent, size: TdcAdaptive.icon(context, 20)),
                onTap: () {
                  prov.selectChapter(course.id, ch.id);
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/chapter');
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAIPanel(BuildContext context) {
    final running = _aiStatus?.running ?? false;
    final models = _aiStatus?.models ?? [];
    return Container(
      padding: EdgeInsets.all(TdcAdaptive.padding(context, TdcSpacing.md)),
      decoration: BoxDecoration(color: TdcColors.surface, borderRadius: TdcRadius.lg, border: Border.all(color: running ? TdcColors.success.withValues(alpha: 0.3) : TdcColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.smart_toy, size: TdcAdaptive.icon(context, 16), color: running ? TdcColors.success : TdcColors.textMuted),
            SizedBox(width: TdcAdaptive.space(context, 8)),
            Text('Ollama IA locale', style: TextStyle(color: TdcColors.textPrimary, fontWeight: FontWeight.bold, fontSize: TdcText.body(context))),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: TdcAdaptive.padding(context, 8), vertical: TdcAdaptive.padding(context, 3)),
              decoration: BoxDecoration(color: running ? TdcColors.success.withValues(alpha: 0.1) : TdcColors.danger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(running ? 'En ligne' : 'Hors-ligne', style: TextStyle(color: running ? TdcColors.success : TdcColors.danger, fontSize: TdcText.label(context), fontWeight: FontWeight.bold)),
            ),
          ]),
          if (running && models.isNotEmpty) ...[
            SizedBox(height: TdcAdaptive.space(context, TdcSpacing.sm)),
            ...models.take(3).map((m) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(children: [
                    const Icon(Icons.circle, size: 6, color: TdcColors.success),
                    const SizedBox(width: 6),
                    Text(m.split(':').first, style: TextStyle(color: TdcColors.textSecondary, fontSize: TdcText.bodySmall(context), fontFamily: 'monospace')),
                  ]),
                )),
            SizedBox(height: TdcAdaptive.space(context, TdcSpacing.sm)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/ai'),
                icon: Icon(Icons.chat, size: TdcAdaptive.icon(context, 14)),
                label: Text('Ouvrir le Chat', style: TextStyle(fontSize: TdcText.button(context))),
                style: ElevatedButton.styleFrom(backgroundColor: TdcColors.accent, padding: EdgeInsets.symmetric(vertical: TdcAdaptive.padding(context, 10))),
              ),
            ),
          ],
          if (!running) ...[
            SizedBox(height: TdcAdaptive.space(context, TdcSpacing.sm)),
            Text('Installez Ollama pour activer l\'assistant IA.', style: TextStyle(color: TdcColors.textSecondary, fontSize: TdcText.caption(context), height: 1.4)),
            SizedBox(height: TdcAdaptive.space(context, TdcSpacing.sm)),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/ai-config'),
                icon: Icon(Icons.settings, size: TdcAdaptive.icon(context, 14)),
                label: Text('Configurer', style: TextStyle(fontSize: TdcText.button(context))),
                style: OutlinedButton.styleFrom(foregroundColor: TdcColors.textSecondary, side: const BorderSide(color: TdcColors.border), padding: EdgeInsets.symmetric(vertical: TdcAdaptive.padding(context, 10))),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildToolsPanel(BuildContext context) {
    final tools = _getTools(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            padding: EdgeInsets.all(TdcAdaptive.padding(context, 6)),
            decoration: BoxDecoration(color: TdcColors.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.auto_awesome, size: TdcAdaptive.icon(context, 16), color: TdcColors.accent),
          ),
          SizedBox(width: TdcAdaptive.space(context, 10)),
          Text('Outils & Services', style: TextStyle(color: TdcColors.textPrimary, fontWeight: FontWeight.bold, fontSize: TdcText.h3(context), letterSpacing: 0.2)),
        ]),
        SizedBox(height: TdcAdaptive.space(context, TdcSpacing.lg)),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tools.length,
          separatorBuilder: (_, __) => SizedBox(height: TdcAdaptive.space(context, 12)),
          itemBuilder: (context, i) => _buildToolButton(context, tools[i]),
        ),
      ],
    );
  }

  List<_ToolItem> _getTools(BuildContext context) {
    return [
      _ToolItem(Icons.map, 'Roadmap', 'Parcours & objectifs', const Color(0xFF10B981), () => Navigator.pushNamed(context, '/roadmap')),
      _ToolItem(Icons.build, 'Outils', 'Diagnostic & Réseau', const Color(0xFF6366F1), () => Navigator.pushNamed(context, '/tools')),
      _ToolItem(Icons.network_check, 'NetKit', 'Outils Réseau Avançé', const Color(0xFFEC4899), () => Navigator.pushNamed(context, '/netkit')),
      _ToolItem(Icons.description, 'Cheat Sheets', 'Mémos & commandes', const Color(0xFF3B82F6), () => Navigator.pushNamed(context, '/cheat-sheets')),
      _ToolItem(Icons.smart_toy, 'Chat IA', 'Posez vos questions', const Color(0xFF8B5CF6), () => Navigator.pushNamed(context, '/ai')),
      _ToolItem(Icons.analytics, 'Diagnostic', 'État du système local', const Color(0xFF3B82F6), () => Navigator.pushNamed(context, '/dashboard')),
      _ToolItem(Icons.settings, 'Config IA', 'Gérer Ollama', const Color(0xFFF59E0B), () => Navigator.pushNamed(context, '/ai-config')),
    ];
  }

  Widget _buildToolButton(BuildContext context, _ToolItem tool) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: tool.onTap,
        borderRadius: TdcRadius.md,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(TdcAdaptive.padding(context, TdcSpacing.md)),
          decoration: BoxDecoration(
            color: TdcColors.surface,
            borderRadius: TdcRadius.md,
            border: Border.all(color: TdcColors.border.withValues(alpha: 0.5)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(children: [
            Container(
              width: TdcAdaptive.icon(context, 44), 
              height: TdcAdaptive.icon(context, 44),
              decoration: BoxDecoration(color: tool.color.withValues(alpha: 0.12), borderRadius: TdcRadius.sm, border: Border.all(color: tool.color.withValues(alpha: 0.2))),
              child: Icon(tool.icon, color: tool.color, size: TdcAdaptive.icon(context, 22)),
            ),
            SizedBox(width: TdcAdaptive.space(context, TdcSpacing.md)),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tool.label, style: TextStyle(color: TdcColors.textPrimary, fontSize: TdcText.body(context), fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(tool.sub, style: TextStyle(color: TdcColors.textMuted, fontSize: TdcText.caption(context)), maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
            Icon(Icons.chevron_right, color: TdcColors.textMuted.withValues(alpha: 0.5), size: TdcAdaptive.icon(context, 18)),
          ]),
        ),
      ),
    );
  }

  Widget _buildProgressPanel(CoursesProvider prov) {
    return Container(
      padding: EdgeInsets.all(TdcAdaptive.padding(context, TdcSpacing.md)),
      decoration: BoxDecoration(color: TdcColors.surface, borderRadius: TdcRadius.lg, border: Border.all(color: TdcColors.border)),
      child: Column(children: [
        Row(children: [
          Icon(Icons.bar_chart, size: TdcAdaptive.icon(context, 15), color: TdcColors.accent),
          SizedBox(width: TdcAdaptive.space(context, 7)),
          Text('Ma progression', style: TextStyle(color: TdcColors.textPrimary, fontWeight: FontWeight.bold, fontSize: TdcText.body(context))),
        ]),
        SizedBox(height: TdcAdaptive.space(context, TdcSpacing.md)),
        Text('${(prov.overallProgress * 100).toInt()}%', style: TextStyle(color: TdcColors.textPrimary, fontSize: TdcText.scale(context, 48), fontWeight: FontWeight.bold)),
        Text('${prov.completedCount} sur ${prov.totalChaptersCount} chapitres', style: TextStyle(color: TdcColors.textSecondary, fontSize: TdcText.caption(context))),
        SizedBox(height: TdcAdaptive.space(context, TdcSpacing.md)),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: prov.overallProgress, minHeight: TdcAdaptive.space(context, 8), backgroundColor: TdcColors.surfaceAlt, valueColor: const AlwaysStoppedAnimation(TdcColors.accent)),
        ),
        SizedBox(height: TdcAdaptive.space(context, TdcSpacing.sm)),
        Text(prov.completedCount == 0 ? 'Commencez votre premier cours !' : 'Continuez votre apprentissage', style: TextStyle(color: TdcColors.textMuted, fontSize: TdcText.label(context))),
      ]),
    );
  }

  Color _levelColor(String l) {
    switch (l.toLowerCase()) {
      case 'beginner': return TdcColors.levelBeginner;
      case 'intermediate': return TdcColors.levelIntermediate;
      case 'advanced': return TdcColors.levelAdvanced;
      default: return TdcColors.textMuted;
    }
  }

  String _levelLabel(String l) {
    switch (l.toLowerCase()) {
      case 'beginner': return 'Débutant';
      case 'intermediate': return 'Intermédiaire';
      case 'advanced': return 'Avancé';
      default: return l;
    }
  }

  IconData _courseIcon(Course course) {
    final cat = course.category.toLowerCase();
    final title = course.title.toLowerCase();
    if (cat.contains('linux') || title.contains('linux') || title.contains('bash')) return Icons.terminal;
    if (cat.contains('docker') || title.contains('docker')) return Icons.view_in_ar;
    if (cat.contains('network') || title.contains('réseau') || title.contains('cisco')) return Icons.hub;
    if (cat.contains('security') || title.contains('sécurité') || title.contains('hack')) return Icons.security;
    if (cat.contains('web') || title.contains('html') || title.contains('css')) return Icons.language;
    if (cat.contains('python') || title.contains('python')) return Icons.code;
    if (cat.contains('database') || title.contains('sql')) return Icons.storage;
    if (cat.contains('git') || title.contains('git')) return Icons.merge_type;
    if (cat.contains('cloud') || title.contains('aws') || title.contains('kubernetes')) return Icons.cloud;
    if (cat.contains('ai') || cat.contains('ia') || title.contains('intelligence')) return Icons.smart_toy;
    return Icons.school;
  }

  Color _courseIconColor(Course course) {
    final cat = course.category.toLowerCase();
    final title = course.title.toLowerCase();
    if (cat.contains('linux') || title.contains('linux') || title.contains('bash')) return const Color(0xFFF59E0B);
    if (cat.contains('docker') || title.contains('docker')) return const Color(0xFF2496ED);
    if (cat.contains('network') || title.contains('réseau') || title.contains('cisco')) return const Color(0xFF10B981);
    if (cat.contains('security') || title.contains('sécurité') || title.contains('hack')) return const Color(0xFFEF4444);
    if (cat.contains('web') || title.contains('html') || title.contains('css')) return const Color(0xFFEC4899);
    if (title.contains('javascript') || title.contains('react')) return const Color(0xFFF7DF1E);
    if (cat.contains('python') || title.contains('python')) return const Color(0xFF3B82F6);
    if (cat.contains('database') || title.contains('sql')) return const Color(0xFF8B5CF6);
    if (cat.contains('git') || title.contains('git')) return const Color(0xFFF97316);
    if (cat.contains('cloud') || title.contains('kubernetes')) return const Color(0xFF06B6D4);
    if (cat.contains('ai') || cat.contains('ia')) return const Color(0xFFA855F7);
    return TdcColors.accent;
  }
}

class _ToolItem {
  final IconData icon;
  final String label;
  final String sub;
  final Color color;
  final VoidCallback onTap;
  const _ToolItem(this.icon, this.label, this.sub, this.color, this.onTap);
}
