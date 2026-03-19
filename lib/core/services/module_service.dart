import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../features/courses/data/course_repository.dart';

class ModuleService {
  static const String _moduleFolder = 'TUTODECODE_Modules';
  static const String _shaFile = '.module_shas.json';

  /// Returns the directory where external modules should be placed.
  Future<Directory> getModulesDirectory() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/$_moduleFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Scans the modules directory for .json files and loads them as Courses.
  Future<List<Course>> loadExternalModules() async {
    final List<Course> externalCourses = [];
    try {
      final dir = await getModulesDirectory();
      if (!await dir.exists()) return [];

      final List<FileSystemEntity> files = dir.listSync();

      for (final file in files) {
        if (file is File && file.path.endsWith('.json')) {
          try {
            final content = await file.readAsString();
            final Map<String, dynamic> data = json.decode(content);
            
            final course = Course.fromMap(data);
            if (!course.keywords.contains('EXTERNAL')) {
              course.keywords.add('EXTERNAL');
            }
            
            externalCourses.add(course);
          } catch (e) {
            print('Error loading module ${file.path}: $e');
          }
        }
      }
    } catch (e) {
      print('Error scanning modules directory: $e');
    }
    return externalCourses;
  }

  /// Saves a module's content and its SHA hash.
  Future<void> saveModule(String fileName, String content, String sha) async {
    final dir = await getModulesDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(content);
    await _updateSha(fileName, sha);
  }

  /// Returns the saved SHA for a given module file.
  Future<String?> getSavedSha(String fileName) async {
    final shas = await _loadShas();
    return shas[fileName];
  }

  Future<Map<String, dynamic>> _loadShas() async {
    final dir = await getModulesDirectory();
    final file = File('${dir.path}/$_shaFile');
    if (await file.exists()) {
      final content = await file.readAsString();
      return json.decode(content);
    }
    return {};
  }

  Future<void> _updateSha(String fileName, String sha) async {
    final shas = await _loadShas();
    shas[fileName] = sha;
    final dir = await getModulesDirectory();
    final file = File('${dir.path}/$_shaFile');
    await file.writeAsString(json.encode(shas));
  }
}
