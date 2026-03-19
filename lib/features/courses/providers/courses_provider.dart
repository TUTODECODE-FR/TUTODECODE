// Feature: courses — State management (Provider)
// Single source of truth for all course state.
import 'package:flutter/material.dart';
import '../data/course_repository.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/module_service.dart';
import '../../../core/services/github_service.dart';

class CoursesProvider with ChangeNotifier {
  final StorageService _storage = StorageService();
  final ModuleService _moduleService = ModuleService();
  final GithubService _githubService = GithubService();

  List<Course> _courses = [];
  List<String> _completed = [];
  String? _currentCourseId;
  String? _currentChapterId;
  bool _loaded = false;
  bool _isUpdating = false;
  String? _errorMessage;

  CoursesProvider() {
    _load();
  }

  // ── Getters ─────────────────────────────────────────────
  List<Course> get courses => _courses;
  List<String> get completed => _completed;
  String? get currentCourseId => _currentCourseId;
  String? get currentChapterId => _currentChapterId;
  bool get loaded => _loaded;
  bool get isUpdating => _isUpdating;
  String? get errorMessage => _errorMessage;

  int get totalChaptersCount =>
      _courses.fold(0, (s, c) => s + c.chapters.length);
  int get completedCount => _completed.length;
  double get overallProgress =>
      totalChaptersCount == 0 ? 0.0 : completedCount / totalChaptersCount;

  int courseChaptersCount(String courseId) {
    for (final c in _courses) {
      if (c.id == courseId) return c.chapters.length;
    }
    return 0;
  }

  int courseCompletedCount(String courseId) =>
      _completed.where((k) => k.startsWith('$courseId:')).length;

  Course? get currentCourse {
    if (_currentCourseId == null) {
      return _courses.isNotEmpty ? _courses.first : null;
    }
    for (final c in _courses) {
      if (c.id == _currentCourseId) return c;
    }
    return _courses.isNotEmpty ? _courses.first : null;
  }

  CourseChapter? get currentChapter {
    final course = currentCourse;
    if (course == null || _currentChapterId == null) return null;
    return course.chapters.firstWhere(
      (ch) => ch.id == _currentChapterId,
      orElse: () => course.chapters.first,
    );
  }

  // ── Actions ─────────────────────────────────────────────
  void selectChapter(String courseId, String chapterId) {
    _currentCourseId = courseId;
    _currentChapterId = chapterId;
    notifyListeners();
  }

  void toggleCompleted(String courseId, String chapterId) {
    final key = '$courseId:$chapterId';
    if (_completed.contains(key)) {
      _completed.remove(key);
    } else {
      _completed.add(key);
    }
    _storage.saveCompleted(_completed);
    notifyListeners();
  }

  Future<void> reload() => _load();

  /// Triggers a synchronization with the remote GitHub repository.
  Future<int> checkForUpdates() async {
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final updatedCount = await _githubService.syncModules();
      if (updatedCount > 0) {
        await _load();
      }
      return updatedCount;
    } catch (err) {
      _errorMessage = 'Update failed: $err';
      return 0;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  Future<void> _load() async {
    try {
      _errorMessage = null;
      _loaded = false;
      _completed = await _storage.loadCompleted();
      
      final assetCourses = await Course.loadAll();
      final externalCourses = await _moduleService.loadExternalModules();
      
      _courses = [...assetCourses, ...externalCourses];
    } catch (err) {
      _errorMessage = err.toString();
      _courses = [];
    } finally {
      _loaded = true;
      notifyListeners();
    }
  }
}
