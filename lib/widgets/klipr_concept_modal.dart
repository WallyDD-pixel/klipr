import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/live_campaign.dart';
import '../screens/clip_tutorial_page.dart';

class KliprConceptModal extends StatefulWidget {
  final LiveCampaign campaign;

  const KliprConceptModal({super.key, required this.campaign});

  @override
  State<KliprConceptModal> createState() => _KliprConceptModalState();
}

class _KliprConceptModalState extends State<KliprConceptModal>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_fadeController);
    
    // Démarrer les animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _closeModal() async {
    await _slideController.reverse();
    await _fadeController.reverse();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Container(
            color: Colors.black.withOpacity(0.8 * _fadeAnimation.value),
            child: SlideTransition(
              position: _slideAnimation,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.85,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F0F0F),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      
                      // Header avec avatar du streamer
                      _buildHeader(),
                      
                      // Contenu scrollable
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              _buildStep1(),
                              const SizedBox(height: 24),
                              _buildStep2(),
                              const SizedBox(height: 24),
                              _buildStep3(),
                              const SizedBox(height: 24),
                              _buildStep4(),
                              const SizedBox(height: 32),
                              _buildCagnoteInfo(),
                            ],
                          ),
                        ),
                      ),
                      
                      // Boutons d'action
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Avatar du streamer
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Infos streamer
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.campaign.streamerName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.campaign.isLive ? Colors.red : Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.campaign.isLive ? 'LIVE' : 'REDIFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.campaign.platform,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Bouton fermer
          GestureDetector(
            onTap: _closeModal,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    String contentText;
    switch (widget.campaign.contentType) {
      case 'live':
        contentText = widget.campaign.isLive 
          ? "Connectez-vous au live de ${widget.campaign.streamerName} sur ${widget.campaign.platform} et découvrez son contenu en temps réel."
          : "Accédez à la rediffusion de ${widget.campaign.streamerName} sur ${widget.campaign.platform} pour voir son contenu précédent.";
        break;
      case 'replay':
        contentText = "Accédez à la rediffusion de ${widget.campaign.streamerName} sur ${widget.campaign.platform} pour voir ses streams précédents.";
        break;
      case 'video':
        contentText = "Regardez la vidéo de ${widget.campaign.streamerName} sur ${widget.campaign.platform} et découvrez son contenu créatif.";
        break;
      default:
        contentText = "Découvrez le contenu de ${widget.campaign.streamerName} sur ${widget.campaign.platform}.";
    }

    return _buildStepCard(
      number: "1",
      title: _getStep1Title(),
      description: contentText,
      icon: Icons.play_circle_filled_rounded,
      color: const Color(0xFF6366F1),
    );
  }

  String _getStep1Title() {
    switch (widget.campaign.contentType) {
      case 'live':
        return widget.campaign.isLive ? "Regarder le Live" : "Voir la Rediffusion";
      case 'replay':
        return "Voir la Rediffusion";
      case 'video':
        return "Regarder la Vidéo";
      default:
        return "Voir le Contenu";
    }
  }

  Widget _buildStep2() {
    return _buildStepCard(
      number: "2",
      title: "Créer et Uploader",
      description: "Créez votre clip avec votre outil préféré, puis uploadez-le avec le hashtag #Klipr obligatoire. Notre système ajoutera automatiquement le filigrane.",
      icon: Icons.cloud_upload_rounded,
      color: const Color(0xFFEF4444),
    );
  }

  Widget _buildStep3() {
    return _buildStepCard(
      number: "3",
      title: "Authentification Automatique",
      description: "Notre système vérifie le hashtag #Klipr et applique automatiquement le filigrane officiel pour authentifier votre clip.",
      icon: Icons.verified_rounded,
      color: const Color(0xFF10B981),
    );
  }

  Widget _buildStep4() {
    return _buildStepCard(
      number: "4",
      title: "Publier et Générer des Revenus",
      description: "Publiez votre clip authentifié sur TikTok. Plus il génère de vues, likes et interactions, plus vous recevez une part de la cagnotte !",
      icon: Icons.trending_up_rounded,
      color: const Color(0xFFF59E0B),
    );
  }

  Widget _buildStepCard({
    required String number,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F23),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Numéro et icône
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        number,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Contenu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCagnoteInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10B981).withOpacity(0.1),
            const Color(0xFF059669).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cagnotte Actuelle',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${widget.campaign.cagnotte.toStringAsFixed(0)}€ disponibles',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: const Color(0xFF10B981),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Plus votre clip performe, plus votre part augmente !',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[300],
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

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F23),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Bouton principal - Créer un clip
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                _closeModal();
                _createClip();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: const Color(0xFF10B981).withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.cloud_upload_rounded,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.campaign.isLive ? 'Uploader un Clip' : 'Uploader pour cette Rediffusion',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Bouton secondaire - Voir le contenu
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                _closeModal();
                _viewContent();
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: _getPlatformColor().withOpacity(0.5),
                ),
                foregroundColor: _getPlatformColor(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getModalContentIcon(),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getModalButtonText(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Bouton fermer
          TextButton(
            onPressed: _closeModal,
            child: Text(
              'Fermer',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _createClip() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClipTutorialPage(campaign: widget.campaign),
      ),
    );
  }

  void _viewContent() {
    Navigator.pop(context);
    
    // Simulation d'ouverture du contenu
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E293B),
        content: Row(
          children: [
            Icon(
              widget.campaign.isLive ? Icons.live_tv : Icons.play_circle,
              color: const Color(0xFF10B981),
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.campaign.isLive 
                  ? 'Ouverture du live sur ${widget.campaign.platform}...'
                  : 'Ouverture de la rediffusion...',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _getPlatformColor() {
    switch (widget.campaign.platform) {
      case 'Twitch':
        return const Color(0xFF9146FF);
      case 'YouTube':
        return const Color(0xFFFF0000);
      case 'Kick':
        return const Color(0xFF53FC18);
      default:
        return const Color(0xFF6366F1);
    }
  }

  IconData _getModalContentIcon() {
    switch (widget.campaign.contentType) {
      case 'live':
        return widget.campaign.isLive ? Icons.play_arrow_rounded : Icons.tv_rounded;
      case 'replay':
        return Icons.tv_rounded;
      case 'video':
        return Icons.play_circle_filled_rounded;
      default:
        return Icons.play_arrow_rounded;
    }
  }

  String _getModalButtonText() {
    switch (widget.campaign.contentType) {
      case 'live':
        if (widget.campaign.isLive) {
          return 'Voir le Live sur ${widget.campaign.platform}';
        } else {
          return 'Voir la Rediffusion';
        }
      case 'replay':
        return 'Voir la Rediffusion';
      case 'video':
        return 'Regarder la Vidéo';
      default:
        return 'Voir sur ${widget.campaign.platform}';
    }
  }
}