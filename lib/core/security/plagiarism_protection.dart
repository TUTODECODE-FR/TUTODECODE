// ============================================================
// Plagiarism Protection System - Protection avancée contre le plagiat
// ============================================================
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Système de protection contre le plagiat et l'usurpation d'identité
/// Protège TUTODECODE contre la copie, la modification et le plagiat
class PlagiarismProtection {
  static const String ANTI_PLAGIARISM_FILE = 'anti_plagiarism.json';
  static const String CODE_DNA_FILE = 'code_dna.json';
  
  // DNA unique du code TUTODECODE
  static const Map<String, String> TUTODECODE_DNA = {
    'main_dna': 'TDC_MAIN_v1.0.3_a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0',
    'courses_dna': 'TDC_COURSES_v1.0.3_b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0a1',
    'ghost_ai_dna': 'TDC_AI_v1.0.3_c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0a1b2',
    'lab_dna': 'TDC_LAB_v1.0.3_d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0a1b2c3',
    'tools_dna': 'TDC_TOOLS_v1.0.3_e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0a1b2c3d4',
    'security_dna': 'TDC_SECURITY_v1.0.3_f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0a1b2c3d4e5',
  };
  
  // Patterns uniques de TUTODECODE
  static const List<String> UNIQUE_PATTERNS = [
    'TUTODECODE_FRAMEWORK',
    'SOVEREIGN_DIGITAL_LEARNING',
    'OFFLINE_TECHNICAL_EDUCATION',
    'ASSOCIATION_TUTODECODE_1901',
    'tutodecode_official_source',
    'TDC_SECURE_ARCHITECTURE',
    'GHOST_AI_LOCAL_TUTOR',
    'TUTODECODE_ETHICAL_HACKING',
    'TUTODECODE_DATACENTER_SIM',
    'TUTODECODE_FORENSIC_TOOLKIT',
  ];
  
  // Signatures de style de code
  static const Map<String, String> CODE_STYLE_SIGNATURES = {
    'naming_convention': 'tutodecode_camel_case_v1',
    'comment_style': 'tutodecode_comments_v1',
    'error_handling': 'tutodecode_error_handling_v1',
    'async_patterns': 'tutodecode_async_v1',
    'ui_components': 'tutodecode_ui_v1',
  };

  /// Analyse un fichier pour détecter le plagiat
  static Future<PlagiarismAnalysis> analyzeFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return PlagiarismAnalysis(
          filePath: filePath,
          isOriginal: false,
          plagiarismScore: 1.0,
          issues: ['File not found'],
          originalityScore: 0.0,
        );
      }
      
      final content = await file.readAsString();
      final issues = <String>[];
      double originalityScore = 100.0;
      
      // 1. Vérifier le DNA du code
      final dnaMatch = await _verifyCodeDNA(filePath, content);
      if (!dnaMatch) {
        issues.add('Code DNA mismatch - File has been modified');
        originalityScore -= 30.0;
      }
      
      // 2. Vérifier les patterns uniques
      final patternMatch = _verifyUniquePatterns(content);
      if (!patternMatch) {
        issues.add('Missing TUTODECODE unique patterns');
        originalityScore -= 25.0;
      }
      
      // 3. Vérifier le style de code
      final styleMatch = await _verifyCodeStyle(content);
      if (!styleMatch) {
        issues.add('Code style does not match TUTODECODE standards');
        originalityScore -= 20.0;
      }
      
      // 4. Détecter les traces de plagiat
      final plagiarismTraces = await _detectPlagiarismTraces(content);
      if (plagiarismTraces.isNotEmpty) {
        issues.addAll(plagiarismTraces);
        originalityScore -= plagiarismTraces.length * 10.0;
      }
      
      // 5. Vérifier les métadonnées
      final metadataMatch = await _verifyFileMetadata(filePath);
      if (!metadataMatch) {
        issues.add('File metadata does not match official version');
        originalityScore -= 15.0;
      }
      
      // 6. Détecter les modifications suspectes
      final suspiciousModifications = await _detectSuspiciousModifications(content);
      if (suspiciousModifications.isNotEmpty) {
        issues.addAll(suspiciousModifications);
        originalityScore -= suspiciousModifications.length * 5.0;
      }
      
      originalityScore = originalityScore.clamp(0.0, 100.0);
      final plagiarismScore = (100.0 - originalityScore) / 100.0;
      
      return PlagiarismAnalysis(
        filePath: filePath,
        isOriginal: originalityScore >= 80.0,
        plagiarismScore: plagiarismScore,
        issues: issues,
        originalityScore: originalityScore,
      );
      
    } catch (e) {
      return PlagiarismAnalysis(
        filePath: filePath,
        isOriginal: false,
        plagiarismScore: 1.0,
        issues: ['Analysis error: $e'],
        originalityScore: 0.0,
      );
    }
  }

  /// Analyse complète du projet pour le plagiat
  static Future<ProjectPlagiarismAnalysis> analyzeProject() async {
    try {
      final criticalFiles = [
        'lib/main.dart',
        'lib/features/courses/providers/courses_provider.dart',
        'lib/features/ghost_ai/providers/ai_tutor_provider.dart',
        'lib/features/lab/screens/ethical_hacking_simulator.dart',
        'lib/features/lab/screens/datacenter_simulator.dart',
        'lib/features/tools/screens/script_generator_screen.dart',
        'lib/features/tools/screens/survival_screen.dart',
        'lib/features/tools/screens/switch_config_screen.dart',
        'lib/features/tools/screens/vpn_guide_screen.dart',
        'lib/core/security/identity_verification.dart',
        'lib/core/security/anti_tampering.dart',
        'lib/core/security/build_verification.dart',
      ];
      
      final fileAnalyses = <PlagiarismAnalysis>[];
      double totalOriginalityScore = 0.0;
      final allIssues = <String>[];
      
      for (final filePath in criticalFiles) {
        final analysis = await analyzeFile(filePath);
        fileAnalyses.add(analysis);
        totalOriginalityScore += analysis.originalityScore;
        allIssues.addAll(analysis.issues);
      }
      
      final averageOriginalityScore = totalOriginalityScore / criticalFiles.length;
      final overallPlagiarismScore = (100.0 - averageOriginalityScore) / 100.0;
      
      // Vérifier le DNA global du projet
      final projectDNA = await _verifyProjectDNA();
      
      // Vérifier l'arborescence
      final structureMatch = await _verifyProjectStructure();
      
      // Vérifier les dépendances
      final dependenciesMatch = await _verifyProjectDependencies();
      
      return ProjectPlagiarismAnalysis(
        isAuthentic: averageOriginalityScore >= 80.0 && projectDNA && structureMatch && dependenciesMatch,
        overallOriginalityScore: averageOriginalityScore,
        overallPlagiarismScore: overallPlagiarismScore,
        fileAnalyses: fileAnalyses,
        projectDNA: projectDNA,
        structureMatch: structureMatch,
        dependenciesMatch: dependenciesMatch,
        allIssues: allIssues,
        analysisDate: DateTime.now(),
        riskLevel: _calculatePlagiarismRisk(overallPlagiarismScore, allIssues),
      );
      
    } catch (e) {
      return ProjectPlagiarismAnalysis(
        isAuthentic: false,
        overallOriginalityScore: 0.0,
        overallPlagiarismScore: 1.0,
        fileAnalyses: [],
        projectDNA: false,
        structureMatch: false,
        dependenciesMatch: false,
        allIssues: ['Analysis error: $e'],
        analysisDate: DateTime.now(),
        riskLevel: PlagiarismRiskLevel.critical,
      );
    }
  }

  /// Génère un certificat d'originalité
  static Future<OriginalityCertificate> generateOriginalityCertificate() async {
    final analysis = await analyzeProject();
    
    return OriginalityCertificate(
      certificateId: _generateCertificateId(),
      projectName: 'TUTODECODE',
      developerId: SourceAuthentication.OFFICIAL_DEVELOPER['developer_id'],
      isOriginal: analysis.isAuthentic,
      originalityScore: analysis.overallOriginalityScore,
      analysisDate: analysis.analysisDate,
      certificateHash: _generateCertificateHash(analysis),
      qrCodeData: _generateCertificateQRCode(analysis),
      digitalSignature: await _signCertificate(analysis),
    );
  }

  /// Crée une signature digitale pour le projet
  static Future<void> createDigitalSignature() async {
    final signature = DigitalSignature(
      signatureId: _generateSignatureId(),
      projectName: 'TUTODECODE',
      version: '1.0.3',
      developerId: SourceAuthentication.OFFICIAL_DEVELOPER['developer_id'],
      codeDNA: TUTODECODE_DNA,
      uniquePatterns: UNIQUE_PATTERNS,
      styleSignatures: CODE_STYLE_SIGNATURES,
      createdAt: DateTime.now(),
      signatureHash: await _calculateSignatureHash(),
    );
    
    final signatureFile = File('digital_signature.json');
    await signatureFile.writeAsString(jsonEncode(signature.toJson()));
  }

  // Méthodes privées
  static Future<bool> _verifyCodeDNA(String filePath, String content) async {
    try {
      // Calculer le DNA du fichier
      final dna = await _calculateFileDNA(content);
      
      // Vérifier si le DNA correspond
      for (final dnaType in TUTODECODE_DNA.keys) {
        if (filePath.toLowerCase().contains(dnaType.split('_')[0])) {
          return dna == TUTODECODE_DNA[dnaType];
        }
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<String> _calculateFileDNA(String content) async {
    try {
      final lines = content.split('\n');
      final lineCount = lines.length;
      final charCount = content.length;
      final classCount = content.split('class ').length - 1;
      final functionCount = content.split('void ').length + content.split('Future<void> ').length - 1;
      final importCount = content.split('import ').length - 1;
      
      // Calculer des métriques uniques
      final avgLineLength = charCount / lineCount;
      final complexity = _calculateComplexity(content);
      final entropy = _calculateEntropy(content);
      
      // Créer un DNA unique
      final dnaData = '$lineCount|$charCount|$classCount|$functionCount|$importCount|${avgLineLength.toStringAsFixed(2)}|$complexity|$entropy';
      final digest = sha256.convert(utf8.encode(dnaData));
      
      return digest.toString();
    } catch (e) {
      return 'DNA_ERROR';
    }
  }

  static double _calculateComplexity(String content) {
    // Calculer la complexité cyclomatique simplifiée
    int complexity = 0;
    
    // Compter les structures de contrôle
    complexity += content.split('if ').length - 1;
    complexity += content.split('for ').length - 1;
    complexity += content.split('while ').length - 1;
    complexity += content.split('switch ').length - 1;
    complexity += content.split('try ').length - 1;
    complexity += content.split('catch ').length - 1;
    
    return complexity.toDouble();
  }

  static double _calculateEntropy(String content) {
    // Calculer l'entropie du texte
    final charFrequency = <String, int>{};
    
    for (final char in content.split('')) {
      charFrequency[char] = (charFrequency[char] ?? 0) + 1;
    }
    
    double entropy = 0.0;
    final totalChars = content.length;
    
    for (final count in charFrequency.values) {
      if (count > 0) {
        final probability = count / totalChars;
        entropy -= probability * (log(probability) / ln(2));
      }
    }
    
    return entropy;
  }

  static bool _verifyUniquePatterns(String content) {
    int foundPatterns = 0;
    
    for (final pattern in UNIQUE_PATTERNS) {
      if (content.contains(pattern)) {
        foundPatterns++;
      }
    }
    
    // Au moins 50% des patterns doivent être présents
    return foundPatterns >= (UNIQUE_PATTERNS.length * 0.5);
  }

  static Future<bool> _verifyCodeStyle(String content) async {
    try {
      // Vérifier les conventions de nommage TUTODECODE
      final camelCasePattern = RegExp(r'[a-z]+[A-Z][a-zA-Z]*');
      final matches = camelCasePattern.allMatches(content);
      
      // Vérifier le style des commentaires
      final commentPattern = RegExp(r'///.*|//.*|/\*[\s\S]*?\*/');
      final comments = commentPattern.allMatches(content);
      
      // Vérifier le style des fonctions async
      final asyncPattern = RegExp(r'Future<.*>\s+async\s+\w+');
      final asyncFunctions = asyncPattern.allMatches(content);
      
      // Scores de style
      final namingScore = matches.length > 10 ? 1.0 : 0.5;
      final commentScore = comments.length > 5 ? 1.0 : 0.5;
      final asyncScore = asyncFunctions.length > 3 ? 1.0 : 0.5;
      
      final overallScore = (namingScore + commentScore + asyncScore) / 3.0;
      
      return overallScore >= 0.7;
    } catch (e) {
      return false;
    }
  }

  static Future<List<String>> _detectPlagiarismTraces(String content) async {
    final traces = <String>[];
    
    // Patterns de plagiat courants
    final plagiarismPatterns = [
      RegExp(r'//.*?Modified by.*?$', multiLine: true),
      RegExp(r'/\*.*?Hacked by.*?\*/', multiLine: true),
      RegExp(r'//.*?Cracked by.*?$', multiLine: true),
      RegExp(r'/\*.*?Pirated version.*?\*/', multiLine: true),
      RegExp(r'//.*?Stolen from.*?$', multiLine: true),
      RegExp(r'/\*.*?Copied from.*?\*/', multiLine: true),
    ];
    
    for (final pattern in plagiarismPatterns) {
      if (pattern.hasMatch(content)) {
        traces.add('Plagiarism pattern detected: ${pattern.pattern}');
      }
    }
    
    return traces;
  }

  static Future<bool> _verifyFileMetadata(String filePath) async {
    try {
      final file = File(filePath);
      final stat = await file.stat();
      final content = await file.readAsString();
      
      // Vérifier la taille du fichier
      final expectedSizes = {
        'lib/main.dart': 5000, // ~5KB
        'lib/features/courses/providers/courses_provider.dart': 8000, // ~8KB
        'lib/features/ghost_ai/providers/ai_tutor_provider.dart': 12000, // ~12KB
      };
      
      final expectedSize = expectedSizes[filePath];
      if (expectedSize != null) {
        final actualSize = stat.size;
        final sizeDifference = (actualSize - expectedSize).abs();
        
        // Tolérance de 20%
        if (sizeDifference > expectedSize * 0.2) {
          return false;
        }
      }
      
      // Vérifier l'encodage (UTF-8 attendu)
      final encodedContent = utf8.encode(content);
      final decodedContent = utf8.decode(encodedContent);
      
      return decodedContent == content;
    } catch (e) {
      return false;
    }
  }

  static Future<List<String>> _detectSuspiciousModifications(String content) async {
    final modifications = <String>[];
    
    // Patterns de modifications suspectes
    final suspiciousPatterns = [
      RegExp(r'//.*?TODO.*?hack', caseSensitive: false),
      RegExp(r'//.*?FIXME.*?crack', caseSensitive: false),
      RegExp(r'/\*.*?backdoor.*?\*/', multiLine: true, caseSensitive: false),
      RegExp(r'//.*?debug.*?malicious', caseSensitive: false),
      RegExp(r'//.*?temp.*?exploit', caseSensitive: false),
    ];
    
    for (final pattern in suspiciousPatterns) {
      if (pattern.hasMatch(content)) {
        modifications.add('Suspicious modification detected: ${pattern.pattern}');
      }
    }
    
    return modifications;
  }

  static Future<bool> _verifyProjectDNA() async {
    try {
      // Calculer le DNA global du projet
      final projectDNA = await _calculateProjectDNA();
      
      // Vérifier avec le DNA attendu
      final expectedDNA = 'TUTODECODE_PROJECT_v1.0.3_' + 
                         sha256.convert(utf8.encode('TUTODECODE_OFFICIAL_PROJECT')).toString().substring(0, 32);
      
      return projectDNA == expectedDNA;
    } catch (e) {
      return false;
    }
  }

  static Future<String> _calculateProjectDNA() async {
    try {
      final allDNA = <String>[];
      
      // Combiner tous les DNA de fichiers
      for (final dnaType in TUTODECODE_DNA.values) {
        allDNA.add(dnaType);
      }
      
      // Ajouter les patterns
      allDNA.addAll(UNIQUE_PATTERNS);
      
      final combined = allDNA.join('|');
      final digest = sha256.convert(utf8.encode(combined));
      
      return 'TUTODECODE_PROJECT_v1.0.3_${digest.toString()}';
    } catch (e) {
      return 'PROJECT_DNA_ERROR';
    }
  }

  static Future<bool> _verifyProjectStructure() async {
    try {
      final expectedDirs = [
        'lib/core',
        'lib/features',
        'lib/features/courses',
        'lib/features/ghost_ai',
        'lib/features/lab',
        'lib/features/tools',
        'lib/features/legal',
        'lib/core/security',
        'assets',
      ];
      
      for (final dirPath in expectedDirs) {
        if (!await Directory(dirPath).exists()) {
          return false;
        }
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _verifyProjectDependencies() async {
    try {
      final pubspecFile = File('pubspec.yaml');
      if (!await pubspecFile.exists()) {
        return false;
      }
      
      final pubspecContent = await pubspecFile.readAsString();
      
      // Vérifier les dépendances officielles
      final expectedDependencies = [
        'flutter:',
        'cupertino_icons:',
        'provider:',
        'shared_preferences:',
        'flutter_markdown:',
        'flutter_highlight:',
        'http:',
        'flutter_animate:',
        'glass_kit:',
        'animations:',
        'google_fonts:',
        'path_provider:',
        'connectivity_plus:',
        'cryptography:',
        'flutter_secure_storage:',
        'file_selector:',
        'device_info_plus:',
        'network_info_plus:',
      ];
      
      for (final dep in expectedDependencies) {
        if (!pubspecContent.contains(dep)) {
          return false;
        }
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  static PlagiarismRiskLevel _calculatePlagiarismRisk(double plagiarismScore, List<String> issues) {
    if (plagiarismScore >= 0.7 || issues.length >= 5) {
      return PlagiarismRiskLevel.critical;
    } else if (plagiarismScore >= 0.4 || issues.length >= 3) {
      return PlagiarismRiskLevel.high;
    } else if (plagiarismScore >= 0.2 || issues.length >= 1) {
      return PlagiarismRiskLevel.medium;
    } else {
      return PlagiarismRiskLevel.low;
    }
  }

  static String _generateCertificateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);
    return 'ORIG_CERT_${timestamp}_$random';
  }

  static String _generateSignatureId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);
    return 'DIG_SIG_${timestamp}_$random';
  }

  static String _generateCertificateHash(ProjectPlagiarismAnalysis analysis) {
    final data = '${analysis.isAuthentic}|${analysis.overallOriginalityScore}|${analysis.analysisDate.toIso8601String()}';
    final digest = sha256.convert(utf8.encode(data));
    return digest.toString();
  }

  static String _generateCertificateQRCode(ProjectPlagiarismAnalysis analysis) {
    return jsonEncode({
      'type': 'ORIGINALITY_CERTIFICATE',
      'project': 'TUTODECODE',
      'developer': SourceAuthentication.OFFICIAL_DEVELOPER['name'],
      'isOriginal': analysis.isAuthentic,
      'originalityScore': analysis.overallOriginalityScore,
      'analysisDate': analysis.analysisDate.toIso8601String(),
      'certificate': _generateCertificateHash(analysis),
      'developer_id': SourceAuthentication.OFFICIAL_DEVELOPER['developer_id'],
    });
  }

  static Future<String> _signCertificate(ProjectPlagiarismAnalysis analysis) async {
    try {
      final data = 'TUTODECODE_ORIGINALITY_${analysis.overallOriginalityScore}_${analysis.analysisDate.toIso8601String()}';
      final digest = sha256.convert(utf8.encode(data));
      return 'SIGNED_${digest.toString()}_BY_${SourceAuthentication.OFFICIAL_DEVELOPER['developer_id']}';
    } catch (e) {
      return 'UNSIGNED';
    }
  }

  static Future<String> _calculateSignatureHash() async {
    try {
      final allDNA = TUTODECODE_DNA.values.toList();
      allDNA.addAll(UNIQUE_PATTERNS);
      allDNA.addAll(CODE_STYLE_SIGNATURES.values);
      
      final combined = allDNA.join('|');
      final digest = sha256.convert(utf8.encode(combined));
      return digest.toString();
    } catch (e) {
      return 'SIGNATURE_HASH_ERROR';
    }
  }
}

// Classes de données
class PlagiarismAnalysis {
  final String filePath;
  final bool isOriginal;
  final double plagiarismScore;
  final List<String> issues;
  final double originalityScore;

  const PlagiarismAnalysis({
    required this.filePath,
    required this.isOriginal,
    required this.plagiarismScore,
    required this.issues,
    required this.originalityScore,
  });

  Map<String, dynamic> toJson() {
    return {
      'filePath': filePath,
      'isOriginal': isOriginal,
      'plagiarismScore': plagiarismScore,
      'issues': issues,
      'originalityScore': originalityScore,
    };
  }
}

class ProjectPlagiarismAnalysis {
  final bool isAuthentic;
  final double overallOriginalityScore;
  final double overallPlagiarismScore;
  final List<PlagiarismAnalysis> fileAnalyses;
  final bool projectDNA;
  final bool structureMatch;
  final bool dependenciesMatch;
  final List<String> allIssues;
  final DateTime analysisDate;
  final PlagiarismRiskLevel riskLevel;

  const ProjectPlagiarismAnalysis({
    required this.isAuthentic,
    required this.overallOriginalityScore,
    required this.overallPlagiarismScore,
    required this.fileAnalyses,
    required this.projectDNA,
    required this.structureMatch,
    required this.dependenciesMatch,
    required this.allIssues,
    required this.analysisDate,
    required this.riskLevel,
  });

  Map<String, dynamic> toJson() {
    return {
      'isAuthentic': isAuthentic,
      'overallOriginalityScore': overallOriginalityScore,
      'overallPlagiarismScore': overallPlagiarismScore,
      'fileAnalyses': fileAnalyses.map((a) => a.toJson()).toList(),
      'projectDNA': projectDNA,
      'structureMatch': structureMatch,
      'dependenciesMatch': dependenciesMatch,
      'allIssues': allIssues,
      'analysisDate': analysisDate.toIso8601String(),
      'riskLevel': riskLevel.name,
    };
  }
}

class OriginalityCertificate {
  final String certificateId;
  final String projectName;
  final String developerId;
  final bool isOriginal;
  final double originalityScore;
  final DateTime analysisDate;
  final String certificateHash;
  final String qrCodeData;
  final String digitalSignature;

  const OriginalityCertificate({
    required this.certificateId,
    required this.projectName,
    required this.developerId,
    required this.isOriginal,
    required this.originalityScore,
    required this.analysisDate,
    required this.certificateHash,
    required this.qrCodeData,
    required this.digitalSignature,
  });

  Map<String, dynamic> toJson() {
    return {
      'certificateId': certificateId,
      'projectName': projectName,
      'developerId': developerId,
      'isOriginal': isOriginal,
      'originalityScore': originalityScore,
      'analysisDate': analysisDate.toIso8601String(),
      'certificateHash': certificateHash,
      'qrCodeData': qrCodeData,
      'digitalSignature': digitalSignature,
    };
  }
}

class DigitalSignature {
  final String signatureId;
  final String projectName;
  final String version;
  final String developerId;
  final Map<String, String> codeDNA;
  final List<String> uniquePatterns;
  final Map<String, String> styleSignatures;
  final DateTime createdAt;
  final String signatureHash;

  const DigitalSignature({
    required this.signatureId,
    required this.projectName,
    required this.version,
    required this.developerId,
    required this.codeDNA,
    required this.uniquePatterns,
    required this.styleSignatures,
    required this.createdAt,
    required this.signatureHash,
  });

  Map<String, dynamic> toJson() {
    return {
      'signatureId': signatureId,
      'projectName': projectName,
      'version': version,
      'developerId': developerId,
      'codeDNA': codeDNA,
      'uniquePatterns': uniquePatterns,
      'styleSignatures': styleSignatures,
      'createdAt': createdAt.toIso8601String(),
      'signatureHash': signatureHash,
    };
  }
}

enum PlagiarismRiskLevel {
  low,
  medium,
  high,
  critical,
}

/// Service de protection contre le plagiat
class PlagiarismProtectionService {
  static ProjectPlagiarismAnalysis? _lastAnalysis;
  static DateTime? _lastAnalysisTime;
  
  /// Analyse le projet avec cache
  static Future<ProjectPlagiarismAnalysis> analyzeProject({bool forceRefresh = false}) async {
    final now = DateTime.now();
    
    // Utiliser le cache si disponible et récent (moins de 60 minutes)
    if (!forceRefresh && 
        _lastAnalysis != null && 
        _lastAnalysisTime != null && 
        now.difference(_lastAnalysisTime!).inMinutes < 60) {
      return _lastAnalysis!;
    }
    
    // Effectuer une nouvelle analyse
    _lastAnalysis = await PlagiarismProtection.analyzeProject();
    _lastAnalysisTime = now;
    
    return _lastAnalysis!;
  }
  
  /// Vérification rapide du projet
  static Future<bool> quickPlagiarismCheck() async {
    try {
      final criticalFiles = ['lib/main.dart', 'pubspec.yaml'];
      
      for (final filePath in criticalFiles) {
        final analysis = await PlagiarismProtection.analyzeFile(filePath);
        if (!analysis.isOriginal) {
          return false;
        }
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Génère un rapport complet
  static Future<Map<String, dynamic>> generatePlagiarismReport() async {
    final analysis = await analyzeProject();
    final certificate = await PlagiarismProtection.generateOriginalityCertificate();
    
    return {
      'analysis': analysis.toJson(),
      'certificate': certificate.toJson(),
      'reportGenerated': DateTime.now().toIso8601String(),
      'summary': {
        'isAuthentic': analysis.isAuthentic,
        'originalityScore': analysis.overallOriginalityScore,
        'plagiarismScore': analysis.overallPlagiarismScore,
        'riskLevel': analysis.riskLevel.name,
        'filesAnalyzed': analysis.fileAnalyses.length,
        'totalIssues': analysis.allIssues.length,
        'recommendation': analysis.isAuthentic 
            ? 'Code original - Utilisation sécurisée'
            : 'Code plagié - Risque de sécurité élevé',
      },
    };
  }
  
  /// Efface le cache d'analyse
  static void clearCache() {
    _lastAnalysis = null;
    _lastAnalysisTime = null;
  }
}
