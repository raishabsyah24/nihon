import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/app_models.dart';
import '../../services/api_client.dart';
import '../common/async_content.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key, required this.apiClient});

  final ApiClient apiClient;

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  String? _type;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jadwal Ujian')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Semua'),
                    selected: _type == null,
                    onSelected: (_) => setState(() => _type = null),
                  ),
                  for (final type in const ['JFT', 'JLPT', 'SSW'])
                    ChoiceChip(
                      label: Text(type),
                      selected: _type == type,
                      onSelected: (_) => setState(() => _type = type),
                    ),
                ],
              ),
            ),
            Expanded(
              child: AsyncContent<List<ExamSchedule>>(
                future: widget.apiClient.getExamSchedules(type: _type),
                fallback: _demoSchedules
                    .where((item) => _type == null || item.type == _type)
                    .toList(),
                isEmpty: (items) => items.isEmpty,
                builder: (context, schedules) {
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: schedules.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) =>
                        _ScheduleTile(schedule: schedules[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  const _ScheduleTile({required this.schedule});

  final ExamSchedule schedule;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => _ScheduleDetailScreen(schedule: schedule),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  InfoPill(
                    label: schedule.type,
                    icon: Icons.event_available_outlined,
                  ),
                  if (schedule.location?.isNotEmpty == true)
                    InfoPill(
                      label: schedule.location!,
                      icon: Icons.place_outlined,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                schedule.title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.schedule_outlined,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_formatScheduleRange(schedule))),
                ],
              ),
              if (schedule.description?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Text(
                  schedule.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (schedule.registerUrl?.isNotEmpty == true) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.link_outlined,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        schedule.registerUrl!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ScheduleDetailScreen extends StatelessWidget {
  const _ScheduleDetailScreen({required this.schedule});

  final ExamSchedule schedule;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Jadwal')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                InfoPill(
                  label: schedule.type,
                  icon: Icons.event_available_outlined,
                ),
                if (schedule.location?.isNotEmpty == true)
                  InfoPill(
                    label: schedule.location!,
                    icon: Icons.place_outlined,
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              schedule.title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 18),
            _DetailRow(
              icon: Icons.schedule_outlined,
              label: 'Waktu',
              value: _formatScheduleRange(schedule),
            ),
            if (schedule.location?.isNotEmpty == true)
              _DetailRow(
                icon: Icons.place_outlined,
                label: 'Lokasi',
                value: schedule.location!,
              ),
            if (schedule.description?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              Text(
                'Deskripsi',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                schedule.description!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
            if (schedule.registerUrl?.isNotEmpty == true) ...[
              const SizedBox(height: 18),
              Text(
                'Link Pendaftaran',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: colorScheme.primaryContainer.withValues(alpha: 0.24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SelectableText(
                    schedule.registerUrl!,
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatScheduleRange(ExamSchedule schedule) {
  final startsAt = schedule.startsAt;
  if (startsAt == null) {
    return 'Tanggal belum tersedia';
  }

  final start = _local(startsAt);
  final endsAt = schedule.endsAt;
  if (endsAt == null) {
    return _formatDateTime(start);
  }

  final end = _local(endsAt);
  final sameDay =
      start.year == end.year &&
      start.month == end.month &&
      start.day == end.day;
  if (sameDay) {
    final date = DateFormat('d MMMM yyyy', 'id_ID').format(start);
    final startTime = DateFormat('HH:mm', 'id_ID').format(start);
    final endTime = DateFormat('HH:mm', 'id_ID').format(end);
    return '$date | $startTime-$endTime';
  }

  return '${_formatDateTime(start)} - ${_formatDateTime(end)}';
}

String _formatDateTime(DateTime value) {
  return DateFormat('d MMMM yyyy, HH:mm', 'id_ID').format(value);
}

DateTime _local(DateTime value) => value.isUtc ? value.toLocal() : value;

final _demoSchedules = [
  ExamSchedule(
    id: 'demo-jft',
    type: 'JFT',
    title: 'JFT Basic Jakarta',
    location: 'Jakarta',
    startsAt: DateTime(2026, 8, 15, 9),
    endsAt: DateTime(2026, 8, 15, 12),
    registerUrl: 'https://example.com/jft',
    description: 'Jadwal demo untuk persiapan JFT Basic.',
  ),
  ExamSchedule(
    id: 'demo-jlpt',
    type: 'JLPT',
    title: 'JLPT Indonesia',
    location: 'Indonesia',
    startsAt: DateTime(2026, 12, 6, 9),
    endsAt: DateTime(2026, 12, 6, 13),
    registerUrl: 'https://example.com/jlpt',
    description: 'Jadwal demo untuk JLPT dari N5 sampai N1.',
  ),
  ExamSchedule(
    id: 'demo-ssw',
    type: 'SSW',
    title: 'SSW Kaigo Skill Test',
    location: 'Online/CBT',
    startsAt: DateTime(2026, 9, 20, 8),
    endsAt: DateTime(2026, 9, 20, 11),
    registerUrl: 'https://example.com/ssw',
    description: 'Jadwal demo untuk ujian keterampilan SSW bidang 介護.',
  ),
];
