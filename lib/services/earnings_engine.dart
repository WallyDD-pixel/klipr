import 'dart:math' as math;
import '../models/clipper.dart';
import 'earnings_calculator.dart';
import 'live_ranking.dart';

/// Moteur principal de calcul des gains
class EarningsCalculationEngine {
  
  /// MÉTHODE CENTRALE - Calcule la distribution des gains pour un live
  static List<ClipperEarning> calculateDistribution(
    String liveId,
    List<Clipper> allClippers, 
    double totalBudget
  ) {
    
    // ÉTAPE 1: Filtrage Anti-Spam + Éligibilité par live
    List<Clipper> eligibleClippers = allClippers
        .where((clipper) => _isEligible(clipper))
        .toList();
    
    if (eligibleClippers.isEmpty) {
      return [];
    }
    
    // ÉTAPE 2: Calculer l'éligibilité spécifique au live
    EligibilityResult eligibility = LiveSpecificRanking.calculateLiveEligibility(
      liveId,
      eligibleClippers,
      totalBudget
    );
    
    // ÉTAPE 3: Distribution Pareto de Base sur les éligibles du live
    List<double> baseEarnings = _calculateParetoDistribution(
      eligibility.eligibleClippers.length, 
      totalBudget
    );
    
    // ÉTAPE 4: Application des Multiplicateurs
    List<ClipperEarning> earnings = [];
    
    for (int i = 0; i < eligibility.eligibleClippers.length; i++) {
      Clipper clipper = eligibility.eligibleClippers[i];
      double baseEarning = baseEarnings[i];
      
      // Appliquer TOUS les multiplicateurs
      double finalEarning = _applyAllMultipliers(clipper, baseEarning);
      MultiplierBreakdown multipliers = MultiplierBreakdown.fromClipper(clipper);
      
      earnings.add(ClipperEarning(
        clipper: clipper,
        baseAmount: baseEarning,
        finalAmount: finalEarning,
        multipliers: multipliers,
        rank: i + 1,
      ));
    }
    
    // ÉTAPE 5: Normalisation pour Respecter le Budget
    _normalizeToBudget(earnings, totalBudget);
    
    // ÉTAPE 6: Tri final par gains décroissants
    earnings.sort((a, b) => b.finalAmount.compareTo(a.finalAmount));
    
    // Réassigner les rangs après le tri
    for (int i = 0; i < earnings.length; i++) {
      earnings[i] = ClipperEarning(
        clipper: earnings[i].clipper,
        baseAmount: earnings[i].baseAmount,
        finalAmount: earnings[i].finalAmount,
        multipliers: earnings[i].multipliers,
        rank: i + 1,
      );
    }
    
    return earnings;
  }
  
  /// Applique tous les multiplicateurs à un gain de base
  static double _applyAllMultipliers(Clipper clipper, double baseEarning) {
    // 1. Multiplicateur principal (vues)
    double viewsMultiplier = ViewsCalculator.getViewsMultiplier(clipper.totalViews);
    
    // 2. Bonus consistance
    double consistencyBonus = ConsistencyCalculator.getConsistencyBonus(
      clipper.successfulClipsCount
    );
    
    // 3. Multiplicateur volume
    double volumeMultiplier = VolumeCalculator.getVolumeMultiplier(
      clipper.totalClipsPosted
    );
    
    // FORMULE FINALE (sans fraîcheur)
    return baseEarning 
      * viewsMultiplier 
      * (1 + consistencyBonus) 
      * volumeMultiplier;
  }
  
  /// Vérification d'éligibilité (combine anti-spam + seuil minimum)
  static bool _isEligible(Clipper clipper) {
    return clipper.totalViews >= 25000 &&           // Seuil minimum
           !clipper.banned &&                        // Pas banni
           clipper.canSubmitClip &&                   // Pas en cooldown
           !AntiSpamSystem.isSpamBehavior(clipper) && // Pas de spam
           !AntiSpamSystem.hasExceededDailyLimit(clipper); // Limite quotidienne
  }
  
  /// Calcule la distribution Pareto adaptative
  static List<double> _calculateParetoDistribution(int clipperCount, double totalBudget) {
    if (clipperCount == 0) return [];
    
    List<double> earnings = [];
    
    // Facteur de concentration selon le nombre de participants
    double concentrationFactor = _getConcentrationFactor(clipperCount);
    
    // Distribution Pareto adaptée
    for (int i = 0; i < clipperCount; i++) {
      double basePercentage = _getBasePercentage(i, clipperCount);
      double adjustedPercentage = basePercentage * concentrationFactor;
      earnings.add(totalBudget * adjustedPercentage);
    }
    
    return earnings;
  }
  
  /// Calcule le facteur de concentration selon le nombre de participants
  static double _getConcentrationFactor(int clipperCount) {
    // Plus il y a de participants, moins la concentration est forte
    if (clipperCount <= 10) return 1.0;        // Concentration normale
    if (clipperCount <= 25) return 0.8;        // Concentration réduite
    if (clipperCount <= 50) return 0.6;        // Concentration faible
    return 0.4;                                 // Concentration minimale
  }
  
  /// Obtient le pourcentage de base pour une position donnée
  static double _getBasePercentage(int position, int totalCount) {
    // Distribution Pareto classique adaptée
    switch (position) {
      case 0: return 0.25;  // 1er: 25%
      case 1: return 0.18;  // 2e: 18%
      case 2: return 0.12;  // 3e: 12%
      case 3: return 0.08;  // 4e: 8%
      case 4: return 0.06;  // 5e: 6%
      default:
        // Pour les positions suivantes, distribution décroissante
        double remainingPercentage = 0.31; // 31% restant
        int remainingPositions = totalCount - 5;
        if (remainingPositions <= 0) return 0.0;
        
        // Distribution décroissante pour le reste
        double baseShare = remainingPercentage / remainingPositions;
        double positionFactor = 1.0 - ((position - 5) * 0.1).clamp(0.0, 0.8);
        return baseShare * positionFactor;
    }
  }
  
  /// Normalise les gains pour respecter exactement le budget
  static void _normalizeToBudget(List<ClipperEarning> earnings, double targetBudget) {
    if (earnings.isEmpty) return;
    
    double totalCalculated = earnings.fold(0.0, (sum, earning) => sum + earning.finalAmount);
    
    if (totalCalculated <= 0) return;
    
    double scaleFactor = targetBudget / totalCalculated;
    
    // Appliquer le facteur de normalisation
    for (int i = 0; i < earnings.length; i++) {
      ClipperEarning earning = earnings[i];
      double normalizedAmount = earning.finalAmount * scaleFactor;
      
      earnings[i] = ClipperEarning(
        clipper: earning.clipper,
        baseAmount: earning.baseAmount,
        finalAmount: normalizedAmount,
        multipliers: earning.multipliers,
        rank: earning.rank,
      );
    }
  }
  
  /// Calcule les statistiques globales d'une distribution
  static Map<String, dynamic> calculateDistributionStats(List<ClipperEarning> earnings) {
    if (earnings.isEmpty) {
      return {
        'totalAmount': 0.0,
        'averageEarning': 0.0,
        'medianEarning': 0.0,
        'topPercentage': 0.0,
        'giniCoefficient': 0.0,
      };
    }
    
    double totalAmount = earnings.fold(0.0, (sum, e) => sum + e.finalAmount);
    double averageEarning = totalAmount / earnings.length;
    
    List<double> amounts = earnings.map((e) => e.finalAmount).toList()..sort();
    double medianEarning = amounts[amounts.length ~/ 2];
    
    // Pourcentage du budget pour le top 10%
    int top10Count = math.max(1, (earnings.length * 0.1).ceil());
    double top10Amount = earnings.take(top10Count).fold(0.0, (sum, e) => sum + e.finalAmount);
    double topPercentage = (top10Amount / totalAmount) * 100;
    
    return {
      'totalAmount': totalAmount,
      'averageEarning': averageEarning,
      'medianEarning': medianEarning,
      'topPercentage': topPercentage,
      'eligibleCount': earnings.length,
    };
  }
}