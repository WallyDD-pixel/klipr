import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/local_clip.dart';

class MesClipsRepository {
  static const String _key = 'processed_clips_v2';
  static Future<List<LocalClip>> getProcessedClips() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> raw = prefs.getStringList(_key) ?? [];
    return raw.map((e) => LocalClip.fromJson(jsonDecode(e))).toList();
  }
  static Future<void> addClip(LocalClip clip) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> raw = prefs.getStringList(_key) ?? [];
    raw.add(jsonEncode(clip.toJson()));
    await prefs.setStringList(_key, raw);
  }
  static Future<void> removeClip(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> raw = prefs.getStringList(_key) ?? [];
    raw.removeWhere((e) => LocalClip.fromJson(jsonDecode(e)).path == path);
    await prefs.setStringList(_key, raw);
  }
}
