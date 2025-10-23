import 'clipper.dart';
import 'campaign.dart';

class LiveCampaign {
  final String id;
  final String streamerName;
  final String streamTitle;
  final String platform;
  final double cagnotte;
  final int clipsCreated;
  final bool isLive;
  final int viewerCount;
  final String thumbnailUrl;
  final String gameCategory;
  final DateTime startTime;
  final int followerCount;
  final bool isNewStreamer; // Compte créé dans les 6 derniers mois
  final double engagementRate; // Ratio interactions/viewers
  final int monthlyViewers;
  final Duration streamDuration;
  final String? channelUrl; // URL de la chaîne pour les rediffs
  final String? replayUrl; // URL de la rediffusion si disponible
  final String contentType; // 'live', 'replay', 'video' (pour YouTube)
  
  // Propriétés pour la cagnotte et les clippers
  List<Clipper> clippers = [];
  
  // Score de recommandation calculé
  double _recommendationScore = 0.0;

  LiveCampaign({
    required this.id,
    required this.streamerName,
    required this.streamTitle,
    required this.platform,
    required this.cagnotte,
    required this.clipsCreated,
    required this.isLive,
    required this.viewerCount,
    required this.thumbnailUrl,
    required this.gameCategory,
    DateTime? startTime,
    required this.followerCount,
    required this.isNewStreamer,
    double? engagementRate,
    required this.monthlyViewers,
    required this.streamDuration,
    this.channelUrl,
    this.replayUrl,
    required this.contentType,
    List<Clipper>? clippers,
  }) : startTime = startTime ?? DateTime.now(),
       engagementRate = engagementRate ?? 0.5 {
    this.clippers = clippers ?? [];
  }

  // Getters pour compatibilité avec la page cagnotte
  double get cagnotteAmount => cagnotte;
  int get totalViews => viewerCount * 100; // Estimation basée sur les viewers actuels

  // Méthode pour calculer le score de recommandation équitable
  void calculateRecommendationScore() {
    // 1. Ratio cagnotte/clips (encourage les gros challenges peu exploités)
    double cagnotteClipsRatio = clipsCreated > 0 ? cagnotte / clipsCreated : cagnotte;
    double cagnotteScore = (cagnotteClipsRatio / 100).clamp(0.0, 1.0);

    // 2. Boost pour petits streamers (courbe logarithmique inversée)
    double smallStreamerBoost = 1.0 - (viewerCount / (viewerCount + 5000)).clamp(0.0, 0.8);
    if (isNewStreamer) smallStreamerBoost *= 1.3;

    // 3. Freshness - favorise les lives récents
    int minutesLive = DateTime.now().difference(startTime).inMinutes;
    double freshnessScore = (1.0 - (minutesLive / 180).clamp(0.0, 0.8));

    // 4. Engagement rate
    double engagementScore = engagementRate.clamp(0.0, 1.0);

    // 5. Diversité (bonus si différent de ce qui est déjà affiché)
    double diversityScore = 0.5; // Sera calculé dynamiquement

    _recommendationScore = (cagnotteScore * 0.30) +
           (smallStreamerBoost * 0.25) +
           (freshnessScore * 0.20) +
           (engagementScore * 0.15) +
           (diversityScore * 0.10);
  }

  // Getter pour le score de recommandation
  double get recommendationScore => _recommendationScore;

  // Algorithme de score de recommandation équitable
  double get _legacyRecommendationScore {
    // 1. Ratio cagnotte/clips (encourage les gros challenges peu exploités)
    double cagnotteClipsRatio = clipsCreated > 0 ? cagnotte / clipsCreated : cagnotte;
    double cagnotteScore = (cagnotteClipsRatio / 100).clamp(0.0, 1.0);

    // 2. Boost pour petits streamers (courbe logarithmique inversée)
    double smallStreamerBoost = 1.0 - (viewerCount / (viewerCount + 5000)).clamp(0.0, 0.8);
    if (isNewStreamer) smallStreamerBoost *= 1.3;

    // 3. Freshness - favorise les lives récents
    int minutesLive = DateTime.now().difference(startTime).inMinutes;
    double freshnessScore = (1.0 - (minutesLive / 180).clamp(0.0, 0.8));

    // 4. Engagement rate
    double engagementScore = engagementRate.clamp(0.0, 1.0);

    // 5. Diversité (bonus si différent de ce qui est déjà affiché)
    double diversityScore = 0.5; // Sera calculé dynamiquement

    return (cagnotteScore * 0.30) +
           (smallStreamerBoost * 0.25) +
           (freshnessScore * 0.20) +
           (engagementScore * 0.15) +
           (diversityScore * 0.10);
  }

  // Helper pour la taille de l'audience
  String get audienceSize {
    if (viewerCount < 100) return 'Micro';
    if (viewerCount < 1000) return 'Petit';
    if (viewerCount < 5000) return 'Moyen';
    if (viewerCount < 20000) return 'Grand';
    return 'Mega';
  }

  // Conversion vers Campaign pour CagnotteDetailsPage
  Campaign toCampaign() {
    return Campaign(
      id: id,
      title: streamTitle,
      description: 'Live de $streamerName - $gameCategory',
      cagnotteAmount: cagnotte,
      totalViews: viewerCount * 10, // Estimation des vues totales
      status: isLive ? CampaignStatus.active : CampaignStatus.completed,
      clippers: clippers,
      createdAt: startTime,
      endDate: isLive ? null : startTime.add(streamDuration),
    );
  }
}