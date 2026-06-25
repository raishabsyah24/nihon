import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nihon_e_ikitai_mobile/src/app.dart';
import 'package:nihon_e_ikitai_mobile/src/services/api_client.dart';
import 'package:nihon_e_ikitai_mobile/src/services/auth_controller.dart';

void main() {
  testWidgets('starts on login with email and phone options', (
    WidgetTester tester,
  ) async {
    final authController = AuthController(apiBaseUrl: 'http://localhost:4000');
    final apiClient = ApiClient(
      baseUrl: 'http://localhost:4000',
      tokenProvider: () async => null,
    );

    await tester.pumpWidget(
      NihonEIkitaiApp(authController: authController, apiClient: apiClient),
    );

    expect(find.text('Masuk ke Nihon e Ikitai'), findsOneWidget);
    expect(find.text('Email'), findsWidgets);
    expect(find.text('Nomor HP'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('shows dashboard bottom navigation after login', (
    WidgetTester tester,
  ) async {
    final authController = AuthController(apiBaseUrl: 'http://localhost:4000');
    authController.useDemoUser(admin: false);
    final apiClient = ApiClient(
      baseUrl: 'http://localhost:4000',
      tokenProvider: () async => null,
    );

    await tester.pumpWidget(
      NihonEIkitaiApp(authController: authController, apiClient: apiClient),
    );

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Beranda'), findsWidgets);
    expect(find.text('Belajar'), findsWidgets);
    expect(find.text('Ujian'), findsWidgets);
    expect(find.text('Info'), findsWidgets);
    expect(find.text('Profil'), findsWidgets);
    expect(find.text('Hiragana'), findsOneWidget);
  });
}
