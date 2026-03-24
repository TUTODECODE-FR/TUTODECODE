// ============================================================
// AI Tutor Screen — Interface de l'assistant IA local
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:tutodecode/core/theme/app_theme.dart';
import 'package:tutodecode/core/providers/shell_provider.dart';
import 'package:tutodecode/features/ghost_ai/providers/ai_tutor_provider.dart';

class AiTutorScreen extends StatefulWidget {
  const AiTutorScreen({super.key});

  @override
  State<AiTutorScreen> createState() => _AiTutorScreenState();
}

class _AiTutorScreenState extends State<AiTutorScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _messageController = TextEditingController();
  final _topicController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShellProvider>().updateShell(
        title: 'Assistant IA',
        showBackButton: true,
        actions: [],
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    _topicController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AiTutorProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            _buildConnectionBar(provider),
            if (!provider.isTutoring) _buildWelcomeScreen(provider),
            if (provider.isTutoring) _buildTutorInterface(provider),
          ],
        );
      },
    );
  }

  Widget _buildConnectionBar(AiTutorProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TdcColors.surface,
        border: Border(bottom: BorderSide(color: TdcColors.border)),
      ),
      child: Row(
        children: [
          Icon(
            provider.isConnected ? Icons.cloud_done : Icons.cloud_off,
            color: provider.isConnected ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              provider.isConnected 
                  ? 'Connecté à Ollama (${provider.selectedModel})'
                  : 'Hors ligne - Ollama non disponible',
              style: TextStyle(
                color: provider.isConnected ? TdcColors.textSecondary : Colors.red,
                fontSize: 12,
              ),
            ),
          ),
          if (provider.errorMessage != null && provider.errorMessage!.isNotEmpty) ...[
            const SizedBox(width: 8),
            Icon(Icons.warning, color: Colors.orange, size: 16),
            const SizedBox(width: 4),
            Expanded(
              flex: 2,
              child: Text(
                provider.errorMessage!,
                style: const TextStyle(color: Colors.orange, fontSize: 10),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          if (!provider.isConnected)
            ElevatedButton.icon(
              onPressed: provider.isLoading ? null : () => provider.checkOllamaConnection(),
              icon: provider.isLoading 
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.refresh),
              label: const Text('Reconnecter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size.zero,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWelcomeScreen(AiTutorProvider provider) {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildNewSessionTab(provider),
          _buildSessionsTab(provider),
          _buildSettingsTab(provider),
        ],
      ),
    );
  }

  Widget _buildNewSessionTab(AiTutorProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nouvelle Session de Tutorat',
            style: TextStyle(
              color: TdcColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choisissez un sujet et démarrez une session d\'apprentissage personnalisée avec votre assistant IA.',
            style: TextStyle(color: TdcColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 32),
          
          // Sélection du mode
          const Text(
            'Mode de Tutorat',
            style: TextStyle(
              color: TdcColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildModeSelector(provider),
          
          const SizedBox(height: 32),
          
          // Sujet
          const Text(
            'Sujet d\'Apprentissage',
            style: TextStyle(
              color: TdcColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _topicController,
            style: const TextStyle(color: TdcColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Ex: Linux, Réseaux, Sécurité...',
              prefixIcon: const Icon(Icons.topic, size: 20),
              filled: true,
              fillColor: TdcColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Suggestions
          const Text(
            'Sujets Populaires',
            style: TextStyle(
              color: TdcColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: provider.suggestedTopics.map((topic) {
              return ActionChip(
                label: Text(topic),
                onPressed: () => _topicController.text = topic,
                backgroundColor: TdcColors.surfaceAlt.withOpacity(0.3),
                labelStyle: const TextStyle(color: TdcColors.textSecondary),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 32),
          
          // Bouton de démarrage
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _topicController.text.isNotEmpty && provider.isConnected
                  ? () => _startNewSession(provider)
                  : null,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Démarrer la Session'),
              style: ElevatedButton.styleFrom(
                backgroundColor: TdcColors.accent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector(AiTutorProvider provider) {
    return Column(
      children: TutorMode.values.map((mode) {
        final isSelected = provider.currentMode == mode;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => provider.setTutorMode(mode),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? mode.color.withOpacity(0.1) : TdcColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? mode.color.withOpacity(0.3) : TdcColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      mode.icon,
                      color: isSelected ? mode.color : TdcColors.textMuted,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mode.displayName,
                            style: TextStyle(
                              color: isSelected ? mode.color : TdcColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mode.description,
                            style: const TextStyle(
                              color: TdcColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle, color: mode.color, size: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSessionsTab(AiTutorProvider provider) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text(
                'Sessions Précédentes',
                style: TextStyle(
                  color: TdcColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (provider.sessions.isNotEmpty)
                TextButton.icon(
                  onPressed: () => _showClearSessionsDialog(provider),
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text('Tout effacer'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
            ],
          ),
        ),
        Expanded(
          child: provider.sessions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, color: TdcColors.textMuted, size: 48),
                      const SizedBox(height: 16),
                      const Text(
                        'Aucune session précédente',
                        style: TextStyle(color: TdcColors.textMuted, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Démarrez votre première session de tutorat',
                        style: TextStyle(color: TdcColors.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.sessions.length,
                  itemBuilder: (context, index) {
                    return _buildSessionCard(provider.sessions[index], provider);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSessionCard(TutorSession session, AiTutorProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: TdcColors.surface,
      child: InkWell(
        onTap: () => provider.selectSession(session),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: session.mode.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      session.mode.displayName,
                      style: TextStyle(
                        color: session.mode.color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: TdcColors.textMuted, size: 16),
                    onSelected: (value) {
                      if (value == 'delete') {
                        provider.deleteSession(session.id);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 16),
                            SizedBox(width: 8),
                            Text('Supprimer'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                session.title,
                style: const TextStyle(
                  color: TdcColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                session.topic,
                style: const TextStyle(
                  color: TdcColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.message, color: TdcColors.textMuted, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${session.messages.length} messages',
                    style: const TextStyle(
                      color: TdcColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.schedule, color: TdcColors.textMuted, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(session.updatedAt ?? session.createdAt),
                    style: const TextStyle(
                      color: TdcColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTab(AiTutorProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Paramètres IA',
            style: TextStyle(
              color: TdcColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // URL Ollama
          const Text(
            'URL Ollama',
            style: TextStyle(
              color: TdcColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: 'http://localhost:11434',
            style: const TextStyle(color: TdcColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'http://localhost:11434',
              prefixIcon: const Icon(Icons.link, size: 20),
              filled: true,
              fillColor: TdcColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onFieldSubmitted: (value) => provider.updateOllamaUrl(value),
          ),
          
          const SizedBox(height: 24),
          
          // Modèle sélectionné
          const Text(
            'Modèle IA',
            style: TextStyle(
              color: TdcColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TdcColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: TdcColors.border),
            ),
            child: provider.availableModels.isEmpty
                ? const Text(
                    'Aucun modèle disponible',
                    style: TextStyle(color: TdcColors.textMuted),
                  )
                : DropdownButton<String>(
                    value: provider.selectedModel,
                    isExpanded: true,
                    items: provider.availableModels.map((model) {
                      return DropdownMenuItem(
                        value: model,
                        child: Text(model),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) provider.selectModel(value);
                    },
                  ),
          ),
          
          const SizedBox(height: 32),
          
          // Statistiques
          const Text(
            'Statistiques d\'Utilisation',
            style: TextStyle(
              color: TdcColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatistics(provider),
        ],
      ),
    );
  }

  Widget _buildStatistics(AiTutorProvider provider) {
    final stats = provider.getStatistics();
    
    return Card(
      color: TdcColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatRow('Sessions totales', '${stats['totalSessions']}'),
            _buildStatRow('Messages échangés', '${stats['totalMessages']}'),
            _buildStatRow('Sujets couverts', '${stats['topicsCovered']}'),
            _buildStatRow('Messages/session', stats['averageMessagesPerSession']),
            _buildStatRow('Mode préféré', stats['mostUsedMode']),
            if (stats['lastActivity'] != null)
              _buildStatRow('Dernière activité', _formatDate(stats['lastActivity'])),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: TdcColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: TdcColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorInterface(AiTutorProvider provider) {
    return Expanded(
      child: Column(
        children: [
          _buildTutorHeader(provider),
          Expanded(
            child: _buildMessagesArea(provider),
          ),
          _buildInputArea(provider),
        ],
      ),
    );
  }

  Widget _buildTutorHeader(AiTutorProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TdcColors.surfaceAlt.withOpacity(0.3),
        border: Border(bottom: BorderSide(color: TdcColors.border)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: provider.currentMode.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              provider.currentMode.displayName,
              style: TextStyle(
                color: provider.currentMode.color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.currentSession?.title ?? 'Session',
                  style: const TextStyle(
                    color: TdcColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  provider.currentTopic ?? 'Sujet',
                  style: const TextStyle(
                    color: TdcColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showSessionOptions(provider),
            icon: const Icon(Icons.more_vert, color: TdcColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesArea(AiTutorProvider provider) {
    return Container(
      color: const Color(0xFF0D1117),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: provider.currentMessages.length,
        itemBuilder: (context, index) {
          final message = provider.currentMessages[index];
          return _buildMessageBubble(message, provider);
        },
      ),
    );
  }

  Widget _buildMessageBubble(TutorMessage message, AiTutorProvider provider) {
    final isUser = message.isFromUser;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: TdcColors.accent,
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isUser ? TdcColors.accent : TdcColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(16).copyWith(
                      bottomLeft: isUser ? Radius.circular(16) : Radius.circular(4),
                      bottomRight: isUser ? Radius.circular(4) : Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      color: isUser ? Colors.white : TdcColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(message.timestamp),
                      style: const TextStyle(
                        color: TdcColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                    if (!isUser) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => provider.regenerateResponse(message.id),
                        child: const Icon(
                          Icons.refresh,
                          color: TdcColors.textMuted,
                          size: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea(AiTutorProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TdcColors.surface,
        border: Border(top: BorderSide(color: TdcColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: TdcColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Posez votre question...',
                filled: true,
                fillColor: TdcColors.surfaceAlt.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _isComposing = value.isNotEmpty;
                });
              },
              onSubmitted: (value) => _sendMessage(provider),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: _isComposing && !provider.isLoading
                ? () => _sendMessage(provider)
                : null,
            backgroundColor: _isComposing ? TdcColors.accent : TdcColors.surfaceAlt,
            mini: true,
            child: provider.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _startNewSession(AiTutorProvider provider) {
    final topic = _topicController.text.trim();
    if (topic.isNotEmpty) {
      provider.createNewSession('Session: $topic', topic);
      _topicController.clear();
    }
  }

  void _sendMessage(AiTutorProvider provider) {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      provider.sendMessage(message);
      _messageController.clear();
      setState(() => _isComposing = false);
      
      // Scroll vers le bas
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _showSessionOptions(AiTutorProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: TdcColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: TdcColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.history, color: TdcColors.textSecondary),
                  title: const Text('Retour aux sessions'),
                  onTap: () {
                    Navigator.pop(context);
                    provider.clearCurrentSession();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Supprimer cette session'),
                  onTap: () {
                    Navigator.pop(context);
                    if (provider.currentSession != null) {
                      provider.deleteSession(provider.currentSession!.id);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showClearSessionsDialog(AiTutorProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TdcColors.surface,
        title: const Text('Effacer toutes les sessions?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implémenter la suppression de toutes les sessions
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Effacer tout'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Aujourd\'hui à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Hier à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
