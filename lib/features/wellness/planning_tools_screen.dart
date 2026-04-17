import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme.dart';
import '../../widgets/completion_dialog.dart';

// ── Focus area model ─────────────────────────────────────────────────────────

class _FocusArea {
  final String label;
  final IconData icon;
  const _FocusArea(this.label, this.icon);
}

// ── Screen ───────────────────────────────────────────────────────────────────

class PlanningToolsScreen extends StatefulWidget {
  const PlanningToolsScreen({super.key});

  @override
  State<PlanningToolsScreen> createState() => _PlanningToolsScreenState();
}

class _PlanningToolsScreenState extends State<PlanningToolsScreen> {
  final _intentionCtrl = TextEditingController();
  final _priorityCtrl  = TextEditingController();
  final List<PlanningTask> _tasks = [];
  final Set<String> _selectedFocus = {};
  bool _canSave = false;

  static const _focusAreas = [
    _FocusArea('Mental Wellbeing',  Icons.psychology_rounded),
    _FocusArea('Physical Health',   Icons.directions_run_rounded),
    _FocusArea('Relationships',     Icons.people_rounded),
    _FocusArea('Personal Growth',   Icons.trending_up_rounded),
    _FocusArea('Work / Career',     Icons.work_rounded),
    _FocusArea('Creativity',        Icons.palette_rounded),
    _FocusArea('Home',              Icons.home_rounded),
    _FocusArea('Community',         Icons.public_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _intentionCtrl.addListener(_check);
    _priorityCtrl.addListener(_check);
  }

  @override
  void dispose() {
    _intentionCtrl.dispose();
    _priorityCtrl.dispose();
    super.dispose();
  }

  void _check() {
    final can = _intentionCtrl.text.trim().isNotEmpty &&
        _priorityCtrl.text.trim().isNotEmpty &&
        _selectedFocus.isNotEmpty;
    if (can != _canSave) setState(() => _canSave = can);
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('planning_tasks_v2') ?? [];
    if (!mounted) return;
    setState(() => _tasks
      ..clear()
      ..addAll(stored.map((s) => PlanningTask.fromJson(
            jsonDecode(s) as Map<String, dynamic>))));
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'planning_tasks_v2',
      _tasks.map((t) => jsonEncode(t.toJson())).toList(),
    );
  }

  Future<void> _saveTask() async {
    if (!_canSave) return;

    final task = PlanningTask(
      intention:  _intentionCtrl.text.trim(),
      priority:   _priorityCtrl.text.trim(),
      focusAreas: _selectedFocus.toList(),
      createdAt:  DateTime.now(),
    );

    setState(() {
      _tasks.insert(0, task);
      _intentionCtrl.clear();
      _priorityCtrl.clear();
      _selectedFocus.clear();
      _canSave = false;
    });

    await _persist();

    if (!mounted) return;
    CompletionDialog.show(
      context: context,
      title: 'Intention Set',
      message:
          'Your intention is now active.\nStay grounded throughout your day.',
      color: AppTheme.primary,
      icon: Icons.flag_rounded,
      primaryLabel: 'Done',
      secondaryLabel: 'Add Another',
      onPrimary: () => Navigator.pop(context),
    );
  }

  void _deleteTask(int index) {
    setState(() => _tasks.removeAt(index));
    _persist();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      appBar: AppBar(title: const Text('Weekly Intention')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHero(),
            const SizedBox(height: 24),
            Text('Your Intention', style: AppTheme.headingSm),
            const SizedBox(height: 8),
            _buildField(
              _intentionCtrl,
              'e.g. Stay calm, focused, and kind today.',
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Text('Top Priority', style: AppTheme.headingSm),
            const SizedBox(height: 8),
            _buildField(
              _priorityCtrl,
              'e.g. Finish presentation, rest early.',
            ),
            const SizedBox(height: 16),
            Text('Focus Areas', style: AppTheme.headingSm),
            const SizedBox(height: 10),
            _buildFocusChips(),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _canSave ? _saveTask : null,
              icon: const Icon(Icons.flag_rounded),
              label: const Text('Save Intention'),
            ),
            const SizedBox(height: 36),
            if (_tasks.isNotEmpty) ...[
              Text('Active Intentions', style: AppTheme.headingSm),
              const SizedBox(height: 12),
              ..._tasks.asMap().entries.map((e) => _IntentionCard(
                    task: e.value,
                    onDelete: () => _deleteTask(e.key),
                  )),
            ] else
              _buildEmptyState(),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.primarySurface,
          borderRadius: BorderRadius.circular(AppTheme.cornerRadiusLg),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.self_improvement_rounded,
                  color: AppTheme.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Set Your Weekly Intention',
                      style: AppTheme.headingSm),
                  const SizedBox(height: 4),
                  Text('Align your energy with what matters most.',
                      style: AppTheme.bodyMd),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildField(TextEditingController ctrl, String hint,
          {int maxLines = 1}) =>
      TextField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(hintText: hint),
      );

  Widget _buildFocusChips() => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _focusAreas.map((area) {
          final selected = _selectedFocus.contains(area.label);
          return FilterChip(
            avatar: Icon(
              area.icon,
              size: 16,
              color: selected ? AppTheme.primary : AppTheme.textMuted,
            ),
            label: Text(area.label),
            selected: selected,
            onSelected: (v) {
              setState(() {
                v
                    ? _selectedFocus.add(area.label)
                    : _selectedFocus.remove(area.label);
              });
              _check();
            },
            selectedColor: AppTheme.primarySurface,
            checkmarkColor: AppTheme.primary,
            labelStyle: TextStyle(
              color: selected ? AppTheme.primary : AppTheme.textBody,
              fontWeight:
                  selected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
          );
        }).toList(),
      );

  Widget _buildEmptyState() => Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            children: [
              const Icon(Icons.flag_outlined,
                  size: 48, color: AppTheme.primaryLight),
              const SizedBox(height: 16),
              Text('No intentions yet', style: AppTheme.headingSm),
              const SizedBox(height: 6),
              Text(
                'Set your first intention to begin\nguiding your energy this week.',
                textAlign: TextAlign.center,
                style: AppTheme.bodyMd,
              ),
            ],
          ),
        ),
      );
}

// ── Data model ───────────────────────────────────────────────────────────────

class PlanningTask {
  final String intention;
  final String priority;
  final List<String> focusAreas;
  final DateTime createdAt;

  PlanningTask({
    required this.intention,
    required this.priority,
    required this.focusAreas,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'intention':  intention,
        'priority':   priority,
        'focusAreas': focusAreas,
        'createdAt':  createdAt.toIso8601String(),
      };

  factory PlanningTask.fromJson(Map<String, dynamic> json) => PlanningTask(
        intention:  json['intention'] as String,
        priority:   json['priority']  as String,
        focusAreas: List<String>.from(json['focusAreas'] as List),
        createdAt:  DateTime.parse(json['createdAt'] as String),
      );
}

// ── Intention card (swipe-to-delete) ─────────────────────────────────────────

class _IntentionCard extends StatelessWidget {
  final PlanningTask task;
  final VoidCallback onDelete;
  const _IntentionCard({required this.task, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.createdAt.toIso8601String()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.crisisRed.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppTheme.cornerRadius),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppTheme.crisisRed),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bgSurface,
          borderRadius: BorderRadius.circular(AppTheme.cornerRadius),
          border: Border.all(color: AppTheme.bgBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Intention ──────────────────────────────────────────
            Text('Your Intention',
                style: AppTheme.bodySm
                    .copyWith(color: AppTheme.textMuted)),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.flag_rounded,
                      size: 16, color: AppTheme.primary),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task.intention,
                    style: AppTheme.bodyLg.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
              ],
            ),

            if (task.priority.isNotEmpty) ...[
              const SizedBox(height: 12),
              // ── Top Priority ────────────────────────────────────
              Text('Top Priority',
                  style: AppTheme.bodySm
                      .copyWith(color: AppTheme.textMuted)),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.star_rounded,
                        size: 14, color: AppTheme.accent),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                      child: Text(task.priority,
                          style: AppTheme.bodyMd)),
                ],
              ),
            ],

            const SizedBox(height: 12),
            // ── Focus Areas ─────────────────────────────────────
            Text('Focus Areas',
                style: AppTheme.bodySm
                    .copyWith(color: AppTheme.textMuted)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: task.focusAreas
                  .map((a) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primarySurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(a,
                            style: AppTheme.bodySm
                                .copyWith(color: AppTheme.primary)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            Text(_formatDate(task.createdAt), style: AppTheme.bodySm),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now   = DateTime.now();
    final today = DateTime(now.year,  now.month,  now.day);
    final day   = DateTime(date.year, date.month, date.day);
    if (day == today) return 'Today';
    if (day == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }
}
