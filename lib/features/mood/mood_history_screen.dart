import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class MoodHistoryScreen extends StatefulWidget {
  const MoodHistoryScreen({super.key});

  @override
  State<MoodHistoryScreen> createState() => _MoodHistoryScreenState();
}

class _MoodHistoryScreenState extends State<MoodHistoryScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _entries = [];
  bool _loading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _loadHistory();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> raw = prefs.getStringList('mood_history') ?? [];
    final List<Map<String, dynamic>> decoded =
        raw.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();

    decoded.sort((a, b) =>
        DateTime.parse(b['timestamp']).compareTo(DateTime.parse(a['timestamp'])));

    setState(() {
      _entries = decoded;
      _loading = false;
    });
    
    if (mounted) {
      _animationController.forward();
    }
  }

  Future<void> _clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('mood_history');
    setState(() => _entries = []);
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF0D896C);
    const Color lightTeal = Color(0xFF4FE2B5);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Reflection History',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: primaryTeal,
        elevation: 0,
        centerTitle: false,
        actions: [
          if (_entries.isNotEmpty)
            IconButton(
              tooltip: 'Clear all reflections',
              icon: Icon(
                Icons.delete_outline_rounded,
                color: Colors.grey.shade600,
              ),
              onPressed: _confirmClear,
            ),
        ],
      ),
      body: _loading
          ? _buildLoadingState()
          : _entries.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  color: primaryTeal,
                  backgroundColor: Colors.white,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.all(20),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              _buildWelcomeHeader(),
                              const SizedBox(height: 24),
                              _buildSummaryCards(),
                              const SizedBox(height: 28),
                              _buildMoodChart(),
                              const SizedBox(height: 32),
                              _buildReflectionsHeader(),
                            ]),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildReflectionCard(_entries[index]),
                              ),
                              childCount: _entries.length,
                            ),
                          ),
                        ),
                        const SliverPadding(
                          padding: EdgeInsets.only(bottom: 40),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  // ---------- Enhanced UI Components ----------

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF0D896C).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_graph_rounded,
              color: Color(0xFF0D896C),
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Loading your journey...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF0D896C).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology_alt_rounded,
                color: Color(0xFF0D896C),
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your Reflection Journey Awaits',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Complete your first mood check-in to start tracking your emotional wellbeing journey. Each reflection helps you build self-awareness.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0D896C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Start Your First Reflection',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello there 👋',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.grey.shade800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Here\'s your emotional wellbeing journey',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    if (_entries.isEmpty) return const SizedBox();

    final avgMood = _entries
            .map((e) => (e['mood_score'] as num).toDouble())
            .reduce((a, b) => a + b) /
        _entries.length;

    final avgEnergy = _entries
            .map((e) => (e['energy_level'] as num).toDouble())
            .reduce((a, b) => a + b) /
        _entries.length;

    final recentMood = (_entries.first['mood_score'] as num).toDouble();

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCardItem(
            'Average Mood',
            avgMood.toStringAsFixed(1),
            _getMoodEmoji(avgMood),
            const Color(0xFF0D896C),
            Icons.trending_up_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCardItem(
            'Current Mood',
            recentMood.toStringAsFixed(1),
            _getMoodEmoji(recentMood),
            const Color(0xFF4FE2B5),
            Icons.favorite_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCardItem(
            'Energy Level',
            avgEnergy.toStringAsFixed(1),
            '⚡',
            const Color(0xFFFFB74D),
            Icons.bolt_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCardItem(
      String title, String value, String emoji, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              Text(
                emoji,
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodChart() {
    if (_entries.length < 2) return const SizedBox();

    final recentEntries = _entries.take(7).toList().reversed.toList();
    final spots = recentEntries.asMap().entries.map((e) {
      final i = e.key.toDouble();
      final mood = (e.value['mood_score'] as num).toDouble();
      return FlSpot(i, mood);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D896C).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  color: Color(0xFF0D896C),
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Mood Trend (Last 7 entries)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 10,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.shade200,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey.shade200),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: const Color(0xFF0D896C),
                    barWidth: 4,
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF0D896C).withOpacity(0.3),
                          const Color(0xFF0D896C).withOpacity(0.1),
                        ],
                      ),
                    ),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                        radius: 4,
                        color: const Color(0xFF0D896C),
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF0D896C),
                        Color(0xFF4FE2B5),
                      ],
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

  Widget _buildReflectionsHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF0D896C).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.history_rounded,
            color: Color(0xFF0D896C),
            size: 18,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Recent Reflections',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
        Text(
          '${_entries.length} total',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildReflectionCard(Map<String, dynamic> entry) {
    final timestamp = DateTime.parse(entry['timestamp']);
    final timeAgo = _getTimeAgo(timestamp);
    final date = DateFormat('EEE, MMM d').format(timestamp);
    final mood = (entry['mood_score'] as num).toDouble();
    final note = entry['note'] ?? '';
    final emotions = List<String>.from(entry['emotions'] ?? []);
    final influences = List<String>.from(entry['influences'] ?? []);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with mood and time
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getMoodColor(mood).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _getMoodEmoji(mood),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mood: ${mood.toStringAsFixed(1)}/10',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$date • $timeAgo',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Emotions and Influences
            if (emotions.isNotEmpty || influences.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...emotions.map((e) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D896C).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          e,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF0D896C),
                          ),
                        ),
                      )),
                  ...influences.map((e) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          e,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      )),
                ],
              ),

            // Note
            if (note.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  note,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---------- Helper Methods ----------

  String _getMoodEmoji(double score) {
    if (score <= 2) return '😞';
    if (score <= 4) return '😕';
    if (score <= 6) return '😐';
    if (score <= 8) return '🙂';
    return '😄';
  }

  Color _getMoodColor(double score) {
    if (score <= 2) return Colors.red;
    if (score <= 4) return Colors.orange;
    if (score <= 6) return Colors.blueGrey;
    if (score <= 8) return Colors.lightGreen;
    return Colors.green;
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${(difference.inDays / 7).floor()}w ago';
  }

  void _confirmClear() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.amber),
            SizedBox(width: 12),
            Text(
              'Clear All History?',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: const Text(
          'This will permanently delete all your reflection history. '
          'This action cannot be undone.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
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
}