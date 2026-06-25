import 'package:flutter/material.dart';

import 'services/api_client.dart';
import 'services/auth_controller.dart';
import 'ui/auth/auth_screen.dart';
import 'ui/home/home_screen.dart';

class NihonEIkitaiApp extends StatelessWidget {
  const NihonEIkitaiApp({
    super.key,
    required this.authController,
    required this.apiClient,
  });

  final AuthController authController;
  final ApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF659287);
    const secondary = Color(0xFF9CBCB0);
    const softBg = Color(0xFFE6F0DD);
    const surface = Color(0xFFFFFFFF);
    const ink = Color(0xFF263238);
    const accent = Color(0xFFD79A2B);
    const ctaRed = Color(0xFFB4232A);

    return MaterialApp(
      title: 'Nihon e Ikitai',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamilyFallback: const [
          'Noto Sans JP',
          'Yu Gothic',
          'Hiragino Sans',
          'Meiryo',
        ],
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          primary: primary,
          secondary: secondary,
          tertiary: accent,
          surface: surface,
          error: ctaRed,
          onSurface: ink,
        ),
        scaffoldBackgroundColor: softBg,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          foregroundColor: ink,
          backgroundColor: softBg,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: primary.withValues(alpha: 0.18)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: primary, width: 1.4),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            side: const BorderSide(color: primary),
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: surface,
          indicatorColor: primary.withValues(alpha: 0.16),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            );
          }),
        ),
      ),
      home: _AuthGate(authController: authController, apiClient: apiClient),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate({required this.authController, required this.apiClient});

  final AuthController authController;
  final ApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: authController,
      builder: (context, _) {
        if (!authController.isSignedIn) {
          return AuthScreen(authController: authController);
        }

        return HomeScreen(authController: authController, apiClient: apiClient);
      },
    );
  }
}
