import 'package:flutter/material.dart';

import '../../models/app_models.dart';
import '../../services/api_client.dart';
import '../common/async_content.dart';

class KotobaScreen extends StatelessWidget {
  const KotobaScreen({super.key, required this.apiClient});

  final ApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kotoba')),
      body: SafeArea(
        child: AsyncContent<List<Kotoba>>(
          future: apiClient.getKotoba(),
          fallback: _demoKotoba,
          isEmpty: (items) => items.isEmpty,
          builder: (context, items) {
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) => _KotobaTile(item: items[index]),
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemCount: items.length,
            );
          },
        ),
      ),
    );
  }
}

class _KotobaTile extends StatelessWidget {
  const _KotobaTile({required this.item});

  final Kotoba item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.kanji?.isNotEmpty == true
                            ? item.kanji!
                            : item.kana,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          item.furigana ?? item.kana,
                          if (item.romaji != null) item.romaji,
                        ].join(' · '),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                InfoPill(label: item.meaning),
              ],
            ),
            if (item.exampleSentence?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              Text(
                item.exampleSentence!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

const _demoKotoba = [
  Kotoba(
    id: 'demo-nihon',
    kanji: '日本',
    kana: 'にほん',
    furigana: 'にほん',
    romaji: 'nihon',
    meaning: 'Jepang',
    exampleSentence: '日本へ行きたいです。',
  ),
  Kotoba(
    id: 'demo-shigoto',
    kanji: '仕事',
    kana: 'しごと',
    furigana: 'しごと',
    romaji: 'shigoto',
    meaning: 'Pekerjaan',
    exampleSentence: '日本で仕事をしたいです。',
  ),
  Kotoba(
    id: 'demo-benkyou',
    kanji: '勉強',
    kana: 'べんきょう',
    furigana: 'べんきょう',
    romaji: 'benkyou',
    meaning: 'Belajar',
    exampleSentence: '毎日日本語を勉強します。',
  ),
];
