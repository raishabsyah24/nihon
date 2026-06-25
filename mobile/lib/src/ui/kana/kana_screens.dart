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
            final sections = _kanaSections(type, items);
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                for (final section in sections)
                  if (section.hasItems) ...[
                    _KanaSectionTitle(title: section.title),
                    const SizedBox(height: 8),
                    _KanaSectionGrid(
                      rows: section.rows,
                      onOpen: (kana) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => KanaDetailScreen(kana: kana),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                  ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _KanaSectionTitle extends StatelessWidget {
  const _KanaSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

class _KanaSectionGrid extends StatelessWidget {
  const _KanaSectionGrid({required this.rows, required this.onOpen});

  final List<List<KanaCharacter?>> rows;
  final ValueChanged<KanaCharacter> onOpen;

  @override
  Widget build(BuildContext context) {
    final cells = rows.expand((row) => row).toList(growable: false);

    return Column(
      children: [
        Row(
          children: const [
            _VowelHeader(label: 'A'),
            _VowelHeader(label: 'I'),
            _VowelHeader(label: 'U'),
            _VowelHeader(label: 'E'),
            _VowelHeader(label: 'O'),
          ],
        ),
        const SizedBox(height: 6),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.78,
          ),
          itemCount: cells.length,
          itemBuilder: (context, index) {
            final kana = cells[index];
            if (kana == null) {
              return const SizedBox.shrink();
            }
            return _KanaCard(kana: kana, onTap: () => onOpen(kana));
          },
        ),
      ],
    );
  }
}

class _VowelHeader extends StatelessWidget {
  const _VowelHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _KanaCard extends StatelessWidget {
  const _KanaCard({required this.kana, required this.onTap});

  final KanaCharacter kana;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                kana.character,
                maxLines: 1,
                overflow: TextOverflow.visible,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                kana.romaji,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KanaSection {
  const _KanaSection({required this.title, required this.rows});

  final String title;
  final List<List<KanaCharacter?>> rows;

  bool get hasItems => rows.any((row) => row.any((kana) => kana != null));
}

List<_KanaSection> _kanaSections(String type, List<KanaCharacter> items) {
  final byCharacter = {for (final item in items) item.character: item};
  final placed = <String>{};
  final layouts = type == 'HIRAGANA' ? _hiraganaLayouts : _katakanaLayouts;

  _KanaSection buildSection(String title, List<List<String?>> layout) {
    final rows = [
      for (final row in layout)
        [
          for (final character in row)
            if (character == null)
              null
            else
              _takeKana(byCharacter, placed, character),
        ],
    ];
    return _KanaSection(title: title, rows: rows);
  }

  final sections = [
    buildSection('Dasar', layouts.basic),
    buildSection('Tenten', layouts.dakuten),
    buildSection('Maru', layouts.handakuten),
  ];

  final remaining = items
      .where((item) => !placed.contains(item.character))
      .toList()
    ..sort((a, b) => a.romaji.compareTo(b.romaji));
  if (remaining.isNotEmpty) {
    sections.add(
      _KanaSection(title: 'Lainnya', rows: _chunkRemaining(remaining)),
    );
  }

  return sections;
}

KanaCharacter? _takeKana(
  Map<String, KanaCharacter> byCharacter,
  Set<String> placed,
  String character,
) {
  final kana = byCharacter[character];
  if (kana != null) {
    placed.add(kana.character);
  }
  return kana;
}

List<List<KanaCharacter?>> _chunkRemaining(List<KanaCharacter> items) {
  final rows = <List<KanaCharacter?>>[];
  for (var index = 0; index < items.length; index += 5) {
    final row = <KanaCharacter?>[
      ...items.skip(index).take(5),
    ];
    while (row.length < 5) {
      row.add(null);
    }
    rows.add(row);
  }
  return rows;
}

const _hiraganaLayouts = (
  basic: _hiraganaBasicRows,
  dakuten: _hiraganaDakutenRows,
  handakuten: _hiraganaHandakutenRows,
);

const _katakanaLayouts = (
  basic: _katakanaBasicRows,
  dakuten: _katakanaDakutenRows,
  handakuten: _katakanaHandakutenRows,
);

const List<List<String?>> _hiraganaBasicRows = [
  ['あ', 'い', 'う', 'え', 'お'],
  ['か', 'き', 'く', 'け', 'こ'],
  ['さ', 'し', 'す', 'せ', 'そ'],
  ['た', 'ち', 'つ', 'て', 'と'],
  ['な', 'に', 'ぬ', 'ね', 'の'],
  ['は', 'ひ', 'ふ', 'へ', 'ほ'],
  ['ま', 'み', 'む', 'め', 'も'],
  ['や', null, 'ゆ', null, 'よ'],
  ['ら', 'り', 'る', 'れ', 'ろ'],
  ['わ', null, null, null, 'を'],
  ['ん', null, null, null, null],
];

const List<List<String?>> _hiraganaDakutenRows = [
  ['が', 'ぎ', 'ぐ', 'げ', 'ご'],
  ['ざ', 'じ', 'ず', 'ぜ', 'ぞ'],
  ['だ', 'ぢ', 'づ', 'で', 'ど'],
  ['ば', 'び', 'ぶ', 'べ', 'ぼ'],
];

const List<List<String?>> _hiraganaHandakutenRows = [
  ['ぱ', 'ぴ', 'ぷ', 'ぺ', 'ぽ'],
];

const List<List<String?>> _katakanaBasicRows = [
  ['ア', 'イ', 'ウ', 'エ', 'オ'],
  ['カ', 'キ', 'ク', 'ケ', 'コ'],
  ['サ', 'シ', 'ス', 'セ', 'ソ'],
  ['タ', 'チ', 'ツ', 'テ', 'ト'],
  ['ナ', 'ニ', 'ヌ', 'ネ', 'ノ'],
  ['ハ', 'ヒ', 'フ', 'ヘ', 'ホ'],
  ['マ', 'ミ', 'ム', 'メ', 'モ'],
  ['ヤ', null, 'ユ', null, 'ヨ'],
  ['ラ', 'リ', 'ル', 'レ', 'ロ'],
  ['ワ', null, null, null, 'ヲ'],
  ['ン', null, null, null, null],
];

const List<List<String?>> _katakanaDakutenRows = [
  ['ガ', 'ギ', 'グ', 'ゲ', 'ゴ'],
  ['ザ', 'ジ', 'ズ', 'ゼ', 'ゾ'],
  ['ダ', 'ヂ', 'ヅ', 'デ', 'ド'],
  ['バ', 'ビ', 'ブ', 'ベ', 'ボ'],
];

const List<List<String?>> _katakanaHandakutenRows = [
  ['パ', 'ピ', 'プ', 'ペ', 'ポ'],
];

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
