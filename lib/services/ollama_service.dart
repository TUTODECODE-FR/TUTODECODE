import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/services/storage_service.dart';

/// Modèles recommandés pour l'apprentissage — légers et efficaces.
const List<Map<String, String>> kRecommendedModels = [
  {'id': 'mistral', 'label': 'Mistral 7B', 'desc': 'Polyvalent, rapide, idéal pour Q&A tech.', 'size': '4.1 GB'},
  {'id': 'llama3.2', 'label': 'Llama 3.2 3B', 'desc': 'Très léger, parfait si RAM < 8 GB.', 'size': '2.0 GB'},
  {'id': 'codellama', 'label': 'CodeLlama 7B', 'desc': 'Spécialisé code. Explications, debug.', 'size': '3.8 GB'},
  {'id': 'phi3', 'label': 'Phi-3 Mini', 'desc': 'Micro-modèle Microsoft, rapide.', 'size': '2.3 GB'},
];

class OllamaStatus {
  final bool running;
  final String? version;
  final List<String> models;
  final String? error;

  const OllamaStatus({
    required this.running,
    this.version,
    this.models = const [],
    this.error,
  });
}

class OllamaService {
  static const _timeout = Duration(seconds: 5);
  static Future<String> get _base async => await StorageService().getOllamaHost();

  /// Vérifie si Ollama tourne et récupère la liste des modèles.
  static Future<OllamaStatus> checkStatus() async {
    try {
      final base = await _base;
      // Ping de base
      final versionRes = await http
          .get(Uri.parse('$base/api/version'))
          .timeout(_timeout);

      if (versionRes.statusCode != 200) {
        return const OllamaStatus(running: false, error: 'Serveur inaccessible');
      }

      String? version;
      try {
        final v = jsonDecode(versionRes.body) as Map<String, dynamic>;
        version = v['version']?.toString();
      } catch (_) {}

      // Récupération des modèles installés
      final modelsRes = await http
          .get(Uri.parse('$base/api/tags'))
          .timeout(_timeout);

      List<String> models = [];
      if (modelsRes.statusCode == 200) {
        final data = jsonDecode(modelsRes.body) as Map<String, dynamic>;
        final list = data['models'] as List<dynamic>? ?? [];
        models = list.map((m) => m['name']?.toString() ?? '').where((s) => s.isNotEmpty).toList();
      }

      return OllamaStatus(running: true, version: version, models: models);
    } on SocketException {
      return const OllamaStatus(running: false, error: 'Ollama n\'est pas démarré');
    } on HttpException {
      return const OllamaStatus(running: false, error: 'Connexion refusée');
    } catch (e) {
      return OllamaStatus(running: false, error: e.toString());
    }
  }

  /// Envoie un message à Ollama et retourne la réponse complète.
  static Future<String> chat(String model, List<Map<String, String>> history) async {
    final base = await _base;
    final body = jsonEncode({
      'model': model,
      'messages': history,
      'stream': false,
    });

    final res = await http.post(
      Uri.parse('$base/api/chat'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    ).timeout(const Duration(seconds: 60));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return data['message']?['content']?.toString() ?? 'Réponse vide.';
    }
    throw Exception('Erreur Ollama: ${res.statusCode}');
  }
}
