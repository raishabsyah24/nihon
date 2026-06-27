import 'package:flutter/material.dart';

import '../../models/app_models.dart';
import '../../services/api_client.dart';
import '../common/async_content.dart';
import '../questions/question_screens.dart';

class SswScreen extends StatelessWidget {
  const SswScreen({super.key, required this.apiClient});

  final ApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SSW')),
      body: SafeArea(
        child: AsyncContent<List<SswCategory>>(
          future: apiClient.getSswCategories(),
          fallback: _demoSswCategories,
          isEmpty: (items) => items.isEmpty,
          builder: (context, categories) {
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final category = categories[index];
                return Card(
                  child: ExpansionTile(
                    leading: const Icon(Icons.work_outline),
                    title: Text(category.title),
                    subtitle: category.description == null
                        ? null
                        : Text(category.description!),
                    children: [
                      for (final module in category.modules)
                        ListTile(
                          title: Text(module.title),
                          subtitle: module.summary == null
                              ? null
                              : Text(module.summary!),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => SswModuleDetailScreen(
                                  apiClient: apiClient,
                                  fallbackModule: module,
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class SswModuleDetailScreen extends StatelessWidget {
  const SswModuleDetailScreen({
    super.key,
    required this.apiClient,
    required this.fallbackModule,
  });

  final ApiClient apiClient;
  final SswModule fallbackModule;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(fallbackModule.title)),
      body: SafeArea(
        child: AsyncContent<SswModule>(
          future: apiClient.getSswModule(fallbackModule.id),
          fallback: fallbackModule,
          builder: (context, module) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          module.title,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        if (module.summary?.isNotEmpty == true) ...[
                          const SizedBox(height: 8),
                          Text(
                            module.summary!,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                        const SizedBox(height: 14),
                        Text(module.content),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (module.vocabulary.isNotEmpty) ...[
                  _VocabularySection(items: module.vocabulary),
                  const SizedBox(height: 12),
                ],
                if (module.examples.isNotEmpty) ...[
                  _ExampleSection(items: module.examples),
                  const SizedBox(height: 12),
                ],
                if (module.questions.isNotEmpty)
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => QuestionPracticeScreen(
                            title: 'Latihan ${module.title}',
                            apiClient: apiClient,
                            progressContentType: 'SSW_MODULE',
                            progressContentId: module.id,
                            loader: () async => module.questions,
                            fallback: module.questions,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.quiz_outlined),
                    label: Text('Latihan ${module.questions.length} Soal'),
                  )
                else
                  const EmptyState(
                    title: 'Soal latihan belum tersedia.',
                    icon: Icons.quiz_outlined,
                  ),
                const SizedBox(height: 12),
                _MarkModuleCompleteButton(
                  apiClient: apiClient,
                  module: module,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MarkModuleCompleteButton extends StatefulWidget {
  const _MarkModuleCompleteButton({
    required this.apiClient,
    required this.module,
  });

  final ApiClient apiClient;
  final SswModule module;

  @override
  State<_MarkModuleCompleteButton> createState() =>
      _MarkModuleCompleteButtonState();
}

class _MarkModuleCompleteButtonState extends State<_MarkModuleCompleteButton> {
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: _saving ? null : _markComplete,
      icon: const Icon(Icons.check_circle_outline),
      label: Text(_saving ? 'Menyimpan...' : 'Tandai Selesai Membaca'),
    );
  }

  Future<void> _markComplete() async {
    setState(() => _saving = true);
    try {
      await widget.apiClient.upsertProgress(
        contentType: 'SSW_MODULE',
        contentId: widget.module.id,
        progressPercent: 100,
        status: 'COMPLETED',
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Progress SSW tersimpan.')),
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

class _VocabularySection extends StatelessWidget {
  const _VocabularySection({required this.items});

  final List<JapaneseVocabulary> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kosakata',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            for (final item in items) ...[
              _JapaneseTextBlock(
                primary: item.kanji?.isNotEmpty == true
                    ? item.kanji!
                    : item.kana ?? '-',
                secondary: [
                  if (item.furigana?.isNotEmpty == true) item.furigana,
                  if (item.romaji?.isNotEmpty == true) item.romaji,
                ].whereType<String>().join(' · '),
                meaning: item.meaning,
              ),
              if (item != items.last) const Divider(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExampleSection extends StatelessWidget {
  const _ExampleSection({required this.items});

  final List<JapaneseExample> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contoh Kalimat',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            for (final item in items) ...[
              _JapaneseTextBlock(
                primary: item.japanese ?? '-',
                secondary: [
                  if (item.furigana?.isNotEmpty == true) item.furigana,
                  if (item.romaji?.isNotEmpty == true) item.romaji,
                ].whereType<String>().join(' · '),
                meaning: item.meaning,
              ),
              if (item != items.last) const Divider(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}

class _JapaneseTextBlock extends StatelessWidget {
  const _JapaneseTextBlock({
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
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        if (secondary.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            secondary,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

const _demoSswCategories = [
  SswCategory(
    id: 'demo-kaigo',
    title: 'Kaigo',
    description: 'Materi dasar SSW bidang perawat lansia.',
    modules: [
      SswModule(
        id: 'demo-kaigo-intro',
        title: 'Pengantar Kaigo',
        summary: 'Pekerjaan, etika, dan kosakata awal.',
        content:
            'Kaigo berfokus pada dukungan aktivitas harian lansia, komunikasi sopan, dan keselamatan kerja.',
        vocabulary: [
          JapaneseVocabulary(
            kanji: '介護',
            kana: 'かいご',
            furigana: 'かいご',
            romaji: 'kaigo',
            meaning: 'Perawatan lansia',
          ),
          JapaneseVocabulary(
            kanji: '食事',
            kana: 'しょくじ',
            furigana: 'しょくじ',
            romaji: 'shokuji',
            meaning: 'Makan',
          ),
        ],
        examples: [
          JapaneseExample(
            japanese: '利用者の食事を手伝います。',
            furigana: 'りようしゃのしょくじをてつだいます。',
            romaji: 'riyousha no shokuji o tetsudaimasu.',
            meaning: 'Membantu makan pengguna layanan.',
          ),
        ],
        questions: [
          QuestionItem(
            id: 'demo-ssw-1',
            prompt: 'Apa fokus utama pekerjaan kaigo?',
            options: [
              'Perawatan lansia',
              'Teknik mesin',
              'Pertanian',
              'Pengolahan makanan',
            ],
            answerIndex: 0,
            category: 'kaigo',
            explanation: 'Kaigo berfokus pada perawatan dan dukungan lansia.',
          ),
        ],
      ),
    ],
  ),
  SswCategory(
    id: 'demo-food',
    title: 'Food Service',
    description: 'Materi pengantar pelayanan makanan.',
    modules: [
      SswModule(
        id: 'demo-food-safety',
        title: 'Keamanan Makanan',
        summary: 'Higienitas dan prosedur dasar.',
        content:
            'Materi ini mengenalkan cara menjaga kebersihan alat, bahan, dan area kerja.',
        vocabulary: [
          JapaneseVocabulary(
            kanji: '衛生',
            kana: 'えいせい',
            furigana: 'えいせい',
            romaji: 'eisei',
            meaning: 'Higienitas',
          ),
        ],
        examples: [
          JapaneseExample(
            japanese: '手をよく洗います。',
            furigana: 'てをよくあらいます。',
            romaji: 'te o yoku araimasu.',
            meaning: 'Mencuci tangan dengan baik.',
          ),
        ],
        questions: [],
      ),
    ],
  ),
];
