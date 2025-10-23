import 'package:flutter/material.dart';
import '../models/live_campaign.dart';
import '../services/data_service.dart';
import 'pages/home_page.dart';
import 'pages/search_page.dart';
import 'pages/clips_page.dart';
import 'pages/profile_page.dart';

/// Écran principal avec navigation à 4 pages
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
  bool _isLoading = true;
  bool _hasError = false;
  int _currentNavIndex = 0;
  
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

  @override
  void dispose() {
    _refreshAnimationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  /// Charge les données initiales
  Future<void> _loadInitialData() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      // Simulation du chargement
      await Future.delayed(const Duration(seconds: 2));
      
      final data = DataService.generateDemoData();
      
      // Calculer les scores de recommandation
      for (final campaign in data) {
        campaign.calculateRecommendationScore();
      }
      
      // Trier par score de recommandation décroissant
      data.sort((a, b) => b.recommendationScore.compareTo(a.recommendationScore));

      if (mounted) {
        setState(() {
          campaigns = data;
          _isLoading = false;
          _hasError = false;
        });
        
        // Démarrer l'animation des cartes
        _cardAnimationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  /// Actualise les données
  Future<void> _refreshData() async {
    if (_isRefreshing) return;

    try {
      setState(() {
        _isRefreshing = true;
        _hasError = false;
      });

      // Démarrer l'animation de refresh
      _refreshAnimationController.forward();
      
      final newData = await DataService.refreshData();
      
      // Calculer les scores de recommandation
      for (final campaign in newData) {
        campaign.calculateRecommendationScore();
      }
      
      // Trier par score de recommandation décroissant
      newData.sort((a, b) => b.recommendationScore.compareTo(a.recommendationScore));

      if (mounted) {
        setState(() {
          campaigns = newData;
          _isRefreshing = false;
        });
        
        // Reset et relancer l'animation des cartes
        _cardAnimationController.reset();
        _cardAnimationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
          _hasError = true;
        });
      }
    } finally {
      _refreshAnimationController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F11),
      body: IndexedStack(
        index: _currentNavIndex,
        children: [
          // Page 0 : Accueil (Feed principal)
          HomePage(
            campaigns: campaigns,
            isLoading: _isLoading,
            hasError: _hasError,
            isRefreshing: _isRefreshing,
            showHint: _showHint,
            pageController: _pageController,
            cardAnimationController: _cardAnimationController,
            onRefresh: _refreshData,
            onLoadInitialData: _loadInitialData,
          ),
          
          // Page 1 : Recherche
          const SearchPage(),
          
          // Page 2 : Clips
          const ClipsPage(),
          
          // Page 3 : Profil
          const ProfilePage(),
        ],
      ),
      
      // Indicateur d'aide pour le swipe (seulement sur la page d'accueil)
      floatingActionButton: _currentNavIndex == 0 && _showHint && !_isLoading
        ? AnimatedOpacity(
            opacity: _showHint ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.only(bottom: 100),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.swipe_down_alt_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tirez vers le bas pour actualiser',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          )
        : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      
      // Barre de navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1F1F23),
          border: Border(
            top: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_rounded,
                  label: 'Accueil',
                  index: 0,
                  isActive: _currentNavIndex == 0,
                ),
                _buildNavItem(
                  icon: Icons.search_rounded,
                  label: 'Recherche',
                  index: 1,
                  isActive: _currentNavIndex == 1,
                ),
                _buildNavItem(
                  icon: Icons.bookmark_rounded,
                  label: 'Mes Clips',
                  index: 2,
                  isActive: _currentNavIndex == 2,
                ),
                _buildNavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  index: 3,
                  isActive: _currentNavIndex == 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentNavIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF6366F1).withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                color: isActive ? const Color(0xFF6366F1) : Colors.grey[400],
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isActive ? const Color(0xFF6366F1) : Colors.grey[500],
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}