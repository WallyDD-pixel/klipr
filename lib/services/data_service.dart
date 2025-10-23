import 'dart:math';
import '../models/live_campaign.dart';
import '../models/clipper.dart';

/// Service de génération de données de démonstration
class DataService {
  static List<LiveCampaign> generateDemoData() {
    return [
      // Live Twitch
      LiveCampaign(
        id: '1',
        streamerName: 'ZeratoR',
        streamTitle: 'LIVE FR - Découverte du nouveau jeu indie ! 🎮',
        platform: 'Twitch',
        cagnotte: 850.0,
        clipsCreated: 12,
        isLive: true,
        viewerCount: 15420,
        thumbnailUrl: 'https://picsum.photos/400/300?random=1',
        gameCategory: 'Gaming',
        startTime: DateTime.now().subtract(const Duration(hours: 1)),
        followerCount: 1250000,
        isNewStreamer: false,
        engagementRate: 0.75,
        monthlyViewers: 450000,
        streamDuration: const Duration(hours: 2, minutes: 30),
        contentType: 'live',
        clippers: _generateClippersForCampaign(850.0, 12),
      ),

      // Rediffusion Twitch
      LiveCampaign(
        id: '2',
        streamerName: 'Domingo',
        streamTitle: 'REDIFF - Le meilleur moment du stream d\'hier !',
        platform: 'Twitch',
        cagnotte: 340.0,
        clipsCreated: 25,
        isLive: false,
        viewerCount: 2140,
        thumbnailUrl: 'https://picsum.photos/400/300?random=2',
        gameCategory: 'Gaming',
        startTime: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
        followerCount: 450000,
        isNewStreamer: false,
        engagementRate: 0.82,
        monthlyViewers: 180000,
        streamDuration: const Duration(hours: 4, minutes: 15),
        contentType: 'replay',
        replayUrl: 'https://twitch.tv/videos/123456789',
        clippers: _generateClippersForCampaign(340.0, 25),
      ),

      // Vidéo YouTube
      LiveCampaign(
        id: '3',
        streamerName: 'Squeezie',
        streamTitle: 'TOP 10 des MOMENTS les plus FOUS en LIVE !',
        platform: 'YouTube',
        cagnotte: 0.0,
        clipsCreated: 0,
        isLive: false,
        viewerCount: 125000,
        thumbnailUrl: 'https://picsum.photos/400/300?random=3',
        gameCategory: 'Entertainment',
        startTime: DateTime.now().subtract(const Duration(hours: 6)),
        followerCount: 18500000,
        isNewStreamer: false,
        engagementRate: 0.95,
        monthlyViewers: 8500000,
        streamDuration: const Duration(minutes: 12, seconds: 34),
        contentType: 'video',
        channelUrl: 'https://youtube.com/@squeezie',
        clippers: [], // YouTube n'a pas de système de cagnotte
      ),

      // Live Kick
      LiveCampaign(
        id: '4',
        streamerName: 'AminePlays',
        streamTitle: 'LIVE KICK - Gaming session chill 🎮',
        platform: 'Kick',
        cagnotte: 420.0,
        clipsCreated: 5,
        isLive: true,
        viewerCount: 3240,
        thumbnailUrl: 'https://picsum.photos/400/300?random=4',
        gameCategory: 'Gaming',
        startTime: DateTime.now().subtract(const Duration(hours: 2)),
        followerCount: 45000,
        isNewStreamer: true,
        engagementRate: 0.78,
        monthlyViewers: 25000,
        streamDuration: const Duration(hours: 3, minutes: 10),
        contentType: 'live',
        clippers: _generateClippersForCampaign(420.0, 5),
      ),

      // Live Twitch supplémentaire
      LiveCampaign(
        id: '5',
        streamerName: 'BuildMasterFR',
        streamTitle: 'LIVE MINECRAFT - Construction du château ! 🏰',
        platform: 'Twitch',
        cagnotte: 780.0,
        clipsCreated: 18,
        isLive: true,
        viewerCount: 5670,
        thumbnailUrl: 'https://picsum.photos/400/300?random=5',
        gameCategory: 'Gaming',
        startTime: DateTime.now().subtract(const Duration(hours: 3)),
        followerCount: 150000,
        isNewStreamer: false,
        engagementRate: 0.72,
        monthlyViewers: 65000,
        streamDuration: const Duration(hours: 4, minutes: 0),
        contentType: 'live',
        clippers: _generateClippersForCampaign(780.0, 18),
      ),
    ];
  }

  /// Génère une liste de clippers pour une campagne
  static List<Clipper> _generateClippersForCampaign(double totalCagnotte, int clipsCount) {
    if (totalCagnotte <= 0 || clipsCount <= 0) return [];
    
    final random = Random();
    final clipperNames = [
      'ClipMaster',
      'VideoWizard',
      'StreamSniper',
      'ClipHero',
      'MomentCapture',
      'HighlightPro',
      'ClipGenius',
      'VideoArtist',
      'ClipKing',
      'StreamCatcher',
      'MomentMaker',
      'ClipWizard',
    ];
    
    // Générer entre 8 et 25 clippers selon la taille de la campagne
    final clipperCount = (clipsCount * 0.6).clamp(8, 25).round();
    final clippers = <Clipper>[];
    
    // Distribution réaliste des performances
    for (int i = 0; i < clipperCount; i++) {
      final name = clipperNames[i % clipperNames.length];
      
      // Génération des vues avec distribution réaliste
      int totalViews;
      int successfulClips;
      int totalClipsPosted;
      ClipperTier tier;
      
      if (i < 2) {
        // Top 2: Viral legends
        totalViews = 500000 + random.nextInt(1500000); // 500k-2M vues
        successfulClips = 15 + random.nextInt(15);      // 15-30 clips réussis
        totalClipsPosted = successfulClips + random.nextInt(10); // Quelques ratés
        tier = ClipperTier.partner;
      } else if (i < 5) {
        // Top 3-5: Excellents performers
        totalViews = 200000 + random.nextInt(300000);   // 200k-500k vues
        successfulClips = 8 + random.nextInt(10);       // 8-18 clips réussis
        totalClipsPosted = successfulClips + random.nextInt(8);
        tier = ClipperTier.premium;
      } else if (i < 10) {
        // Top 6-10: Bons performers
        totalViews = 75000 + random.nextInt(150000);    // 75k-225k vues
        successfulClips = 4 + random.nextInt(8);        // 4-12 clips réussis
        totalClipsPosted = successfulClips + random.nextInt(12);
        tier = ClipperTier.verified;
      } else if (i < 15) {
        // Performers moyens
        totalViews = 35000 + random.nextInt(50000);     // 35k-85k vues
        successfulClips = 2 + random.nextInt(4);        // 2-6 clips réussis
        totalClipsPosted = successfulClips + random.nextInt(15);
        tier = ClipperTier.verified;
      } else {
        // Débutants/casuals
        totalViews = 15000 + random.nextInt(30000);     // 15k-45k vues
        successfulClips = 1 + random.nextInt(3);        // 1-4 clips réussis
        totalClipsPosted = successfulClips + random.nextInt(20);
        tier = ClipperTier.newUser;
      }
      
      // Quelques clippers sous le seuil pour montrer le système
      if (i >= clipperCount - 3) {
        totalViews = 5000 + random.nextInt(20000);      // Sous le seuil de 25k
        successfulClips = 0;
        totalClipsPosted = random.nextInt(10) + 1;
        tier = ClipperTier.newUser;
      }
      
      // Calcul des gains avec le nouveau système (sera recalculé)
      double earningsEstimate = _estimateEarnings(totalViews, successfulClips, totalClipsPosted, totalCagnotte, clipperCount);
      
      clippers.add(Clipper(
        id: 'clipper_$i',
        username: name,
        avatarUrl: 'https://picsum.photos/64/64?random=${100 + i}',
        clipsCount: successfulClips, // Clips réussis sur ce live
        totalViews: totalViews,
        earnings: earningsEstimate,
        lastClipDate: DateTime.now().subtract(Duration(hours: random.nextInt(48) + 1)),
        isVerified: tier != ClipperTier.newUser,
        bestClipTitle: i < 5 ? 'MOMENT ÉPIQUE !' : 'Highlight du live',
        bestClipViews: (totalViews * (0.3 + random.nextDouble() * 0.3)).round(),
        // Nouvelles propriétés
        successfulClipsCount: successfulClips,
        totalClipsPosted: totalClipsPosted,
        tier: tier,
        banned: false,
        qualityScore: _calculateQualityScore(totalViews, successfulClips, totalClipsPosted),
      ));
    }
    
    return clippers;
  }
  
  // Estime les gains avec l'ancien système (pour compatibilité)
  static double _estimateEarnings(int totalViews, int successfulClips, int totalClipsPosted, double totalCagnotte, int clipperCount) {
    if (totalViews < 25000) return 0.0; // Non éligible
    
    // Estimation simple basée sur les vues et la consistance
    double viewsScore = totalViews / 1000000.0; // Score sur les vues
    double consistencyScore = successfulClips / 20.0; // Score sur la consistance
    double combinedScore = (viewsScore * 0.7) + (consistencyScore * 0.3);
    
    // Part estimée de la cagnotte (sera recalculée précisément)
    double estimatedShare = (combinedScore.clamp(0.0, 1.0) * 0.4) + 0.01;
    return totalCagnotte * estimatedShare;
  }
  
  // Calcule un score de qualité pour le clipper
  static double _calculateQualityScore(int totalViews, int successfulClips, int totalClipsPosted) {
    if (totalClipsPosted == 0) return 0.5;
    
    double successRate = successfulClips / totalClipsPosted;
    double viewsQuality = (totalViews / 100000.0).clamp(0.0, 1.0); // Normalisé sur 100k vues
    double consistencyQuality = (successfulClips / 10.0).clamp(0.0, 1.0); // Normalisé sur 10 clips
    
    return (successRate * 0.4) + (viewsQuality * 0.3) + (consistencyQuality * 0.3);
  }

  /// Ajuste le nombre de viewers selon le type de contenu
  static int adjustViewerCount(int baseCount, String contentType) {
    switch (contentType) {
      case 'live':
        return baseCount; // Nombre réel pour les lives
      case 'replay':
        return (baseCount * 0.15).round(); // 15% pour les rediffusions
      case 'video':
        return (baseCount * 2.5).round(); // 250% pour les vidéos YouTube (vues cumulées)
      default:
        return baseCount;
    }
  }

  /// Simule le rafraîchissement des données
  static Future<List<LiveCampaign>> refreshData() async {
    // Simulation d'une requête réseau
    await Future.delayed(const Duration(seconds: 2));
    
    final data = generateDemoData();
    
    // Shuffle les données pour simuler un nouvel algorithme
    data.shuffle();
    
    // Note: On ne modifie pas directement viewerCount car il est final
    // Les variations seraient gérées dans une version production avec de nouveaux objets
    
    return data;
  }

  /// Filtre les données par type de contenu
  static List<LiveCampaign> filterByContentType(List<LiveCampaign> campaigns, String contentType) {
    return campaigns.where((campaign) => campaign.contentType == contentType).toList();
  }

  /// Filtre les données par plateforme
  static List<LiveCampaign> filterByPlatform(List<LiveCampaign> campaigns, String platform) {
    return campaigns.where((campaign) => campaign.platform == platform).toList();
  }

  /// Obtient les statistiques des données
  static Map<String, dynamic> getDataStats(List<LiveCampaign> campaigns) {
    final liveCount = campaigns.where((c) => c.contentType == 'live').length;
    final replayCount = campaigns.where((c) => c.contentType == 'replay').length;
    final videoCount = campaigns.where((c) => c.contentType == 'video').length;
    
    final twitchCount = campaigns.where((c) => c.platform == 'Twitch').length;
    final youtubeCount = campaigns.where((c) => c.platform == 'YouTube').length;
    final kickCount = campaigns.where((c) => c.platform == 'Kick').length;
    
    final totalViewers = campaigns.fold<int>(0, (sum, c) => sum + c.viewerCount);
    
    return {
      'total': campaigns.length,
      'contentTypes': {
        'live': liveCount,
        'replay': replayCount,
        'video': videoCount,
      },
      'platforms': {
        'Twitch': twitchCount,
        'YouTube': youtubeCount,
        'Kick': kickCount,
      },
      'totalViewers': totalViewers,
    };
  }
}