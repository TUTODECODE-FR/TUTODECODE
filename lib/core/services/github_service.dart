import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import './module_service.dart';

class GithubService {
  final String repoOwner = 'TUTODECODE-FR';
  final String repoName = 'TUTODECODE';
  final String modulesPath = 'modules'; // Folder in the repo containing .json files
  final ModuleService _moduleService = ModuleService();

  /// Fetches the list of files in the modules directory and downloads new/updated ones.
  Future<int> syncModules() async {
    int updatedCount = 0;
    try {
      final url = Uri.parse('https://api.github.com/repos/$repoOwner/$repoName/contents/$modulesPath');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> contents = json.decode(response.body);
        
        for (var item in contents) {
          if (item['type'] == 'file' && item['name'].endsWith('.json')) {
            final fileName = item['name'];
            final downloadUrl = item['download_url'];
            final sha = item['sha'];

            // Check if we need to update this file
            if (await _shouldUpdate(fileName, sha)) {
              final contentResponse = await http.get(Uri.parse(downloadUrl));
              if (contentResponse.statusCode == 200) {
                await _moduleService.saveModule(fileName, contentResponse.body, sha);
                updatedCount++;
              }
            }
          }
        }
      } else {
        print('Failed to load repo contents: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during GitHub sync: $e');
    }
    return updatedCount;
  }

  Future<bool> _shouldUpdate(String fileName, String remoteSha) async {
    final localSha = await _moduleService.getSavedSha(fileName);
    return localSha != remoteSha;
  }
}
