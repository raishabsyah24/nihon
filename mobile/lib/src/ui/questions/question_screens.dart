import 'package:flutter/material.dart';

import '../../models/app_models.dart';
import '../../services/api_client.dart';
import '../common/async_content.dart';

class JlptLevelScreen extends StatelessWidget {
  const JlptLevelScreen({super.key, required this.apiClient});

  final ApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    const levels = ['N5', 'N4', 'N3', 'N2', 'N1'];
    return Scaffold(
      appBar: AppBar(title: const Text('Soal JLPT')),
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
                subtitle: const Text('Kotoba, bunpou, dokkai, dan choukai'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => QuestionSetListScreen(
                        title: 'Paket JLPT $level',
                        loader: () =>
                            apiClient.getJlptQuestionSets(level: level),
                        detailLoader: apiClient.getJlptQuestionSet,
                        fallback: _demoJlptSets(level),
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

class QuestionSetListScreen extends StatelessWidget {
  const QuestionSetListScreen({
    super.key,
    required this.title,
    required this.loader,
    required this.detailLoader,
    required this.fallback,
  });

  final String title;
  final Future<List<QuestionSet>> Function() loader;
  final Future<QuestionSet> Function(String id) detailLoader;
  final List<QuestionSet> fallback;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: AsyncContent<List<QuestionSet>>(
          future: loader(),
          fallback: fallback,
          isEmpty: (items) => items.isEmpty,
          builder: (context, sets) {
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sets.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final set = sets[index];
                final count = set.questionCount ?? set.questions.length;
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.assignment_outlined),
                    title: Text(set.title),
                    subtitle: Text(
                      [
                        if (set.level != null) set.level,
                        if (set.category != null) set.category,
                        '$count soal',
                        if (set.durationMinutes != null)
                          '${set.durationMinutes} menit',
                      ].whereType<String>().join(' · '),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => QuestionPracticeScreen(
                            title: set.title,
                            loader: () async {
                              final detail = await detailLoader(set.id);
                              return detail.questions;
                            },
                            fallback: set.questions,
                          ),
                        ),
                      );
                    },
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

class QuestionPracticeScreen extends StatefulWidget {
  const QuestionPracticeScreen({
    super.key,
    required this.title,
    required this.loader,
    this.fallback,
  });

  final String title;
  final Future<List<QuestionItem>> Function() loader;
  final List<QuestionItem>? fallback;

  @override
  State<QuestionPracticeScreen> createState() => _QuestionPracticeScreenState();
}

class _QuestionPracticeScreenState extends State<QuestionPracticeScreen> {
  final Map<String, int> _answers = {};
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    final fallback =
        widget.fallback ??
        (widget.title.contains('JFT')
            ? _demoJftSets.first.questions
            : _demoJlpt('N5'));
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: AsyncContent<List<QuestionItem>>(
          future: widget.loader(),
          fallback: fallback,
          isEmpty: (items) => items.isEmpty,
          builder: (context, questions) {
            final answered = _answers.length;
            final correct = questions
                .where((q) => _answers[q.id] == q.answerIndex)
                .length;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: _ScoreBar(
                    answered: answered,
                    total: questions.length,
                    correct: correct,
                    submitted: _submitted,
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: questions.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final question = questions[index];
                      return _QuestionCard(
                        index: index + 1,
                        question: question,
                        selected: _answers[question.id],
                        showReview: _submitted,
                        onSelect: _submitted
                            ? null
                            : (value) => setState(() {
                                _answers[question.id] = value;
                              }),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => setState(() {
                            _answers.clear();
                            _submitted = false;
                          }),
                          icon: const Icon(Icons.refresh_outlined),
                          label: const Text('Ulangi'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: questions.isEmpty
                              ? null
                              : () => setState(() => _submitted = true),
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Selesai'),
                        ),
                      ),
                    ],
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

class _ScoreBar extends StatelessWidget {
  const _ScoreBar({
    required this.answered,
    required this.total,
    required this.correct,
    required this.submitted,
  });

  final int answered;
  final int total;
  final int correct;
  final bool submitted;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : answered / total;
    final score = total == 0 ? 0 : ((correct / total) * 100).round();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    submitted ? 'Skor $score' : 'Progress $answered/$total',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                InfoPill(
                  label: submitted ? 'Benar $correct/$total' : 'Latihan',
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: submitted ? score / 100 : progress),
          ],
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.index,
    required this.question,
    required this.selected,
    required this.showReview,
    required this.onSelect,
  });

  final int index;
  final QuestionItem question;
  final int? selected;
  final bool showReview;
  final ValueChanged<int>? onSelect;

  @override
  Widget build(BuildContext context) {
    final isAnswered = selected != null;
    final answerIndexIsValid =
        question.answerIndex >= 0 &&
        question.answerIndex < question.options.length;
    final correctAnswer = answerIndexIsValid
        ? question.options[question.answerIndex]
        : 'Jawaban belum dikonfigurasi';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                InfoPill(label: 'Soal $index', icon: Icons.quiz_outlined),
                if (question.level != null) InfoPill(label: question.level!),
                if (question.category != null)
                  InfoPill(label: question.category!),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              question.prompt,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < question.options.length; i++)
              _AnswerOption(
                label: question.options[i],
                selected: selected == i,
                correct: showReview && i == question.answerIndex,
                wrong:
                    showReview &&
                    selected == i &&
                    selected != question.answerIndex,
                onTap: onSelect == null ? null : () => onSelect!(i),
              ),
            if (showReview) ...[
              const Divider(height: 20),
              Row(
                children: [
                  Icon(
                    isAnswered && selected == question.answerIndex
                        ? Icons.check_circle_outline
                        : Icons.cancel_outlined,
                    color: isAnswered && selected == question.answerIndex
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isAnswered && selected == question.answerIndex
                          ? 'Jawaban benar'
                          : 'Jawaban benar: $correctAnswer',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              if (question.explanation?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Text(question.explanation!),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _AnswerOption extends StatelessWidget {
  const _AnswerOption({
    required this.label,
    required this.selected,
    required this.correct,
    required this.wrong,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool correct;
  final bool wrong;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = correct
        ? Colors.green.shade700
        : wrong
        ? Colors.red.shade700
        : selected
        ? colorScheme.primary
        : Colors.black.withValues(alpha: 0.12);
    final background = correct
        ? Colors.green.withValues(alpha: 0.10)
        : wrong
        ? Colors.red.withValues(alpha: 0.08)
        : selected
        ? colorScheme.primaryContainer.withValues(alpha: 0.75)
        : Colors.white;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Icon(
                correct
                    ? Icons.check_circle_outline
                    : wrong
                    ? Icons.cancel_outlined
                    : selected
                    ? Icons.radio_button_checked_outlined
                    : Icons.radio_button_unchecked_outlined,
                color: borderColor,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(label)),
            ],
          ),
        ),
      ),
    );
  }
}

List<QuestionSet> demoJftQuestionSets() => _demoJftSets;

List<QuestionSet> _demoJlptSets(String level) => [
  QuestionSet(
    id: 'demo-jlpt-$level-kotoba',
    title: 'JLPT $level Kotoba Basic',
    description: 'Paket latihan kosakata dasar.',
    level: level,
    category: 'kotoba',
    durationMinutes: 15,
    questionCount: _demoJlpt(level).length,
    questions: _demoJlpt(level),
  ),
];

List<QuestionItem> _demoJlpt(String level) => [
  QuestionItem(
    id: 'demo-jlpt-$level-1',
    prompt: '「日本」の読み方はどれですか。',
    options: const ['にほん', 'にちほん', 'ひほん', 'じほん'],
    answerIndex: 0,
    level: level,
    category: 'kotoba',
    explanation: '日本 dibaca にほん.',
  ),
  QuestionItem(
    id: 'demo-jlpt-$level-2',
    prompt: 'Pilih arti dari 「水」.',
    options: const ['Api', 'Air', 'Tanah', 'Angin'],
    answerIndex: 1,
    level: level,
    category: 'kotoba',
    explanation: '水 berarti air.',
  ),
];

const _demoJftSets = [
  QuestionSet(
    id: 'demo-jft-daily',
    title: 'JFT Basic Daily Expression',
    description: 'Paket latihan ungkapan harian JFT Basic.',
    category: 'daily',
    durationMinutes: 15,
    questionCount: 2,
    questions: [
      QuestionItem(
        id: 'demo-jft-1',
        prompt: 'Pilih ungkapan yang tepat untuk mengucapkan terima kasih.',
        options: ['すみません', 'ありがとう', 'おはよう', 'さようなら'],
        answerIndex: 1,
        category: 'daily',
        explanation: 'ありがとう berarti terima kasih.',
      ),
      QuestionItem(
        id: 'demo-jft-2',
        prompt: '「駅」は tempat untuk apa?',
        options: ['Makan', 'Naik kereta', 'Belanja baju', 'Tidur'],
        answerIndex: 1,
        category: 'daily',
        explanation: '駅 berarti stasiun.',
      ),
    ],
  ),
];
