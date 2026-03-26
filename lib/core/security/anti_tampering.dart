// ============================================================
// Anti-Tampering System - Protection contre la modification
// ============================================================
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;

/// Système anti-tampering pour protéger TUTODECODE contre les modifications
class AntiTamperingSystem {
  static const String INTEGRITY_FILE = 'app_integrity.json';
  static const String SIGNATURE_FILE = 'app_signature.sig';
  static const String CHECKSUM_FILE = 'app_checksum.sha256';
  
  // Hashs officiels des fichiers critiques
  static const Map<String, String> OFFICIAL_HASHES = {
    'lib/main.dart': 'a1b2c3d4e5f6789012345678901234567890abcdef',
    'lib/features/courses/providers/courses_provider.dart': 'b2c3d4e5f6789012345678901234567890abcdefa1',
    'lib/features/ghost_ai/providers/ai_tutor_provider.dart': 'c3d4e5f6789012345678901234567890abcdefa1b2',
    'pubspec.yaml': 'd4e5f6789012345678901234567890abcdefa1b2c3d4',
    'assets/courses.json': 'e5f6789012345678901234567890abcdefa1b2c3d4e5f6',
  };

  /// Vérifie l'intégrité complète de l'application
  static Future<IntegrityCheckResult> performIntegrityCheck() async {
    try {
      final results = <String, bool>{};
      final modifiedFiles = <String>[];
      final missingFiles = <String>[];
      
      // 1. Vérifier les fichiers critiques
      for (final filePath in OFFICIAL_HASHES.keys) {
        final fileExists = await File(filePath).exists();
        
        if (!fileExists) {
          missingFiles.add(filePath);
          results[filePath] = false;
        } else {
          final currentHash = await _calculateFileHash(filePath);
          final officialHash = OFFICIAL_HASHES[filePath]!;
          final isIntact = currentHash == officialHash;
          
          results[filePath] = isIntact;
          if (!isIntact) {
            modifiedFiles.add(filePath);
          }
        }
      }
      
      // 2. Vérifier la structure des répertoires
      final structureValid = await _verifyDirectoryStructure();
      
      // 3. Vérifier les dépendances
      final dependenciesValid = await _verifyDependencies();
      
      // 4. Vérifier la signature de l'application
      final signatureValid = await _verifyApplicationSignature();
      
      // 5. Vérifier le checksum global
      final checksumValid = await _verifyGlobalChecksum();
      
      // 6. Détecter les fichiers suspects
      final suspiciousFiles = await _detectSuspiciousFiles();
      
      final allChecksPass = results.values.every((valid) => valid) &&
                           structureValid &&
                           dependenciesValid &&
                           signatureValid &&
                           checksumValid &&
                           suspiciousFiles.isEmpty;
      
      return IntegrityCheckResult(
        isIntegrityValid: allChecksPass,
        fileResults: results,
        modifiedFiles: modifiedFiles,
        missingFiles: missingFiles,
        suspiciousFiles: suspiciousFiles,
        structureValid: structureValid,
        dependenciesValid: dependenciesValid,
        signatureValid: signatureValid,
        checksumValid: checksumValid,
        checkDate: DateTime.now(),
        riskLevel: _calculateRiskLevel(modifiedFiles.length, suspiciousFiles.length),
      );
      
    } catch (e) {
      return IntegrityCheckResult(
        isIntegrityValid: false,
        fileResults: {},
        modifiedFiles: [],
        missingFiles: [],
        suspiciousFiles: [],
        structureValid: false,
        dependenciesValid: false,
        signatureValid: false,
        checksumValid: false,
        checkDate: DateTime.now(),
        riskLevel: RiskLevel.critical,
        error: 'Erreur lors de la vérification d\'intégrité: $e',
      );
    }
  }

  /// Crée un fichier d'intégrité pour la version actuelle
  static Future<void> createIntegrityFile() async {
    final integrityData = {
      'version': '1.0.3',
      'buildDate': DateTime.now().toIso8601String(),
      'files': <String, String>{},
      'checksum': await _calculateGlobalChecksum(),
      'signature': await _createApplicationSignature(),
    };
    
    // Calculer les hashes de tous les fichiers
    for (final filePath in OFFICIAL_HASHES.keys) {
      if (await File(filePath).exists()) {
        (integrityData['files'] as Map<String, String>)[filePath] = await _calculateFileHash(filePath);
      }
    }
    
    final integrityFile = File(INTEGRITY_FILE);
    await integrityFile.writeAsString(jsonEncode(integrityData));
  }

  /// Vérifie si l'application a été modifiée
  static Future<bool> isApplicationModified() async {
    final result = await performIntegrityCheck();
    return !result.isIntegrityValid;
  }

  /// Génère un rapport d'intégrité détaillé
  static Future<Map<String, dynamic>> generateIntegrityReport() async {
    final result = await performIntegrityCheck();
    
    return {
      'summary': {
        'isIntegrityValid': result.isIntegrityValid,
        'riskLevel': result.riskLevel.name,
        'checkDate': result.checkDate.toIso8601String(),
        'totalFilesChecked': result.fileResults.length,
        'modifiedFilesCount': result.modifiedFiles.length,
        'missingFilesCount': result.missingFiles.length,
        'suspiciousFilesCount': result.suspiciousFiles.length,
      },
      'checks': {
        'structure': result.structureValid,
        'dependencies': result.dependenciesValid,
        'signature': result.signatureValid,
        'checksum': result.checksumValid,
      },
      'files': {
        'valid': result.fileResults.entries.where((e) => e.value).map((e) => e.key).toList(),
        'modified': result.modifiedFiles,
        'missing': result.missingFiles,
        'suspicious': result.suspiciousFiles,
      },
      'recommendations': _generateRecommendations(result),
    };
  }

  // Méthodes privées
  static Future<String> _calculateFileHash(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final digest = sha256.convert(bytes);
      return digest.toString();
    } catch (e) {
      return '';
    }
  }

  static Future<String> _calculateGlobalChecksum() async {
    try {
      final allHashes = <String>[];
      
      // Hasher tous les fichiers critiques
      for (final filePath in OFFICIAL_HASHES.keys) {
        if (await File(filePath).exists()) {
          final hash = await _calculateFileHash(filePath);
          allHashes.add(hash);
        }
      }
      
      // Hasher la structure
      final structureHash = await _hashDirectoryStructure();
      allHashes.add(structureHash);
      
      // Créer le hash global
      final combinedData = allHashes.join('|');
      final digest = sha256.convert(utf8.encode(combinedData));
      return digest.toString();
    } catch (e) {
      return '';
    }
  }

  static Future<String> _hashDirectoryStructure() async {
    try {
      final structure = <String>[];
      
      // Parcourir la structure des répertoires critiques
      final criticalDirs = ['lib', 'assets'];
      
      for (final dir in criticalDirs) {
        final directory = Directory(dir);
        if (await directory.exists()) {
          await _processDirectory(directory, structure);
        }
      }
      
      final structureData = structure.join('|');
      final digest = sha256.convert(utf8.encode(structureData));
      return digest.toString();
    } catch (e) {
      return '';
    }
  }

  static Future<void> _processDirectory(Directory directory, List<String> structure) async {
    try {
      final files = await directory.list().toList();
      
      for (final file in files) {
        final relativePath = path.relative(file.path, from: Directory.current.path);
        structure.add(relativePath);
        
        if (file is Directory) {
          await _processDirectory(file, structure);
        }
      }
    } catch (e) {
      // Ignorer les erreurs de lecture de fichiers
    }
  }

  static Future<bool> _verifyDirectoryStructure() async {
    try {
      // Vérifier que les répertoires critiques existent
      final criticalDirs = ['lib', 'assets', 'features', 'core'];
      
      for (final dir in criticalDirs) {
        if (!await Directory(dir).exists()) {
          return false;
        }
      }
      
      // Vérifier qu'il n'y a pas de répertoires suspects
      final suspiciousDirs = ['hack', 'crack', 'patch', 'mod'];
      final currentDir = Directory.current;
      
      await for (final entity in currentDir.list()) {
        if (entity is Directory) {
          final dirName = path.basename(entity.path);
          if (suspiciousDirs.contains(dirName.toLowerCase())) {
            return false;
          }
        }
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _verifyDependencies() async {
    try {
      // Vérifier que pubspec.yaml n'a pas été modifié avec des dépendances suspectes
      final pubspecFile = File('pubspec.yaml');
      if (!await pubspecFile.exists()) return false;
      
      final content = await pubspecFile.readAsString();
      final suspiciousDeps = ['http:', 'git:', 'path:'];
      
      for (final dep in suspiciousDeps) {
        if (content.contains('dependencies:') && content.contains(dep)) {
          // Vérifier si c'est une dépendance officielle ou suspecte
          final lines = content.split('\n');
          for (final line in lines) {
            if (line.trim().startsWith(dep) && !line.contains('tutodecode')) {
              return false;
            }
          }
        }
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _verifyApplicationSignature() async {
    try {
      // Vérifier la signature de l'application
      final signatureFile = File(SIGNATURE_FILE);
      if (!await signatureFile.exists()) {
        // Créer une signature pour la version actuelle
        await _createApplicationSignature();
        return true;
      }
      
      final signature = await signatureFile.readAsString();
      final expectedSignature = await _getExpectedSignature();
      
      return signature == expectedSignature;
    } catch (e) {
      return false;
    }
  }

  static Future<String> _createApplicationSignature() async {
    final timestamp = DateTime.now().toIso8601String();
    final checksum = await _calculateGlobalChecksum();
    final signatureData = 'TUTODECODE|$timestamp|$checksum';
    
    final digest = sha256.convert(utf8.encode(signatureData));
    final signature = digest.toString();
    
    // Sauvegarder la signature
    final signatureFile = File(SIGNATURE_FILE);
    await signatureFile.writeAsString(signature);
    
    return signature;
  }

  static Future<String> _getExpectedSignature() async {
    // En production, ceci récupérerait la signature officielle
    // Pour la démo, nous générons une signature cohérente
    return 'TUTODECODE_SIGNATURE_1.0.3_OFFICIAL';
  }

  static Future<bool> _verifyGlobalChecksum() async {
    try {
      final currentChecksum = await _calculateGlobalChecksum();
      final expectedChecksum = await _getExpectedChecksum();
      
      return currentChecksum == expectedChecksum;
    } catch (e) {
      return false;
    }
  }

  static Future<String> _getExpectedChecksum() async {
    // Checksum officiel de la version
    return 'official_checksum_1.0.3_tutodecode';
  }

  static Future<List<String>> _detectSuspiciousFiles() async {
    final suspiciousFiles = <String>[];
    final currentDir = Directory.current;
    
    // Patterns de fichiers suspects
    final suspiciousPatterns = [
      RegExp(r'\.patch$', caseSensitive: false),
      RegExp(r'\.crack$', caseSensitive: false),
      RegExp(r'\.hack$', caseSensitive: false),
      RegExp(r'\.mod$', caseSensitive: false),
      RegExp(r'keylogger', caseSensitive: false),
      RegExp(r'trojan', caseSensitive: false),
      RegExp(r'backdoor', caseSensitive: false),
      RegExp(r'suspicious', caseSensitive: false),
    ];
    
    await for (final entity in currentDir.list(recursive: true)) {
      if (entity is File) {
        final fileName = path.basename(entity.path);
        
        for (final pattern in suspiciousPatterns) {
          if (pattern.hasMatch(fileName)) {
            suspiciousFiles.add(entity.path);
            break;
          }
        }
      }
    }
    
    return suspiciousFiles;
  }

  static RiskLevel _calculateRiskLevel(int modifiedFiles, int suspiciousFiles) {
    if (suspiciousFiles > 0) return RiskLevel.critical;
    if (modifiedFiles > 5) return RiskLevel.critical;
    if (modifiedFiles > 2) return RiskLevel.high;
    if (modifiedFiles > 0) return RiskLevel.medium;
    return RiskLevel.low;
  }

  static List<String> _generateRecommendations(IntegrityCheckResult result) {
    final recommendations = <String>[];
    
    if (!result.isIntegrityValid) {
      recommendations.add('L\'intégrité de l\'application est compromise. Téléchargez la version officielle depuis tutodecode.org');
    }
    
    if (result.modifiedFiles.isNotEmpty) {
      recommendations.add('${result.modifiedFiles.length} fichier(s) modifié(s) détecté(s)');
    }
    
    if (result.missingFiles.isNotEmpty) {
      recommendations.add('${result.missingFiles.length} fichier(s) manquant(s) détecté(s)');
    }
    
    if (result.suspiciousFiles.isNotEmpty) {
      recommendations.add('${result.suspiciousFiles.length} fichier(s) suspect(s) détecté(s)');
    }
    
    if (!result.signatureValid) {
      recommendations.add('La signature de l\'application est invalide');
    }
    
    if (!result.checksumValid) {
      recommendations.add('Le checksum global ne correspond pas');
    }
    
    if (result.isIntegrityValid) {
      recommendations.add('L\'intégrité de l\'application est validée');
    }
    
    return recommendations;
  }
}

/// Résultat de la vérification d'intégrité
class IntegrityCheckResult {
  final bool isIntegrityValid;
  final Map<String, bool> fileResults;
  final List<String> modifiedFiles;
  final List<String> missingFiles;
  final List<String> suspiciousFiles;
  final bool structureValid;
  final bool dependenciesValid;
  final bool signatureValid;
  final bool checksumValid;
  final DateTime checkDate;
  final RiskLevel riskLevel;
  final String? error;

  const IntegrityCheckResult({
    required this.isIntegrityValid,
    required this.fileResults,
    required this.modifiedFiles,
    required this.missingFiles,
    required this.suspiciousFiles,
    required this.structureValid,
    required this.dependenciesValid,
    required this.signatureValid,
    required this.checksumValid,
    required this.checkDate,
    required this.riskLevel,
    this.error,
  });

  Map<String, dynamic> toJson() {
    return {
      'isIntegrityValid': isIntegrityValid,
      'fileResults': fileResults,
      'modifiedFiles': modifiedFiles,
      'missingFiles': missingFiles,
      'suspiciousFiles': suspiciousFiles,
      'structureValid': structureValid,
      'dependenciesValid': dependenciesValid,
      'signatureValid': signatureValid,
      'checksumValid': checksumValid,
      'checkDate': checkDate.toIso8601String(),
      'riskLevel': riskLevel.name,
      'error': error,
    };
  }
}

/// Niveaux de risque
enum RiskLevel {
  low,
  medium,
  high,
  critical,
}

/// Service anti-tampering
class AntiTamperingService {
  static IntegrityCheckResult? _lastCheck;
  static DateTime? _lastCheckTime;
  
  /// Effectue une vérification d'intégrité avec cache
  static Future<IntegrityCheckResult> checkIntegrity({bool forceRefresh = false}) async {
    final now = DateTime.now();
    
    // Utiliser le cache si disponible et récent (moins de 10 minutes)
    if (!forceRefresh && 
        _lastCheck != null && 
        _lastCheckTime != null && 
        now.difference(_lastCheckTime!).inMinutes < 10) {
      return _lastCheck!;
    }
    
    // Effectuer une nouvelle vérification
    _lastCheck = await AntiTamperingSystem.performIntegrityCheck();
    _lastCheckTime = now;
    
    return _lastCheck!;
  }
  
  /// Vérification rapide (seulement les fichiers critiques)
  static Future<bool> quickIntegrityCheck() async {
    try {
      final criticalFiles = ['lib/main.dart', 'pubspec.yaml'];
      
      for (final filePath in criticalFiles) {
        if (!await File(filePath).exists()) {
          return false;
        }
        
        final currentHash = await AntiTamperingSystem._calculateFileHash(filePath);
        final officialHash = AntiTamperingSystem.OFFICIAL_HASHES[filePath];
        
        if (currentHash != officialHash) {
          return false;
        }
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Efface le cache de vérification
  static void clearCache() {
    _lastCheck = null;
    _lastCheckTime = null;
  }
}
