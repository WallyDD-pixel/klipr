import 'package:flutter/material.dart';
import 'dart:math';
import '../models/live_campaign.dart';
import '../widgets/live_card.dart';
import '../widgets/animations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  List<LiveCampaign> campaigns = [];
  bool _isRefreshing = false;
  bool _showHint = true;
  bool _isLoading = true; // État de chargement initial
  bool _hasError = false; // État d'erreur
  int _currentNavIndex = 0; // Index de la navigation actuelle
  
  // Controllers d'animation
  late AnimationController _refreshAnimationController;
  late AnimationController _cardAnimationController;

  @override
  void initState() {
    super.initState();
    
    // Initialiser les contrôleurs d'animation
    _refreshAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Charger les données initiales
    _loadInitialData();
    
    // Masquer l'indication après 5 secondes
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showHint = false;
        });
      }
    });
  }
  
  // Méthode pour charger les données initiales
  Future<void> _loadInitialData() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      // Simuler un délai de chargement réseau
      await Future.delayed(const Duration(milliseconds: 1500));

      // Générer les données
      _generateDummyCampaigns();

      setState(() {
        _isLoading = false;
      });

      // Déclencher l'animation d'apparition initiale
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _cardAnimationController.forward();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  // Méthode pour actualiser les données avec pull-to-refresh
  Future<void> _refreshFeed() async {
    // Masquer l'indication dès le premier usage
    setState(() {
      _showHint = false;
    });

    // Animation de sortie des cartes existantes (non-bloquante)
    _cardAnimationController.reverse();
    
    // Délai pour simuler le chargement
    await Future.delayed(const Duration(milliseconds: 600));

    // Régénérer les campagnes avec de nouvelles données aléatoires
    _generateDummyCampaigns();
    
    // Forcer la mise à jour de l'interface
    setState(() {});
    
    // Animation d'entrée des nouvelles cartes (non-bloquante)
    // Utilise addPostFrameCallback pour éviter les conflits
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cardAnimationController.forward();
    });
  }

  void _generateDummyCampaigns() {
    final random = Random();
    
    // Liste de streamers variés pour plus de diversité
    final List<Map<String, dynamic>> streamerPool = [
      {
        'name': 'GamerPro85',
        'title': 'Découverte de ce nouveau jeu indie',
        'category': 'Indie Games',
        'platform': 'Twitch',
        'isNew': true,
        'contentType': 'live',
      },
      {
        'name': 'StreamQueen',
        'title': 'Construction de ma base principale',
        'category': 'Minecraft',
        'platform': 'YouTube',
        'isNew': false,
        'contentType': 'live',
      },
      {
        'name': 'TechNinja',
        'title': 'Speedrun Any% - tentative record personnel',
        'category': 'Speedrunning',
        'platform': 'Kick',
        'isNew': false,
        'contentType': 'live',
      },
      {
        'name': 'RetroGamer92',
        'title': 'Nostalgie des années 90 - jeux arcade',
        'category': 'Retro Gaming',
        'platform': 'Twitch',
        'isNew': false,
        'contentType': 'replay',
      },
      {
        'name': 'CreativeBuilder',
        'title': 'Tutoriel Photoshop : Effets cinématiques',
        'category': 'Digital Art',
        'platform': 'YouTube',
        'isNew': true,
        'contentType': 'video',
      },
      {
        'name': 'StrategyMaster',
        'title': 'Analyse des méta actuelles',
        'category': 'Strategy Games',
        'platform': 'Kick',
        'isNew': false,
        'contentType': 'live',
      },
      {
        'name': 'MusicVibes',
        'title': 'Composition en live - Lofi Hip Hop',
        'category': 'Music',
        'platform': 'Twitch',
        'isNew': true,
        'contentType': 'live',
      },
      {
        'name': 'CookingChef',
        'title': 'Recette secrète de grand-mère',
        'category': 'Cooking',
        'platform': 'YouTube',
        'isNew': false,
        'contentType': 'video',
      },
      {
        'name': 'FitnessGuru',
        'title': 'Programme musculation complet 30min',
        'category': 'Fitness',
        'platform': 'YouTube',
        'isNew': true,
        'contentType': 'video',
      },
      {
        'name': 'CodeWizard',
        'title': 'Développement app mobile live',
        'category': 'Programming',
        'platform': 'Kick',
        'isNew': false,
        'contentType': 'live',
      },
      {
        'name': 'GameReviewer',
        'title': 'Test complet du dernier AAA',
        'category': 'Game Reviews',
        'platform': 'YouTube',
        'isNew': false,
        'contentType': 'video',
      },
      {
        'name': 'ESportsPro',
        'title': 'Entraînement compétitif Valorant',
        'category': 'Esports',
        'platform': 'Kick',
        'isNew': true,
        'contentType': 'live',
      },
    ];

    // Sélectionner 6-8 streamers aléatoirement, avec une petite chance d'état vide
    final shuffledStreamers = List.from(streamerPool)..shuffle(random);
    
    // 5% de chance d'avoir aucune campagne pour tester l'état vide
    if (random.nextInt(20) == 0) {
      campaigns = [];
    } else {
      final selectedStreamers = shuffledStreamers.take(6 + random.nextInt(3)).toList();

      campaigns = selectedStreamers.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, dynamic> streamer = entry.value;
      
      // Génération de données aléatoires mais cohérentes
      int baseViewers = random.nextInt(5000) + 50;
      int followers = baseViewers * (3 + random.nextInt(10));
      bool isNewStreamer = streamer['isNew'] as bool;
      
      // Les nouveaux streamers ont tendance à avoir moins de viewers mais plus de potentiel
      if (isNewStreamer) {
        baseViewers = (baseViewers * 0.3).round() + random.nextInt(200);
        followers = (followers * 0.2).round() + random.nextInt(1000);
      }

      // Déterminer le type de contenu et statut
      String contentType = streamer['contentType'] as String;
      bool isCurrentlyLive = contentType == 'live' && (random.nextInt(5) != 0); // 80% chance d'être en live pour les lives
      
      // Pour les vidéos YouTube, toujours pas en live
      if (contentType == 'video') {
        isCurrentlyLive = false;
      }
      
      // Ajuster le nombre de viewers selon le type de contenu
      int actualViewers;
      if (contentType == 'video') {
        // Les vidéos YouTube ont souvent plus de vues
        actualViewers = baseViewers * (2 + random.nextInt(3));
      } else if (isCurrentlyLive) {
        actualViewers = baseViewers;
      } else {
        // Rediffusions ont moins de viewers
        actualViewers = (baseViewers * 0.4).round();
      }

      return LiveCampaign(
        id: '${index + 1}',
        streamerName: streamer['name'] as String,
        streamTitle: streamer['title'] as String,
        gameCategory: streamer['category'] as String,
        platform: streamer['platform'] as String,
        viewerCount: actualViewers,
        cagnotte: (random.nextDouble() * 300) + 50.0,
        clipsCreated: random.nextInt(15) + 1,
        thumbnailUrl: 'https://picsum.photos/400/300?random=${DateTime.now().millisecondsSinceEpoch + index}',
        isNewStreamer: isNewStreamer,
        followerCount: followers,
        monthlyViewers: followers * (2 + random.nextInt(5)),
        streamDuration: Duration(
          hours: random.nextInt(4) + 1,
          minutes: random.nextInt(60),
        ),
        isLive: isCurrentlyLive,
        channelUrl: !isCurrentlyLive || contentType == 'video' ? 'https://${streamer['platform'].toString().toLowerCase()}.com/${streamer['name'].toString().toLowerCase()}' : null,
        replayUrl: !isCurrentlyLive || contentType == 'video' ? 'https://${streamer['platform'].toString().toLowerCase()}.com/video/replay_${index + 1}' : null,
        contentType: contentType,
      );
    }).toList();
    }

    // Appliquer l'algorithme de recommandation équitable si des campagnes existent
    if (campaigns.isNotEmpty) {
      campaigns = _applyFairRecommendationAlgorithm(campaigns);
    }
    
    // Déclencher l'animation d'apparition initiale
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cardAnimationController.forward();
    });
  }

  List<LiveCampaign> _applyFairRecommendationAlgorithm(List<LiveCampaign> campaigns) {
    // Calcul du score de recommandation pour chaque campagne
    for (var campaign in campaigns) {
      campaign.calculateRecommendationScore();
    }

    // Tri par score de recommandation décroissant
    campaigns.sort((a, b) => b.recommendationScore.compareTo(a.recommendationScore));

    // Boost équitable : s'assurer qu'au moins 30% des premières positions 
    // sont occupées par des petits streamers ou nouveaux
    final totalCampaigns = campaigns.length;
    final smallStreamerQuota = (totalCampaigns * 0.3).round();
    
    final smallStreamers = campaigns.where((c) => 
      c.audienceSize == 'Micro' || c.audienceSize == 'Petit' || c.isNewStreamer
    ).toList();
    
    final largeStreamers = campaigns.where((c) => 
      c.audienceSize != 'Micro' && c.audienceSize != 'Petit' && !c.isNewStreamer
    ).toList();

    // Créer un mix équitable en alternant ou en privilégiant les petits streamers
    final List<LiveCampaign> fairMix = [];
    int smallIndex = 0, largeIndex = 0;
    
    for (int i = 0; i < totalCampaigns; i++) {
      // Logique d'alternance avec boost pour les petits streamers
      bool shouldPickSmall = false;
      
      if (i < smallStreamerQuota && smallIndex < smallStreamers.length) {
        shouldPickSmall = true;
      } else if (smallIndex < smallStreamers.length && largeIndex < largeStreamers.length) {
        // Alternance après avoir rempli le quota minimal
        shouldPickSmall = i % 3 == 0; // 1 petit streamer tous les 3
      } else if (smallIndex < smallStreamers.length) {
        shouldPickSmall = true;
      }
      
      if (shouldPickSmall && smallIndex < smallStreamers.length) {
        fairMix.add(smallStreamers[smallIndex++]);
      } else if (largeIndex < largeStreamers.length) {
        fairMix.add(largeStreamers[largeIndex++]);
      } else if (smallIndex < smallStreamers.length) {
        fairMix.add(smallStreamers[smallIndex++]);
      }
    }

    return fairMix;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _refreshAnimationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Logo cliquable pour refresh
                      GestureDetector(
                        onTap: () => _refreshFeed(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Klipr',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Indicateur de rafraîchissement animé
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: RefreshIndicatorWidget(
                          isRefreshing: _isRefreshing,
                          onTap: _isRefreshing ? null : () => _refreshFeed(),
                        ),
                      ),
                      
                      // Menu button avec indication pull-to-refresh
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: const Icon(
                          Icons.menu_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Contenu principal avec gestion des états
                Expanded(
                  child: _buildMainContent(),
                ),
              ],
            ),
            
            // Indicateur pull-to-refresh en bas
            if (!_isRefreshing && _showHint && !_isLoading && campaigns.isNotEmpty)
              Positioned(
                bottom: 90, // Ajusté pour laisser place à la navbar
                left: 20,
                right: 20,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _showHint ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 16,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Tire vers le bas pour de nouvelles recommandations',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      
      // Navigation bar en bas
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFF1F1F23),
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 0.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Accueil
            _buildNavItem(
              icon: Icons.home_rounded,
              label: 'Accueil',
              isActive: _currentNavIndex == 0,
              onTap: () => _changeNavIndex(0),
            ),
            
            // Recherche
            _buildNavItem(
              icon: Icons.search_rounded,
              label: 'Recherche',
              isActive: _currentNavIndex == 1,
              onTap: () => _changeNavIndex(1),
            ),
            
            // Mes clips
            _buildNavItem(
              icon: Icons.video_library_rounded,
              label: 'Mes clips',
              isActive: _currentNavIndex == 2,
              onTap: () => _changeNavIndex(2),
            ),
            
            // Profil
            _buildNavItem(
              icon: Icons.person_rounded,
              label: 'Profil',
              isActive: _currentNavIndex == 3,
              onTap: () => _changeNavIndex(3),
            ),
          ],
        ),
      ),
    );
  }

  // Méthode pour changer d'onglet dans la navigation
  void _changeNavIndex(int index) {
    setState(() {
      _currentNavIndex = index;
    });
  }

  // Méthode pour construire le contenu principal selon l'onglet sélectionné
  Widget _buildMainContent() {
    switch (_currentNavIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return _buildSearchContent();
      case 2:
        return _buildMyClipsContent();
      case 3:
        return _buildProfileContent();
      default:
        return _buildHomeContent();
    }
  }

  // Contenu de l'accueil
  Widget _buildHomeContent() {
    if (_isLoading) {
      return _buildLoadingState();
    } else if (_hasError) {
      return _buildErrorState();
    } else if (campaigns.isEmpty) {
      return _buildEmptyState();
    } else {
      return _buildCampaignsContent();
    }
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
              onPressed: _loadInitialData,
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
              onPressed: () => _refreshFeed(),
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
      onRefresh: _refreshFeed,
      backgroundColor: const Color(0xFF1F1F23),
      color: const Color(0xFF6366F1),
      strokeWidth: 3,
      displacement: 40,
      edgeOffset: 20,
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: campaigns.length,
        itemBuilder: (context, index) {
          return AnimatedCardBuilder(
            controller: _cardAnimationController,
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

  // Page de recherche
  Widget _buildSearchContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Barre de recherche
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1F1F23),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Rechercher des utilisateurs...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Suggestions de recherche
          Expanded(
            child: ListView(
              children: [
                _buildSearchCategory('Utilisateurs populaires', [
                  'GamerPro85', 'StreamQueen', 'TechNinja', 'RetroGamer92'
                ]),
                const SizedBox(height: 20),
                _buildSearchCategory('Catégories tendances', [
                  'Gaming', 'Art numérique', 'Musique', 'Cuisine'
                ]),
                const SizedBox(height: 20),
                _buildSearchCategory('Recherches récentes', [
                  'speedrun', 'minecraft', 'live cooking'
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Page Mes clips
  Widget _buildMyClipsContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône clips
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6366F1).withOpacity(0.1),
                    const Color(0xFF8B5CF6).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.video_library_rounded,
                size: 50,
                color: Color(0xFF6366F1),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aucun clip créé',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Commencez à créer vos premiers clips\nen regardant vos lives préférés !',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _changeNavIndex(0), // Retour à l'accueil
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
                  Icon(Icons.play_arrow_rounded, size: 20),
                  SizedBox(width: 8),
                  Text('Découvrir des lives', style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Page Profil
  Widget _buildProfileContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header profil
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Utilisateur Klipr',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Membre depuis aujourd\'hui',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Options du profil
          Expanded(
            child: ListView(
              children: [
                _buildProfileOption(
                  icon: Icons.settings_rounded,
                  title: 'Paramètres',
                  subtitle: 'Préférences et confidentialité',
                  onTap: () {},
                ),
                _buildProfileOption(
                  icon: Icons.favorite_rounded,
                  title: 'Favoris',
                  subtitle: 'Lives et créateurs favoris',
                  onTap: () {},
                ),
                _buildProfileOption(
                  icon: Icons.history_rounded,
                  title: 'Historique',
                  subtitle: 'Lives récemment regardés',
                  onTap: () {},
                ),
                _buildProfileOption(
                  icon: Icons.help_rounded,
                  title: 'Aide & Support',
                  subtitle: 'FAQ et contact',
                  onTap: () {},
                ),
                _buildProfileOption(
                  icon: Icons.info_rounded,
                  title: 'À propos',
                  subtitle: 'Version et informations',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour une catégorie de recherche
  Widget _buildSearchCategory(String title, List<String> items) {
    return Column(
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
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1F1F23),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Text(
              item,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  // Widget pour une option du profil
  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F23),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF6366F1),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 13,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  // Méthode pour construire un élément de navigation
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isActive 
                  ? const Color(0xFF6366F1)
                  : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isActive 
                  ? [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
              ),
              child: Icon(
                icon,
                color: isActive 
                  ? Colors.white
                  : Colors.grey[500],
                size: 22,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 11,
                color: isActive 
                  ? const Color(0xFF6366F1)
                  : Colors.grey[500],
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}