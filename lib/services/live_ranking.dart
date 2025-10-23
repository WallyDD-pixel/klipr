import 'dart:math' as math;
import '../models/clipper.dart';
import 'earnings_calculator.dart';

/// Système de classement spécifique par live
class LiveSpecificRanking {
  
  /// Calcule l'éligibilité pour un live spécifique
  static EligibilityResult calculateLiveEligibility(
    String liveId,
    List<Clipper> clippersForThisLive,
    double cagnotteAmount
  ) {
    
    // 1. Filtrer directement par le seuil de 25k vues
    List<Clipper> eligibleClippers = clippersForThisLive
        .where((clipper) => clipper.totalViews >= 25000)
        .toList();
    
    // 2. Trier par vues décroissantes
    eligibleClippers.sort((a, b) => b.totalViews.compareTo(a.totalViews));
    
    // 3. S'assurer qu'on a des participants
    if (eligibleClippers.isEmpty) {
      return EligibilityResult(
        liveId: liveId,
        eligibleClippers: [],
        totalParticipants: clippersForThisLive.length,
        eligibleCount: 0,
        thresholdViews: 25000,
        thresholdClips: 0,
      );
    }
    
    return EligibilityResult(
      liveId: liveId,
      eligibleClippers: eligibleClippers,
      totalParticipants: clippersForThisLive.length,
      eligibleCount: eligibleClippers.length,
      thresholdViews: 25000, // Toujours 25k
      thresholdClips: 0,
    );
  }
  
  /// Obtient le rang d'un clipper spécifique pour un live
  static int getClipperRankForLive(
    String liveId,
    Clipper targetClipper,
    List<Clipper> allClippersForLive
  ) {
    // Trier par vues décroissantes et trouver le rang
    List<Clipper> sortedClippers = List<Clipper>.from(allClippersForLive);
    sortedClippers.sort((a, b) => b.totalViews.compareTo(a.totalViews));
    
    for (int i = 0; i < sortedClippers.length; i++) {
      if (sortedClippers[i].id == targetClipper.id) {
        return i + 1; // Rang commence à 1
      }
    }
    
    return -1; // Non trouvé
  }
}

/// Système anti-spam
class AntiSpamSystem {
  
  /// Obtient la limite quotidienne selon le tier
  static int getDailyLimit(ClipperTier tier) {
    switch (tier) {
      case ClipperTier.newUser:
        return 3;
      case ClipperTier.verified:
        return 6;
      case ClipperTier.premium:
        return 12;
      case ClipperTier.partner:
        return 24;
    }
  }
  
  /// Vérifie si un comportement est suspect (simplifié pour la démo)
  static bool isSpamBehavior(Clipper clipper) {
    // Dans la vraie app, on vérifierait:
    // - Clips trop courts (< 10 secondes)
    // - Burst posting (> 5 clips/heure)  
    // - Contenu similaire récent
    // - Même timestamp du live
    
    // Pour la démo, on considère spam si trop de clips en peu de temps
    return clipper.successRate < 0.1 && clipper.totalClipsPosted > 10;
  }
  
  /// Vérifie les limites quotidiennes (simplifié)
  static bool hasExceededDailyLimit(Clipper clipper) {
    // Dans la vraie app, on vérifierait les clips soumis aujourd'hui
    // Pour la démo, on utilise une estimation
    int dailyLimit = getDailyLimit(clipper.tier);
    int estimatedDailyClips = clipper.totalClipsPosted > 0 ? 
        math.min(dailyLimit, (clipper.totalClipsPosted / 7).round()) : 0;
    
    return estimatedDailyClips >= dailyLimit;
  }
}