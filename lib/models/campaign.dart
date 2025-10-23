import 'clipper.dart';

enum CampaignStatus {
  active,
  completed,
  draft,
  archived,
}

class Campaign {
  final String id;
  final String title;
  final String description;
  final double cagnotteAmount;
  final int totalViews;
  final CampaignStatus status;
  final List<Clipper> clippers;
  final DateTime createdAt;
  final DateTime? endDate;

  Campaign({
    required this.id,
    required this.title,
    required this.description,
    required this.cagnotteAmount,
    required this.totalViews,
    required this.status,
    required this.clippers,
    required this.createdAt,
    this.endDate,
  });

  // Méthode factory pour créer une campagne de test
  factory Campaign.test({
    String id = 'test-campaign',
    String title = 'Campagne Test',
    String description = 'Une campagne de test',
    double cagnotteAmount = 1000.0,
    int totalViews = 500000,
    CampaignStatus status = CampaignStatus.active,
    List<Clipper>? clippers,
  }) {
    return Campaign(
      id: id,
      title: title,
      description: description,
      cagnotteAmount: cagnotteAmount,
      totalViews: totalViews,
      status: status,
      clippers: clippers ?? [],
      createdAt: DateTime.now(),
    );
  }
}