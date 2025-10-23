class LocalClip {
  final String path;
  final String liveId;
  final String liveTitle;
  final String? liveThumbnail;
  final String creator;

  LocalClip({
    required this.path,
    required this.liveId,
    required this.liveTitle,
    this.liveThumbnail,
    required this.creator,
  });

  Map<String, dynamic> toJson() => {
    'path': path,
    'liveId': liveId,
    'liveTitle': liveTitle,
    'liveThumbnail': liveThumbnail,
    'creator': creator,
  };

  static LocalClip fromJson(Map<String, dynamic> json) => LocalClip(
    path: json['path'],
    liveId: json['liveId'],
    liveTitle: json['liveTitle'],
    liveThumbnail: json['liveThumbnail'],
    creator: json['creator'] ?? '',
  );
}
