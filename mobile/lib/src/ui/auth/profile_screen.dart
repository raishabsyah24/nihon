import 'package:flutter/material.dart';

import '../../services/auth_controller.dart';
import '../common/async_content.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.authController});

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SafeArea(child: ProfileContent(authController: authController)),
    );
  }
}

class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key, required this.authController});

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: authController,
      builder: (context, _) {
        final user = authController.profile;

        if (user == null) {
          return const EmptyState(
            title: 'Sesi belum aktif.',
            icon: Icons.account_circle_outlined,
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withValues(alpha: 0.7),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundImage: user.photoUrl == null
                          ? null
                          : NetworkImage(user.photoUrl!),
                      child: user.photoUrl == null
                          ? const Icon(Icons.person_outline)
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.displayName ??
                                user.email ??
                                user.phoneNumber ??
                                'Pengguna Nihon e Ikitai',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              InfoPill(
                                label: user.role,
                                icon: Icons.verified_user_outlined,
                              ),
                              if (user.email != null)
                                InfoPill(
                                  label: user.email!,
                                  icon: Icons.mail_outline,
                                ),
                              if (user.phoneNumber != null)
                                InfoPill(
                                  label: user.phoneNumber!,
                                  icon: Icons.phone_outlined,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: authController.isBusy
                  ? null
                  : authController.refreshProfile,
              icon: const Icon(Icons.sync_outlined),
              label: const Text('Refresh Profil'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: authController.isBusy ? null : authController.signOut,
              icon: const Icon(Icons.logout_outlined),
              label: const Text('Keluar'),
            ),
            if (authController.errorMessage != null) ...[
              const SizedBox(height: 12),
              InlineNotice(
                icon: Icons.info_outline,
                message: authController.errorMessage!,
              ),
            ],
          ],
        );
      },
    );
  }
}
