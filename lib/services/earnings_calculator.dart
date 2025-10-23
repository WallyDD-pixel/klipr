import '../models/clipper.dart';

/// Calculateur des multiplicateurs basés sur les vues
class ViewsCalculator {
  static double getViewsMultiplier(int totalViews) {
    if (totalViews < 25000) return 0.0;      // Non éligible
    if (totalViews < 50000) return 1.0;      // Base
    if (totalViews < 100000) return 1.3;     // Bon
    if (totalViews < 250000) return 1.7;     // Très bon
    if (totalViews < 500000) return 2.2;     // Excellent
    if (totalViews < 1000000) return 3.0;    // Viral
    return 4.5;                              // Légende
  }
  
  static String getViewsTierName(int totalViews) {
    if (totalViews < 25000) return 'Non éligible';
    if (totalViews < 50000) return 'Base';
    if (totalViews < 100000) return 'Bon';
    if (totalViews < 250000) return 'Très bon';
    if (totalViews < 500000) return 'Excellent';
    if (totalViews < 1000000) return 'Viral';
    return 'Légende';
  }
}

/// Calculateur des bonus de consistance
class ConsistencyCalculator {
  static double getConsistencyBonus(int successfulClips) {
    if (successfulClips <= 2) return 0.0;    // Débutant
    if (successfulClips <= 5) return 0.2;    // Régulier (+20%)
    if (successfulClips <= 10) return 0.4;   // Expert (+40%)
    if (successfulClips <= 20) return 0.65;  // Master (+65%)
    return 1.0;                              // Legend (+100%)
  }
  
  static String getConsistencyTierName(int successfulClips) {
    if (successfulClips <= 2) return 'Débutant';
    if (successfulClips <= 5) return 'Régulier';
    if (successfulClips <= 10) return 'Expert';
    if (successfulClips <= 20) return 'Master';
    return 'Legend';
  }
}

/// Calculateur des multiplicateurs de volume
class VolumeCalculator {
  static double getVolumeMultiplier(int totalClipsPosted) {
    if (totalClipsPosted <= 5) return 1.0;    // Casual
    if (totalClipsPosted <= 15) return 1.1;   // Actif (+10%)
    if (totalClipsPosted <= 30) return 1.2;   // Productif (+20%)
    if (totalClipsPosted <= 50) return 1.35;  // Prolific (+35%)
    return 1.5;                               // Machine (+50%)
  }
  
  static String getVolumeTierName(int totalClipsPosted) {
    if (totalClipsPosted <= 5) return 'Casual';
    if (totalClipsPosted <= 15) return 'Actif';
    if (totalClipsPosted <= 30) return 'Productif';
    if (totalClipsPosted <= 50) return 'Prolific';
    return 'Machine';
  }
}

/// Classe pour stocker les détails des multiplicateurs
class MultiplierBreakdown {
  final double viewsMultiplier;
  final double consistencyBonus;
  final double volumeMultiplier;
  final double totalMultiplier;
  final String viewsTier;
  final String consistencyTier;
  final String volumeTier;
  
  const MultiplierBreakdown({
    required this.viewsMultiplier,
    required this.consistencyBonus,
    required this.volumeMultiplier,
    required this.totalMultiplier,
    required this.viewsTier,
    required this.consistencyTier,
    required this.volumeTier,
  });
  
  factory MultiplierBreakdown.fromClipper(Clipper clipper) {
    final viewsMultiplier = ViewsCalculator.getViewsMultiplier(clipper.totalViews);
    final consistencyBonus = ConsistencyCalculator.getConsistencyBonus(clipper.successfulClipsCount);
    final volumeMultiplier = VolumeCalculator.getVolumeMultiplier(clipper.totalClipsPosted);
    
    final totalMultiplier = viewsMultiplier * (1 + consistencyBonus) * volumeMultiplier;
    
    return MultiplierBreakdown(
      viewsMultiplier: viewsMultiplier,
      consistencyBonus: consistencyBonus,
      volumeMultiplier: volumeMultiplier,
      totalMultiplier: totalMultiplier,
      viewsTier: ViewsCalculator.getViewsTierName(clipper.totalViews),
      consistencyTier: ConsistencyCalculator.getConsistencyTierName(clipper.successfulClipsCount),
      volumeTier: VolumeCalculator.getVolumeTierName(clipper.totalClipsPosted),
    );
  }
}

/// Résultat de calcul des gains pour un clipper
class ClipperEarning {
  final Clipper clipper;
  final double baseAmount;           // Gain Pareto de base
  final double finalAmount;          // Gain final après multiplicateurs
  final MultiplierBreakdown multipliers; // Détail des bonus
  final int rank;                    // Position dans le classement
  
  const ClipperEarning({
    required this.clipper,
    required this.baseAmount,
    required this.finalAmount,
    required this.multipliers,
    required this.rank,
  });
}

/// Résultat d'éligibilité pour un live
class EligibilityResult {
  final String liveId;
  final List<Clipper> eligibleClippers;
  final int totalParticipants;
  final int eligibleCount;
  final int thresholdViews;
  final int thresholdClips;
  
  const EligibilityResult({
    required this.liveId,
    required this.eligibleClippers,
    required this.totalParticipants,
    required this.eligibleCount,
    required this.thresholdViews,
    required this.thresholdClips,
  });
}

/// Performance d'un clipper sur un live spécifique
class LiveClipperPerformance {
  final Clipper clipper;
  final String liveId;
  final int totalViewsOnThisLive;
  final int clipsCountOnThisLive;
  final int bestClipViews;
  final double liveScore;
  
  LiveClipperPerformance({
    required this.clipper,
    required this.liveId,
    required this.totalViewsOnThisLive,
    required this.clipsCountOnThisLive,
    required this.bestClipViews,
  }) : liveScore = _calculateLiveScore(totalViewsOnThisLive, clipsCountOnThisLive, bestClipViews);
  
  static double _calculateLiveScore(int totalViews, int clipsCount, int bestClipViews) {
    return (totalViews * 1.0) +           // Vues totales sur ce live
           (clipsCount * 5000) +          // Bonus par clip réussi
           (bestClipViews * 0.5);         // Bonus meilleur clip
  }
}