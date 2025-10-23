import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const KliprApp());
}

class KliprApp extends StatelessWidget {
  const KliprApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Klipr',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        primaryColor: const Color(0xFF6366F1),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFFEC4899),
          surface: Color(0xFF1F1F23),
          background: Color(0xFF0A0A0A),
          onBackground: Colors.white,
          onSurface: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}