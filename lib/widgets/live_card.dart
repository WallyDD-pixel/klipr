import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/live_campaign.dart';
import '../screens/cagnotte_details_page.dart';
import '../screens/clips_list_page.dart';
import 'klipr_concept_modal.dart';

class LiveCard extends StatefulWidget {
  final LiveCampaign campaign;

  const LiveCard({super.key, required this.campaign});

  @override
  State<LiveCard> createState() => _LiveCardState();
}

class _LiveCardState extends State<LiveCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isCagnottePressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: _buildCard(),
          ),
        );
      },
    );
  }

  Widget _buildCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.03),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Image de couverture / thumbnail - PLEIN ÉCRAN
            Container(
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.0, 0.5, 0.8, 1.0],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Image.network(
                  widget.campaign.thumbnailUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getPlatformColor().withOpacity(0.4),
                            _getPlatformColor().withOpacity(0.1),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white54,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getPlatformColor().withOpacity(0.4),
                            _getPlatformColor().withOpacity(0.1),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.play_circle_fill_rounded,
                          size: 64,
                          color: Colors.white54,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // ZONE HAUTE (Safe zone) - Badges et infos
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  // Badge Live, Rediff ou Vidéo
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getContentTypeColor(),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: _getContentTypeColor().withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getContentTypeLabel(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Badge boost pour petits streamers
                  if (widget.campaign.isNewStreamer || widget.campaign.recommendationScore > 0.7)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: widget.campaign.isNewStreamer ? Colors.orange : Colors.green,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        widget.campaign.isNewStreamer ? 'NOUVEAU' : 'OPPORTUNITÉ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  
                  const Spacer(),
                  
                  // Nombre de viewers - REPOSITIONNÉ EN HAUT (seulement pour lives et vidéos)
                  if (widget.campaign.contentType != 'replay')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.campaign.contentType == 'live' 
                              ? Icons.visibility_rounded 
                              : Icons.play_circle_outline_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.campaign.contentType == 'live' 
                              ? _formatViewers(widget.campaign.viewerCount)
                              : '${_formatViewers(widget.campaign.viewerCount)} vues',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            
            // ZONE BASSE - Informations et bouton principal (Zone accessible aux deux pouces)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                      Colors.black.withOpacity(0.95),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info streamer
                    Row(
                      children: [
                        // Avatar
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                _getPlatformColor(),
                                _getPlatformColor().withOpacity(0.6),
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // Nom et plateforme
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
                                      color: _getPlatformColor(),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          widget.campaign.platform == 'Twitch' ? Icons.videocam_rounded : Icons.play_circle_rounded,
                                          size: 12,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          widget.campaign.platform,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getAudienceSizeColor().withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: _getAudienceSizeColor().withOpacity(0.4),
                                      ),
                                    ),
                                    child: Text(
                                      widget.campaign.audienceSize,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: _getAudienceSizeColor(),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Titre du stream
                    Text(
                      widget.campaign.streamTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Catégorie
                    Row(
                      children: [
                        Icon(
                          Icons.videogame_asset_rounded,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.campaign.gameCategory,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Statistiques compactes
                    Row(
                      children: [
                        // Cagnotte (cliquable)
                        Expanded(
                          child: GestureDetector(
                            onTapDown: (_) => setState(() => _isCagnottePressed = true),
                            onTapUp: (_) => setState(() => _isCagnottePressed = false),
                            onTapCancel: () => setState(() => _isCagnottePressed = false),
                            onTap: () {
                              // Feedback haptique
                              HapticFeedback.lightImpact();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CagnotteDetailsPage(
                                    campaign: widget.campaign.toCampaign(),
                                  ),
                                ),
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              transform: Matrix4.identity()
                                ..scale(_isCagnottePressed ? 0.95 : 1.0),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF10B981).withOpacity(_isCagnottePressed ? 0.3 : 0.2),
                                    const Color(0xFF059669).withOpacity(_isCagnottePressed ? 0.2 : 0.1),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF10B981).withOpacity(_isCagnottePressed ? 0.5 : 0.3),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF10B981).withOpacity(_isCagnottePressed ? 0.25 : 0.15),
                                    blurRadius: _isCagnottePressed ? 12 : 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF10B981).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.euro_rounded,
                                          color: Color(0xFF10B981),
                                          size: 18,
                                        ),
                                      ),
                                      const Spacer(),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    '${widget.campaign.cagnotte.toStringAsFixed(0)}€',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Cagnotte',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[400],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      // Icône simple pour indiquer que c'est cliquable
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        color: const Color(0xFF10B981).withOpacity(0.6),
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Clips (amélioré visuellement)
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ClipsListPage(campaign: widget.campaign),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF3B82F6).withOpacity(0.2),
                                    const Color(0xFF2563EB).withOpacity(0.1),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF3B82F6).withOpacity(0.3),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF3B82F6).withOpacity(0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3B82F6).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.play_circle_outline_rounded,
                                    color: Color(0xFF3B82F6),
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  widget.campaign.clipsCreated.toString(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF3B82F6),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.campaign.clipsCreated <= 1 ? 'Clip créé' : 'Clips créés',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[400],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // BOUTON PRINCIPAL - Position optimale pour les pouces
                    SizedBox(
                      width: double.infinity,
                      height: 56, // Plus grand pour faciliter l'appui
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          // Ouvrir la modal selon le type de contenu
                          _openContent();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getPlatformColor(),
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: _getPlatformColor().withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getContentIcon(),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _getContentButtonText(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Nouveau widget pour les statistiques compactes (zone basse)
  Widget _buildCompactStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    bool isClickable = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                    if (isClickable)
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: color,
                        size: 12,
                      ),
                  ],
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
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

  Color _getContentTypeColor() {
    switch (widget.campaign.contentType) {
      case 'live':
        return Colors.red;
      case 'replay':
        return Colors.orange;
      case 'video':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getContentTypeLabel() {
    switch (widget.campaign.contentType) {
      case 'live':
        return widget.campaign.isLive ? 'LIVE' : 'REDIFF';
      case 'replay':
        return 'REDIFF';
      case 'video':
        return 'VIDÉO';
      default:
        return 'CONTENU';
    }
  }

  Color _getAudienceSizeColor() {
    switch (widget.campaign.audienceSize) {
      case 'Micro':
        return Colors.green;
      case 'Petit':
        return Colors.blue;
      case 'Moyen':
        return Colors.orange;
      case 'Grand':
        return Colors.purple;
      case 'Mega':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatViewers(int viewers) {
    if (viewers < 1000) return viewers.toString();
    if (viewers < 1000000) return '${(viewers / 1000).toStringAsFixed(1)}K';
    return '${(viewers / 1000000).toStringAsFixed(1)}M';
  }

  void _openLiveStream() {
    // Ouvrir la modal explicative du concept Klipr
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => KliprConceptModal(campaign: widget.campaign),
    );
  }

  void _openChannel() {
    // Ouvrir la modal explicative du concept Klipr
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => KliprConceptModal(campaign: widget.campaign),
    );
  }

  void _openContent() {
    // Ouvrir la modal explicative du concept Klipr pour tous les types de contenu
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => KliprConceptModal(campaign: widget.campaign),
    );
  }

  IconData _getContentIcon() {
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

  String _getContentButtonText() {
    switch (widget.campaign.contentType) {
      case 'live':
        if (widget.campaign.isLive) {
          return 'Regarder sur ${widget.campaign.platform}';
        } else {
          return 'Voir la rediffusion';
        }
      case 'replay':
        return 'Voir la rediffusion';
      case 'video':
        return 'Regarder la vidéo';
      default:
        return 'Voir le contenu';
    }
  }
}