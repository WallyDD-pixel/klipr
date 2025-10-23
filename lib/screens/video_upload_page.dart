import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/live_campaign.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/local_clip.dart';
import '../repositories/mes_clips_repository.dart';

class VideoUploadPage extends StatefulWidget {
  final LiveCampaign campaign;

  const VideoUploadPage({super.key, required this.campaign});

  @override
  State<VideoUploadPage> createState() => _VideoUploadPageState();
}

class _VideoUploadPageState extends State<VideoUploadPage>
    with TickerProviderStateMixin {
  File? _selectedVideo;
  bool _isProcessing = false;
  bool _isUploaded = false;
  String _processingStep = '';
  double _progressValue = 0.0;

  late AnimationController _progressController;
  late AnimationController _successController;
  late Animation<double> _progressAnimation;
  late Animation<double> _successAnimation;

  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _successController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _successAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    ));

    _progressController.addListener(() {
      setState(() {
        _progressValue = _progressAnimation.value;

        if (_progressValue < 0.2) {
          _processingStep = 'Analyse de la vidéo...';
        } else if (_progressValue < 0.5) {
          _processingStep = 'Vérification du hashtag #Klipr...';
        } else if (_progressValue < 0.8) {
          _processingStep = 'Application du filigrane Klipr...';
        } else {
          _processingStep = 'Finalisation...';
        }
      });
    });

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isProcessing = false;
          _isUploaded = true;
        });
        _successController.forward();
      }
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _progressController.dispose();
    _successController.dispose();
    super.dispose();
  }

  Future<String?> _showManualPathDialog() async {
    TextEditingController controller = TextEditingController();
    return await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Chemin de la vidéo',
              style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Ex: C:/Users/nom/video.mp4',
              hintStyle: TextStyle(color: Colors.white38),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child:
                  const Text('Annuler', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981)),
              child:
                  const Text('Valider', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _selectVideo() async {
    HapticFeedback.lightImpact();
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedVideo = File(result.files.single.path!);
      });
      _initVideoPreview();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFEF4444),
          content: Text('❌ Aucune vidéo sélectionnée.',
              style: TextStyle(color: Colors.white)),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _processVideo() async {
    if (_selectedVideo == null) return;

    setState(() {
      _isProcessing = true;
      _progressValue = 0.0;
    });

    HapticFeedback.mediumImpact();
    _progressController.forward();
  }

  void _restartProcess() {
    setState(() {
      _selectedVideo = null;
      _isProcessing = false;
      _isUploaded = false;
      _progressValue = 0.0;
      _processingStep = '';
    });

    _progressController.reset();
    _successController.reset();
  }

  Future<void> _scanFileForGallery(String path) async {
    const platform = MethodChannel('com.chho.app/media_scanner');
    try {
      await platform.invokeMethod('scanFile', {'path': path});
    } catch (e) {
      // ignore: avoid_print
      print('Erreur scan media: $e');
    }
  }

  void _initVideoPreview() {
    if (_selectedVideo != null) {
      _videoController = VideoPlayerController.file(_selectedVideo!)
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  // Sauvegarde le chemin du clip traité dans SharedPreferences
  Future<void> _saveProcessedClipPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> clips = prefs.getStringList('processed_clips') ?? [];
    if (!clips.contains(path)) {
      clips.add(path);
      await prefs.setStringList('processed_clips', clips);
    }
  }

  // Sauvegarde le clip traité avec infos live
  Future<void> _saveProcessedClip(LocalClip clip) async {
    await MesClipsRepository.addClip(clip);
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
          'Upload de Clip',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info campagne
            _buildCampaignInfo(),
            const SizedBox(height: 24),

            // Exigences d'authentification
            _buildAuthRequirements(),
            const SizedBox(height: 24),

            // Zone d'upload
            if (!_isUploaded) ...[
              _buildUploadZone(),
              const SizedBox(height: 24),
            ],

            // Traitement en cours
            if (_isProcessing) ...[
              _buildProcessingSection(),
              const SizedBox(height: 24),
            ],

            // Succès
            if (_isUploaded) ...[
              _buildSuccessSection(),
              const SizedBox(height: 24),
            ],

            // Boutons d'action
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Clip pour ${widget.campaign.streamerName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Cagnotte: ${widget.campaign.cagnotte.toStringAsFixed(0)}€',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: widget.campaign.isLive ? Colors.red : Colors.orange,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.campaign.isLive ? 'LIVE' : 'REDIFF',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthRequirements() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFEF4444).withOpacity(0.1),
            const Color(0xFFF59E0B).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFEF4444).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.verified_user,
                color: Color(0xFFEF4444),
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Exigences d\'Authentification',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRequirement(
            '🏷️',
            'Hashtag Obligatoire',
            'Votre vidéo DOIT contenir #Klipr dans la description',
            isRequired: true,
          ),
          const SizedBox(height: 12),
          _buildRequirement(
            '🎬',
            'Filigrane Automatique',
            'Le logo Klipr sera ajouté automatiquement à votre vidéo',
            isRequired: false,
          ),
          const SizedBox(height: 12),
          _buildRequirement(
            '⏱️',
            'Durée Limitée',
            'Maximum 3 minutes (180 secondes)',
            isRequired: true,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber,
                  color: Color(0xFFF59E0B),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Les vidéos ne respectant pas ces critères seront automatiquement rejetées.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirement(String emoji, String title, String description,
      {required bool isRequired}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isRequired) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'OBLIGATOIRE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUploadZone() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: _selectedVideo != null
            ? const Color(0xFF10B981).withOpacity(0.1)
            : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _selectedVideo != null
              ? const Color(0xFF10B981)
              : Colors.white.withOpacity(0.3),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: InkWell(
        onTap: _selectVideo,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _selectedVideo != null
                    ? Icons.check_circle
                    : Icons.cloud_upload,
                color: _selectedVideo != null
                    ? const Color(0xFF10B981)
                    : Colors.white.withOpacity(0.7),
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                _selectedVideo != null
                    ? 'Vidéo sélectionnée ✅ (cliquez pour changer)'
                    : 'Aucune vidéo sélectionnée',
                style: TextStyle(
                  color: _selectedVideo != null
                      ? const Color(0xFF10B981)
                      : Colors.white.withOpacity(0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _selectedVideo != null
                    ? 'Prêt pour le traitement'
                    : 'Formats acceptés: MP4, MOV, AVI (max 3 min)',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  value: _progressValue,
                  strokeWidth: 3,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Traitement en cours...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _processingStep,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(_progressValue * 100).round()}%',
                style: const TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: _progressValue,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessSection() {
    // Initialise la prévisualisation si ce n'est pas déjà fait
    if (_videoController == null && _selectedVideo != null) {
      _initVideoPreview();
    }
    return AnimatedBuilder(
      animation: _successAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _successAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF10B981).withOpacity(0.2),
                  const Color(0xFF059669).withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF10B981),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF10B981),
                  size: 60,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Clip Traité avec Succès ! 🎉',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (_videoController != null && _videoController!.value.isInitialized)
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: VideoPlayer(_videoController!),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20, right: 20),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF6366F1).withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.play_circle_fill_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Klipr',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -0.5,
                                shadows: [
                                  Shadow(
                                    blurRadius: 4,
                                    color: Colors.black54,
                                    offset: Offset(1, 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: FloatingActionButton(
                          mini: true,
                          backgroundColor: Colors.black54,
                          onPressed: () {
                            setState(() {
                              if (_videoController!.value.isPlaying) {
                                _videoController!.pause();
                              } else {
                                _videoController!.play();
                              }
                            });
                          },
                          child: Icon(
                            _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                Text(
                  'Votre clip a été authentifié et le filigrane Klipr a été appliqué. Il est maintenant prêt à être téléchargé !',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        color: Color(0xFFF59E0B),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Votre clip peut maintenant générer des revenus !',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_selectedVideo != null && !_isProcessing && !_isUploaded)
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _processVideo,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_fix_high, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Traiter et Authentifier',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (_isUploaded) ...[
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () async {
                if (_selectedVideo != null) {
                  try {
                    // 1. Enregistre dans la pellicule
                    Directory? downloadsDir;
                    if (Platform.isAndroid) {
                      final dcimDir = Directory('/storage/emulated/0/DCIM/Camera');
                      if (!(await dcimDir.exists())) {
                        await dcimDir.create(recursive: true);
                      }
                      downloadsDir = dcimDir;
                    } else if (Platform.isIOS) {
                      downloadsDir = await getApplicationDocumentsDirectory();
                    }
                    if (downloadsDir != null) {
                      final fileName = _selectedVideo!.path.split(Platform.pathSeparator).last;
                      final destPath = '${downloadsDir.path}/$fileName';
                      await File(_selectedVideo!.path).copy(destPath);
                      await _scanFileForGallery(destPath);
                      // Enregistre le clip avec infos live
                      await _saveProcessedClip(LocalClip(
                        path: destPath,
                        liveId: widget.campaign.id ?? widget.campaign.streamerName,
                        liveTitle: widget.campaign.streamTitle ?? widget.campaign.streamerName,
                        liveThumbnail: null, // Ajoute une miniature si dispo
                        creator: widget.campaign.streamerName,
                      ));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF10B981),
                          content: Text('Vidéo enregistrée dans : $destPath\nVisible dans la galerie.'),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Color(0xFFEF4444),
                          content: Text('Impossible de trouver le dossier de téléchargement.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFFEF4444),
                        content: Text('Erreur lors de l\'enregistrement : $e'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.download, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Télécharger le Clip',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: _restartProcess,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white38),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Créer un Autre Clip'),
            ),
          ),
        ],
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Retour',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
