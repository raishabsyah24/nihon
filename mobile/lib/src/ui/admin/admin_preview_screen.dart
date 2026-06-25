import 'package:flutter/material.dart';

import '../../services/api_client.dart';
import '../common/async_content.dart';

class AdminPreviewScreen extends StatelessWidget {
  const AdminPreviewScreen({super.key, required this.apiClient});

  final ApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Preview')),
      body: SafeArea(
        child: AsyncContent<List<_AdminMetric>>(
          future: _loadMetrics(),
          fallback: const [
            _AdminMetric(
              label: 'Kotoba',
              count: 3,
              icon: Icons.menu_book_outlined,
            ),
            _AdminMetric(
              label: 'SSW Kategori',
              count: 2,
              icon: Icons.work_outline,
            ),
            _AdminMetric(label: 'Jadwal', count: 3, icon: Icons.event_outlined),
            _AdminMetric(
              label: 'Berita',
              count: 2,
              icon: Icons.newspaper_outlined,
            ),
          ],
          builder: (context, metrics) {
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: metrics.length,
              itemBuilder: (context, index) {
                final metric = metrics[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          metric.icon,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const Spacer(),
                        Text(
                          metric.count.toString(),
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        Text(metric.label),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<List<_AdminMetric>> _loadMetrics() async {
    final results = await Future.wait([
      apiClient.getKotoba(),
      apiClient.getSswCategories(),
      apiClient.getExamSchedules(),
      apiClient.getJapanNews(),
    ]);

    return [
      _AdminMetric(
        label: 'Kotoba',
        count: results[0].length,
        icon: Icons.menu_book_outlined,
      ),
      _AdminMetric(
        label: 'SSW Kategori',
        count: results[1].length,
        icon: Icons.work_outline,
      ),
      _AdminMetric(
        label: 'Jadwal',
        count: results[2].length,
        icon: Icons.event_outlined,
      ),
      _AdminMetric(
        label: 'Berita',
        count: results[3].length,
        icon: Icons.newspaper_outlined,
      ),
    ];
  }
}

class _AdminMetric {
  const _AdminMetric({
    required this.label,
    required this.count,
    required this.icon,
  });

  final String label;
  final int count;
  final IconData icon;
}
