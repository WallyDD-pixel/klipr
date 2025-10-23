import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Page de recherche d'utilisateurs et de contenus
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> 
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _searchAnimationController;
  late Animation<double> _searchFadeAnimation;
  late Animation<Offset> _searchSlideAnimation;
  
  bool _isSearching = false;
  List<String> _recentSearches = [
    'ZeratoR',
    'Gotaga',
    'Squeezie',
    'Domingo',
    'Solary',
  ];

  @override
  void initState() {
    super.initState();
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _searchFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeOut,
    ));
    
    _searchSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeOut,
    ));
    
    _searchAnimationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchAnimationController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;
    
    setState(() {
      _isSearching = true;
    });
    
    // Simulation d'une recherche
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    });
    
    // Ajouter à l'historique
    if (!_recentSearches.contains(query)) {
      setState(() {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 5) {
          _recentSearches.removeLast();
        }
      });
    }
  }

  void _clearRecentSearches() {
    setState(() {
      _recentSearches.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F11),
      body: SafeArea(
        child: Column(
          children: [
            // Barre de recherche
            _buildSearchBar(),
            
            // Contenu principal
            Expanded(
              child: _isSearching 
                ? _buildSearchingState()
                : _buildSearchContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return FadeTransition(
      opacity: _searchFadeAnimation,
      child: SlideTransition(
        position: _searchSlideAnimation,
        child: Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1F1F23),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: TextField(
            controller: _searchController,
            onSubmitted: _performSearch,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Rechercher un créateur, une plateforme...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: Colors.grey[400],
                size: 24,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                    icon: Icon(
                      Icons.clear_rounded,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                  )
                : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            onChanged: (value) => setState(() {}),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
            'Recherche en cours...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recherches récentes
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recherches récentes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[200],
                  ),
                ),
                TextButton(
                  onPressed: _clearRecentSearches,
                  child: Text(
                    'Effacer',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...(_recentSearches.map((search) => _buildRecentSearchItem(search))),
            const SizedBox(height: 32),
          ],
          
          // Plateformes populaires
          Text(
            'Plateformes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[200],
            ),
          ),
          const SizedBox(height: 16),
          _buildPlatformGrid(),
          
          const SizedBox(height: 32),
          
          // Catégories populaires
          Text(
            'Catégories populaires',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[200],
            ),
          ),
          const SizedBox(height: 16),
          _buildCategoriesGrid(),
        ],
      ),
    );
  }

  Widget _buildRecentSearchItem(String search) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _searchController.text = search;
          _performSearch(search);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1F1F23),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.history_rounded,
                color: Colors.grey[400],
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  search,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              Icon(
                Icons.north_west_rounded,
                color: Colors.grey[500],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlatformGrid() {
    final platforms = [
      {'name': 'Twitch', 'color': const Color(0xFF9146FF), 'icon': Icons.live_tv},
      {'name': 'YouTube', 'color': const Color(0xFFFF0000), 'icon': Icons.play_circle_fill},
      {'name': 'Kick', 'color': const Color(0xFF53FC18), 'icon': Icons.sports_esports},
    ];

    return Row(
      children: platforms.map((platform) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () {
                _searchController.text = platform['name'] as String;
                _performSearch(platform['name'] as String);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: (platform['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (platform['color'] as Color).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      platform['icon'] as IconData,
                      color: platform['color'] as Color,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      platform['name'] as String,
                      style: TextStyle(
                        color: platform['color'] as Color,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildCategoriesGrid() {
    final categories = [
      'Gaming', 'IRL', 'Musique', 'Sport',
      'Éducation', 'Cuisine', 'Art', 'Technologie',
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: categories.map((category) {
        return InkWell(
          onTap: () {
            _searchController.text = category;
            _performSearch(category);
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1F1F23),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF6366F1).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              category,
              style: TextStyle(
                color: Colors.grey[200],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}