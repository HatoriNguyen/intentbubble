import 'package:flutter/material.dart';
import 'screens/auth_screen.dart';

void main() => runApp(const IntentApp());

class IntentApp extends StatelessWidget {
  const IntentApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'INTENT',
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
      scaffoldBackgroundColor: const Color(0xFFF8F7FC),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    home: const AuthGate(),
  );
}
