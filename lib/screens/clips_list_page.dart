import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import '../models/live_campaign.dart';

class MesClipsRepository {
  static const String _key = 'processed_clips';

  static Future<List<String>> getProcessedClips() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  static Future<void> removeClip(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> clips = prefs.getStringList(_key) ?? [];
    clips.remove(path);
    await prefs.setStringList(_key, clips);
  }
}

class ClipsListPage extends StatefulWidget {
  final LiveCampaign campaign;

  const ClipsListPage({super.key, required this.campaign});

  @override
  State<ClipsListPage> createState() => _ClipsListPageState();
}

class _ClipsListPageState extends State<ClipsListPage> {
  late Future<List<String>> _processedClipsFuture;
  List<String> _clipPaths = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _processedClipsFuture = MesClipsRepository.getProcessedClips();
    _loadClips();
  }

  Future<void> _loadClips() async {
    final paths = await MesClipsRepository.getProcessedClips();
    setState(() {
      _clipPaths = paths;
      _loading = false;
    });
  }

  Future<void> _removeClip(String path) async {
    await MesClipsRepository.removeClip(path);
    _loadClips();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mes Clips',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _clipPaths.isEmpty
              ? _buildEmptyState()
              : _buildClipsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.videocam_off_outlined,
              size: 64,
              color: Colors.grey.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Aucun clip enregistré',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vous n\'avez pas encore enregistré de clips sur cet appareil.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClipsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _clipPaths.length,
      itemBuilder: (context, index) {
        final path = _clipPaths[index];
        return _buildClipCard(path);
      },
    );
  }

  Widget _buildClipCard(String path) {
    return Card(
      color: const Color(0xFF1E293B),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: SizedBox(
          width: 80,
          height: 48,
          child: VideoPlayerPreview(path: path),
        ),
        title: Text(
          path.split(Platform.pathSeparator).last,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          path,
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _removeClip(path),
        ),
        onTap: () => _showClipDialog(path),
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

class VideoPlayerPreview extends StatefulWidget {
  final String path;

  const VideoPlayerPreview({super.key, required this.path});

  @override
  State<VideoPlayerPreview> createState() => _VideoPlayerPreviewState();
}

class _VideoPlayerPreviewState extends State<VideoPlayerPreview> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.path))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_controller!.value.isPlaying) {
            _controller!.pause();
          } else {
            _controller!.play();
          }
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),
          if (!_controller!.value.isPlaying)
            const Icon(Icons.play_circle_fill, color: Colors.white, size: 32),
        ],
      ),
    );
  }
}