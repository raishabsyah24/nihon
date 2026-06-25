import 'package:flutter/material.dart';

import '../../data/local_kana.dart';
import '../../models/app_models.dart';
import '../../services/api_client.dart';
import '../common/async_content.dart';

class KanaListScreen extends StatelessWidget {
  const KanaListScreen({
    super.key,
    required this.title,
    required this.type,
    required this.apiClient,
  });

  final String title;
  final String type;
  final ApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: AsyncContent<List<KanaCharacter>>(
          future: apiClient.getKana(type),
          fallback: localKana(type),
          isEmpty: (items) => items.isEmpty,
          builder: (context, items) {
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.9,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final kana = items[index];
                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => KanaDetailScreen(kana: kana),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            kana.character,
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            kana.romaji,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ],
                      ),
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
}

class KanaDetailScreen extends StatefulWidget {
  const KanaDetailScreen({super.key, required this.kana});

  final KanaCharacter kana;

  @override
  State<KanaDetailScreen> createState() => _KanaDetailScreenState();
}

class _KanaDetailScreenState extends State<KanaDetailScreen> {
  int _step = 1;

  @override
  Widget build(BuildContext context) {
    final kana = widget.kana;
    final steps = kana.strokeSteps.isEmpty
        ? [const StrokeStep(step: 1, note: 'Stroke data belum tersedia.')]
        : kana.strokeSteps;
    final activeStep = steps[(_step - 1).clamp(0, steps.length - 1)];

    return Scaffold(
      appBar: AppBar(title: Text('${kana.character}  ${kana.romaji}')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Text(
                      kana.character,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 96,
                      ),
                    ),
                    Text(
                      kana.romaji,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    InfoPill(
                      label: 'Contoh: ${kana.example}',
                      icon: Icons.lightbulb_outline,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Cara Menulis',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            AspectRatio(
              aspectRatio: 1,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: CustomPaint(
                    painter: StrokePracticePainter(
                      character: kana.character,
                      step: _step,
                      totalSteps: steps.length,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: Center(
                      child: Text(
                        kana.character,
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(
                              fontSize: 120,
                              color: Colors.black.withValues(alpha: 0.12),
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InfoPill(
                      label: 'Stroke $_step dari ${steps.length}',
                      icon: Icons.timeline_outlined,
                    ),
                    const SizedBox(height: 10),
                    Text(activeStep.note),
                    const SizedBox(height: 12),
                    Slider(
                      value: _step.toDouble(),
                      min: 1,
                      max: steps.length.toDouble(),
                      divisions: steps.length > 1 ? steps.length - 1 : null,
                      label: '$_step',
                      onChanged: (value) =>
                          setState(() => _step = value.round()),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _step <= 1
                                ? null
                                : () => setState(() => _step--),
                            icon: const Icon(Icons.arrow_back_outlined),
                            label: const Text('Sebelum'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _step >= steps.length
                                ? null
                                : () => setState(() => _step++),
                            icon: const Icon(Icons.arrow_forward_outlined),
                            label: const Text('Lanjut'),
                          ),
                        ),
                      ],
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
}

class StrokePracticePainter extends CustomPainter {
  const StrokePracticePainter({
    required this.character,
    required this.step,
    required this.totalSteps,
    required this.color,
  });

  final String character;
  final int step;
  final int totalSteps;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final guidePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawLine(
      Offset(center.dx, 0),
      Offset(center.dx, size.height),
      guidePaint,
    );
    canvas.drawLine(
      Offset(0, center.dy),
      Offset(size.width, center.dy),
      guidePaint,
    );

    final progress = step / totalSteps;
    final path = Path()
      ..moveTo(size.width * 0.26, size.height * 0.32)
      ..quadraticBezierTo(
        size.width * (0.42 + progress * 0.12),
        size.height * 0.18,
        size.width * 0.70,
        size.height * 0.38,
      )
      ..moveTo(size.width * 0.34, size.height * 0.55)
      ..quadraticBezierTo(
        size.width * 0.52,
        size.height * (0.48 + progress * 0.16),
        size.width * 0.68,
        size.height * 0.72,
      );

    canvas.drawPath(path, strokePaint);
    final dotPaint = Paint()..color = color;
    canvas.drawCircle(
      Offset(size.width * 0.26, size.height * 0.32),
      6,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant StrokePracticePainter oldDelegate) {
    return character != oldDelegate.character ||
        step != oldDelegate.step ||
        totalSteps != oldDelegate.totalSteps ||
        color != oldDelegate.color;
  }
}
