import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/config/app_config.dart';
import 'src/services/api_client.dart';
import 'src/services/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authController = AuthController(
    apiBaseUrl: AppConfig.apiBaseUrl,
    googleServerClientId: AppConfig.googleServerClientId,
  );
  await authController.initialize();

  final apiClient = ApiClient(
    baseUrl: AppConfig.apiBaseUrl,
    tokenProvider: authController.getIdToken,
  );

  runApp(NihonEIkitaiApp(authController: authController, apiClient: apiClient));
}
