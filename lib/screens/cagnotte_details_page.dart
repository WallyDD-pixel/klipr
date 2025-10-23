import 'package:flutter/material.dart';
import '../models/campaign.dart';
import '../models/clipper.dart';
import '../services/earnings_calculator.dart';
import '../services/earnings_engine.dart';

class CagnotteDetailsPage extends StatefulWidget {
  final Campaign campaign;

  const CagnotteDetailsPage({super.key, required this.campaign});

  @override
  State<CagnotteDetailsPage> createState() => _CagnotteDetailsPageState();
}

class _CagnotteDetailsPageState extends State<CagnotteDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showAllClippers = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getContentColor() {
    switch (widget.campaign.status) {
      case CampaignStatus.active:
        return Colors.teal;
      case CampaignStatus.completed:
        return Colors.blue;
      case CampaignStatus.draft:
        return Colors.orange;
      case CampaignStatus.archived:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    } else {
      return number.toString();
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  List<ClipperEarning> _getDistributionResult() {
    return EarningsCalculationEngine.calculateDistribution(
      'live_${widget.campaign.id}', // ID du live
      widget.campaign.clippers,
      widget.campaign.cagnotteAmount,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: _getContentColor(),
        foregroundColor: Colors.white,
        title: Text(
          widget.campaign.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Classement'),
            Tab(text: 'Informations'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildClippersRanking(),
          _buildCampaignInformation(),
        ],
      ),
    );
  }

  Widget _buildCampaignInformation() {
    final stats = EarningsCalculationEngine.calculateDistributionStats(_getDistributionResult());
    final totalClippersViews = _getTotalClippersViews();
    final averageViewsPerClipper = widget.campaign.clippers.isNotEmpty 
        ? (totalClippersViews / widget.campaign.clippers.length).round()
        : 0;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations de la Campagne',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Statistiques globales
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getContentColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getContentColor().withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.analytics,
                      color: _getContentColor(),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Statistiques Globales',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getContentColor(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Total des vues clippers', _formatNumber(totalClippersViews)),
                _buildInfoRow('Moyenne par clipper', _formatNumber(averageViewsPerClipper)),
                _buildInfoRow('Clippers éligibles', '${stats['eligibleCount']} / ${widget.campaign.clippers.length}'),
                _buildInfoRow('Montant distribué', '${stats['totalAmount']?.toStringAsFixed(0) ?? '0'}€'),
                _buildInfoRow('Gain moyen', '${stats['averageEarning']?.toStringAsFixed(0) ?? '0'}€'),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Critères d'éligibilité
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.rule,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Critères d\'Éligibilité',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '• Minimum 25,000 vues requises\n• Tous les clippers éligibles participent\n• Aucune restriction de pourcentage\n• Anti-spam automatique',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Système de calcul
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calculate,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Système de Calcul',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Distribution Pareto + Multiplicateurs 3D\n\nMultiplicateurs:\n• Vues: 7 niveaux (×1.0 à ×4.5)\n• Régularité: 5 niveaux (×1.0 à ×1.75)\n• Volume: 5 niveaux (×1.0 à ×1.5)',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Performances par niveau
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.purple.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: Colors.purple,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Niveaux de Performance',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildPerformanceLevel('VIRAL', '1M+', Colors.red),
                _buildPerformanceLevel('TRENDING', '500k+', Colors.orange),
                _buildPerformanceLevel('STAR', '250k+', Colors.purple),
                _buildPerformanceLevel('POPULAIRE', '100k+', Colors.blue),
                _buildPerformanceLevel('ÉMERGENT', '50k+', Colors.amber),
                _buildPerformanceLevel('STANDARD', '<50k', Colors.grey),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Détails de la campagne
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.teal.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info,
                      color: Colors.teal,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Détails de la Campagne',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Nom', widget.campaign.title),
                _buildInfoRow('Statut', _getStatusText()),
                _buildInfoRow('Budget total', '${widget.campaign.cagnotteAmount.toInt()}€'),
                _buildInfoRow('Date de création', _formatDate(widget.campaign.createdAt)),
                if (widget.campaign.endDate != null)
                  _buildInfoRow('Date de fin', _formatDate(widget.campaign.endDate!)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClippersRanking() {
    // Calculer avec le nouveau système
    final earnings = _getDistributionResult();
    final stats = EarningsCalculationEngine.calculateDistributionStats(earnings);
    
    // Créer une liste complète avec tous les clippers triés par vues
    final allClippers = List<Clipper>.from(widget.campaign.clippers);
    allClippers.sort((a, b) => b.totalViews.compareTo(a.totalViews));
    
    // Limiter l'affichage selon l'état
    final displayedClippers = _showAllClippers 
        ? allClippers 
        : allClippers.take(5).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec seuils d'éligibilité
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getContentColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getContentColor().withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Classement des Clippers',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Carte d'informations sur le live
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue.withOpacity(0.8),
                        Colors.indigo.withOpacity(0.9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getStreamStatusIcon(),
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
                                  widget.campaign.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _getStreamComment(),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildInfoStat('Vues Clippers', _formatNumber(_getTotalClippersViews()), Icons.visibility),
                          const SizedBox(width: 16),
                          _buildInfoStat('Cagnotte', '${widget.campaign.cagnotteAmount.toInt()}€', Icons.euro),
                          const SizedBox(width: 16),
                          _buildInfoStat('Participants', '${widget.campaign.clippers.length}', Icons.people),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: _getContentColor(),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Éligibilité: 25k vues minimum • ${stats['eligibleCount'] ?? 0} clippers éligibles',
                        style: TextStyle(
                          color: _getContentColor(),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Liste des clippers
          ...displayedClippers.asMap().entries.map((entry) {
            final index = entry.key;
            final clipper = entry.value;
            final rank = index + 1;
            
            // Vérifier l'éligibilité
            final isEligible = clipper.totalViews >= 25000 && !clipper.banned;
            
            // Trouver les gains si éligible
            ClipperEarning? earning;
            if (isEligible) {
              try {
                earning = earnings.firstWhere((e) => e.clipper.id == clipper.id);
              } catch (e) {
                earning = null;
              }
            }
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: isEligible && rank <= 3 ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _getRankColor(rank).withOpacity(0.05),
                    _getRankColor(rank).withOpacity(0.1),
                  ],
                ) : null,
                color: isEligible && rank > 3 ? Theme.of(context).cardColor : 
                       !isEligible ? Colors.red.withOpacity(0.03) : null,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isEligible 
                    ? (rank <= 3 ? _getRankColor(rank).withOpacity(0.3) : _getContentColor().withOpacity(0.2))
                    : Colors.red.withOpacity(0.2),
                  width: isEligible && rank <= 3 ? 2 : 1,
                ),
                boxShadow: isEligible && rank <= 3 ? [
                  BoxShadow(
                    color: _getRankColor(rank).withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ] : null,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Badge de rang ou statut non-éligible
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: isEligible && rank <= 3 
                            ? LinearGradient(
                                colors: [
                                  _getRankColor(rank),
                                  _getRankColor(rank).withOpacity(0.7),
                                ],
                              )
                            : null,
                          color: isEligible 
                            ? (rank > 3 ? _getContentColor() : null)
                            : Colors.red.shade400,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: isEligible
                            ? (rank <= 3 
                                ? Icon(
                                    rank == 1 ? Icons.emoji_events :
                                    rank == 2 ? Icons.workspace_premium :
                                    Icons.star,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : Text(
                                    '$rank',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ))
                            : Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Avatar
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: isEligible 
                          ? _getContentColor().withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                        child: Text(
                          clipper.username[0].toUpperCase(),
                          style: TextStyle(
                            color: isEligible ? _getContentColor() : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Informations détaillées
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      clipper.username,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          isEligible ? 'ÉLIGIBLE' : 'NON ÉLIGIBLE',
                                          style: TextStyle(
                                            color: isEligible ? _getContentColor() : Colors.red,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _getPerformanceBadgeColor(clipper.totalViews).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: _getPerformanceBadgeColor(clipper.totalViews).withOpacity(0.3),
                                            ),
                                          ),
                                          child: Text(
                                            _getPerformanceBadgeText(clipper.totalViews),
                                            style: TextStyle(
                                              color: _getPerformanceBadgeColor(clipper.totalViews),
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Text(
                                  isEligible && earning != null 
                                    ? '${earning.finalAmount.toStringAsFixed(0)}€'
                                    : '0€',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isEligible ? _getContentColor() : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.remove_red_eye,
                                  size: 14,
                                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${_formatNumber(clipper.totalViews)} vues',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                                  ),
                                ),
                                const Spacer(),
                                if (isEligible && earning != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getContentColor().withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '×${earning.multipliers.totalMultiplier.toStringAsFixed(1)}',
                                      style: TextStyle(
                                        color: _getContentColor(),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                else if (!isEligible)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      clipper.banned ? 'BANNI' : '< 25k',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
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
                  
                  // Détail des multiplicateurs pour le top 3 éligible
                  if (isEligible && earning != null && rank <= 3) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMiniMultiplier('Vues', earning.multipliers.viewsMultiplier, earning.multipliers.viewsTier),
                          _buildMiniMultiplier('Régularité', earning.multipliers.consistencyBonus, earning.multipliers.consistencyTier),
                          _buildMiniMultiplier('Volume', earning.multipliers.volumeMultiplier, earning.multipliers.volumeTier),
                        ],
                      ),
                    ),
                  ],
                  
                  // Message d'aide pour les non-éligibles
                  if (!isEligible) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.red,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              clipper.banned 
                                ? 'Clipper banni - Pas de gains'
                                : 'Seuil requis: 25,000 vues minimum',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
          
          // Bouton "Voir plus" / "Voir moins"
          if (widget.campaign.clippers.length > 5) ...[
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showAllClippers = !_showAllClippers;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: _getContentColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getContentColor().withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _showAllClippers 
                          ? 'Voir moins' 
                          : 'Voir tous (${widget.campaign.clippers.length})',
                        style: TextStyle(
                          color: _getContentColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _showAllClippers ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: _getContentColor(),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildMiniMultiplier(String label, double multiplier, String tier) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
        ),
        Text(
          '×${multiplier.toStringAsFixed(1)}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: _getContentColor(),
          ),
        ),
        Text(
          tier,
          style: TextStyle(
            fontSize: 9,
            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  // Méthodes pour la carte d'informations
  IconData _getStreamStatusIcon() {
    final clippersViews = _getTotalClippersViews();
    if (clippersViews >= 1000000) return Icons.whatshot; // 1M+ = Viral
    if (clippersViews >= 500000) return Icons.trending_up; // 500k+ = Trending
    if (clippersViews >= 100000) return Icons.visibility; // 100k+ = Populaire
    return Icons.play_circle_outline; // Moins = Normal
  }

  String _getStreamComment() {
    final clippersViews = _getTotalClippersViews();
    if (clippersViews >= 1000000) return "🔥 Clippers VIRAUX ! Performance exceptionnelle";
    if (clippersViews >= 500000) return "📈 En tendance ! Très belle communauté";
    if (clippersViews >= 100000) return "✨ Populaire ! Bonne engagement";
    if (clippersViews >= 50000) return "👍 Correct ! Communauté active";
    return "📊 Communauté en croissance...";
  }

  Widget _buildInfoStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white.withOpacity(0.8),
              size: 16,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Méthodes pour les badges de performance
  Color _getPerformanceBadgeColor(int views) {
    if (views >= 1000000) return Colors.red; // Viral
    if (views >= 500000) return Colors.orange; // Trending
    if (views >= 250000) return Colors.purple; // Star
    if (views >= 100000) return Colors.blue; // Populaire
    if (views >= 50000) return Colors.amber; // Émergent
    return Colors.grey; // Standard
  }

  String _getPerformanceBadgeText(int views) {
    if (views >= 1000000) return "VIRAL";
    if (views >= 500000) return "TRENDING";
    if (views >= 250000) return "STAR";
    if (views >= 100000) return "POPULAIRE";
    if (views >= 50000) return "ÉMERGENT";
    return "STANDARD";
  }

  // Calcul du total des vues des clippers
  int _getTotalClippersViews() {
    return widget.campaign.clippers.fold<int>(0, (total, clipper) => total + clipper.totalViews);
  }

  // Méthodes pour l'onglet Informations
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceLevel(String title, String threshold, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            threshold,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText() {
    switch (widget.campaign.status) {
      case CampaignStatus.active:
        return "Active";
      case CampaignStatus.completed:
        return "Terminée";
      case CampaignStatus.draft:
        return "Brouillon";
      case CampaignStatus.archived:
        return "Archivée";
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}