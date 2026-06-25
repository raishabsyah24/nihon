import 'package:flutter/material.dart';

import '../../models/app_models.dart';
import '../../services/api_client.dart';
import '../../services/auth_controller.dart';
import '../admin/admin_preview_screen.dart';
import '../auth/profile_screen.dart';
import '../kana/kana_screens.dart';
import '../kotoba/kotoba_screen.dart';
import '../news/news_screen.dart';
import '../questions/question_screens.dart';
import '../schedules/schedule_screen.dart';
import '../ssw/ssw_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.authController,
    required this.apiClient,
  });

  final AuthController authController;
  final ApiClient apiClient;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.authController,
      builder: (context, _) {
        final user = widget.authController.profile;
        final actions = _actions(context, user);
        final pages = [
          _DashboardTab(user: user, actions: actions, onOpen: _open),
          _ActionListTab(
            title: 'Belajar',
            subtitle: 'Kana, kotoba, dan materi SSW.',
            actions: actions
                .where((item) => item.group == _ActionGroup.learn)
                .toList(),
            onOpen: _open,
          ),
          _ActionListTab(
            title: 'Ujian',
            subtitle: 'Latihan JFT, JLPT, dan jadwal ujian.',
            actions: actions
                .where((item) => item.group == _ActionGroup.exam)
                .toList(),
            onOpen: _open,
          ),
          _ActionListTab(
            title: 'Info',
            subtitle: 'Berita Jepang dan akses tambahan.',
            actions: actions
                .where((item) => item.group == _ActionGroup.info)
                .toList(),
            onOpen: _open,
          ),
          ProfileContent(authController: widget.authController),
        ];

        return Scaffold(
          appBar: AppBar(
            title: Text(_titles[_index]),
            actions: [
              IconButton(
                tooltip: 'Refresh profil',
                onPressed: widget.authController.isBusy
                    ? null
                    : widget.authController.refreshProfile,
                icon: const Icon(Icons.sync_outlined),
              ),
            ],
          ),
          body: SafeArea(
            child: IndexedStack(index: _index, children: pages),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (value) => setState(() => _index = value),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Beranda',
              ),
              NavigationDestination(
                icon: Icon(Icons.auto_stories_outlined),
                selectedIcon: Icon(Icons.auto_stories),
                label: 'Belajar',
              ),
              NavigationDestination(
                icon: Icon(Icons.assignment_outlined),
                selectedIcon: Icon(Icons.assignment),
                label: 'Ujian',
              ),
              NavigationDestination(
                icon: Icon(Icons.public_outlined),
                selectedIcon: Icon(Icons.public),
                label: 'Info',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        );
      },
    );
  }

  List<_HomeAction> _actions(BuildContext context, AppUser? user) {
    return [
      _HomeAction(
        title: 'Hiragana',
        subtitle: 'Kana dasar Jepang',
        icon: Icons.brush_outlined,
        color: const Color(0xFF659287),
        group: _ActionGroup.learn,
        destination: KanaListScreen(
          title: 'Hiragana',
          type: 'HIRAGANA',
          apiClient: widget.apiClient,
        ),
      ),
      _HomeAction(
        title: 'Katakana',
        subtitle: 'Kana kata serapan',
        icon: Icons.edit_note_outlined,
        color: const Color(0xFF9CBCB0),
        group: _ActionGroup.learn,
        destination: KanaListScreen(
          title: 'Katakana',
          type: 'KATAKANA',
          apiClient: widget.apiClient,
        ),
      ),
      _HomeAction(
        title: 'Kotoba',
        subtitle: 'Kanji, furigana, arti',
        icon: Icons.menu_book_outlined,
        color: const Color(0xFFD79A2B),
        group: _ActionGroup.learn,
        destination: KotobaScreen(apiClient: widget.apiClient),
      ),
      _HomeAction(
        title: 'SSW',
        subtitle: 'Materi dan soal bidang',
        icon: Icons.work_outline,
        color: const Color(0xFF4F756C),
        group: _ActionGroup.learn,
        destination: SswScreen(apiClient: widget.apiClient),
      ),
      _HomeAction(
        title: 'Soal JFT',
        subtitle: 'Latihan JFT Basic',
        icon: Icons.quiz_outlined,
        color: const Color(0xFFB4232A),
        group: _ActionGroup.exam,
        destination: QuestionSetListScreen(
          title: 'Paket JFT',
          loader: widget.apiClient.getJftQuestionSets,
          detailLoader: widget.apiClient.getJftQuestionSet,
          fallback: demoJftQuestionSets(),
        ),
      ),
      _HomeAction(
        title: 'Soal JLPT',
        subtitle: 'N5 sampai N1',
        icon: Icons.school_outlined,
        color: const Color(0xFFD79A2B),
        group: _ActionGroup.exam,
        destination: JlptLevelScreen(apiClient: widget.apiClient),
      ),
      _HomeAction(
        title: 'Jadwal Ujian',
        subtitle: 'JFT, JLPT, SSW',
        icon: Icons.event_outlined,
        color: const Color(0xFF9CB080),
        group: _ActionGroup.exam,
        destination: ScheduleScreen(apiClient: widget.apiClient),
      ),
      _HomeAction(
        title: 'Berita Jepang',
        subtitle: 'Info terbaru',
        icon: Icons.newspaper_outlined,
        color: const Color(0xFF557B72),
        group: _ActionGroup.info,
        destination: NewsScreen(apiClient: widget.apiClient),
      ),
      if (user?.isAdmin ?? false)
        _HomeAction(
          title: 'Admin Preview',
          subtitle: 'Akses khusus admin',
          icon: Icons.admin_panel_settings_outlined,
          color: const Color(0xFF263238),
          group: _ActionGroup.info,
          destination: AdminPreviewScreen(apiClient: widget.apiClient),
        ),
    ];
  }

  void _open(Widget destination) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => destination));
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab({
    required this.user,
    required this.actions,
    required this.onOpen,
  });

  final AppUser? user;
  final List<_HomeAction> actions;
  final ValueChanged<Widget> onOpen;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final displayName = user?.displayName ?? user?.email ?? 'Minasan';
    final featured = actions.take(4).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'こんにちは, $displayName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimary.withValues(alpha: 0.88),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Lanjutkan belajar Jepang hari ini.',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    _HeroPill(label: 'Kana'),
                    _HeroPill(label: 'Kotoba'),
                    _HeroPill(label: 'JLPT'),
                    _HeroPill(label: 'SSW'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: const [
            Expanded(
              child: _MetricTile(
                value: '2',
                label: 'Kana',
                icon: Icons.edit_outlined,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _MetricTile(
                value: '3',
                label: 'Ujian',
                icon: Icons.assignment_outlined,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _MetricTile(
                value: 'SSW',
                label: 'Modul',
                icon: Icons.work_outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        _SectionTitle(
          title: 'Akses Cepat',
          trailing: Text(
            user?.isAdmin ?? false ? 'Admin aktif' : 'User',
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 154,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: featured.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = featured[index];
              return SizedBox(
                width: 170,
                child: _ActionCard(
                  item: item,
                  dense: false,
                  onTap: () => onOpen(item.destination),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 22),
        const _SectionTitle(title: 'Semua Menu'),
        const SizedBox(height: 12),
        _ResponsiveActionGrid(actions: actions, onOpen: onOpen),
      ],
    );
  }
}

class _ActionListTab extends StatelessWidget {
  const _ActionListTab({
    required this.title,
    required this.subtitle,
    required this.actions,
    required this.onOpen,
  });

  final String title;
  final String subtitle;
  final List<_HomeAction> actions;
  final ValueChanged<Widget> onOpen;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        for (final item in actions) ...[
          _ActionListTile(item: item, onTap: () => onOpen(item.destination)),
          if (item != actions.last) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _ResponsiveActionGrid extends StatelessWidget {
  const _ResponsiveActionGrid({required this.actions, required this.onOpen});

  final List<_HomeAction> actions;
  final ValueChanged<Widget> onOpen;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 520 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: columns == 2 ? 1.08 : 1.2,
          ),
          itemBuilder: (context, index) {
            final item = actions[index];
            return _ActionCard(
              item: item,
              dense: true,
              onTap: () => onOpen(item.destination),
            );
          },
        );
      },
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.item,
    required this.dense,
    required this.onTap,
  });

  final _HomeAction item;
  final bool dense;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(dense ? 14 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ActionIcon(item: item),
              const Spacer(),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                item.subtitle,
                maxLines: dense ? 2 : 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionListTile extends StatelessWidget {
  const _ActionListTile({required this.item, required this.onTap});

  final _HomeAction item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: _ActionIcon(item: item),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(item.subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({required this.item});

  final _HomeAction item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: item.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(item.icon, color: item.color),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colorScheme.primary, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: colorScheme.onPrimary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class _HomeAction {
  const _HomeAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.group,
    required this.destination,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final _ActionGroup group;
  final Widget destination;
}

enum _ActionGroup { learn, exam, info }

const _titles = ['Beranda', 'Belajar', 'Ujian', 'Info', 'Profil'];
