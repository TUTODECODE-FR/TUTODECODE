// ============================================================
// AI Tutor Provider — Assistant IA local pour tutoriels interactifs
// ============================================================
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tutodecode/core/services/storage_service.dart';

class AiTutorProvider with ChangeNotifier {
  final StorageService _storage = StorageService();
  
  bool _isConnected = false;
  bool _isLoading = false;
  String? _errorMessage;
  List<String> _availableModels = [];
  String _selectedModel = 'llama2';
  List<TutorSession> _sessions = [];
  TutorSession? _currentSession;
  List<TutorMessage> _currentMessages = [];
  
  // Tutoring state
  bool _isTutoring = false;
  TutorMode _currentMode = TutorMode.explanation;
  String? _currentTopic;
  List<String> _suggestedTopics = [];
  Map<String, dynamic> _userProgress = {};
  
  // Ollama connection
  String _ollamaUrl = 'http://localhost:11434';
  Timer? _connectionCheckTimer;

  // Getters
  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<String> get availableModels => _availableModels;
  String get selectedModel => _selectedModel;
  List<TutorSession> get sessions => _sessions;
  TutorSession? get currentSession => _currentSession;
  List<TutorMessage> get currentMessages => _currentMessages;
  bool get isTutoring => _isTutoring;
  TutorMode get currentMode => _currentMode;
  String? get currentTopic => _currentTopic;
  List<String> get suggestedTopics => _suggestedTopics;
  Map<String, dynamic> get userProgress => _userProgress;

  AiTutorProvider() {
    _loadSettings();
    _initializeTutor();
    _startConnectionCheck();
  }

  @override
  void dispose() {
    _connectionCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _storage.loadAiSettings();
      _ollamaUrl = settings['ollamaUrl'] ?? 'http://localhost:11434';
      _selectedModel = settings['selectedModel'] ?? 'llama2';
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur chargement settings IA: $e');
    }
  }

  Future<void> _initializeTutor() async {
    await checkOllamaConnection();
    if (_isConnected) {
      await loadAvailableModels();
      await loadSessions();
      _generateSuggestedTopics();
    }
  }

  void _startConnectionCheck() {
    _connectionCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      checkOllamaConnection();
    });
  }

  Future<void> checkOllamaConnection() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await http.get(
        Uri.parse('$_ollamaUrl/api/tags'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        _isConnected = true;
        final data = jsonDecode(response.body);
        _availableModels = (data['models'] as List?)
            ?.map((model) => model['name'] as String)
            .toList() ?? [];
      } else {
        _isConnected = false;
        _errorMessage = 'Ollama non disponible (code: ${response.statusCode})';
      }
    } catch (e) {
      _isConnected = false;
      _errorMessage = 'Impossible de se connecter à Ollama: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAvailableModels() async {
    try {
      final response = await http.get(
        Uri.parse('$_ollamaUrl/api/tags'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _availableModels = (data['models'] as List?)
            ?.map((model) => model['name'] as String)
            .toList() ?? [];
        
        // Sélectionner le premier modèle si le modèle actuel n'est pas disponible
        if (_availableModels.isNotEmpty && !_availableModels.contains(_selectedModel)) {
          _selectedModel = _availableModels.first;
        }
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erreur chargement modèles: $e');
    }
  }

  Future<void> selectModel(String model) async {
    _selectedModel = model;
    await _storage.saveAiSettings({'ollamaUrl': _ollamaUrl, 'selectedModel': model});
    notifyListeners();
  }

  Future<void> updateOllamaUrl(String url) async {
    _ollamaUrl = url;
    await checkOllamaConnection();
    await _storage.saveAiSettings({'ollamaUrl': url, 'selectedModel': _selectedModel});
    notifyListeners();
  }

  // Session management
  Future<void> loadSessions() async {
    try {
      _sessions = List<TutorSession>.from(await _storage.loadTutorSessions());
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur chargement sessions: $e');
    }
  }

  Future<void> createNewSession(String title, String topic) async {
    try {
      final session = TutorSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        topic: topic,
        createdAt: DateTime.now(),
        messages: [],
        mode: _currentMode,
      );
      
      _sessions.insert(0, session);
      _currentSession = session;
      _currentMessages = [];
      _currentTopic = topic;
      _isTutoring = true;
      
      await _storage.saveTutorSessions(_sessions);
      
      // Envoyer le message de bienvenue
      await _sendWelcomeMessage();
      
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur création session: $e';
      notifyListeners();
    }
  }

  Future<void> selectSession(TutorSession session) async {
    _currentSession = session;
    _currentMessages = session.messages;
    _currentTopic = session.topic;
    _currentMode = session.mode;
    _isTutoring = true;
    notifyListeners();
  }

  Future<void> deleteSession(String sessionId) async {
    try {
      _sessions.removeWhere((s) => s.id == sessionId);
      if (_currentSession?.id == sessionId) {
        _currentSession = null;
        _currentMessages = [];
        _isTutoring = false;
      }
      await _storage.saveTutorSessions(_sessions);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur suppression session: $e';
      notifyListeners();
    }
  }

  // Tutoring methods
  Future<void> _sendWelcomeMessage() async {
    final welcomePrompt = _generateWelcomePrompt();
    await _generateAiResponse(welcomePrompt, isWelcome: true);
  }

  String _generateWelcomePrompt() {
    switch (_currentMode) {
      case TutorMode.explanation:
        return '''Tu es un tuteur technique expert pour TUTODECODE. 
Le sujet est: $_currentTopic.
Explique les concepts fondamentaux de manière claire et progressive.
Sois encouraging et pose des questions pour vérifier la compréhension.
Limite ta réponse à 200 mots maximum.''';
      
      case TutorMode.practice:
        return '''Tu es un coach pratique pour TUTODECODE.
Le sujet est: $_currentTopic.
Propose des exercices pratiques et des scénarios réels.
Donne des instructions étape par étape.
Sois patient et guide l'utilisateur à travers les erreurs.
Limite ta réponse à 150 mots maximum.''';
      
      case TutorMode.troubleshooting:
        return '''Tu es un expert en dépannage pour TUTODECODE.
Le sujet est: $_currentTopic.
Aide à résoudre des problèmes techniques courants.
Pose des questions diagnostiques pertinentes.
Propose des solutions étape par étape.
Limite ta réponse à 180 mots maximum.''';
      
      case TutorMode.quiz:
        return '''Tu es un évaluateur pédagogique pour TUTODECODE.
Le sujet est: $_currentTopic.
Crée des questions pertinentes pour évaluer les connaissances.
Varie les types de questions (QCM, vrai/faux, ouvertes).
Donne des feedbacks constructifs.
Limite ta réponse à 120 mots maximum.''';
    }
  }

  Future<void> sendMessage(String userMessage) async {
    if (!_isConnected || _currentSession == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      // Ajouter le message utilisateur
      final userMsg = TutorMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: userMessage,
        isFromUser: true,
        timestamp: DateTime.now(),
      );
      
      _currentMessages.add(userMsg);
      
      // Mettre à jour la session
      final updatedSession = _currentSession!.copyWith(
        messages: _currentMessages,
        updatedAt: DateTime.now(),
      );
      
      final sessionIndex = _sessions.indexWhere((s) => s.id == _currentSession!.id);
      if (sessionIndex != -1) {
        _sessions[sessionIndex] = updatedSession;
      }
      
      await _storage.saveTutorSessions(_sessions);
      
      // Générer la réponse IA
      await _generateAiResponse(userMessage);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur envoi message: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _generateAiResponse(String userMessage, {bool isWelcome = false}) async {
    try {
      final contextMessages = _buildContextMessages(isWelcome);
      
      final requestBody = {
        'model': _selectedModel,
        'messages': contextMessages,
        'stream': false,
        'options': {
          'temperature': 0.7,
          'top_p': 0.9,
          'max_tokens': 500,
        }
      };

      final response = await http.post(
        Uri.parse('$_ollamaUrl/api/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiContent = data['message']['content'] as String;
        
        // Ajouter la réponse IA
        final aiMsg = TutorMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: aiContent,
          isFromUser: false,
          timestamp: DateTime.now(),
        );
        
        _currentMessages.add(aiMsg);
        
        // Mettre à jour la session
        final updatedSession = _currentSession!.copyWith(
          messages: _currentMessages,
          updatedAt: DateTime.now(),
        );
        
        final sessionIndex = _sessions.indexWhere((s) => s.id == _currentSession!.id);
        if (sessionIndex != -1) {
          _sessions[sessionIndex] = updatedSession;
        }
        
        await _storage.saveTutorSessions(_sessions);
        
        // Mettre à jour le progrès utilisateur
        _updateUserProgress();
        
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erreur génération réponse IA: $e');
      
      // Ajouter un message d'erreur
      final errorMsg = TutorMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Désolé, je ne peux pas répondre pour le moment. Vérifiez la connexion à Ollama.',
        isFromUser: false,
        timestamp: DateTime.now(),
      );
      
      _currentMessages.add(errorMsg);
    }
  }

  List<Map<String, String>> _buildContextMessages(bool isWelcome) {
    final systemPrompt = isWelcome ? _generateWelcomePrompt() : _generateContextPrompt();
    
    final messages = [
      {'role': 'system', 'content': systemPrompt},
    ];
    
    // Ajouter les messages récents (limiter à 10 pour éviter les tokens excessifs)
    final recentMessages = _currentMessages.length > 10 
        ? _currentMessages.sublist(_currentMessages.length - 10)
        : _currentMessages;
    
    for (final msg in recentMessages) {
      messages.add({
        'role': msg.isFromUser ? 'user' : 'assistant',
        'content': msg.content,
      });
    }
    
    return messages;
  }

  String _generateContextPrompt() {
    final basePrompt = '''Tu es un tuteur technique expert pour TUTODECODE, une plateforme d'apprentissage IT 100% offline.

Règles importantes:
- Sois clair, concis et pédagogique
- Adapte ton niveau au contexte de la conversation
- Utilise des exemples pratiques quand possible
- Sois encouraging et constructif
- Évite le jargon excessif
- Limite tes réponses à 200 mots maximum

Sujet actuel: $_currentTopic
Mode: ${_currentMode.name}''';

    // Ajouter le contexte des messages précédents
    if (_currentMessages.isNotEmpty) {
      final lastMessages = _currentMessages.reversed.take(4).toList().reversed.toList();
      final context = lastMessages.map((msg) => 
          '${msg.isFromUser ? "Utilisateur" : "Tuteur"}: ${msg.content}'
      ).join('\n');
      
      return '''$basePrompt\n\nContexte récent:\n$context''';
    }
    
    return basePrompt;
  }

  void _updateUserProgress() {
    // Mettre à jour les statistiques d'apprentissage
    final topicKey = _currentTopic?.toLowerCase() ?? 'general';
    final currentProgress = _userProgress[topicKey] ?? {'messages': 0, 'sessions': 0, 'lastActivity': null};
    
    _userProgress[topicKey] = {
      'messages': (currentProgress['messages'] as int? ?? 0) + 1,
      'sessions': (currentProgress['sessions'] as int? ?? 0),
      'lastActivity': DateTime.now().toIso8601String(),
    };
    
    _storage.saveUserProgress(_userProgress);
  }

  void _generateSuggestedTopics() {
    _suggestedTopics = [
      'Linux et Bash',
      'Réseaux TCP/IP',
      'Sécurité informatique',
      'Docker et conteneurs',
      'Python pour l\'admin sys',
      'Bases de données SQL',
      'Virtualisation',
      'Scripting avancé',
      'Monitoring et logs',
      'Cloud computing',
    ];
    notifyListeners();
  }

  Future<void> setTutorMode(TutorMode mode) async {
    _currentMode = mode;
    if (_currentSession != null) {
      final updatedSession = _currentSession!.copyWith(mode: mode);
      final sessionIndex = _sessions.indexWhere((s) => s.id == _currentSession!.id);
      if (sessionIndex != -1) {
        _sessions[sessionIndex] = updatedSession;
        await _storage.saveTutorSessions(_sessions);
      }
    }
    notifyListeners();
  }

  Future<void> clearCurrentSession() async {
    _currentSession = null;
    _currentMessages = [];
    _currentTopic = null;
    _isTutoring = false;
    notifyListeners();
  }

  Future<void> regenerateResponse(String messageId) async {
    if (!_isConnected || _currentSession == null) return;

    try {
      // Trouver le message et le précédent
      final messageIndex = _currentMessages.indexWhere((m) => m.id == messageId);
      if (messageIndex == -1 || messageIndex == 0) return;

      // Supprimer l'ancienne réponse IA
      _currentMessages.removeAt(messageIndex);
      
      // Récupérer le message utilisateur précédent
      final userMessage = _currentMessages[messageIndex - 1];
      
      // Régénérer la réponse
      await _generateAiResponse(userMessage.content);
      
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur régénération: $e';
      notifyListeners();
    }
  }

  Map<String, dynamic> getStatistics() {
    final totalSessions = _sessions.length;
    final totalMessages = _sessions.fold(0, (sum, session) => sum + session.messages.length);
    final topicsCovered = _sessions.map((s) => s.topic).toSet().length;
    final averageMessagesPerSession = totalSessions > 0 ? totalMessages / totalSessions : 0.0;
    
    return {
      'totalSessions': totalSessions,
      'totalMessages': totalMessages,
      'topicsCovered': topicsCovered,
      'averageMessagesPerSession': averageMessagesPerSession.toStringAsFixed(1),
      'mostUsedMode': _getMostUsedMode(),
      'lastActivity': _sessions.isNotEmpty ? _sessions.first.updatedAt : null,
    };
  }

  TutorMode _getMostUsedMode() {
    final modeCounts = <TutorMode, int>{};
    for (final session in _sessions) {
      modeCounts[session.mode] = (modeCounts[session.mode] ?? 0) + 1;
    }
    
    if (modeCounts.isEmpty) return TutorMode.explanation;
    
    return modeCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}

// Models
class TutorSession {
  final String id;
  final String title;
  final String topic;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<TutorMessage> messages;
  final TutorMode mode;

  const TutorSession({
    required this.id,
    required this.title,
    required this.topic,
    required this.createdAt,
    this.updatedAt,
    required this.messages,
    required this.mode,
  });

  TutorSession copyWith({
    String? id,
    String? title,
    String? topic,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TutorMessage>? messages,
    TutorMode? mode,
  }) {
    return TutorSession(
      id: id ?? this.id,
      title: title ?? this.title,
      topic: topic ?? this.topic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
      mode: mode ?? this.mode,
    );
  }
}

class TutorMessage {
  final String id;
  final String content;
  final bool isFromUser;
  final DateTime timestamp;

  const TutorMessage({
    required this.id,
    required this.content,
    required this.isFromUser,
    required this.timestamp,
  });
}

enum TutorMode {
  explanation,
  practice,
  troubleshooting,
  quiz,
}

extension TutorModeExtension on TutorMode {
  String get displayName {
    switch (this) {
      case TutorMode.explanation: return 'Explications';
      case TutorMode.practice: return 'Pratique';
      case TutorMode.troubleshooting: return 'Dépannage';
      case TutorMode.quiz: return 'Quiz';
    }
  }

  String get description {
    switch (this) {
      case TutorMode.explanation: return 'Apprendre les concepts théoriques';
      case TutorMode.practice: return 'Exercices pratiques guidés';
      case TutorMode.troubleshooting: return 'Résolution de problèmes';
      case TutorMode.quiz: return 'Évaluer vos connaissances';
    }
  }

  IconData get icon {
    switch (this) {
      case TutorMode.explanation: return Icons.school;
      case TutorMode.practice: return Icons.build;
      case TutorMode.troubleshooting: return Icons.build_circle;
      case TutorMode.quiz: return Icons.quiz;
    }
  }

  Color get color {
    switch (this) {
      case TutorMode.explanation: return Colors.blue;
      case TutorMode.practice: return Colors.green;
      case TutorMode.troubleshooting: return Colors.orange;
      case TutorMode.quiz: return Colors.purple;
    }
  }
}
