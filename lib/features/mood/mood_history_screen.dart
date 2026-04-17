import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme.dart';
import '../../services/streak_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class MoodHistoryScreen extends StatefulWidget {
  const MoodHistoryScreen({super.key});

  @override
  State<MoodHistoryScreen> createState() => _MoodHistoryScreenState();
}

class _MoodHistoryScreenState extends State<MoodHistoryScreen>
    with SingleTickerProviderStateMixin {

  List<Map<String, dynamic>> _entries   = [];
  Map<String, double>        _moodByDay = {};
  Set<String>                _earnedIds = {};
  int  _streak        = 0;
  int  _longestStreak = 0;
  int  _uniqueDays    = 0;
  bool _loading       = true;

  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw   = prefs.getStringList('mood_history') ?? [];
    final list  = raw
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .toList()
      ..sort((a, b) => DateTime.parse(b['timestamp'])
          .compareTo(DateTime.parse(a['timestamp'])));

    final earned = await StreakService.earnedIds();

    if (!mounted) return;
    setState(() {
      _entries      = list;
      _moodByDay    = StreakService.moodByDay(raw);
      _earnedIds    = earned;
      _streak       = StreakService.currentStreak(raw);
      _longestStreak= StreakService.longestStreak(raw);
      _uniqueDays   = StreakService.totalUniqueDays(raw);
      _loading      = false;
    });
  }

  Future<void> _deleteEntry(int index) async {
    final prefs   = await SharedPreferences.getInstance();
    final removed = _entries[index];
    setState(() => _entries.removeAt(index));
    final raw = prefs.getStringList('mood_history') ?? [];
    raw.removeWhere((s) {
      try {
        return (jsonDecode(s) as Map<String, dynamic>)['timestamp'] ==
            removed['timestamp'];
      } catch (_) { return false; }
    });
    await prefs.setStringList('mood_history', raw);
    // Recalculate stats
    setState(() {
      _moodByDay    = StreakService.moodByDay(raw);
      _streak       = StreakService.currentStreak(raw);
      _longestStreak= StreakService.longestStreak(raw);
      _uniqueDays   = StreakService.totalUniqueDays(raw);
    });
  }

  Future<void> _clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('mood_history');
    setState(() {
      _entries      = [];
      _moodByDay    = {};
      _streak       = 0;
      _longestStreak= 0;
      _uniqueDays   = 0;
    });
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: 'Go back',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: const Text('Mood Journey'),
        actions: [
          if (_entries.isNotEmpty)
            Tooltip(
              message: 'Clear all entries',
              child: IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: _confirmClear,
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Achievements'),
            Tab(text: 'Journal'),
          ],
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary))
          : TabBarView(
              controller: _tabCtrl,
              children: [
                _buildOverviewTab(),
                _buildAchievementsTab(),
                _buildJournalTab(),
              ],
            ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tab 1 — Overview (stats + heatmap)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: _load,
      color: AppTheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsRow(),
            const SizedBox(height: 24),
            _buildHeatmapCard(),
            const SizedBox(height: 24),
            _buildMoodTrendCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _StatCard(
          emoji: '🔥',
          value: '$_streak',
          label: 'Day Streak',
          color: const Color(0xFFFF6B35),
          bgColor: const Color(0xFFFFF3EE),
        ),
        const SizedBox(width: 10),
        _StatCard(
          emoji: '📅',
          value: '$_uniqueDays',
          label: 'Days Active',
          color: AppTheme.primary,
          bgColor: AppTheme.primarySurface,
        ),
        const SizedBox(width: 10),
        _StatCard(
          emoji: '⭐',
          value: '$_longestStreak',
          label: 'Best Streak',
          color: const Color(0xFF7B5EA7),
          bgColor: const Color(0xFFF3EEF9),
        ),
      ],
    );
  }

  Widget _buildHeatmapCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.bgBorder),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.grid_view_rounded,
                  size: 16, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(
                'Activity Heatmap',
                style: AppTheme.bodyMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              const Spacer(),
              Text(
                'Last 15 weeks',
                style: AppTheme.bodySm,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _entries.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'Complete a check-in to see your heatmap',
                      style: AppTheme.bodySm,
                    ),
                  ),
                )
              : _MoodHeatmap(moodByDay: _moodByDay),
        ],
      ),
    );
  }

  Widget _buildMoodTrendCard() {
    if (_entries.isEmpty) return const SizedBox.shrink();

    // Last 7 entries for a quick trend
    final recent = _entries.take(7).toList().reversed.toList();
    final max = 10.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.bgBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.show_chart_rounded,
                  size: 16, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(
                'Recent Mood Trend',
                style: AppTheme.bodyMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              const Spacer(),
              Text('Last ${recent.length}', style: AppTheme.bodySm),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: recent.map((entry) {
                final mood = (entry['mood_score'] as num).toDouble();
                final frac = (mood / max).clamp(0.05, 1.0);
                final color = _moodColor(mood);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          mood.toStringAsFixed(0),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          height: 56 * frac,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: recent.map((entry) {
              final ts = DateTime.parse(entry['timestamp'] as String);
              return Expanded(
                child: Text(
                  '${ts.day}/${ts.month}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 9, color: AppTheme.textMuted),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tab 2 — Achievements
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildAchievementsTab() {
    final earned   = _earnedIds.length;
    final total    = StreakService.milestones.length;
    final progress = total == 0 ? 0.0 : earned / total;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress summary
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A6B52), Color(0xFF2E9B78)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🏅', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$earned of $total achievements',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            earned == total
                                ? 'All achievements unlocked! Amazing!'
                                : earned == 0
                                    ? 'Start a check-in to earn your first badge'
                                    : 'Keep checking in to unlock more',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Semantics(
                  label: '$earned of $total achievements unlocked',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor:
                          const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'CHECK-IN MILESTONES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          _buildBadgeGrid(
            StreakService.milestones.where((m) => !m.isStreak).toList(),
          ),

          const SizedBox(height: 24),

          Text(
            'STREAK MILESTONES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: const Color(0xFFFF6B35),
            ),
          ),
          const SizedBox(height: 12),
          _buildBadgeGrid(
            StreakService.milestones.where((m) => m.isStreak).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeGrid(List<Milestone> ms) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.9,
      ),
      itemCount: ms.length,
      itemBuilder: (_, i) {
        final m       = ms[i];
        final isEarned = _earnedIds.contains(m.id);
        return _BadgeCard(milestone: m, earned: isEarned);
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tab 3 — Journal
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildJournalTab() {
    if (_entries.isEmpty) return _buildEmptyJournal();

    return RefreshIndicator(
      onRefresh: _load,
      color: AppTheme.primary,
      child: _buildJournalList(),
    );
  }

  Widget _buildEmptyJournal() {
    return Padding(
      padding: const EdgeInsets.all(36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: const BoxDecoration(
              color: AppTheme.primarySurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.book_rounded,
                size: 52, color: AppTheme.primary),
          ),
          const SizedBox(height: 28),
          Text('Your journal is empty',
              style: AppTheme.headingMd, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(
            'Every mood check-in you complete gets saved here as a personal journal entry.',
            textAlign: TextAlign.center,
            style: AppTheme.bodyMd,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.add_rounded),
              label: const Text('Start a Check-in'),
              onPressed: () => context.push('/chatmood'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalList() {
    final groups  = <String, List<_IndexedEntry>>{};
    final ordered = <String>[];

    for (int i = 0; i < _entries.length; i++) {
      final label =
          _dateLabel(DateTime.parse(_entries[i]['timestamp'] as String));
      if (!groups.containsKey(label)) {
        groups[label] = [];
        ordered.add(label);
      }
      groups[label]!.add(_IndexedEntry(index: i, data: _entries[i]));
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      itemCount: ordered.length,
      itemBuilder: (_, gi) {
        final label   = ordered[gi];
        final entries = groups[label]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DateHeader(label: label, count: entries.length),
            const SizedBox(height: 8),
            ...entries.map((ie) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _EntryCard(
                    entry: ie.data,
                    onDelete: () {
                      HapticFeedback.lightImpact();
                      _deleteEntry(ie.index);
                    },
                  ),
                )),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  void _confirmClear() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Clear All History?', style: AppTheme.headingSm),
        content: Text(
          'This permanently deletes all your mood reflections.',
          style: AppTheme.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            style:
                TextButton.styleFrom(foregroundColor: AppTheme.crisisRed),
            onPressed: () async {
              Navigator.pop(ctx);
              await _clearAll();
            },
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  String _dateLabel(DateTime dt) {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day   = DateTime(dt.year, dt.month, dt.day);
    if (day == today) return 'Today';
    if (day == today.subtract(const Duration(days: 1))) return 'Yesterday';
    if (today.difference(day).inDays < 7) {
      const weekdays = [
        'Monday', 'Tuesday', 'Wednesday',
        'Thursday', 'Friday', 'Saturday', 'Sunday',
      ];
      return weekdays[dt.weekday - 1];
    }
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  Color _moodColor(double v) {
    if (v < 3)  return const Color(0xFFEF5350);
    if (v < 5)  return const Color(0xFFFF8A65);
    if (v < 7)  return const Color(0xFF78909C);
    if (v < 9)  return AppTheme.primaryMid;
    return AppTheme.primary;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat card
// ─────────────────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color  color;
  final Color  bgColor;

  const _StatCard({
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        label: '$label: $value',
        child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            ExcludeSemantics(child: Text(emoji, style: const TextStyle(fontSize: 22))),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: color.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        ), // Container
      ), // Semantics
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mood heatmap
// ─────────────────────────────────────────────────────────────────────────────

class _MoodHeatmap extends StatelessWidget {
  final Map<String, double> moodByDay;

  static const double _cell  = 15;
  static const double _gap   = 3;
  static const int    _weeks = 15;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  const _MoodHeatmap({required this.moodByDay});

  static String _key(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Color _colorForDay(DateTime day) {
    final today = DateTime.now();
    if (day.isAfter(DateTime(today.year, today.month, today.day))) {
      return Colors.transparent;
    }
    final mood = moodByDay[_key(day)];
    if (mood == null) return const Color(0xFFE8E8E8);
    if (mood < 3)  return const Color(0xFFFFCDD2);
    if (mood < 5)  return const Color(0xFFFFE0B2);
    if (mood < 7)  return const Color(0xFFB2DFDB);
    if (mood < 9)  return const Color(0xFF81C784);
    return const Color(0xFF2E9B78);
  }

  @override
  Widget build(BuildContext context) {
    final today     = DateTime.now();
    // Start from the Monday of (_weeks - 1) full weeks ago
    final startDate = today.subtract(
      Duration(days: today.weekday - 1 + (_weeks - 1) * 7),
    );

    // Build list of weeks
    final weeks = <List<DateTime>>[];
    var weekStart = startDate;
    while (!weekStart.isAfter(today)) {
      weeks.add(
        List.generate(7, (i) => weekStart.add(Duration(days: i))),
      );
      weekStart = weekStart.add(const Duration(days: 7));
    }

    // Month label positions
    final monthLabels = <int, String>{};
    for (int wi = 0; wi < weeks.length; wi++) {
      final mon = weeks[wi][0];
      if (wi == 0 || mon.month != weeks[wi - 1][0].month) {
        monthLabels[wi] = _months[mon.month - 1];
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month labels
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(width: 20), // day-label spacer
            ...List.generate(weeks.length, (wi) => SizedBox(
              width: _cell + _gap,
              child: monthLabels.containsKey(wi)
                  ? Text(
                      monthLabels[wi]!,
                      style: const TextStyle(
                          fontSize: 9, color: AppTheme.textMuted),
                    )
                  : null,
            )),
          ],
        ),
        const SizedBox(height: 4),

        // Grid
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day labels
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: ['M', '', 'W', '', 'F', '', 'S']
                  .map((d) => SizedBox(
                        width: 14,
                        height: _cell + _gap,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: d.isNotEmpty
                              ? Text(
                                  d,
                                  style: const TextStyle(
                                      fontSize: 9,
                                      color: AppTheme.textMuted),
                                )
                              : null,
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(width: 4),

            // Week columns
            ...weeks.map((week) => Padding(
                  padding: const EdgeInsets.only(right: _gap),
                  child: Column(
                    children: week.map((day) {
                      final color = _colorForDay(day);
                      final mood = moodByDay[_key(day)];
                      final today = DateTime.now();
                      final isFuture = day.isAfter(
                          DateTime(today.year, today.month, today.day));
                      final label = isFuture
                          ? null
                          : mood == null
                              ? 'No check-in on ${day.day}/${day.month}'
                              : 'Mood ${mood.toStringAsFixed(1)} on ${day.day}/${day.month}';
                      return Semantics(
                        label: label,
                        excludeSemantics: label == null,
                        child: Container(
                          width: _cell,
                          height: _cell,
                          margin: const EdgeInsets.only(bottom: _gap),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                )),
          ],
        ),

        const SizedBox(height: 10),

        // Legend
        Row(
          children: [
            const SizedBox(width: 18),
            Text('No check-in',
                style:
                    const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
            const SizedBox(width: 6),
            ...[
              const Color(0xFFE8E8E8),
              const Color(0xFFFFCDD2),
              const Color(0xFFFFE0B2),
              const Color(0xFFB2DFDB),
              const Color(0xFF81C784),
              const Color(0xFF2E9B78),
            ].map((c) => Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(left: 3),
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(2),
                  ),
                )),
            const SizedBox(width: 6),
            Text('Great mood',
                style:
                    const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Badge card
// ─────────────────────────────────────────────────────────────────────────────

class _BadgeCard extends StatelessWidget {
  final Milestone milestone;
  final bool      earned;

  const _BadgeCard({required this.milestone, required this.earned});

  @override
  Widget build(BuildContext context) {
    final semanticLabel = earned
        ? '${milestone.title} — ${milestone.subtitle} — Earned'
        : '${milestone.title} — ${milestone.subtitle} — Locked';
    return Semantics(
      label: semanticLabel,
      child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: earned ? Colors.white : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: earned
              ? AppTheme.primary.withValues(alpha: 0.2)
              : const Color(0xFFE0E0E0),
          width: earned ? 1.5 : 1,
        ),
        boxShadow: earned
            ? [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          earned
              ? Text(milestone.emoji,
                  style: const TextStyle(fontSize: 28))
              : const Icon(Icons.lock_outline_rounded,
                  color: Color(0xFFBDBDBD), size: 24),
          const SizedBox(height: 8),
          Text(
            milestone.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: earned
                  ? AppTheme.textDark
                  : const Color(0xFFBDBDBD),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            milestone.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: earned
                  ? AppTheme.textMuted
                  : const Color(0xFFD0D0D0),
            ),
          ),
        ],
      ),
      ), // AnimatedContainer
    ); // Semantics
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Date header
// ─────────────────────────────────────────────────────────────────────────────

class _DateHeader extends StatelessWidget {
  final String label;
  final int    count;
  const _DateHeader({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: AppTheme.bodyMd
              .copyWith(fontWeight: FontWeight.w700, color: AppTheme.textDark),
        ),
        const SizedBox(width: 8),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppTheme.primarySurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: AppTheme.bodySm.copyWith(
              color: AppTheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Entry card (expandable, swipe to delete)
// ─────────────────────────────────────────────────────────────────────────────

class _EntryCard extends StatefulWidget {
  final Map<String, dynamic> entry;
  final VoidCallback         onDelete;

  const _EntryCard({required this.entry, required this.onDelete});

  @override
  State<_EntryCard> createState() => _EntryCardState();
}

class _EntryCardState extends State<_EntryCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _ctrl;
  late final Animation<double>   _rotation;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _rotation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final entry    = widget.entry;
    final ts       = DateTime.parse(entry['timestamp'] as String);
    final mood     = (entry['mood_score'] as num).toDouble();
    final emotions = List<String>.from(entry['emotions'] ?? []);
    final influences = List<String>.from(entry['influences'] ?? []);
    final note     = (entry['note'] as String?) ?? '';
    final bodyFeel = (entry['body_feel'] as String?) ?? '';
    final intent   = (entry['intent'] as String?) ?? '';
    final moodCfg  = _moodConfig(mood);
    final time = '${ts.hour.toString().padLeft(2, '0')}:'
        '${ts.minute.toString().padLeft(2, '0')}';

    return Dismissible(
      key: ValueKey(entry['timestamp']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.crisisRed.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppTheme.crisisRed),
      ),
      confirmDismiss: (_) async => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Delete entry?', style: AppTheme.headingSm),
          content: Text('This reflection will be permanently removed.',
              style: AppTheme.bodyMd),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            TextButton(
              style:
                  TextButton.styleFrom(foregroundColor: AppTheme.crisisRed),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
      onDismissed: (_) => widget.onDelete(),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.bgSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.bgBorder),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Semantics(
              hint: _expanded ? 'Tap to collapse entry' : 'Tap to expand entry',
              child: InkWell(
              onTap: _toggle,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: moodCfg.color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(moodCfg.emoji,
                            style: const TextStyle(fontSize: 20)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Mood ${mood.toStringAsFixed(1)}/10',
                                style: AppTheme.bodyMd.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: moodCfg.color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  moodCfg.label,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: moodCfg.color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(time,
                                  style: AppTheme.bodySm
                                      .copyWith(fontSize: 12)),
                              if (emotions.isNotEmpty)
                                Text(
                                  '  ·  ${emotions.take(2).join(', ')}'
                                  '${emotions.length > 2 ? ' +${emotions.length - 2}' : ''}',
                                  style: AppTheme.bodySm.copyWith(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    RotationTransition(
                      turns: _rotation,
                      child: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
            ), // InkWell
            ), // Semantics
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: _expanded
                  ? _buildExpanded(
                      mood, emotions, influences, note, bodyFeel, intent)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpanded(
    double mood,
    List<String> emotions,
    List<String> influences,
    String note,
    String bodyFeel,
    String intent,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: AppTheme.bgBorder, height: 1),
          const SizedBox(height: 14),
          _DetailBar(
              label: 'Mood', value: mood, color: _moodConfig(mood).color),
          if (bodyFeel.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Body ', style: AppTheme.bodySm),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.primarySurface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(bodyFeel,
                      style: AppTheme.bodySm.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
          if (intent.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Text('Intent ', style: AppTheme.bodySm),
                Expanded(
                  child: Text(
                    intent,
                    style: AppTheme.bodySm.copyWith(color: AppTheme.textBody),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if (emotions.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text('Emotions',
                style: AppTheme.bodySm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textBody)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: emotions
                  .map((e) => _Chip(
                        label: e,
                        bg: AppTheme.primarySurface,
                        fg: AppTheme.primary,
                      ))
                  .toList(),
            ),
          ],
          if (influences.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Influences',
                style: AppTheme.bodySm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textBody)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: influences
                  .map((e) => _Chip(
                        label: e,
                        bg: AppTheme.accentSurface,
                        fg: AppTheme.accent,
                      ))
                  .toList(),
            ),
          ],
          if (note.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.bgPage,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.bgBorder),
              ),
              child: Text(note,
                  style: AppTheme.bodyMd.copyWith(height: 1.5)),
            ),
          ],
        ],
      ),
    );
  }

  _MoodCfg _moodConfig(double v) {
    if (v <= 2) return _MoodCfg('😞', const Color(0xFFEF5350), 'Very Low');
    if (v <= 4) return _MoodCfg('😔', const Color(0xFFFF8A65), 'Low');
    if (v <= 6) return _MoodCfg('😐', const Color(0xFF78909C), 'Neutral');
    if (v <= 8) return _MoodCfg('🙂', AppTheme.primaryMid, 'Good');
    return       _MoodCfg('😄', AppTheme.primary, 'Great');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _DetailBar extends StatelessWidget {
  final String label;
  final double value;
  final Color  color;
  const _DetailBar(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(label,
              style: AppTheme.bodySm.copyWith(color: AppTheme.textBody)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 10,
              minHeight: 7,
              backgroundColor: AppTheme.bgBorder,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value.toStringAsFixed(1),
          style: AppTheme.bodySm.copyWith(
              fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color  bg;
  final Color  fg;
  const _Chip({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTheme.bodySm.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

class _IndexedEntry {
  final int index;
  final Map<String, dynamic> data;
  const _IndexedEntry({required this.index, required this.data});
}

class _MoodCfg {
  final String emoji;
  final Color  color;
  final String label;
  const _MoodCfg(this.emoji, this.color, this.label);
}
