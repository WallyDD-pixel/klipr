import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import '../../models/local_clip.dart';
import 'package:app/screens/tiktok_login_page.dart';
import '../live_clips_page.dart';

/// Page des clips favoris de l'utilisateur
class ClipsPage extends StatefulWidget {
  const ClipsPage({super.key});

  @override
  State<ClipsPage> createState() => _ClipsPageState();
}

class _ClipsPageState extends State<ClipsPage> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  List<LocalClip> _clips = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadClips();
  }

  Future<void> _loadClips() async {
    final clips = await MesClipsRepository.getProcessedClips();
    setState(() {
      _clips = clips;
      _loading = false;
    });
  }

  Future<void> _removeClip(String path) async {
    await MesClipsRepository.removeClip(path);
    _loadClips();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F11),
      body: SafeArea(
        child: Column(
          children: [
            // Header avec titre
            _buildHeader(),
            
            // Tabs
            _buildTabBar(),
            
            // Contenu des tabs
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSavedClips(),
                  _buildWatchLater(),
                  _buildHistory(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Text(
            'Mes Clips',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey[100],
            ),
          ),
          const Spacer(),
          Builder(
            builder: (context) => ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TikTokLoginPage(),
                  ),
                );
              },
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Se déconnecter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F23),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF6366F1),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[400],
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        tabs: const [
          Tab(text: 'Sauvegardés'),
          Tab(text: 'À regarder'),
          Tab(text: 'Historique'),
        ],
      ),
    );
  }

  Widget _buildSavedClips() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_clips.isEmpty) {
      return _buildEmptyState(
        icon: Icons.bookmark_border_rounded,
        title: 'Aucun clip enregistré',
        subtitle: 'Enregistrez vos clips pour les retrouver ici',
      );
    }
    // Regrouper par liveId + creator
    final Map<String, List<LocalClip>> grouped = {};
    for (var clip in _clips) {
      final key = '${clip.liveId}__${clip.creator}';
      grouped.putIfAbsent(key, () => []).add(clip);
    }
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      children: grouped.entries.map((entry) {
        final first = entry.value.first;
        final count = entry.value.length;
        final hasThumbnail = first.liveThumbnail != null && first.liveThumbnail!.isNotEmpty;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showLiveClips(entry.key, entry.value),
            splashColor: const Color(0xFF6366F1).withOpacity(0.08),
            highlightColor: const Color(0xFF6366F1).withOpacity(0.04),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF20223A),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.13),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.13), width: 1.2),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: hasThumbnail
                          ? Image.network(
                              first.liveThumbnail!,
                              width: 48,
                              height: 32,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 48,
                                height: 32,
                                color: Colors.blueGrey.shade800,
                                child: Icon(Icons.videocam, color: Colors.white, size: 18),
                              ),
                            )
                          : Container(
                              width: 48,
                              height: 32,
                              color: Colors.blueGrey.shade800,
                              child: Icon(Icons.videocam, color: Colors.white, size: 18),
                            ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            first.liveTitle,
                            style: const TextStyle(
                              color: Color(0xFFB3C7F7),
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              letterSpacing: 0.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.person, color: Color(0xFF6EE7B7), size: 14),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  first.creator,
                                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          // Infos détaillées sur le créateur
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: Color(0xFF38BDF8), size: 13),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'ID: A0${first.liveId}  •  Clips: $count',
                                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w400),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.13),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(Icons.arrow_forward_ios, color: Color(0xFF6366F1), size: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showLiveClips(String liveId, List<LocalClip> clips) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LiveClipsPage(liveId: liveId, clips: clips),
      ),
    );
  }

  Widget _buildWatchLater() {
    return _buildEmptyState(
      icon: Icons.watch_later_outlined,
      title: 'Liste "À regarder" vide',
      subtitle: 'Ajoutez des clips à votre liste pour les regarder plus tard',
    );
  }

  Widget _buildHistory() {
    return _buildEmptyState(
      icon: Icons.history_rounded,
      title: 'Historique vide',
      subtitle: 'Votre historique de visionnage apparaîtra ici',
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: const Color(0xFF6366F1).withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 50,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClipItem(Map<String, String> clip) {
    Color platformColor;
    IconData platformIcon;
    
    switch (clip['platform']) {
      case 'Twitch':
        platformColor = const Color(0xFF9146FF);
        platformIcon = Icons.live_tv;
        break;
      case 'YouTube':
        platformColor = const Color(0xFFFF0000);
        platformIcon = Icons.play_circle_fill;
        break;
      case 'Kick':
        platformColor = const Color(0xFF53FC18);
        platformIcon = Icons.sports_esports;
        break;
      default:
        platformColor = Colors.grey;
        platformIcon = Icons.play_circle_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F23),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          // Ouvrir le clip
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Thumbnail
              Container(
                width: 120,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    // Image placeholder
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.play_circle_outline,
                        color: Colors.grey[500],
                        size: 32,
                      ),
                    ),
                    // Durée
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          clip['duration']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Informations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre
                    Text(
                      clip['title']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Créateur avec badge plateforme
                    Row(
                      children: [
                        Icon(
                          platformIcon,
                          color: platformColor,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            clip['creator']!,
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Stats
                    Row(
                      children: [
                        Text(
                          '${clip['views']} vues',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• ${clip['date']}',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Actions
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'remove':
                      // Retirer des sauvegardés
                      break;
                    case 'share':
                      // Partager
                      break;
                    case 'watch_later':
                      // Ajouter à "À regarder"
                      break;
                  }
                },
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: Colors.grey[400],
                  size: 20,
                ),
                color: const Color(0xFF2A2A2E),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.bookmark_remove, color: Colors.red, size: 20),
                        SizedBox(width: 12),
                        Text('Retirer', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'watch_later',
                    child: Row(
                      children: [
                        Icon(Icons.watch_later, color: Colors.orange, size: 20),
                        SizedBox(width: 12),
                        Text('À regarder plus tard', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(Icons.share, color: Colors.blue, size: 20),
                        SizedBox(width: 12),
                        Text('Partager', style: TextStyle(color: Colors.white)),
                      ],
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

  Widget _buildClipItemLocal(LocalClip clip) {
    final isValidPath = clip.path.isNotEmpty && (clip.path.startsWith('/') || clip.path.contains(':'));
    final hasThumbnail = clip.liveThumbnail != null && clip.liveThumbnail!.isNotEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF181C2F),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.blueGrey.shade900, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Row(
          children: [
            // Miniature vidéo ou icône
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: hasThumbnail
                  ? Image.network(
                      clip.liveThumbnail!,
                      width: 44,
                      height: 28,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 44,
                        height: 28,
                        color: Colors.blueGrey.shade800,
                        child: Icon(Icons.videocam, color: Colors.white, size: 16),
                      ),
                    )
                  : (isValidPath
                      ? SizedBox(
                          width: 44,
                          height: 28,
                          child: VideoPlayerPreview(path: clip.path),
                        )
                      : Container(
                          width: 44,
                          height: 28,
                          color: Colors.blueGrey.shade800,
                          child: Icon(Icons.videocam_off, color: Colors.white, size: 16),
                        )),
            ),
            const SizedBox(width: 8),
            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    clip.liveTitle,
                    style: const TextStyle(
                      color: Color(0xFFB3C7F7),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Icon(Icons.person, color: Color(0xFF6EE7B7), size: 12),
                      const SizedBox(width: 2),
                      Text(
                        clip.creator,
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.video_file, color: Color(0xFF818CF8), size: 11),
                      const SizedBox(width: 2),
                      Text(
                        clip.path.split(Platform.pathSeparator).last,
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 9),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Actions
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.play_circle_fill, color: Color(0xFF38BDF8), size: 18),
                  onPressed: isValidPath ? () => _showClipDialog(clip.path) : null,
                  tooltip: 'Prévisualiser',
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Color(0xFFF87171), size: 16),
                  onPressed: () => _removeClip(clip.path),
                  tooltip: 'Supprimer',
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showClipDialog(String path) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(path.split(Platform.pathSeparator).last, style: const TextStyle(color: Colors.white)),
        content: SizedBox(
          width: 300,
          height: 200,
          child: VideoPlayerPreview(path: path),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ...existing code...

class MesClipsRepository {
  static const String _key = 'processed_clips_v2';
  static Future<List<LocalClip>> getProcessedClips() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> raw = prefs.getStringList(_key) ?? [];
    return raw.map((e) => LocalClip.fromJson(Map<String, dynamic>.from(Uri.splitQueryString(e)))).toList();
  }
  static Future<void> addClip(LocalClip clip) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> raw = prefs.getStringList(_key) ?? [];
    raw.add(Uri(queryParameters: clip.toJson()).query);
    await prefs.setStringList(_key, raw);
  }
  static Future<void> removeClip(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> raw = prefs.getStringList(_key) ?? [];
    raw.removeWhere((e) => Map<String, dynamic>.from(Uri.splitQueryString(e))['path'] == path);
    await prefs.setStringList(_key, raw);
  }
}

class VideoPlayerPreview extends StatefulWidget {
  final String path;

  const VideoPlayerPreview({super.key, required this.path});

  @override
  State<VideoPlayerPreview> createState() => _VideoPlayerPreviewState();
}

class _VideoPlayerPreviewState extends State<VideoPlayerPreview> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.path));
    _initializeVideoPlayerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          );
        } else {
          return Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              ),
            ),
          );
        }
      },
    );
  }
}