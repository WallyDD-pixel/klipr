import 'package:flutter/material.dart';
import '../../models/local_clip.dart';

class LiveClipsPage extends StatelessWidget {
  final String liveId;
  final List<LocalClip> clips;

  const LiveClipsPage({super.key, required this.liveId, required this.clips});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E293B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181C2F),
        title: Text(clips.first.liveTitle, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: clips.length,
        itemBuilder: (context, index) {
          final clip = clips[index];
          return Card(
            color: const Color(0xFF181C2F),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: clip.liveThumbnail != null && clip.liveThumbnail!.isNotEmpty
                  ? Image.network(clip.liveThumbnail!, width: 44, height: 28, fit: BoxFit.cover)
                  : Icon(Icons.videocam, color: Colors.white),
              title: Text(clip.liveTitle, style: const TextStyle(color: Color(0xFFB3C7F7), fontWeight: FontWeight.w700, fontSize: 13)),
              subtitle: Text('Créateur: ${clip.creator}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
              trailing: Icon(Icons.play_circle_fill, color: Color(0xFF38BDF8)),
              onTap: () {
                // Action pour ouvrir/voir le clip
              },
            ),
          );
        },
      ),
    );
  }
}
