import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/app_models.dart';
import '../../services/api_client.dart';
import '../common/async_content.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key, required this.apiClient});

  final ApiClient apiClient;

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  String? _category;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Berita Jepang')),
      body: SafeArea(
        child: AsyncContent<List<JapanNews>>(
          future: widget.apiClient.getJapanNews(),
          fallback: _demoNews,
          isEmpty: (items) => items.isEmpty,
          builder: (context, news) {
            final categories = _categories(news);
            final filtered = _category == null
                ? news
                : news.where((item) => item.category == _category).toList();

            return Column(
              children: [
                if (categories.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('Semua'),
                            selected: _category == null,
                            onSelected: (_) => setState(() => _category = null),
                          ),
                          for (final category in categories)
                            ChoiceChip(
                              label: Text(category),
                              selected: _category == category,
                              onSelected: (_) =>
                                  setState(() => _category = category),
                            ),
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  child: filtered.isEmpty
                      ? const EmptyState(title: 'Berita belum tersedia.')
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _NewsCard(news: filtered[index]);
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.news});

  final JapanNews news;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => NewsDetailScreen(news: news)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (news.thumbnail?.isNotEmpty == true)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  news.thumbnail!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const _ImageFallback(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (news.category?.isNotEmpty == true)
                        InfoPill(label: news.category!),
                      if (news.publishedAt != null)
                        InfoPill(
                          label: _formatNewsDate(news.publishedAt!),
                          icon: Icons.calendar_today_outlined,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    news.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(news.body, maxLines: 3, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewsDetailScreen extends StatelessWidget {
  const NewsDetailScreen({super.key, required this.news});

  final JapanNews news;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Berita')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (news.thumbnail?.isNotEmpty == true)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    news.thumbnail!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const _ImageFallback(),
                  ),
                ),
              ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (news.category?.isNotEmpty == true)
                  InfoPill(label: news.category!),
                if (news.publishedAt != null)
                  InfoPill(
                    label: _formatNewsDate(news.publishedAt!),
                    icon: Icons.calendar_today_outlined,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              news.title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            SelectableText(
              news.body,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colorScheme.secondaryContainer.withValues(alpha: 0.45),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: colorScheme.onSecondaryContainer,
          size: 36,
        ),
      ),
    );
  }
}

List<String> _categories(List<JapanNews> news) {
  final values = <String>{};
  for (final item in news) {
    final category = item.category?.trim();
    if (category != null && category.isNotEmpty) {
      values.add(category);
    }
  }
  return values.toList()..sort();
}

String _formatNewsDate(DateTime value) {
  final local = value.isUtc ? value.toLocal() : value;
  return DateFormat('d MMMM yyyy', 'id_ID').format(local);
}

final _demoNews = [
  JapanNews(
    id: 'demo-news-1',
    slug: 'belajar-bahasa-jepang-untuk-kerja',
    title: 'Belajar Bahasa Jepang untuk Kerja',
    body:
        'Berita demo tentang persiapan bahasa Jepang untuk kerja di Jepang. Pelajari kata seperti 日本, 仕事, dan 介護 supaya transisi belajar terasa lebih nyata.',
    category: 'karier',
    publishedAt: DateTime(2026, 6, 23),
  ),
  JapanNews(
    id: 'demo-news-2',
    slug: 'tips-mengatur-jadwal-belajar-jlpt',
    title: 'Tips Mengatur Jadwal Belajar JLPT',
    body:
        'Pisahkan waktu untuk kotoba, bunpou, dokkai, dan latihan soal. Target harian kecil seperti 毎日10語 membuat ritme belajar lebih stabil.',
    category: 'belajar',
    publishedAt: DateTime(2026, 6, 22),
  ),
  JapanNews(
    id: 'demo-news-3',
    slug: 'persiapan-ujian-ssw-kaigo',
    title: 'Persiapan Ujian SSW Kaigo',
    body:
        'Untuk SSW bidang kaigo, biasakan membaca istilah 介護, 食事, dan 利用者 bersama arti Indonesianya.',
    category: 'ssw',
    publishedAt: DateTime(2026, 6, 21),
  ),
];
