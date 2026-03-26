// ============================================================
// Build Verification System - Vérification de build officiel
// ============================================================
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'anti_tampering.dart';

/// Système de vérification des builds officiels TUTODECODE
class BuildVerification {
  static const String OFFICIAL_BUILD_PREFIX = 'TUTODECODE_OFFICIAL';
  static const String BUILD_MANIFEST_FILE = 'build_manifest.json';
  static const String BUILD_SIGNATURE_FILE = 'build_signature.sig';
  
  // Informations de build officielles
  static const Map<String, BuildInfo> OFFICIAL_BUILDS = {
    '1.0.3+3': BuildInfo(
      version: '1.0.3+3',
      buildNumber: '20240320-001',
      buildDate: '2024-03-20',
      platform: 'multi',
      architecture: 'universal',
      buildType: 'release',
      signature: 'SHA256:abc123def456...',
      checksum: 'checksum_1.0.3_release',
      isOfficial: true,
      buildEnvironment: 'ci/github-actions',
    ),
    '1.0.2+2': BuildInfo(
      version: '1.0.2+2',
      buildNumber: '20240310-002',
      buildDate: '2024-03-10',
      platform: 'multi',
      architecture: 'universal',
      buildType: 'release',
      signature: 'SHA256:def456ghi789...',
      checksum: 'checksum_1.0.2_release',
      isOfficial: true,
      buildEnvironment: 'ci/github-actions',
    ),
  };

  /// Vérifie si le build actuel est officiel
  static Future<BuildVerificationResult> verifyCurrentBuild() async {
    try {
      // 1. Obtenir les informations du build actuel
      final currentBuildInfo = await _getCurrentBuildInfo();
      
      // 2. Vérifier si c'est un build officiel
      final officialBuild = OFFICIAL_BUILDS[currentBuildInfo.version];
      
      if (officialBuild == null) {
        return BuildVerificationResult(
          isOfficial: false,
          buildInfo: currentBuildInfo,
          verificationDate: DateTime.now(),
          reasons: ['Version non trouvée dans les builds officiels'],
          riskLevel: RiskLevel.high,
          checks: {
            'signature': false,
            'checksum': false,
            'environment': false,
            'manifest': false,
            'metadata': false,
          },
        );
      }
      
      // 3. Comparer les signatures
      final signatureValid = await _verifyBuildSignature(currentBuildInfo, officialBuild);
      
      // 4. Vérifier le checksum
      final checksumValid = await _verifyBuildChecksum(currentBuildInfo, officialBuild);
      
      // 5. Vérifier l'environnement de build
      final environmentValid = await _verifyBuildEnvironment(currentBuildInfo, officialBuild);
      
      // 6. Vérifier le manifest de build
      final manifestValid = await _verifyBuildManifest(currentBuildInfo);
      
      // 7. Vérifier les métadonnées du build
      final metadataValid = await _verifyBuildMetadata(currentBuildInfo, officialBuild);
      
      final allChecksPass = signatureValid && 
                           checksumValid && 
                           environmentValid && 
                           manifestValid && 
                           metadataValid;
      
      final reasons = <String>[];
      if (!signatureValid) reasons.add('Signature de build invalide');
      if (!checksumValid) reasons.add('Checksum de build incorrect');
      if (!environmentValid) reasons.add('Environnement de build non officiel');
      if (!manifestValid) reasons.add('Manifest de build absent ou modifié');
      if (!metadataValid) reasons.add('Métadonnées de build incohérentes');
      
      return BuildVerificationResult(
        isOfficial: allChecksPass,
        buildInfo: currentBuildInfo,
        officialBuildInfo: officialBuild,
        verificationDate: DateTime.now(),
        checks: {
          'signature': signatureValid,
          'checksum': checksumValid,
          'environment': environmentValid,
          'manifest': manifestValid,
          'metadata': metadataValid,
        },
        reasons: reasons.isEmpty ? null : reasons,
        riskLevel: allChecksPass ? RiskLevel.low : _calculateBuildRisk(reasons),
      );
      
    } catch (e) {
      return BuildVerificationResult(
        isOfficial: false,
        buildInfo: await _getCurrentBuildInfo(),
        verificationDate: DateTime.now(),
        error: 'Erreur lors de la vérification du build: $e',
        riskLevel: RiskLevel.critical,
        checks: {
          'signature': false,
          'checksum': false,
          'environment': false,
          'manifest': false,
          'metadata': false,
        },
      );
    }
  }

  /// Génère un certificat de build officiel
  static Future<BuildCertificate> generateBuildCertificate() async {
    final verification = await verifyCurrentBuild();
    
    return BuildCertificate(
      certificateId: _generateCertificateId(),
      buildInfo: verification.buildInfo,
      isOfficial: verification.isOfficial,
      verificationDate: verification.verificationDate,
      certificateHash: _generateCertificateHash(verification),
      qrCodeData: _generateBuildQRCode(verification),
      signature: await _signCertificate(verification),
    );
  }

  /// Crée un manifest de build pour la version actuelle
  static Future<void> createBuildManifest() async {
    final buildInfo = await _getCurrentBuildInfo();
    final manifest = BuildManifest(
      buildInfo: buildInfo,
      files: await _getBuildFiles(),
      dependencies: await _getBuildDependencies(),
      checksum: await _calculateBuildChecksum(),
      signature: await _createBuildSignature(),
      createdAt: DateTime.now(),
    );
    
    final manifestFile = File(BUILD_MANIFEST_FILE);
    await manifestFile.writeAsString(jsonEncode(manifest.toJson()));
  }

  // Méthodes privées
  static Future<BuildInfo> _getCurrentBuildInfo() async {
    try {
      // Lire depuis pubspec.yaml
      final pubspecFile = File('pubspec.yaml');
      if (!await pubspecFile.exists()) {
        throw Exception('pubspec.yaml non trouvé');
      }
      
      final pubspecContent = await pubspecFile.readAsString();
      final version = _extractVersionFromPubspec(pubspecContent);
      
      // Obtenir les informations de plateforme
      final platform = _getCurrentPlatform();
      final architecture = _getCurrentArchitecture();
      
      return BuildInfo(
        version: version,
        buildNumber: await _getBuildNumber(),
        buildDate: DateTime.now().toIso8601String().split('T')[0],
        platform: platform,
        architecture: architecture,
        buildType: 'release',
        signature: 'SHA256:${await _calculateBuildSignature()}',
        checksum: await _calculateBuildChecksum(),
        isOfficial: false, // À vérifier
        buildEnvironment: 'development',
      );
    } catch (e) {
      // Retourner des informations par défaut en cas d'erreur
      return BuildInfo(
        version: '1.0.3+3',
        buildNumber: 'dev-001',
        buildDate: DateTime.now().toIso8601String().split('T')[0],
        platform: _getCurrentPlatform(),
        architecture: _getCurrentArchitecture(),
        buildType: 'debug',
        signature: 'SHA256:unknown',
        checksum: 'unknown',
        isOfficial: false,
        buildEnvironment: 'development',
      );
    }
  }

  static String _extractVersionFromPubspec(String pubspecContent) {
    final lines = pubspecContent.split('\n');
    for (final line in lines) {
      if (line.trim().startsWith('version:')) {
        return line.split(':')[1].trim();
      }
    }
    return '1.0.3+3'; // Version par défaut
  }

  static String _getCurrentPlatform() {
    if (Platform.isWindows) return 'windows';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isLinux) return 'linux';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'unknown';
  }

  static String _getCurrentArchitecture() {
    // Simplification - en production, utiliser une vraie détection
    return 'universal';
  }

  static Future<String> _getBuildNumber() async {
    // En production, générer un numéro de build unique
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'build-$timestamp';
  }

  static Future<bool> _verifyBuildSignature(BuildInfo current, BuildInfo official) async {
    try {
      // Vérifier que la signature correspond
      return current.signature == official.signature;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _verifyBuildChecksum(BuildInfo current, BuildInfo official) async {
    try {
      // Vérifier que le checksum correspond
      return current.checksum == official.checksum;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _verifyBuildEnvironment(BuildInfo current, BuildInfo official) async {
    try {
      // Vérifier que l'environnement de build est officiel
      return current.buildEnvironment == official.buildEnvironment ||
             current.buildEnvironment == 'ci/github-actions';
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _verifyBuildManifest(BuildInfo buildInfo) async {
    try {
      final manifestFile = File(BUILD_MANIFEST_FILE);
      if (!await manifestFile.exists()) {
        return false;
      }
      
      final manifestContent = await manifestFile.readAsString();
      final manifest = jsonDecode(manifestContent) as Map<String, dynamic>;
      
      // Vérifier que le manifest correspond au build actuel
      return manifest['buildInfo']['version'] == buildInfo.version &&
             manifest['buildInfo']['buildNumber'] == buildInfo.buildNumber;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _verifyBuildMetadata(BuildInfo current, BuildInfo official) async {
    try {
      // Vérifier les métadonnées clés
      return current.version == official.version &&
             current.platform == official.platform &&
             current.buildType == official.buildType;
    } catch (e) {
      return false;
    }
  }

  static Future<List<String>> _getBuildFiles() async {
    final files = <String>[];
    final libDir = Directory('lib');
    
    if (await libDir.exists()) {
      await for (final entity in libDir.list(recursive: true)) {
        if (entity is File) {
          files.add(entity.path);
        }
      }
    }
    
    return files;
  }

  static Future<Map<String, dynamic>> _getBuildDependencies() async {
    try {
      final pubspecFile = File('pubspec.yaml');
      if (!await pubspecFile.exists()) {
        return {};
      }
      
      final pubspecContent = await pubspecFile.readAsString();
      final lines = pubspecContent.split('\n');
      final dependencies = <String, String>{};
      bool inDependencies = false;
      
      for (final line in lines) {
        if (line.trim() == 'dependencies:') {
          inDependencies = true;
          continue;
        }
        
        if (line.startsWith('dev_dependencies:') || line.startsWith('flutter:')) {
          inDependencies = false;
          continue;
        }
        
        if (inDependencies && line.trim().isNotEmpty && !line.startsWith(' ')) {
          final parts = line.split(':');
          if (parts.length >= 2) {
            dependencies[parts[0].trim()] = parts[1].trim();
          }
        }
      }
      
      return dependencies;
    } catch (e) {
      return {};
    }
  }

  static Future<String> _calculateBuildChecksum() async {
    try {
      final files = await _getBuildFiles();
      final hashes = <String>[];
      
      for (final filePath in files) {
        final file = File(filePath);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final digest = sha256.convert(bytes);
          hashes.add(digest.toString());
        }
      }
      
      final combined = hashes.join('|');
      final digest = sha256.convert(utf8.encode(combined));
      return digest.toString();
    } catch (e) {
      return 'unknown_checksum';
    }
  }

  static Future<String> _createBuildSignature() async {
    try {
      final buildInfo = await _getCurrentBuildInfo();
      final signatureData = '${buildInfo.version}|${buildInfo.buildNumber}|${buildInfo.buildDate}';
      final digest = sha256.convert(utf8.encode(signatureData));
      return 'SHA256:${digest.toString()}';
    } catch (e) {
      return 'SHA256:unknown';
    }
  }

  static Future<String> _calculateBuildSignature() async {
    try {
      final checksum = await _calculateBuildChecksum();
      final digest = sha256.convert(utf8.encode(checksum));
      return digest.toString();
    } catch (e) {
      return 'unknown';
    }
  }

  static Future<String> _signCertificate(BuildVerificationResult verification) async {
    try {
      final data = '${verification.buildInfo.version}|${verification.verificationDate.toIso8601String()}|${verification.isOfficial}';
      final digest = sha256.convert(utf8.encode(data));
      return 'SIGNED:${digest.toString()}';
    } catch (e) {
      return 'UNSIGNED';
    }
  }

  static String _generateCertificateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'BUILD_CERT_$timestamp';
  }

  static String _generateCertificateHash(BuildVerificationResult verification) {
    final data = '${verification.buildInfo.version}|${verification.isOfficial}|${verification.verificationDate.toIso8601String()}';
    final digest = sha256.convert(utf8.encode(data));
    return digest.toString();
  }

  static String _generateBuildQRCode(BuildVerificationResult verification) {
    return jsonEncode({
      'app': 'TUTODECODE',
      'version': verification.buildInfo.version,
      'build': verification.buildInfo.buildNumber,
      'platform': verification.buildInfo.platform,
      'isOfficial': verification.isOfficial,
      'verificationDate': verification.verificationDate.toIso8601String(),
      'certificate': _generateCertificateHash(verification),
    });
  }

  static RiskLevel _calculateBuildRisk(List<String> reasons) {
    if (reasons.isEmpty) return RiskLevel.low;
    if (reasons.length >= 3) return RiskLevel.critical;
    if (reasons.length >= 2) return RiskLevel.high;
    return RiskLevel.medium;
  }
}

/// Informations de build
class BuildInfo {
  final String version;
  final String buildNumber;
  final String buildDate;
  final String platform;
  final String architecture;
  final String buildType;
  final String signature;
  final String checksum;
  final bool isOfficial;
  final String buildEnvironment;

  const BuildInfo({
    required this.version,
    required this.buildNumber,
    required this.buildDate,
    required this.platform,
    required this.architecture,
    required this.buildType,
    required this.signature,
    required this.checksum,
    required this.isOfficial,
    required this.buildEnvironment,
  });

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'buildNumber': buildNumber,
      'buildDate': buildDate,
      'platform': platform,
      'architecture': architecture,
      'buildType': buildType,
      'signature': signature,
      'checksum': checksum,
      'isOfficial': isOfficial,
      'buildEnvironment': buildEnvironment,
    };
  }

  factory BuildInfo.fromJson(Map<String, dynamic> json) {
    return BuildInfo(
      version: json['version'],
      buildNumber: json['buildNumber'],
      buildDate: json['buildDate'],
      platform: json['platform'],
      architecture: json['architecture'],
      buildType: json['buildType'],
      signature: json['signature'],
      checksum: json['checksum'],
      isOfficial: json['isOfficial'],
      buildEnvironment: json['buildEnvironment'],
    );
  }
}

/// Résultat de vérification de build
class BuildVerificationResult {
  final bool isOfficial;
  final BuildInfo buildInfo;
  final BuildInfo? officialBuildInfo;
  final DateTime verificationDate;
  final Map<String, bool> checks;
  final List<String>? reasons;
  final RiskLevel riskLevel;
  final String? error;

  const BuildVerificationResult({
    required this.isOfficial,
    required this.buildInfo,
    this.officialBuildInfo,
    required this.verificationDate,
    required this.checks,
    this.reasons,
    required this.riskLevel,
    this.error,
  });

  Map<String, dynamic> toJson() {
    return {
      'isOfficial': isOfficial,
      'buildInfo': buildInfo.toJson(),
      'officialBuildInfo': officialBuildInfo?.toJson(),
      'verificationDate': verificationDate.toIso8601String(),
      'checks': checks,
      'reasons': reasons,
      'riskLevel': riskLevel.name,
      'error': error,
    };
  }
}

/// Certificat de build
class BuildCertificate {
  final String certificateId;
  final BuildInfo buildInfo;
  final bool isOfficial;
  final DateTime verificationDate;
  final String certificateHash;
  final String qrCodeData;
  final String signature;

  const BuildCertificate({
    required this.certificateId,
    required this.buildInfo,
    required this.isOfficial,
    required this.verificationDate,
    required this.certificateHash,
    required this.qrCodeData,
    required this.signature,
  });

  Map<String, dynamic> toJson() {
    return {
      'certificateId': certificateId,
      'buildInfo': buildInfo.toJson(),
      'isOfficial': isOfficial,
      'verificationDate': verificationDate.toIso8601String(),
      'certificateHash': certificateHash,
      'qrCodeData': qrCodeData,
      'signature': signature,
    };
  }
}

/// Manifest de build
class BuildManifest {
  final BuildInfo buildInfo;
  final List<String> files;
  final Map<String, dynamic> dependencies;
  final String checksum;
  final String signature;
  final DateTime createdAt;

  const BuildManifest({
    required this.buildInfo,
    required this.files,
    required this.dependencies,
    required this.checksum,
    required this.signature,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'buildInfo': buildInfo.toJson(),
      'files': files,
      'dependencies': dependencies,
      'checksum': checksum,
      'signature': signature,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BuildManifest.fromJson(Map<String, dynamic> json) {
    return BuildManifest(
      buildInfo: BuildInfo.fromJson(json['buildInfo']),
      files: List<String>.from(json['files']),
      dependencies: json['dependencies'],
      checksum: json['checksum'],
      signature: json['signature'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

/// Service de vérification de build
class BuildVerificationService {
  static BuildVerificationResult? _lastVerification;
  static DateTime? _lastVerificationTime;
  
  /// Vérifie le build avec cache
  static Future<BuildVerificationResult> verifyBuild({bool forceRefresh = false}) async {
    final now = DateTime.now();
    
    // Utiliser le cache si disponible et récent (moins de 15 minutes)
    if (!forceRefresh && 
        _lastVerification != null && 
        _lastVerificationTime != null && 
        now.difference(_lastVerificationTime!).inMinutes < 15) {
      return _lastVerification!;
    }
    
    // Effectuer une nouvelle vérification
    _lastVerification = await BuildVerification.verifyCurrentBuild();
    _lastVerificationTime = now;
    
    return _lastVerification!;
  }
  
  /// Vérification rapide du build
  static Future<bool> quickBuildCheck() async {
    try {
      final buildInfo = await BuildVerification._getCurrentBuildInfo();
      final officialBuild = BuildVerification.OFFICIAL_BUILDS[buildInfo.version];
      
      return officialBuild != null && 
             buildInfo.version == officialBuild.version &&
             buildInfo.platform == officialBuild.platform;
    } catch (e) {
      return false;
    }
  }
  
  /// Génère un rapport de build complet
  static Future<Map<String, dynamic>> generateBuildReport() async {
    final verification = await verifyBuild();
    final certificate = await BuildVerification.generateBuildCertificate();
    
    return {
      'verification': verification.toJson(),
      'certificate': certificate.toJson(),
      'reportGenerated': DateTime.now().toIso8601String(),
      'summary': {
        'isOfficial': verification.isOfficial,
        'version': verification.buildInfo.version,
        'platform': verification.buildInfo.platform,
        'riskLevel': verification.riskLevel.name,
        'recommendation': verification.isOfficial 
            ? 'Build officiel - Utilisation recommandée'
            : 'Build non officiel - Risque de sécurité',
      },
    };
  }
  
  /// Efface le cache de vérification
  static void clearCache() {
    _lastVerification = null;
    _lastVerificationTime = null;
  }
}
