import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/live_campaign.dart';
import 'video_upload_page.dart';

class ClipTutorialPage extends StatefulWidget {
  final LiveCampaign campaign;

  const ClipTutorialPage({super.key, required this.campaign});

  @override
  State<ClipTutorialPage> createState() => _ClipTutorialPageState();
}

class _ClipTutorialPageState extends State<ClipTutorialPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 7;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Guide de Création de Clips',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Passer',
              style: TextStyle(
                color: Color(0xFF10B981),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                _buildWelcomeSlide(),
                _buildBestPracticesSlide(),
                _buildToolsSlide(),
                _buildTikTokExamplesSlide(),
                _buildViralFormatsSlide(),
                _buildTimingSlide(),
                _buildFinalTipsSlide(),
              ],
            ),
          ),
          _buildNavigationBar(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSlide() {
    return _buildSlideContainer(
      title: 'Bienvenue dans le Guide de Clips !',
      content: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              ),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.play_circle_filled,
              color: Colors.white,
              size: 60,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Créer des clips viraux sur TikTok',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Ce guide vous apprendra les meilleures techniques pour transformer les moments forts de ${widget.campaign.streamerName} en clips TikTok performants.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF10B981).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Color(0xFF10B981),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Durée estimée : 2-3 minutes\nNiveau : Débutant à Intermédiaire',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
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

  Widget _buildBestPracticesSlide() {
    return _buildSlideContainer(
      title: 'Meilleures Pratiques',
      content: Column(
        children: [
          _buildTipCard(
            icon: Icons.schedule,
            title: 'Durée Optimale',
            description: '15-30 secondes pour TikTok\n45-60 secondes maximum',
            color: const Color(0xFF3B82F6),
          ),
          const SizedBox(height: 16),
          _buildTipCard(
            icon: Icons.trending_up,
            title: 'Moments à Clipper',
            description:
                'Réactions fortes, fails épiques, moments drôles, skillshots impressionnants',
            color: const Color(0xFFEF4444),
          ),
          const SizedBox(height: 16),
          _buildTipCard(
            icon: Icons.volume_up,
            title: 'Audio Important',
            description:
                'Gardez les réactions vocales du streamer, elles créent l\'engagement',
            color: const Color(0xFF8B5CF6),
          ),
          const SizedBox(height: 16),
          _buildTipCard(
            icon: Icons.speed,
            title: 'Rythme Rapide',
            description:
                'Action dès les premières secondes, pas de temps morts',
            color: const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }

  Widget _buildToolsSlide() {
    return _buildSlideContainer(
      title: 'Outils & Exigences',
      content: Column(
        children: [
          _buildToolCard(
            name: 'OpusClip',
            description:
                'IA pour identifier automatiquement les meilleurs moments',
            features: [
              'Détection automatique',
              'Sous-titres IA',
              'Format vertical'
            ],
            isPremium: true,
          ),
          const SizedBox(height: 16),
          _buildToolCard(
            name: 'CapCut',
            description: 'Éditeur mobile gratuit de TikTok',
            features: ['Templates viraux', 'Effets tendances', 'Musique libre'],
            isPremium: false,
          ),
          const SizedBox(height: 20),

          // Exigences Klipr
          Container(
            padding: const EdgeInsets.all(16),
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
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Exigences Klipr',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildRequirementItem('🏷️', 'Hashtag #Klipr obligatoire'),
                _buildRequirementItem('🎬', 'Filigrane automatique ajouté'),
                _buildRequirementItem('⏱️', 'Maximum 3 minutes'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTikTokExamplesSlide() {
    return _buildSlideContainer(
      title: 'Exemples TikTok Viraux',
      content: Column(
        children: [
          const Text(
            'Types de clips qui performent bien :',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Grid d'exemples avec vos images
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildExampleCard(
                  title: 'Réaction Gaming',
                  views: '2.1M',
                  imagePath: 'assets/images/tutorial/tuto1.png',
                ),
                _buildExampleCard(
                  title: 'Fail Épique',
                  views: '1.8M',
                  imagePath: 'assets/images/tutorial/tuto2.png',
                ),
                _buildExampleCard(
                  title: 'Format Viral',
                  views: '3.2M',
                  imagePath: 'assets/images/tutorial/tuto3.png',
                ),
                _buildExampleCard(
                  title: 'Réaction TV',
                  views: '1.5M',
                  imagePath: 'assets/images/tutorial/tuto4.png',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildViralFormatsSlide() {
    return _buildSlideContainer(
      title: 'Formats qui Cartonnent',
      content: Column(
        children: [
          const Text(
            'Basés sur vos exemples TikTok :',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildFormatCard(
            emoji: '😱',
            title: 'Réaction + Gameplay',
            description: 'Face cam du streamer + moment fort de jeu',
            example: 'John Doe découvre un stunt GTA',
            color: const Color(0xFFEF4444),
          ),
          const SizedBox(height: 16),
          _buildFormatCard(
            emoji: '🤣',
            title: 'Fail + Commentaire',
            description: 'Échec épique + réaction spontanée',
            example: 'Léo rate son saut de moto dans l\'eau',
            color: const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 16),
          _buildFormatCard(
            emoji: '🔥',
            title: 'Texte + Action',
            description: 'Hook textuel + moment spectaculaire',
            example: '"VIDÉOS VIRALES SONT" + explosion',
            color: const Color(0xFF10B981),
          ),
          const SizedBox(height: 16),
          _buildFormatCard(
            emoji: '🎭',
            title: 'Réaction Méta',
            description: 'Streamer réagit à du contenu viral',
            example: 'Lonni réagit aux grimaces TikTok',
            color: const Color(0xFF8B5CF6),
          ),
        ],
      ),
    );
  }

  Widget _buildTimingSlide() {
    return _buildSlideContainer(
      title: 'Timing & Engagement',
      content: Column(
        children: [
          _buildTimingTip(
            timeframe: '0-3 secondes',
            tip: 'Hook immédiat',
            description: 'Action ou réaction forte dès le début',
            color: const Color(0xFFEF4444),
          ),
          const SizedBox(height: 16),
          _buildTimingTip(
            timeframe: '3-15 secondes',
            tip: 'Développement',
            description: 'Montez en tension, ajoutez du contexte',
            color: const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 16),
          _buildTimingTip(
            timeframe: '15-30 secondes',
            tip: 'Climax',
            description: 'Le moment fort principal',
            color: const Color(0xFF10B981),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF3B82F6).withOpacity(0.1),
                  const Color(0xFF8B5CF6).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF3B82F6).withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.psychology,
                      color: Color(0xFF3B82F6),
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Astuce Psychologique',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Les utilisateurs décident en 3 secondes s\'ils vont regarder jusqu\'au bout. Votre début doit être PARFAIT !',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalTipsSlide() {
    return _buildSlideContainer(
      title: 'Conseils Finaux',
      content: Column(
        children: [
          const Icon(
            Icons.star,
            color: Color(0xFFF59E0B),
            size: 80,
          ),
          const SizedBox(height: 24),
          const Text(
            'Prêt à créer votre premier clip viral !',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildFinalTip('🎯', 'Qualité > Quantité',
              'Un clip parfait vaut mieux que 10 clips moyens'),
          const SizedBox(height: 12),
          _buildFinalTip(
              '📱', 'Format Vertical', 'Toujours en 9:16 pour TikTok'),
          const SizedBox(height: 12),
          _buildFinalTip(
              '🏷️', 'Hashtag #Klipr', 'OBLIGATOIRE dans la description'),
          const SizedBox(height: 12),
          _buildFinalTip('⏱️', 'Durée Limitée',
              'Maximum 3 minutes pour l\'authentification'),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF10B981).withOpacity(0.3),
              ),
            ),
            child: Text(
              'Vous êtes maintenant prêt à uploader votre clip avec le hashtag #Klipr !',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Progress indicator for the tutorial steps
  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_totalPages, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentPage == index ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: _currentPage == index
                  ? const Color(0xFF10B981)
                  : Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  // Méthodes helpers
  Widget _buildSlideContainer(
      {required String title, required Widget content}) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(child: content),
        ],
      ),
    );
  }

  Widget _buildTipCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard({
    required String name,
    required String description,
    required List<String> features,
    required bool isPremium,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPremium
              ? const Color(0xFFF59E0B).withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isPremium) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(description,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.7), fontSize: 14)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: features
                .map((feature) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(feature,
                          style: const TextStyle(
                              color: Color(0xFF10B981), fontSize: 12)),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleCard({
    required String title,
    required String views,
    required String imagePath,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.black, // Fond noir pour mieux voir les images
                ),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit
                      .contain, // Changé de cover à contain pour voir l'image entière
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.play_circle_filled,
                                color: Colors.white, size: 40),
                            const SizedBox(height: 8),
                            Text(
                              title,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Image en cours\nde chargement',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$views vues',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatCard({
    required String emoji,
    required String title,
    required String description,
    required String example,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(description,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.8), fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('Ex: $example',
                style: TextStyle(
                    color: color, fontSize: 12, fontStyle: FontStyle.italic)),
          ),
        ],
      ),
    );
  }

  Widget _buildTimingTip({
    required String timeframe,
    required String tip,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(8)),
            child: Text(timeframe,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tip,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                Text(description,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.7), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalTip(String emoji, String title, String description) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
              Text(description,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.7), fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousPage,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white38),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Précédent'),
              ),
            )
          else
            const Expanded(child: SizedBox()),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                if (_currentPage == _totalPages - 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          VideoUploadPage(campaign: widget.campaign),
                    ),
                  );
                } else {
                  _nextPage();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _currentPage == _totalPages - 1
                    ? 'Uploader mon Clip !'
                    : 'Suivant',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
