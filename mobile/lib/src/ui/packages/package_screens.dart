import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/app_models.dart';
import '../../services/api_client.dart';
import '../common/async_content.dart';
import '../questions/question_screens.dart';

class PackageListScreen extends StatelessWidget {
  const PackageListScreen({
    super.key,
    required this.title,
    required this.apiClient,
    required this.kinds,
    this.level,
    this.fallback = const [],
  });

  final String title;
  final ApiClient apiClient;
  final List<String> kinds;
  final String? level;
  final List<ProductPackage> fallback;

  Future<List<ProductPackage>> _load() async {
    final rows = await Future.wait(
      kinds.map((kind) => apiClient.getPackages(kind: kind, level: level)),
    );
    final flattened = rows.expand((items) => items).toList();
    flattened.sort((left, right) {
      final levelCompare = (left.level ?? '').compareTo(right.level ?? '');
      if (levelCompare != 0) {
        return levelCompare;
      }
      return left.price.compareTo(right.price);
    });
    return flattened;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: AsyncContent<List<ProductPackage>>(
          future: _load(),
          fallback: fallback,
          isEmpty: (items) => items.isEmpty,
          emptyMessage: 'Paket belum tersedia.',
          builder: (context, packages) {
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: packages.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = packages[index];
                return _PackageCard(
                  package: item,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PackageDetailScreen(
                          apiClient: apiClient,
                          package: item,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class PackageDetailScreen extends StatefulWidget {
  const PackageDetailScreen({
    super.key,
    required this.apiClient,
    required this.package,
  });

  final ApiClient apiClient;
  final ProductPackage package;

  @override
  State<PackageDetailScreen> createState() => _PackageDetailScreenState();
}

class _PackageDetailScreenState extends State<PackageDetailScreen> {
  late Future<ProductPackage> _future;
  bool _ordering = false;

  @override
  void initState() {
    super.initState();
    _future = widget.apiClient.getMyPackage(widget.package.slug);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.package.title)),
      body: SafeArea(
        child: AsyncContent<ProductPackage>(
          future: _future,
          fallback: widget.package,
          builder: (context, item) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            InfoPill(label: packageKindLabel(item.kind)),
                            if (item.level?.isNotEmpty == true)
                              InfoPill(label: item.level!),
                            if (item.category?.isNotEmpty == true)
                              InfoPill(label: item.category!),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        if (item.subtitle?.isNotEmpty == true) ...[
                          const SizedBox(height: 8),
                          Text(item.subtitle!),
                        ],
                        const SizedBox(height: 14),
                        Text(
                          formatCurrency(item.price, item.currency),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        if (item.description?.isNotEmpty == true) ...[
                          const SizedBox(height: 14),
                          Text(item.description!),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (item.benefits.isNotEmpty)
                  _BenefitCard(benefits: item.benefits),
                if (item.benefits.isNotEmpty) const SizedBox(height: 12),
                _ContentCard(contents: item.contents),
                const SizedBox(height: 16),
                if (item.hasAccess)
                  FilledButton.icon(
                    onPressed: () => _openContent(item),
                    icon: const Icon(Icons.lock_open_outlined),
                    label: const Text('Buka Paket'),
                  )
                else
                  FilledButton.icon(
                    onPressed: _ordering ? null : () => _createOrder(item),
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: Text(_ordering ? 'Membuat Order...' : 'Buat Order'),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _createOrder(ProductPackage item) async {
    final checkout = await showDialog<_CheckoutInput>(
      context: context,
      builder: (context) => const _CheckoutDialog(),
    );
    if (checkout == null) {
      return;
    }

    setState(() => _ordering = true);
    try {
      final order = await widget.apiClient.createOrder(
        packageIds: [item.id],
        voucherCode: checkout.voucherCode,
        pointsToUse: checkout.pointsToUse,
      );
      if (!mounted) {
        return;
      }
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Order dibuat'),
          content: Text(_orderCreatedMessage(order)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      setState(() {
        _future = widget.apiClient.getMyPackage(item.slug);
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _ordering = false);
      }
    }
  }

  void _openContent(ProductPackage item) {
    if (item.contents.isEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _MaterialPlaceholderScreen(
            apiClient: widget.apiClient,
            package: item,
          ),
        ),
      );
      return;
    }

    if (item.contents.length == 1) {
      _openContentItem(item, item.contents.first);
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              Text(
                'Pilih Konten',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              for (final content in item.contents)
                Card(
                  child: ListTile(
                    leading: Icon(_contentIcon(content.contentType)),
                    title: Text(content.title ?? content.contentId),
                    subtitle: Text(_contentTypeLabel(content.contentType)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.of(context).pop();
                      _openContentItem(item, content);
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _openContentItem(ProductPackage item, PackageContent content) {
    if (content.contentType == 'QUESTION_SET') {
      final detailLoader = item.kind.startsWith('JFT')
          ? widget.apiClient.getMyJftQuestionSet
          : widget.apiClient.getMyJlptQuestionSet;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => QuestionPracticeScreen(
            title: content.title ?? item.title,
            apiClient: widget.apiClient,
            progressContentType: 'QUESTION_SET',
            progressContentId: content.contentId,
            packageId: item.id,
            loader: () async {
              final detail = await detailLoader(content.contentId);
              return detail.questions;
            },
          ),
        ),
      );
      return;
    }

    if (content.contentType == 'SSW_MODULE') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => QuestionPracticeScreen(
            title: content.title ?? item.title,
            apiClient: widget.apiClient,
            progressContentType: 'SSW_MODULE',
            progressContentId: content.contentId,
            packageId: item.id,
            loader: () async {
              final module = await widget.apiClient.getMySswModule(
                content.contentId,
              );
              return module.questions;
            },
          ),
        ),
      );
      return;
    }

    if (content.contentType == 'JFT_MATERIAL' ||
        content.contentType == 'JLPT_MATERIAL') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _StudyMaterialScreen(
            apiClient: widget.apiClient,
            package: item,
            content: content,
          ),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _MaterialPlaceholderScreen(
          apiClient: widget.apiClient,
          package: item,
          content: content,
        ),
      ),
    );
  }
}

IconData _contentIcon(String contentType) {
  return switch (contentType) {
    'QUESTION_SET' => Icons.quiz_outlined,
    'SSW_MODULE' => Icons.work_outline,
    'JFT_MATERIAL' => Icons.auto_stories_outlined,
    'JLPT_MATERIAL' => Icons.auto_stories_outlined,
    _ => Icons.layers_outlined,
  };
}

String _contentTypeLabel(String contentType) {
  return switch (contentType) {
    'QUESTION_SET' => 'Latihan soal',
    'SSW_MODULE' => 'Modul SSW',
    'JFT_MATERIAL' => 'Materi JFT',
    'JLPT_MATERIAL' => 'Materi JLPT',
    _ => contentType,
  };
}

String _orderCreatedMessage(OrderSummary order) {
  final lines = [
    'Nomor order: ${order.orderNumber}',
    'Subtotal: ${formatCurrency(order.subtotal, order.currency)}',
    if (order.promoDiscount > 0)
      'Promo: -${formatCurrency(order.promoDiscount, order.currency)}',
    if (order.voucherDiscount > 0)
      'Voucher: -${formatCurrency(order.voucherDiscount, order.currency)}',
    if (order.pointDiscount > 0)
      'Point: -${formatCurrency(order.pointDiscount, order.currency)}',
    'Total: ${formatCurrency(order.total, order.currency)}',
    '',
    'Status masih PENDING. Admin perlu verifikasi pembayaran agar paket terbuka.',
  ];

  return lines.join('\n');
}

class _CheckoutInput {
  const _CheckoutInput({required this.voucherCode, required this.pointsToUse});

  final String? voucherCode;
  final int pointsToUse;
}

class _CheckoutDialog extends StatefulWidget {
  const _CheckoutDialog();

  @override
  State<_CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<_CheckoutDialog> {
  final _voucherController = TextEditingController();
  final _pointsController = TextEditingController(text: '0');

  @override
  void dispose() {
    _voucherController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Buat Order'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _voucherController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Kode Voucher',
                hintText: 'Opsional',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pointsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Point Digunakan',
                hintText: '0',
              ),
            ),
            const SizedBox(height: 12),
            const InlineNotice(
              icon: Icons.info_outline,
              message:
                  'Promo otomatis dipilih backend. Voucher dan point akan dihitung saat order dibuat.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () {
            final rawPoints = int.tryParse(_pointsController.text.trim()) ?? 0;
            final points = rawPoints.clamp(0, 999999).toInt();
            Navigator.of(context).pop(
              _CheckoutInput(
                voucherCode: _voucherController.text.trim().isEmpty
                    ? null
                    : _voucherController.text.trim().toUpperCase(),
                pointsToUse: points,
              ),
            );
          },
          child: const Text('Lanjut'),
        ),
      ],
    );
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({required this.package, required this.onTap});

  final ProductPackage package;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          package.isQuestionPackage
              ? Icons.quiz_outlined
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
            if (package.category?.isNotEmpty == true) package.category,
            formatCurrency(package.price, package.currency),
          ].whereType<String>().join(' - '),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}

class _BenefitCard extends StatelessWidget {
  const _BenefitCard({required this.benefits});

  final List<String> benefits;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Benefit',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (final benefit in benefits)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(benefit)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({required this.contents});

  final List<PackageContent> contents;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Isi Paket',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            if (contents.isEmpty)
              const Text('Konten paket sedang disiapkan.')
            else
              for (final content in contents)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.layers_outlined, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          content.title?.isNotEmpty == true
                              ? content.title!
                              : content.contentId,
                        ),
                      ),
                      Text(content.contentType),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _StudyMaterialScreen extends StatefulWidget {
  const _StudyMaterialScreen({
    required this.apiClient,
    required this.package,
    required this.content,
  });

  final ApiClient apiClient;
  final ProductPackage package;
  final PackageContent content;

  @override
  State<_StudyMaterialScreen> createState() => _StudyMaterialScreenState();
}

class _StudyMaterialScreenState extends State<_StudyMaterialScreen> {
  late Future<StudyMaterial> _future;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _future = widget.apiClient.getMyStudyMaterial(widget.content.contentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.content.title ?? widget.package.title)),
      body: SafeArea(
        child: AsyncContent<StudyMaterial>(
          future: _future,
          fallback: _fallbackMaterial,
          builder: (context, material) {
            final canRead = material.hasAccess || material.content != null;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            InfoPill(label: packageKindLabel(material.kind)),
                            if (material.level?.isNotEmpty == true)
                              InfoPill(label: material.level!),
                            if (material.category?.isNotEmpty == true)
                              InfoPill(label: material.category!),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          material.title,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        if (material.summary?.isNotEmpty == true) ...[
                          const SizedBox(height: 10),
                          Text(material.summary!),
                        ],
                        if (!canRead) ...[
                          const SizedBox(height: 12),
                          const InlineNotice(
                            icon: Icons.lock_outline,
                            message:
                                'Materi lengkap terbuka setelah paket aktif.',
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (canRead) ...[
                  const SizedBox(height: 12),
                  if (material.content?.isNotEmpty == true)
                    _MaterialBodyCard(text: material.content!),
                  if (material.sections.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    for (final section in material.sections) ...[
                      _MaterialSectionCard(section: section),
                      const SizedBox(height: 10),
                    ],
                  ],
                  if (material.vocabulary.isNotEmpty)
                    _StudyVocabularyCard(items: material.vocabulary),
                  if (material.vocabulary.isNotEmpty)
                    const SizedBox(height: 12),
                  if (material.examples.isNotEmpty)
                    _StudyExamplesCard(items: material.examples),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _saving ? null : () => _markComplete(material),
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(_saving ? 'Menyimpan...' : 'Tandai Selesai'),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  StudyMaterial get _fallbackMaterial {
    return StudyMaterial(
      id: widget.content.contentId,
      kind: widget.content.contentType,
      title: widget.content.title ?? widget.package.title,
      slug: widget.content.contentId,
      level: widget.package.level,
      category: widget.package.category,
      summary: widget.package.previewDescription ?? widget.package.description,
      content: widget.package.description,
      sections: const [],
      vocabulary: const [],
      examples: const [],
      access: const PackageAccess(isFree: false, hasAccess: true),
    );
  }

  Future<void> _markComplete(StudyMaterial material) async {
    setState(() => _saving = true);
    try {
      await widget.apiClient.upsertProgress(
        contentType: material.kind,
        contentId: material.id,
        packageId: widget.package.id,
        progressPercent: 100,
        status: 'COMPLETED',
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Materi ditandai selesai.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Progress belum tersimpan: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}

class _MaterialBodyCard extends StatelessWidget {
  const _MaterialBodyCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }
}

class _MaterialSectionCard extends StatelessWidget {
  const _MaterialSectionCard({required this.section});

  final StudyMaterialSection section;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (section.title?.isNotEmpty == true)
              Text(
                section.title!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            if (section.title?.isNotEmpty == true) const SizedBox(height: 8),
            Text(section.body ?? '-'),
          ],
        ),
      ),
    );
  }
}

class _StudyVocabularyCard extends StatelessWidget {
  const _StudyVocabularyCard({required this.items});

  final List<JapaneseVocabulary> items;

  @override
  Widget build(BuildContext context) {
    return _JapaneseListCard(
      title: 'Kosakata',
      children: items
          .map(
            (item) => _JapaneseLine(
              primary: item.kanji?.isNotEmpty == true
                  ? item.kanji!
                  : item.kana ?? '-',
              secondary: [
                if (item.furigana?.isNotEmpty == true) item.furigana,
                if (item.romaji?.isNotEmpty == true) item.romaji,
              ].whereType<String>().join(' - '),
              meaning: item.meaning,
            ),
          )
          .toList(),
    );
  }
}

class _StudyExamplesCard extends StatelessWidget {
  const _StudyExamplesCard({required this.items});

  final List<JapaneseExample> items;

  @override
  Widget build(BuildContext context) {
    return _JapaneseListCard(
      title: 'Contoh Kalimat',
      children: items
          .map(
            (item) => _JapaneseLine(
              primary: item.japanese ?? '-',
              secondary: [
                if (item.furigana?.isNotEmpty == true) item.furigana,
                if (item.romaji?.isNotEmpty == true) item.romaji,
              ].whereType<String>().join(' - '),
              meaning: item.meaning,
            ),
          )
          .toList(),
    );
  }
}

class _JapaneseListCard extends StatelessWidget {
  const _JapaneseListCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < children.length; i++) ...[
              children[i],
              if (i != children.length - 1) const Divider(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}

class _JapaneseLine extends StatelessWidget {
  const _JapaneseLine({
    required this.primary,
    required this.secondary,
    required this.meaning,
  });

  final String primary;
  final String secondary;
  final String? meaning;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          primary,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        if (secondary.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            secondary,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        if (meaning?.isNotEmpty == true) ...[
          const SizedBox(height: 4),
          Text(meaning!),
        ],
      ],
    );
  }
}

class _MaterialPlaceholderScreen extends StatefulWidget {
  const _MaterialPlaceholderScreen({
    required this.apiClient,
    required this.package,
    this.content,
  });

  final ApiClient apiClient;
  final ProductPackage package;
  final PackageContent? content;

  @override
  State<_MaterialPlaceholderScreen> createState() =>
      _MaterialPlaceholderScreenState();
}

class _MaterialPlaceholderScreenState
    extends State<_MaterialPlaceholderScreen> {
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final package = widget.package;

    return Scaffold(
      appBar: AppBar(title: Text(package.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      package.title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      package.description ??
                          package.previewDescription ??
                          'Materi paket ini sedang disiapkan.',
                    ),
                    const SizedBox(height: 12),
                    const InlineNotice(
                      icon: Icons.auto_stories_outlined,
                      message:
                          'Konten materi detail akan diisi dari admin pada phase berikutnya.',
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _saving ? null : _markComplete,
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text(
                        _saving ? 'Menyimpan...' : 'Tandai Selesai',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _markComplete() async {
    final content = widget.content;
    final contentType = content?.contentType ?? widget.package.kind;
    final contentId = content?.contentId ?? widget.package.id;

    setState(() => _saving = true);
    try {
      await widget.apiClient.upsertProgress(
        contentType: contentType,
        contentId: contentId,
        packageId: widget.package.id,
        progressPercent: 100,
        status: 'COMPLETED',
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Materi ditandai selesai.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Progress belum tersimpan: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}

String packageKindLabel(String kind) {
  return switch (kind) {
    'JFT_MATERIAL' => 'Paket JFT',
    'JFT_QUESTION' => 'Soal JFT',
    'JLPT_MATERIAL' => 'Paket JLPT',
    'JLPT_QUESTION' => 'Soal JLPT',
    'SSW_QUESTION' => 'Soal SSW',
    _ => kind,
  };
}

String formatCurrency(int value, String currency) {
  return NumberFormat.currency(
    locale: 'id_ID',
    symbol: currency == 'IDR' ? 'Rp' : '$currency ',
    decimalDigits: 0,
  ).format(value);
}
