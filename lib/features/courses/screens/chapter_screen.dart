import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import '../../providers/courses_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/responsive/responsive.dart';
import '../../../core/providers/shell_provider.dart';
import '../../../core/widgets/tdc_widgets.dart';
import '../widgets/qcm_widget.dart';

class ChapterScreen extends StatefulWidget {
  const ChapterScreen({super.key});
  @override _ChapterScreenState createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateShell();
    });
  }

  void _updateShell() {
    final prov = context.read<CoursesProvider>();
    final course = prov.currentCourse;
    final chapter = prov.currentChapter;
    if (course != null && chapter != null) {
      context.read<ShellProvider>().updateShell(
        title: chapter.title,
        showBackButton: true,
      );
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<CoursesProvider>(context);
    final course = prov.currentCourse;
    final chapter = prov.currentChapter;

    if (course == null || chapter == null) {
      return Center(child: Text('Aucun chapitre', style: TextStyle(color: TdcColors.textMuted)));
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.all(24),
            children: [
              Text(course.title, style: const TextStyle(color: TdcColors.accent, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(chapter.title, style: const TextStyle(color: TdcColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _markdown(chapter.content),
              if (chapter.quiz != null) ...[
                const SizedBox(height: 32),
                const TdcSectionTitle('QUIZ'),
                const SizedBox(height: 16),
                QcmWidget(
                  questions: chapter.quiz!,
                  onComplete: (ok) { if (ok) prov.toggleCompleted(course.id, chapter.id); },
                ),
              ],
              const SizedBox(height: 48),
            ],
          ),
        ),
        _nav(course, chapter, prov),
      ],
    );
  }

  Widget _markdown(String content) {
    return MarkdownBody(
      data: content,
      styleSheet: MarkdownStyleSheet(
        p: const TextStyle(color: TdcColors.textSecondary, fontSize: 15, height: 1.6),
        h1: const TextStyle(color: TdcColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
        code: const TextStyle(color: TdcColors.warning, backgroundColor: TdcColors.surfaceAlt),
      ),
    );
  }

  Widget _nav(course, chapter, prov) {
    final idx = course.chapters.indexOf(chapter);
    final hasNext = idx < course.chapters.length - 1;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: TdcColors.surface, border: Border(top: BorderSide(color: TdcColors.border))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (idx > 0) TextButton(onPressed: () => prov.selectChapter(course.id, course.chapters[idx-1].id), child: const Text('Précédent')),
          const Spacer(),
          if (hasNext) ElevatedButton(onPressed: () => prov.selectChapter(course.id, course.chapters[idx+1].id), child: const Text('Suivant'))
          else ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: TdcColors.success), child: const Text('Terminer')),
        ],
      ),
    );
  }
}
