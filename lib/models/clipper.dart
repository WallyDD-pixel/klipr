/// Tiers de clippers pour le système anti-spam
enum ClipperTier {
  newUser,
  verified,
  premium,
  partner,
}

/// Modèle représentant un utilisateur qui a créé des clips
class Clipper {
  final String id;
  final String username;
  final String avatarUrl;
  final int clipsCount;
  final int totalViews;
  final double earnings; // Gains générés par ses clips
  final DateTime lastClipDate;
  final bool isVerified;
  final String? bestClipTitle;
  final int? bestClipViews;
  
  // Nouvelles propriétés pour le système de récompense
  final int successfulClipsCount; // Clips avec 25k+ vues
  final int totalClipsPosted;     // Tous les clips postés (même ratés)
  final ClipperTier tier;         // Niveau du clipper pour anti-spam
  final bool banned;              // Status de ban
  final double qualityScore;      // Score de qualité historique
  
  const Clipper({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.clipsCount,
    required this.totalViews,
    required this.earnings,
    required this.lastClipDate,
    this.isVerified = false,
    this.bestClipTitle,
    this.bestClipViews,
    // Nouvelles propriétés avec valeurs par défaut
    this.successfulClipsCount = 0,
    this.totalClipsPosted = 0,
    this.tier = ClipperTier.newUser,
    this.banned = false,
    this.qualityScore = 0.5,
  });
  
  /// Calcule le gain moyen par clip
  double get averageEarningsPerClip {
    if (clipsCount == 0) return 0.0;
    return earnings / clipsCount;
  }
  
  /// Calcule les vues moyennes par clip
  double get averageViewsPerClip {
    if (clipsCount == 0) return 0.0;
    return totalViews / clipsCount;
  }
  
  /// Calcule le taux de réussite (clips 25k+ / total clips)
  double get successRate {
    if (totalClipsPosted == 0) return 0.0;
    return successfulClipsCount / totalClipsPosted;
  }
  
  /// Vérifie si le clipper peut soumettre un clip (anti-spam)
  bool get canSubmitClip {
    return !banned && !_isInCooldown();
  }
  
  /// Vérifie si le clipper est en cooldown
  bool _isInCooldown() {
    final now = DateTime.now();
    final timeSinceLastClip = now.difference(lastClipDate);
    
    switch (tier) {
      case ClipperTier.newUser:
        return timeSinceLastClip.inHours < 6;
      case ClipperTier.verified:
        return timeSinceLastClip.inHours < 3;
      case ClipperTier.premium:
        return timeSinceLastClip.inHours < 1;
      case ClipperTier.partner:
        return timeSinceLastClip.inMinutes < 30;
      default:
        return false; // Par défaut, pas de cooldown
    }
  }
  
  /// Obtient la limite quotidienne selon le tier
  int get dailyLimit {
    switch (tier) {
      case ClipperTier.newUser:
        return 3;
      case ClipperTier.verified:
        return 6;
      case ClipperTier.premium:
        return 12;
      case ClipperTier.partner:
        return 24;
      default:
        return 3; // Par défaut, limite de newUser
    }
  }
}

/// Statistiques globales de la cagnotte
class CagnotteStats {
  final double totalAmount;
  final int totalClips;
  final int totalViews;
  final int totalClippers;
  final double averageEarningsPerClip;
  final DateTime lastActivity;
  final Map<String, int> viewsByPlatform; // Répartition des vues par plateforme
  
  const CagnotteStats({
    required this.totalAmount,
    required this.totalClips,
    required this.totalViews,
    required this.totalClippers,
    required this.averageEarningsPerClip,
    required this.lastActivity,
    required this.viewsByPlatform,
  });
}