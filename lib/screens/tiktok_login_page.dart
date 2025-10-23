import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tiktok_sdk_v2/tiktok_sdk_v2.dart';
import 'package:flutter/services.dart';

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
    _setupTikTokSDK();
    _checkIfAlreadyConnected();
  }

  Future<void> _setupTikTokSDK() async {
    // On initialise le SDK avec la clé client de l'app "klipr"
    await TikTokSDK.instance.setup(clientKey: "sbaw1wr5v89m3jx5n9");
  }

  Future<void> _checkIfAlreadyConnected() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('tiktok_access_token');
    if (accessToken != null && accessToken.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      });
    }
  }

  Future<void> _loginWithTikTok() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await TikTokSDK.instance.login(
        permissions: {
          TikTokPermissionType.userInfoBasic,
          TikTokPermissionType.userInfoProfile,
          TikTokPermissionType.userInfoStats,
          TikTokPermissionType.videoList,
        },
        // Le redirectUri est géré par le Manifest, on passe une URL factice.
        redirectUri: 'https://auth.lespcdewarren.fr/auth/tiktok',
      );

      if (result.status == TikTokLoginStatus.success && result.authCode != null) {
        await _exchangeCodeForToken(result.authCode!);
      } else {
        setState(() {
          _error = "TikTok Login Failed: ${result.status.name} - ${result.errorMessage}";
          _isLoading = false;
        });
      }
    } on PlatformException catch (e) {
       setState(() {
        _error = "TikTok SDK Platform Error: ${e.message}";
        _isLoading = false;
      });
    }
  }

  Future<void> _exchangeCodeForToken(String code) async {
    try {
      // Assurez-vous que cette URL est celle de votre backend
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
    } catch (e) {
      if (mounted) setState(() => _error = 'Network Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _forceLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('tiktok_access_token');
    setState(() {
      _error = 'Token effacé. Vous pouvez vous reconnecter.';
    });
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
                  SizedBox(height: 10),
                  TextButton.icon(
                    icon: Icon(Icons.delete_sweep, color: Colors.grey),
                    label: Text('Forcer la déconnexion (Debug)', style: TextStyle(color: Colors.grey)),
                    onPressed: _forceLogout,
                  ),
                  if (_error != null) ...[
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        _error!,
                        style: TextStyle(color: _error!.startsWith('Token') ? Colors.green : Colors.red),
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
