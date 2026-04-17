import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Insights screen — aggregate analytics across all mood entries
// ─────────────────────────────────────────────────────────────────────────────

class SessionSummaryScreen extends StatefulWidget {
  const SessionSummaryScreen({super.key});

  @override
  State<SessionSummaryScreen> createState() => _SessionSummaryScreenState();
}

class _SessionSummaryScreenState extends State<SessionSummaryScreen> {
  List<Map<String, dynamic>> _entries = [];
  bool _loading = true;

  // ── Computed stats ────────────────────────────────────────────────────────
  int    _streak       = 0;
  int    _weekCount    = 0;
  double _avgMood      = 0;
  double _avgMoodWeek  = 0;
  List<MapEntry<String, int>> _topEmotions   = [];
  List<MapEntry<String, int>> _topInfluences = [];
  List<FlSpot>                _chartSpots    = [];


  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs   = await SharedPreferences.getInstance();
    final raw     = prefs.getStringList('mood_history') ?? [];
    final entries = raw
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .toList()
      ..sort((a, b) => DateTime.parse(b['timestamp'])
          .compareTo(DateTime.parse(a['timestamp'])));

    if (!mounted) return;
    if (entries.isNotEmpty) _computeStats(entries);
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  void _computeStats(List<Map<String, dynamic>> entries) {
    // All-time averages
    _avgMood = entries
            .map((e) => (e['mood_score'] as num).toDouble())
            .reduce((a, b) => a + b) /
        entries.length;

    // Streak
    final dates = <String>{};
    for (final e in entries) {
      final ts = DateTime.parse(e['timestamp'] as String);
      dates.add('${ts.year}-${ts.month}-${ts.day}');
    }
    var day = DateTime.now();
    _streak = 0;
    while (dates.contains('${day.year}-${day.month}-${day.day}')) {
      _streak++;
      day = day.subtract(const Duration(days: 1));
    }

    // This week
    final weekAgo    = DateTime.now().subtract(const Duration(days: 7));
    final thisWeek   = entries.where((e) =>
        DateTime.parse(e['timestamp']).isAfter(weekAgo)).toList();
    _weekCount  = thisWeek.length;
    _avgMoodWeek = thisWeek.isEmpty
        ? _avgMood
        : thisWeek
                .map((e) => (e['mood_score'] as num).toDouble())
                .reduce((a, b) => a + b) /
            thisWeek.length;

    // Top emotions
    final ec = <String, int>{};
    for (final e in entries) {
      for (final em in List<String>.from(e['emotions'] ?? [])) {
        ec[em] = (ec[em] ?? 0) + 1;
      }
    }
    _topEmotions = (ec.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .take(5)
        .toList();

    // Top influences
    final ic = <String, int>{};
    for (final e in entries) {
      for (final inf in List<String>.from(e['influences'] ?? [])) {
        ic[inf] = (ic[inf] ?? 0) + 1;
      }
    }
    _topInfluences = (ic.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .take(5)
        .toList();

    // Chart spots — last 14, chronological
    final chartEntries = entries.take(14).toList().reversed.toList();
    _chartSpots = chartEntries.asMap().entries.map((e) {
      return FlSpot(
        e.key.toDouble(),
        (e.value['mood_score'] as num).toDouble(),
      );
    }).toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      appBar: AppBar(title: const Text('Insights')),
      body: _loading
          ? _buildLoading()
          : _entries.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppTheme.primary,
                  child: _buildContent(),
                ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppTheme.primarySurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.insights_rounded,
                size: 36, color: AppTheme.primary),
          ),
          const SizedBox(height: 20),
          Text('Building your insights…', style: AppTheme.bodyMd),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: const BoxDecoration(
              color: AppTheme.primarySurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bar_chart_rounded,
                size: 52, color: AppTheme.primary),
          ),
          const SizedBox(height: 28),
          Text('No insights yet',
              style: AppTheme.headingMd, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(
            'Complete a few mood check-ins and your patterns, trends, and personal insights will appear here.',
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

  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsRow(),
          const SizedBox(height: 24),
          if (_chartSpots.length >= 2) ...[
            _buildTrendChart(),
            const SizedBox(height: 24),
          ],
          if (_topEmotions.isNotEmpty) ...[
            _buildPatternSection(
              'Most Felt Emotions',
              Icons.psychology_rounded,
              AppTheme.primary,
              _topEmotions,
              _emotionColor,
            ),
            const SizedBox(height: 20),
          ],
          if (_topInfluences.isNotEmpty) ...[
            _buildPatternSection(
              'Top Influences',
              Icons.flag_rounded,
              AppTheme.accent,
              _topInfluences,
              (_) => AppTheme.accent,
            ),
            const SizedBox(height: 20),
          ],
          _buildObservation(),
          const SizedBox(height: 24),
          _buildActions(),
        ],
      ),
    );
  }

  // ── Stats row ─────────────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    final moodTrend = _avgMoodWeek - _avgMood;

    return Row(
      children: [
        _StatCard(
          label: 'Check-ins',
          value: '${_entries.length}',
          icon: Icons.check_circle_outline_rounded,
          color: AppTheme.primary,
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: 'Day Streak',
          value: '$_streak',
          icon: Icons.local_fire_department_rounded,
          color: const Color(0xFFFF7043),
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: 'Avg Mood',
          value: _avgMood.toStringAsFixed(1),
          icon: Icons.mood_rounded,
          color: _moodColor(_avgMood),
          sub: moodTrend > 0.3
              ? '+${moodTrend.toStringAsFixed(1)} this wk'
              : moodTrend < -0.3
                  ? '${moodTrend.toStringAsFixed(1)} this wk'
                  : null,
          subPositive: moodTrend >= 0,
        ),
      ],
    );
  }

  // ── Mood trend chart ──────────────────────────────────────────────────────

  Widget _buildTrendChart() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.show_chart_rounded,
            color: AppTheme.primary,
            title: 'Mood Trend',
            sub: 'Last ${_chartSpots.length} check-ins',
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 10,
                clipData: const FlClipData.all(),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppTheme.bgBorder,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 5,
                      getTitlesWidget: (v, _) => Text(
                        v.toInt().toString(),
                        style: AppTheme.bodySm.copyWith(fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: _chartSpots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    barWidth: 3,
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.primaryLight],
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.primary.withValues(alpha: 0.2),
                          AppTheme.primary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                        radius: 3.5,
                        color: AppTheme.primary,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Pattern section ───────────────────────────────────────────────────────

  Widget _buildPatternSection(
    String title,
    IconData icon,
    Color color,
    List<MapEntry<String, int>> items,
    Color Function(String) chipColor,
  ) {
    final maxCount = items.first.value;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(icon: icon, color: color, title: title),
          const SizedBox(height: 14),
          ...items.map((entry) {
            final fraction = entry.value / maxCount;
            final c        = chipColor(entry.key);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 90,
                    child: Text(
                      entry.key,
                      style: AppTheme.bodyMd.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: fraction,
                        minHeight: 8,
                        backgroundColor: AppTheme.bgBorder,
                        valueColor: AlwaysStoppedAnimation(c),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '×${entry.value}',
                    style: AppTheme.bodySm.copyWith(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Observation ───────────────────────────────────────────────────────────

  Widget _buildObservation() {
    final obs = _generateObservation();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.primarySurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_rounded,
              color: AppTheme.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pattern Observed',
                  style: AppTheme.bodyMd.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(obs, style: AppTheme.bodyMd),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _generateObservation() {
    if (_entries.length < 3) {
      return 'Keep checking in — after a few more sessions your patterns will become visible here.';
    }

    final topEmotion   = _topEmotions.isNotEmpty ? _topEmotions.first.key : null;
    final topInfluence = _topInfluences.isNotEmpty ? _topInfluences.first.key : null;
    final moodDiff     = _avgMoodWeek - _avgMood;

    if (moodDiff > 0.5 && _weekCount > 0) {
      return 'Your mood this week (${ _avgMoodWeek.toStringAsFixed(1)}) is above your all-time average (${_avgMood.toStringAsFixed(1)}). Something positive is happening — notice it.';
    }
    if (moodDiff < -0.5 && _weekCount > 0) {
      return 'Your mood this week is a little lower than usual. Be gentle with yourself — this is exactly what check-ins are for.';
    }
    if (topEmotion != null && topInfluence != null) {
      return 'You most often feel $topEmotion, and $topInfluence tends to be the biggest factor in your mood. That awareness is a real strength.';
    }
    if (topEmotion != null) {
      return 'Across your check-ins, $topEmotion has been your most frequent emotion. Noticing patterns is the first step toward understanding them.';
    }
    if (_avgMood >= 7) {
      return 'Your average mood of ${_avgMood.toStringAsFixed(1)}/10 shows real resilience. Keep prioritising your wellbeing.';
    }
    return 'You have completed ${_entries.length} check-ins. Regular reflection builds emotional awareness that compounds over time.';
  }

  // ── CTAs ──────────────────────────────────────────────────────────────────

  Widget _buildActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            icon: const Icon(Icons.psychology_alt_rounded),
            label: const Text('New Check-in'),
            onPressed: () => context.push('/chatmood'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.history_rounded),
            label: const Text('View Full History'),
            onPressed: () => context.push('/history'),
          ),
        ),
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  BoxDecoration _cardDeco() => BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.bgBorder),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      );

  Color _moodColor(double v) {
    if (v <= 2) return const Color(0xFFEF5350);
    if (v <= 4) return const Color(0xFFFF8A65);
    if (v <= 6) return const Color(0xFF78909C);
    if (v <= 8) return AppTheme.primaryMid;
    return AppTheme.primary;
  }

  Color _emotionColor(String emotion) {
    const map = {
      'Calm':       Color(0xFF4FC3F7),
      'Happy':      Color(0xFFFFD54F),
      'Sad':        Color(0xFF64B5F6),
      'Anxious':    Color(0xFFE57373),
      'Tired':      Color(0xFF9575CD),
      'Excited':    Color(0xFF4DB6AC),
      'Frustrated': Color(0xFFFF8A65),
      'Grateful':   Color(0xFF81C784),
      'Confused':   Color(0xFFBA68C8),
      'Proud':      Color(0xFFFFB74D),
    };
    return map[emotion] ?? AppTheme.primary;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String   label;
  final String   value;
  final IconData icon;
  final Color    color;
  final String?  sub;
  final bool     subPositive;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.sub,
    this.subPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.bgSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.bgBorder),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: AppTheme.bodySm),
            if (sub != null) ...[
              const SizedBox(height: 2),
              Text(
                sub!,
                style: AppTheme.bodySm.copyWith(
                  fontSize: 10,
                  color: subPositive
                      ? AppTheme.primary
                      : const Color(0xFFEF5350),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final Color    color;
  final String   title;
  final String?  sub;

  const _SectionHeader({
    required this.icon,
    required this.color,
    required this.title,
    this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTheme.bodyMd.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            if (sub != null)
              Text(sub!, style: AppTheme.bodySm.copyWith(fontSize: 11)),
          ],
        ),
      ],
    );
  }
}
