import 'package:flutter/material.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TikTokLoginPage extends StatefulWidget {
  @override
  _TikTokLoginPageState createState() => _TikTokLoginPageState();
}

class _TikTokLoginPageState extends State<TikTokLoginPage> {
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkIfAlreadyConnected();
  }

  Future<void> _checkIfAlreadyConnected() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('tiktok_access_token');
    if (accessToken != null && accessToken.isNotEmpty) {
      Future.delayed(Duration.zero, () {
        Navigator.of(context).pushReplacementNamed('/home');
      });
    }
  }

  Future<void> _loginWithTikTok() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Configuration pour "klipr"
      final clientKey = 'sbaw1wr5v89m3jx5n9'; // La clé client de votre app "klipr"
      final redirectUri = 'https://auth.lespcdewarren.fr/auth/tiktok';
      final scope = 'user.info.basic,user.info.profile,user.info.stats,video.list';
      final state = 'klipr_login_${DateTime.now().millisecondsSinceEpoch}';
      final encodedRedirectUri = Uri.encodeComponent(redirectUri);
      final authUrl =
          'https://www.tiktok.com/v2/auth/authorize?client_key=$clientKey&response_type=code&scope=$scope&redirect_uri=$encodedRedirectUri&state=$state';

      // Lance l'authentification via un navigateur externe
      final result = await FlutterWebAuth2.authenticate(
        url: authUrl,
        callbackUrlScheme: "klipr", // Ceci doit correspondre à votre AndroidManifest
      );

      // Le code est renvoyé par votre serveur Node.js
      final code = Uri.parse(result).queryParameters['code'];

      if (code != null) {
        // Échange du code contre un token
        final response = await http.post(
          Uri.parse('https://klipr.app/api/tiktok/token'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'code': code}),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final accessToken = data['access_token'];
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('tiktok_access_token', accessToken ?? '');
          
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        } else {
          if (mounted) setState(() => _error = 'Backend Error: ${response.body}');
        }
      } else {
        if (mounted) setState(() => _error = 'TikTok code not found in redirect from server.');
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Auth cancelled or failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connexion TikTok')),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.login),
                    label: Text('Se connecter avec TikTok'),
                    onPressed: _loginWithTikTok,
                  ),
                  if (_error != null) ...[
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        _error!,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
