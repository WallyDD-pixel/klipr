import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/live_campaign.dart';

class ClipCreatorPage extends StatefulWidget {
  final LiveCampaign campaign;

  const ClipCreatorPage({super.key, required this.campaign});

  @override
  State<ClipCreatorPage> createState() => _ClipCreatorPageState();
}

class _ClipCreatorPageState extends State<ClipCreatorPage> {
  double _clipStart = 0.0;
  double _clipEnd = 30.0;
  final double _maxDuration = 60.0;
  final TextEditingController _titleController = TextEditingController();
  
  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Créer un Clip',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _createClip,
            child: const Text(
              'Créer',
              style: TextStyle(
                color: Color(0xFF10B981),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info du stream
            _buildStreamInfo(),
            const SizedBox(height: 24),
            
            // Lecteur vidéo simulé
            _buildVideoPlayer(),
            const SizedBox(height: 20),
            
            // Timeline de sélection
            _buildTimeline(),
            const SizedBox(height: 24),
            
            // Informations du clip
            _buildClipInfo(),
            const SizedBox(height: 24),
            
            // Options avancées
            _buildAdvancedOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildStreamInfo() {
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
                  widget.campaign.streamTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.campaign.streamerName,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
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

  Widget _buildVideoPlayer() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Placeholder vidéo
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.withOpacity(0.3),
                  Colors.purple.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          
          // Contrôles de lecture
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 30,
            ),
          ),
          
          // Durée sélectionnée
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${(_clipEnd - _clipStart).toInt()}s',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sélection du clip',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        // Timeline slider
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Début du clip
              Row(
                children: [
                  const Text(
                    'Début:',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  Expanded(
                    child: Slider(
                      value: _clipStart,
                      min: 0,
                      max: _maxDuration - 5,
                      divisions: 120,
                      activeColor: const Color(0xFF10B981),
                      onChanged: (value) {
                        setState(() {
                          _clipStart = value;
                          if (_clipEnd <= _clipStart + 5) {
                            _clipEnd = _clipStart + 5;
                          }
                        });
                      },
                    ),
                  ),
                  Text(
                    '${_clipStart.toInt()}s',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
              
              // Fin du clip
              Row(
                children: [
                  const Text(
                    'Fin:',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  Expanded(
                    child: Slider(
                      value: _clipEnd,
                      min: _clipStart + 5,
                      max: _maxDuration,
                      divisions: 120,
                      activeColor: const Color(0xFF10B981),
                      onChanged: (value) {
                        setState(() {
                          _clipEnd = value;
                        });
                      },
                    ),
                  ),
                  Text(
                    '${_clipEnd.toInt()}s',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClipInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informations du clip',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Titre du clip',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  hintText: 'Ex: Moment épique !',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(color: Color(0xFF10B981)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Options avancées',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildOptionTile(
                'Publication automatique',
                'Publier automatiquement sur TikTok',
                true,
              ),
              const Divider(color: Colors.white24),
              _buildOptionTile(
                'Qualité HD',
                'Exporter en 1080p (recommandé)',
                true,
              ),
              const Divider(color: Colors.white24),
              _buildOptionTile(
                'Hashtags automatiques',
                'Ajouter des hashtags pertinents',
                true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionTile(String title, String subtitle, bool value) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          activeColor: const Color(0xFF10B981),
          onChanged: (bool newValue) {
            // TODO: Gérer les changements d'options
          },
        ),
      ],
    );
  }

  void _createClip() {
    HapticFeedback.mediumImpact();
    
    // TODO: Logique de création du clip
    // - Valider les paramètres
    // - Traiter la vidéo
    // - Sauvegarder le clip
    // - Publier si option activée
    
    // Pour l'instant, simuler la création
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Clip créé !',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Votre clip "${_titleController.text.isEmpty ? "Sans titre" : _titleController.text}" a été créé avec succès !',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Fermer la dialog
              Navigator.pop(context); // Retourner à la page précédente
            },
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF10B981)),
            ),
          ),
        ],
      ),
    );
  }
}