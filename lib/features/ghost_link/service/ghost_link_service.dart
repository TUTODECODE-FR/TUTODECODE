// ============================================================
import 'dart:math';
import 'dart:async';
// Découverte : broadcast UDP port 54321
// Messages   : TCP socket     port 54322
// ============================================================
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cryptography/cryptography.dart';
import 'package:file_picker/file_picker.dart';

const int _discoveryPort = 54321;
const int _tcpPort = 54322;
const String _broadcastAddr = '255.255.255.255';
const Duration _announceInterval = Duration(seconds: 3);
const Duration _peerTimeout = Duration(seconds: 10);

// ─── Modèles ─────────────────────────────────────────────────
class GhostPeer {
  final String id;
  final String name;
  final String ip;
  final bool isManual;
  DateTime lastSeen;
  bool get isOnline => isManual ? _isManualOnline : DateTime.now().difference(lastSeen) < _peerTimeout;
  bool _isManualOnline = false;
  final bool isPinned;
  final int protocolVersion;

  GhostPeer({
    required this.id,
    required this.name,
    required this.ip,
    required this.lastSeen,
    this.isManual = false,
    this.isPinned = false,
    this.protocolVersion = 1,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'ip': ip, 'isManual': isManual, 'isPinned': isPinned, 'v': protocolVersion,
  };

  factory GhostPeer.fromMap(Map<String, dynamic> map) => GhostPeer(
    id: map['id'], name: map['name'], ip: map['ip'],
    lastSeen: DateTime.now(),
    isManual: map['isManual'] ?? false,
    isPinned: map['isPinned'] ?? false,
    protocolVersion: map['v'] ?? 1,
  );
}

class GhostMessage {
  final String id;
  final String fromId;
  final String fromName;
  final String peerIp; // IP de l'autre côté (pour grouper par pair)
  final String text;
  final DateTime timestamp;
  final bool isOwn;

  GhostMessage({
    required this.id,
    required this.fromId,
    required this.fromName,
    required this.peerIp,
    required this.text,
    required this.timestamp,
    required this.isOwn,
    this.expiry,
    this.fileData,
    this.fileName,
  });

  final DateTime? expiry;
  final String? fileName;
  final Uint8List? fileData;

  bool get isExpired => expiry != null && DateTime.now().isAfter(expiry!);
}

// ─── Service ─────────────────────────────────────────────────
class GhostLinkService extends ChangeNotifier {
  static final GhostLinkService _instance = GhostLinkService._();
  factory GhostLinkService() => _instance;
  GhostLinkService._();

  // State
  bool _running = false;
  bool get isRunning => _running;

  bool _stealthMode = true;
  bool get stealthMode => _stealthMode;

  String _localIp = '';
  String _localId = '';
  String _localName = 'Ghost';
  String get localIp => _localIp;
  String get localName => _localName;

  void setStealthMode(bool val) {
    _stealthMode = val;
    notifyListeners();
  }

  final Map<String, GhostPeer> _peers = {};
  List<GhostPeer> get peers => _peers.values.toList()..sort((a, b) => b.lastSeen.compareTo(a.lastSeen));

  // Messages groupés par IP du pair
  final Map<String, List<GhostMessage>> _conversations = {};
  List<GhostMessage> getConversation(String peerIp) => _conversations[peerIp] ?? [];

  // Sockets
  RawDatagramSocket? _udpSocket;
  ServerSocket? _tcpServer;
  final Map<String, Socket> _activeSockets = {};
  Timer? _announceTimer;
  Timer? _cleanupTimer;

  // ─── Démarrage ──────────────────────────────────────────────
  Future<bool> start({String? name}) async {
    if (_running) return true;
    try {
      // Récupérer IP locale
      final info = NetworkInfo();
      _localIp = await info.getWifiIP() ?? '127.0.0.1';

      // Nom de l'appareil
      final di = DeviceInfoPlugin();
      if (Platform.isMacOS) {
        final mac = await di.macOsInfo;
        _localName = name ?? mac.computerName;
      } else if (Platform.isWindows) {
        final win = await di.windowsInfo;
        _localName = name ?? win.computerName;
      } else if (Platform.isAndroid) {
        _localName = name ?? 'Android';
      } else if (Platform.isIOS) {
        final ios = await di.iosInfo;
        _localName = name ?? ios.name;
      } else {
        _localName = name ?? 'GhostUser';
      }

      // Charger état persistant
      final prefs = await SharedPreferences.getInstance();
      _localId = prefs.getString('ghost_link_local_id') ?? 'ghost_${DateTime.now().millisecondsSinceEpoch}';
      if (!prefs.containsKey('ghost_link_local_id')) await prefs.setString('ghost_link_local_id', _localId);
      await _loadPeers();

      // Socket UDP pour discovery
      _udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, _discoveryPort,
          reuseAddress: true, reusePort: true);
      _udpSocket!.broadcastEnabled = true;
      _udpSocket!.listen(_onUdpData);

      // Serveur TCP pour recevoir les messages
      _tcpServer = await ServerSocket.bind(InternetAddress.anyIPv4, _tcpPort);
      _tcpServer!.listen(_onNewTcpConnection);

      _running = true;
      notifyListeners();

      // Annoncer périodiquement
      _announce();
      _announceTimer = Timer.periodic(_announceInterval, (_) => _announce());
      _cleanupTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        _cleanupPeers();
        _cleanupMessages();
      });

      if (kDebugMode) debugPrint('[GhostLink] Started. IP=$_localIp Name=$_localName');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('[GhostLink] Start failed: $e');
      return false;
    }
  }

  Future<void> stop() async {
    _announceTimer?.cancel();
    _cleanupTimer?.cancel();
    _udpSocket?.close();
    await _tcpServer?.close();
    for (final s in _activeSockets.values) {
      await s.close();
    }
    _activeSockets.clear();
    _peers.removeWhere((key, value) => !value.isPinned); // Keep pinned peers
    _running = false;
    notifyListeners();
  }

  // ─── Persistence ──────────────────────────────────────────────
  static const String _prefKey = 'ghost_link_pinned_peers';
  
  Future<void> _savePeers() async {
    final prefs = await SharedPreferences.getInstance();
    final pinned = _peers.values.where((p) => p.isPinned == true).map((p) => jsonEncode(p.toMap())).toList();
    await prefs.setStringList(_prefKey, pinned);
  }

  Future<void> _loadPeers() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_prefKey) ?? [];
    for (final it in list) {
      try {
        final peer = GhostPeer.fromMap(jsonDecode(it));
        _peers[peer.id] = peer;
      } catch (_) {}
    }
    notifyListeners();
  }

  // ─── Security ───────────────────────────────────────────────
  final _cipher = AesGcm.with256bits();
  // Shared Default Key (should ideally be derived from a room password)
  final _secretKey = SecretKey([
    0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16,
    0x17, 0x18, 0x19, 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x30, 0x31, 0x32,
  ]);

  Future<String> _encrypt(String text) async {
    final nonce = _cipher.newNonce();
    final secretBox = await _cipher.encrypt(
      utf8.encode(text),
      secretKey: _secretKey,
      nonce: nonce,
    );
    return jsonEncode({
      'iv': base64Encode(secretBox.nonce),
      'mac': base64Encode(secretBox.mac.bytes),
      'ct': base64Encode(secretBox.cipherText),
    });
  }

  Future<String> _decrypt(String raw) async {
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final secretBox = SecretBox(
        base64Decode(data['ct']),
        nonce: base64Decode(data['iv']),
        mac: Mac(base64Decode(data['mac'])),
      );
      final decrypted = await _cipher.decrypt(secretBox, secretKey: _secretKey);
      return utf8.decode(decrypted);
    } catch (e) {
      if (kDebugMode) debugPrint('[GhostLink] Decrypt failed: $e');
      return '';
    }
  }

  // ─── Discovery UDP ───────────────────────────────────────────
  void _announce() {
    if (_udpSocket == null || _stealthMode) return;
    final msg = jsonEncode({'type': 'announce', 'id': _localId, 'name': _localName, 'ip': _localIp});
    final bytes = utf8.encode(msg);
    _udpSocket!.send(bytes, InternetAddress(_broadcastAddr), _discoveryPort);
  }

  void _onUdpData(RawSocketEvent event) {
    if (event != RawSocketEvent.read) return;
    final dg = _udpSocket?.receive();
    if (dg == null) return;
    try {
      final raw = utf8.decode(dg.data);
      final data = jsonDecode(raw) as Map<String, dynamic>;
      if (data['type'] != 'announce') return;
      final id = data['id'] as String;
      final ip = data['ip'] as String;
      if (id == _localId) return; // Ignorer soi-même
      if (_peers.containsKey(id)) {
        _peers[id]!.lastSeen = DateTime.now();
      } else {
        _peers[id] = GhostPeer(id: id, name: data['name'] as String, ip: ip, lastSeen: DateTime.now());
        if (kDebugMode) debugPrint('[GhostLink] Peer found: ${data['name']} @ $ip');
      }
      notifyListeners();
    } catch (_) {}
  }

  // ─── Manual Peers ───────────────────────────────────────────
  Future<void> addManualPeer(String ip, String name) async {
    final id = 'manual_$ip';
    final peer = GhostPeer(
      id: id,
      name: name.isEmpty ? 'Peer ($ip)' : name,
      ip: ip,
      lastSeen: DateTime.now(),
      isManual: true,
      isPinned: true, // Auto-pin manual IPs for stability
    );
    _peers[id] = peer;
    await _savePeers();
    notifyListeners();
    await verifyPeerConnection(ip);
  }

  Future<void> togglePin(String peerId) async {
    if (_peers.containsKey(peerId)) {
      final p = _peers[peerId]!;
      _peers[peerId] = GhostPeer(
        id: p.id, name: p.name, ip: p.ip,
        lastSeen: p.lastSeen,
        isManual: p.isManual,
        isPinned: !p.isPinned,
      );
      await _savePeers();
      notifyListeners();
    }
  }

  Future<bool> verifyPeerConnection(String ip) async {
    final id = 'manual_$ip';
    if (!_peers.containsKey(id)) return false;
    
    try {
      final socket = await Socket.connect(ip, _tcpPort, timeout: const Duration(seconds: 2));
      await socket.close();
      _peers[id]!._isManualOnline = true;
      _peers[id]!.lastSeen = DateTime.now();
      notifyListeners();
      return true;
    } catch (_) {
      _peers[id]!._isManualOnline = false;
      notifyListeners();
      return false;
    }
  }

  void _cleanupPeers() {
    final before = _peers.length;
    _peers.removeWhere((_, peer) => !peer.isManual && !peer.isOnline);
    // For manual peers, we just update status periodically
    for (final p in _peers.values.where((p) => p.isManual)) {
       verifyPeerConnection(p.ip);
    }
    if (_peers.length != before) notifyListeners();
  }

  void _cleanupMessages() {
    bool changed = false;
    for (final ip in _conversations.keys) {
      final list = _conversations[ip]!;
      final count = list.length;
      list.removeWhere((m) => m.isExpired);
      if (list.length != count) changed = true;
    }
    if (changed) notifyListeners();
  }

  // ─── Messaging TCP ───────────────────────────────────────────
  void _onNewTcpConnection(Socket socket) {
    final remoteIp = socket.remoteAddress.address;
    _setupSocket(socket, remoteIp);
    // Send our handshake first
    _sendHandshake(socket);
  }

  void _setupSocket(Socket socket, String remoteIp) {
    _activeSockets[remoteIp] = socket;
    final buffer = StringBuffer();
    socket.listen(
      (bytes) async {
        buffer.write(utf8.decode(bytes));
        final raw = buffer.toString();
        if (raw.contains('\n')) {
          final lines = raw.split('\n');
          for (var i = 0; i < lines.length - 1; i++) {
            await _handleIncomingPacket(lines[i], remoteIp, socket);
          }
          buffer.clear();
          if (lines.last.isNotEmpty) buffer.write(lines.last);
        }
      },
      onDone: () { _activeSockets.remove(remoteIp); },
      onError: (_) { _activeSockets.remove(remoteIp); },
      cancelOnError: false,
    );
  }

  Future<void> _sendHandshake(Socket socket) async {
    final packet = {
      'type': 'handshake',
      'id': _localId,
      'name': _localName,
      'v': 2, // Protocol version 2 (Hardened)
    };
    socket.write('${jsonEncode(packet)}\n');
  }

  Future<void> _handleIncomingPacket(String raw, String senderIp, Socket socket) async {
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final type = data['type'] as String;

      switch (type) {
        case 'handshake':
          final id = data['id'] as String;
          final name = data['name'] as String;
          final version = data['v'] as int? ?? 1;
          if (id != _localId) {
            _peers[id] = GhostPeer(id: id, name: name, ip: senderIp, lastSeen: DateTime.now(), protocolVersion: version);
            notifyListeners();
          }
          break;
        case 'secure_msg':
          final encrypted = data['data'] as String;
          final decrypted = await _decrypt(encrypted);
          if (decrypted.isNotEmpty) {
             _handleDecryptedMessage(decrypted, senderIp);
             // Send ACK
             _sendPacket(socket, {'type': 'ack', 'id': jsonDecode(decrypted)['id']}, encrypt: false);
          }
          break;
        case 'ack':
          if (kDebugMode) debugPrint('[GhostLink] ACK received for msg ${data['id']}');
          break;
        case 'req_info':
          _sendSystemInfo(socket);
          break;
        case 'info_res':
          _handleSystemInfoResponse(data['data'], senderIp);
          break;
        case 'file_meta':
          _handleFileMeta(data, senderIp);
          break;
        case 'file_chunk':
          _handleFileChunk(data, senderIp);
          break;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[GhostLink] Packet error: $e');
    }
  }

  void _sendSystemInfo(Socket socket) {
    final info = {
      'os': Platform.operatingSystem,
      'version': Platform.operatingSystemVersion,
      'cpuCount': Platform.numberOfProcessors,
      'mem': 'Local device stats', // Placeholder for more advanced metrics
      'ts': DateTime.now().millisecondsSinceEpoch,
    };
    _sendPacket(socket, {'type': 'info_res', 'data': info});
  }

  void _handleSystemInfoResponse(dynamic data, String senderIp) {
     // Notify UI with system info
     if (kDebugMode) debugPrint('[GhostLink] System info from $senderIp: $data');
  }

  void _handleFileMeta(Map<String, dynamic> data, String senderIp) {
    _conversations.putIfAbsent(senderIp, () => []).add(GhostMessage(
      id: data['id'],
      fromId: data['fromId'],
      fromName: data['fromName'],
      peerIp: senderIp,
      text: 'Fichier entrant : ${data['name']} (${data['size']} octets)',
      timestamp: DateTime.now(),
      isOwn: false,
      fileName: data['name'],
    ));
    notifyListeners();
  }

  void _handleFileChunk(Map<String, dynamic> data, String senderIp) {
    // In a real implementation, we'd append to a file or buffer.
    // For now, we just log it to verify the protocol.
    if (kDebugMode) debugPrint('[GhostLink] Chunk received from $senderIp');
  }

  void _handleDecryptedMessage(String decrypted, String senderIp) {
    try {
      final data = jsonDecode(decrypted) as Map<String, dynamic>;
      final msg = GhostMessage(
        id: data['id'] as String,
        fromId: data['fromId'] as String,
        fromName: data['fromName'] as String,
        peerIp: senderIp,
        text: data['text'] as String,
        timestamp: DateTime.fromMillisecondsSinceEpoch(data['ts'] as int),
        isOwn: false,
        expiry: data.containsKey('expiry') ? DateTime.fromMillisecondsSinceEpoch(data['expiry'] as int) : null,
        fileName: data['fileName'] as String?,
      );
      // Éviter les doublons
      final conv = _conversations.putIfAbsent(senderIp, () => []);
      if (!conv.any((m) => m.id == msg.id)) {
        conv.add(msg);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _sendPacket(Socket socket, Map<String, dynamic> packet, {bool encrypt = true}) async {
    if (encrypt) {
      final raw = jsonEncode(packet);
      final encrypted = await _encrypt(raw);
      socket.write('${jsonEncode({'type': 'secure_msg', 'data': encrypted})}\n');
    } else {
      socket.write('${jsonEncode(packet)}\n');
    }
  }

  Future<bool> sendMessage(GhostPeer peer, String text, {Duration? expiry}) async {
    try {
      Socket? socket = _activeSockets[peer.ip];
      if (socket == null) {
        socket = await Socket.connect(peer.ip, _tcpPort, timeout: const Duration(seconds: 4));
        _setupSocket(socket, peer.ip);
        await _sendHandshake(socket);
        await Future.delayed(const Duration(milliseconds: 200)); 
      }

      final msgId = DateTime.now().millisecondsSinceEpoch.toString();
      final packet = {
        'id': msgId,
        'fromId': _localId,
        'fromName': _localName,
        'text': text,
        'ts': DateTime.now().millisecondsSinceEpoch,
        if (expiry != null) 'expiry': DateTime.now().add(expiry).millisecondsSinceEpoch,
      };

      await _sendPacket(socket, packet);

      final msg = GhostMessage(
        id: msgId,
        fromId: _localId,
        fromName: _localName,
        peerIp: peer.ip,
        text: text,
        timestamp: DateTime.now(),
        isOwn: true,
        expiry: expiry != null ? DateTime.now().add(expiry) : null,
      );
      _conversations.putIfAbsent(peer.ip, () => []).add(msg);
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('[GhostLink] Send failed: $e');
      return false;
    }
  }

  Future<void> requestRemoteInfo(GhostPeer peer) async {
    final socket = _activeSockets[peer.ip];
    if (socket != null) {
      await _sendPacket(socket, {'type': 'req_info'});
    }
  }

  Future<void> sendFile(GhostPeer peer) async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final socket = _activeSockets[peer.ip];
    if (socket == null) return;

    final msgId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // 1. Send metadata
    await _sendPacket(socket, {
      'type': 'file_meta',
      'id': msgId,
      'name': file.name,
      'size': file.size,
      'fromId': _localId,
      'fromName': _localName,
    });

    // 2. Send in chunks (simulated for now with the first few bytes)
    if (file.bytes != null) {
      final chunk = file.bytes!.sublist(0, min(1024, file.size));
      await _sendPacket(socket, {
        'type': 'file_chunk',
        'id': msgId,
        'data': base64Encode(chunk),
      });
    }

    _conversations.putIfAbsent(peer.ip, () => []).add(GhostMessage(
      id: msgId,
      fromId: _localId,
      fromName: _localName,
      peerIp: peer.ip,
      text: 'Fichier envoyé : ${file.name}',
      timestamp: DateTime.now(),
      isOwn: true,
      fileName: file.name,
    ));
    notifyListeners();
  }
}
