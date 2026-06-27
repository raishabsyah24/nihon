import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/app_models.dart';
import '../../services/api_client.dart';
import '../../services/auth_controller.dart';
import '../admin/admin_preview_screen.dart';
import '../auth/profile_screen.dart';
import '../common/async_content.dart';
import '../kana/kana_screens.dart';
import '../kotoba/kotoba_screen.dart';
import '../news/news_screen.dart';
import '../packages/package_screens.dart';
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
  late Future<HomeCatalog> _catalogFuture;

  @override
  void initState() {
    super.initState();
    _catalogFuture = widget.apiClient.getHomeCatalog();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.authController,
      builder: (context, _) {
        final user = widget.authController.profile;
        final actions = _actions(context, user);
        final pages = [
          _DashboardTab(
            user: user,
            actions: actions
                .where((item) => item.group != _ActionGroup.hidden)
                .toList(),
            catalogFuture: _catalogFuture,
            onOpen: _open,
          ),
          _LearningTab(
            actions: actions
                .where((item) => item.group == _ActionGroup.learn)
                .toList(),
            apiClient: widget.apiClient,
            onOpen: _open,
          ),
          _ExamTab(apiClient: widget.apiClient, onOpen: _open),
          _InfoTab(
            actions: actions
                .where((item) => item.group == _ActionGroup.info)
                .toList(),
            apiClient: widget.apiClient,
            onOpen: _open,
          ),
          ProfileContent(
            authController: widget.authController,
            apiClient: widget.apiClient,
          ),
        ];

        return Scaffold(
          appBar: AppBar(
            title: Text(_titles[_index]),
            actions: [
              IconButton(
                tooltip: 'Refresh profil',
                onPressed: widget.authController.isBusy
                    ? null
                    : () {
                        setState(() {
                          _catalogFuture = widget.apiClient.getHomeCatalog();
                        });
                        widget.authController.refreshProfile();
                      },
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
        subtitle: 'Info bidang dan latihan soal',
        icon: Icons.work_outline,
        color: const Color(0xFF4F756C),
        group: _ActionGroup.learn,
        destination: SswScreen(apiClient: widget.apiClient),
      ),
      _HomeAction(
        title: 'JFT',
        subtitle: 'Materi dan soal JFT Basic',
        icon: Icons.quiz_outlined,
        color: const Color(0xFFB4232A),
        group: _ActionGroup.exam,
        destination: PackageListScreen(
          title: 'JFT',
          apiClient: widget.apiClient,
          kinds: const ['JFT_MATERIAL', 'JFT_QUESTION'],
        ),
      ),
      _HomeAction(
        title: 'JLPT',
        subtitle: 'Materi dan soal N5-N1',
        icon: Icons.school_outlined,
        color: const Color(0xFFD79A2B),
        group: _ActionGroup.exam,
        destination: _JlptPackageLevelScreen(apiClient: widget.apiClient),
      ),
      _HomeAction(
        title: 'Jadwal Ujian',
        subtitle: 'JFT, JLPT, SSW',
        icon: Icons.event_outlined,
        color: const Color(0xFF9CB080),
        group: _ActionGroup.info,
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
          group: _ActionGroup.hidden,
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
    required this.catalogFuture,
    required this.onOpen,
  });

  final AppUser? user;
  final List<_HomeAction> actions;
  final Future<HomeCatalog> catalogFuture;
  final ValueChanged<Widget> onOpen;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final displayName = user?.displayName ?? user?.email ?? 'Minasan';

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
        _CatalogPreviewSection(catalogFuture: catalogFuture),
        const SizedBox(height: 12),
        const _SectionTitle(title: 'Semua Menu'),
        const SizedBox(height: 12),
        _ResponsiveActionGrid(actions: actions, onOpen: onOpen),
      ],
    );
  }
}

class _CatalogPreviewSection extends StatelessWidget {
  const _CatalogPreviewSection({required this.catalogFuture});

  final Future<HomeCatalog> catalogFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<HomeCatalog>(
      future: catalogFuture,
      builder: (context, snapshot) {
        final catalog = snapshot.data ?? _fallbackCatalog;
        final menus = [...catalog.freeMenus, ...catalog.paidMenus];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(
              title: 'Preview Learning Center',
              trailing: snapshot.connectionState == ConnectionState.waiting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
            ),
            if (snapshot.hasError) ...[
              const SizedBox(height: 8),
              const InlineNotice(
                icon: Icons.cloud_off_outlined,
                message:
                    'Katalog backend belum terbaca. Menampilkan preview lokal.',
              ),
            ],
            const SizedBox(height: 12),
            for (final menu in menus) ...[
              _CatalogMenuTile(menu: menu),
              if (menu != menus.last) const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }
}

class _LearningTab extends StatelessWidget {
  const _LearningTab({
    required this.actions,
    required this.apiClient,
    required this.onOpen,
  });

  final List<_HomeAction> actions;
  final ApiClient apiClient;
  final ValueChanged<Widget> onOpen;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _TabHeader(
          title: 'Belajar',
          subtitle: 'Progress belajar dan materi yang sudah kamu punya.',
        ),
        const SizedBox(height: 16),
        _ProgressPreview(apiClient: apiClient),
        const SizedBox(height: 16),
        const _SectionTitle(title: 'Fitur Belajar'),
        const SizedBox(height: 12),
        for (final item in actions) ...[
          _ActionListTile(item: item, onTap: () => onOpen(item.destination)),
          if (item != actions.last) const SizedBox(height: 10),
        ],
        const SizedBox(height: 20),
        _EntitlementSection(
          title: 'Materi Dibeli',
          emptyMessage: 'Belum ada materi JFT/JLPT yang dibeli.',
          apiClient: apiClient,
          allowedKinds: const ['JFT_MATERIAL', 'JLPT_MATERIAL'],
          onOpen: onOpen,
        ),
      ],
    );
  }
}

class _ExamTab extends StatelessWidget {
  const _ExamTab({required this.apiClient, required this.onOpen});

  final ApiClient apiClient;
  final ValueChanged<Widget> onOpen;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _HomeAction(
        title: 'JFT',
        subtitle: 'Paket soal JFT Basic',
        icon: Icons.quiz_outlined,
        color: const Color(0xFFB4232A),
        group: _ActionGroup.exam,
        destination: PackageListScreen(
          title: 'Paket JFT',
          apiClient: apiClient,
          kinds: const ['JFT_QUESTION'],
        ),
      ),
      _HomeAction(
        title: 'JLPT',
        subtitle: 'Paket soal N5-N1',
        icon: Icons.school_outlined,
        color: const Color(0xFFD79A2B),
        group: _ActionGroup.exam,
        destination: _JlptPackageLevelScreen(
          apiClient: apiClient,
          questionOnly: true,
        ),
      ),
      _HomeAction(
        title: 'SSW',
        subtitle: 'Paket soal bidang kerja',
        icon: Icons.work_outline,
        color: const Color(0xFF4F756C),
        group: _ActionGroup.exam,
        destination: PackageListScreen(
          title: 'Paket Soal SSW',
          apiClient: apiClient,
          kinds: const ['SSW_QUESTION'],
        ),
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _TabHeader(
          title: 'Ujian',
          subtitle: 'Soal yang sudah dibeli akan muncul di sini.',
        ),
        const SizedBox(height: 16),
        _EntitlementSection(
          title: 'Soal Dibeli',
          emptyMessage: 'Belum ada paket soal yang aktif.',
          apiClient: apiClient,
          allowedKinds: const [
            'JFT_QUESTION',
            'JLPT_QUESTION',
            'SSW_QUESTION',
          ],
          onOpen: onOpen,
        ),
        const SizedBox(height: 20),
        const _SectionTitle(title: 'Cari Paket Ujian'),
        const SizedBox(height: 12),
        for (final item in actions) ...[
          _ActionListTile(item: item, onTap: () => onOpen(item.destination)),
          if (item != actions.last) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _InfoTab extends StatelessWidget {
  const _InfoTab({
    required this.actions,
    required this.apiClient,
    required this.onOpen,
  });

  final List<_HomeAction> actions;
  final ApiClient apiClient;
  final ValueChanged<Widget> onOpen;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _TabHeader(
          title: 'Info',
          subtitle: 'Berita Jepang dan jadwal ujian terdekat.',
        ),
        const SizedBox(height: 16),
        _CountdownPreview(apiClient: apiClient),
        const SizedBox(height: 20),
        const _SectionTitle(title: 'Menu Info'),
        const SizedBox(height: 12),
        for (final item in actions) ...[
          _ActionListTile(item: item, onTap: () => onOpen(item.destination)),
          if (item != actions.last) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _CatalogMenuTile extends StatelessWidget {
  const _CatalogMenuTile({required this.menu});

  final CatalogMenu menu;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final priceText = menu.minPrice == null
        ? 'Preview'
        : 'Mulai ${formatCurrency(menu.minPrice!, menu.currency)}';
    final count = menu.itemCount ?? menu.packageCount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: (menu.isFree ? colorScheme.primary : colorScheme.error)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                menu.isFree
                    ? Icons.lock_open_outlined
                    : Icons.workspace_premium_outlined,
                color: menu.isFree ? colorScheme.primary : colorScheme.error,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          menu.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      InfoPill(label: menu.isFree ? 'Gratis' : priceText),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    menu.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (count != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '$count konten tersedia',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabHeader extends StatelessWidget {
  const _TabHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.school_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressPreview extends StatelessWidget {
  const _ProgressPreview({required this.apiClient});

  final ApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LearningProgress>>(
      future: apiClient.getMyProgress(),
      builder: (context, snapshot) {
        final progress = snapshot.data ?? const <LearningProgress>[];
        final average = progress.isEmpty
            ? 0
            : (progress
                      .map((item) => item.progressPercent)
                      .reduce((left, right) => left + right) /
                  progress.length)
                  .round();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Progress Belajar',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      InfoPill(label: '$average%'),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(value: average / 100),
                const SizedBox(height: 12),
                if (snapshot.hasError)
                  const InlineNotice(
                    icon: Icons.cloud_off_outlined,
                    message: 'Progress belum bisa dimuat dari backend.',
                  )
                else if (progress.isEmpty)
                  Text(
                    'Belum ada aktivitas belajar. Mulai dari Kana atau Kotoba dulu.',
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                else
                  for (final item in progress.take(3))
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${item.contentType} ${item.progressPercent}%',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EntitlementSection extends StatelessWidget {
  const _EntitlementSection({
    required this.title,
    required this.emptyMessage,
    required this.apiClient,
    required this.allowedKinds,
    required this.onOpen,
  });

  final String title;
  final String emptyMessage;
  final ApiClient apiClient;
  final List<String> allowedKinds;
  final ValueChanged<Widget> onOpen;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserEntitlement>>(
      future: apiClient.getMyEntitlements(),
      builder: (context, snapshot) {
        final entitlements = (snapshot.data ?? const <UserEntitlement>[])
            .where((item) => allowedKinds.contains(item.package.kind))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(
              title: title,
              trailing: snapshot.connectionState == ConnectionState.waiting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            if (snapshot.hasError)
              const InlineNotice(
                icon: Icons.cloud_off_outlined,
                message: 'Paket user belum bisa dimuat dari backend.',
              )
            else if (entitlements.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      const Icon(Icons.shopping_bag_outlined),
                      const SizedBox(width: 10),
                      Expanded(child: Text(emptyMessage)),
                    ],
                  ),
                ),
              )
            else
              for (final entitlement in entitlements) ...[
                _EntitlementTile(
                  package: entitlement.package,
                  onTap: () => onOpen(
                    PackageDetailScreen(
                      apiClient: apiClient,
                      package: entitlement.package,
                    ),
                  ),
                ),
                if (entitlement != entitlements.last) const SizedBox(height: 10),
              ],
          ],
        );
      },
    );
  }
}

class _EntitlementTile extends StatelessWidget {
  const _EntitlementTile({required this.package, required this.onTap});

  final ProductPackage package;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          package.isQuestionPackage
              ? Icons.assignment_turned_in_outlined
              : Icons.auto_stories_outlined,
        ),
        title: Text(
          package.title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          [
            packageKindLabel(package.kind),
            if (package.level?.isNotEmpty == true) package.level,
          ].whereType<String>().join(' - '),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}

class _CountdownPreview extends StatelessWidget {
  const _CountdownPreview({required this.apiClient});

  final ApiClient apiClient;

  Future<_CountdownPreviewData> _load() async {
    final selectedFuture = apiClient.getMyExamScheduleSelection();
    final schedulesFuture = apiClient.getExamSchedules();

    return _CountdownPreviewData(
      selected: await selectedFuture,
      schedules: await schedulesFuture,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_CountdownPreviewData>(
      future: _load(),
      builder: (context, snapshot) {
        final now = DateTime.now();
        final data = snapshot.data ?? const _CountdownPreviewData();
        final selected = data.selected;
        final schedules = data.schedules
            .where((item) => item.startsAt != null)
            .map((item) {
              final start = item.startsAt!.isUtc
                  ? item.startsAt!.toLocal()
                  : item.startsAt!;
              return MapEntry(item, start);
            })
            .where((entry) => entry.value.isAfter(now))
            .toList()
          ..sort((left, right) => left.value.compareTo(right.value));
        final rawSelectedStart = selected?.startsAt;
        DateTime? selectedStart;
        if (rawSelectedStart != null) {
          selectedStart = rawSelectedStart.isUtc
              ? rawSelectedStart.toLocal()
              : rawSelectedStart;
        }
        final selectedEntry =
            selected != null &&
                selectedStart != null &&
                selectedStart.isAfter(now)
            ? MapEntry(selected, selectedStart)
            : null;
        final nearest =
            selectedEntry ?? (schedules.isEmpty ? null : schedules.first);
        final label = selectedEntry == null ? 'Terdekat' : 'Pilihan Saya';

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Countdown Ujian',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (snapshot.hasError)
                  const InlineNotice(
                    icon: Icons.cloud_off_outlined,
                    message: 'Jadwal belum bisa dimuat dari backend.',
                  )
                else if (nearest == null)
                  const Text(
                    'Belum ada jadwal ujian aktif. Pilih jadwal di menu Jadwal Ujian.',
                  )
                else
                  _CountdownDetail(
                    schedule: nearest.key,
                    start: nearest.value,
                    label: label,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CountdownPreviewData {
  const _CountdownPreviewData({
    this.selected,
    this.schedules = const <ExamSchedule>[],
  });

  final ExamSchedule? selected;
  final List<ExamSchedule> schedules;
}

class _CountdownDetail extends StatelessWidget {
  const _CountdownDetail({
    required this.schedule,
    required this.start,
    required this.label,
  });

  final ExamSchedule schedule;
  final DateTime start;
  final String label;

  @override
  Widget build(BuildContext context) {
    final remaining = start.difference(DateTime.now());
    final days = remaining.inDays.clamp(0, 9999);
    final hours = remaining.inHours.remainder(24).clamp(0, 23);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            InfoPill(label: label, icon: Icons.notifications_active_outlined),
            InfoPill(label: schedule.type, icon: Icons.event_available_outlined),
            InfoPill(label: '$days hari $hours jam'),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          schedule.title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(start)),
      ],
    );
  }
}

class _JlptPackageLevelScreen extends StatelessWidget {
  const _JlptPackageLevelScreen({
    required this.apiClient,
    this.questionOnly = false,
  });

  final ApiClient apiClient;
  final bool questionOnly;

  @override
  Widget build(BuildContext context) {
    const levels = ['N5', 'N4', 'N3', 'N2', 'N1'];
    return Scaffold(
      appBar: AppBar(title: const Text('JLPT')),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: levels.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final level = levels[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(child: Text(level.substring(1))),
                title: Text('JLPT $level'),
                subtitle: Text(
                  questionOnly
                      ? 'Paket soal JLPT $level'
                      : 'Materi dan soal JLPT $level',
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PackageListScreen(
                        title: questionOnly
                            ? 'Soal JLPT $level'
                            : 'Paket JLPT $level',
                        apiClient: apiClient,
                        kinds: questionOnly
                            ? const ['JLPT_QUESTION']
                            : const ['JLPT_MATERIAL', 'JLPT_QUESTION'],
                        level: level,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
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

enum _ActionGroup { learn, exam, info, hidden }

const _titles = ['Beranda', 'Belajar', 'Ujian', 'Info', 'Profil'];

const _fallbackCatalog = HomeCatalog(
  freeMenus: [
    CatalogMenu(
      key: 'kana',
      title: 'Kana',
      description: 'Hiragana dan Katakana gratis untuk semua user.',
      isFree: true,
      itemCount: 92,
    ),
    CatalogMenu(
      key: 'kotoba',
      title: 'Kotoba',
      description: 'Kosakata Jepang dengan kanji, furigana, romaji, dan arti.',
      isFree: true,
    ),
  ],
  paidMenus: [
    CatalogMenu(
      key: 'jft',
      title: 'JFT',
      description: 'Materi dan soal JFT Basic dari A1 sampai B2.',
      isFree: false,
      packageCount: 8,
      minPrice: 99000,
    ),
    CatalogMenu(
      key: 'jlpt',
      title: 'JLPT',
      description: 'Materi dan soal JLPT N5 sampai N1.',
      isFree: false,
      packageCount: 10,
      minPrice: 149000,
    ),
    CatalogMenu(
      key: 'ssw',
      title: 'SSW',
      description: 'Informasi bidang kerja dan latihan soal SSW.',
      isFree: false,
      packageCount: 1,
      minPrice: 129000,
    ),
  ],
);
