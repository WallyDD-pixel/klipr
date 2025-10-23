import 'package:flutter/material.dart';
import '../../models/live_campaign.dart';
import '../../widgets/live_card.dart';
import '../../widgets/animations.dart';

/// Page d'accueil avec le feed des lives
class HomePage extends StatelessWidget {
  final List<LiveCampaign> campaigns;
  final bool isLoading;
  final bool hasError;
  final bool isRefreshing;
  final bool showHint;
  final PageController pageController;
  final AnimationController cardAnimationController;
  final VoidCallback onRefresh;
  final VoidCallback onLoadInitialData;

  const HomePage({
    super.key,
    required this.campaigns,
    required this.isLoading,
    required this.hasError,
    required this.isRefreshing,
    required this.showHint,
    required this.pageController,
    required this.cardAnimationController,
    required this.onRefresh,
    required this.onLoadInitialData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header avec logo Klipr
        _buildHeader(),
        
        // Contenu principal
        Expanded(
          child: () {
            if (isLoading) {
              return _buildLoadingState();
            } else if (hasError) {
              return _buildErrorState();
            } else if (campaigns.isEmpty) {
              return _buildEmptyState();
            } else {
              return _buildCampaignsContent();
            }
          }(),
        ),
      ],
    );
  }

  // Header avec logo Klipr
  Widget _buildHeader() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        margin: const EdgeInsets.only(top: 8), // Petit espace au dessus
        child: Row(
          children: [
            // Logo Klipr
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.play_circle_fill_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Texte Klipr
            const Text(
              'Klipr',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            
            const Spacer(),
          ],
        ),
      ),
    );
  }

  // État de chargement
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animation de chargement personnalisée
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Recherche de nouvelles recommendations...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Notre algorithme équitable travaille pour vous',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // État d'erreur
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône d'erreur
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Oops ! Une erreur est survenue',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Impossible de charger les recommendations.\nVérifiez votre connexion internet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            // Bouton retry
            ElevatedButton(
              onPressed: onLoadInitialData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded, size: 20),
                  SizedBox(width: 8),
                  Text('Réessayer', style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // État vide
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration vide
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6366F1).withOpacity(0.1),
                    const Color(0xFF8B5CF6).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(60),
                border: Border.all(
                  color: const Color(0xFF6366F1).withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.live_tv_rounded,
                    size: 60,
                    color: Colors.grey[600],
                  ),
                  Positioned(
                    right: 25,
                    top: 25,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.search_off_rounded,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Aucun live disponible',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Il n\'y a actuellement aucun live à découvrir.\nTirez vers le bas pour actualiser ou revenez plus tard !',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            // Bouton d'actualisation
            OutlinedButton(
              onPressed: onRefresh,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: const Color(0xFF6366F1).withOpacity(0.5)),
                foregroundColor: const Color(0xFF6366F1),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded, size: 20),
                  SizedBox(width: 8),
                  Text('Actualiser', style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Contenu avec les campagnes
  Widget _buildCampaignsContent() {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      backgroundColor: const Color(0xFF1F1F23),
      color: const Color(0xFF6366F1),
      strokeWidth: 3,
      displacement: 40,
      edgeOffset: 20,
      child: PageView.builder(
        controller: pageController,
        scrollDirection: Axis.vertical,
        itemCount: campaigns.length,
        itemBuilder: (context, index) {
          return AnimatedCardBuilder(
            controller: cardAnimationController,
            enableScale: true,
            enableFade: true,
            enableSlide: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LiveCard(campaign: campaigns[index]),
            ),
          );
        },
      ),
    );
  }
}