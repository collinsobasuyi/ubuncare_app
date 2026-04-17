import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Milestone definition
// ─────────────────────────────────────────────────────────────────────────────

class Milestone {
  final String id;
  final String emoji;
  final String title;
  final String subtitle;
  final bool   isStreak;  // true = streak-based, false = total check-in based
  final int    threshold;

  const Milestone({
    required this.id,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.isStreak,
    required this.threshold,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// StreakService
// ─────────────────────────────────────────────────────────────────────────────

class StreakService {
  static const _earnedKey = 'earned_milestone_ids';

  // All milestones in the order they appear in the UI
  static const milestones = <Milestone>[
    // ── Total check-in milestones ─────────────────────────────────────────
    Milestone(id: 'ci_1',   emoji: '🌱', title: 'First Step',           subtitle: '1 check-in',       isStreak: false, threshold: 1),
    Milestone(id: 'ci_3',   emoji: '✨', title: 'Getting Started',      subtitle: '3 check-ins',      isStreak: false, threshold: 3),
    Milestone(id: 'ci_7',   emoji: '🌟', title: 'One Week Done',        subtitle: '7 check-ins',      isStreak: false, threshold: 7),
    Milestone(id: 'ci_14',  emoji: '💪', title: 'Two Weeks Strong',     subtitle: '14 check-ins',     isStreak: false, threshold: 14),
    Milestone(id: 'ci_30',  emoji: '🏆', title: 'Month of Mindfulness', subtitle: '30 check-ins',     isStreak: false, threshold: 30),
    Milestone(id: 'ci_50',  emoji: '🌿', title: 'Deeply Dedicated',     subtitle: '50 check-ins',     isStreak: false, threshold: 50),
    Milestone(id: 'ci_100', emoji: '💫', title: 'Centurion',            subtitle: '100 check-ins',    isStreak: false, threshold: 100),
    // ── Streak milestones ─────────────────────────────────────────────────
    Milestone(id: 'str_3',  emoji: '🔥', title: '3-Day Streak',         subtitle: '3 days in a row',  isStreak: true,  threshold: 3),
    Milestone(id: 'str_7',  emoji: '⚡', title: 'Week Warrior',         subtitle: '7 days in a row',  isStreak: true,  threshold: 7),
    Milestone(id: 'str_14', emoji: '🌙', title: 'Fortnight Flow',       subtitle: '14 days in a row', isStreak: true,  threshold: 14),
    Milestone(id: 'str_30', emoji: '🌈', title: 'Monthly Master',       subtitle: '30 days in a row', isStreak: true,  threshold: 30),
  ];

  // ── Streak computation ───────────────────────────────────────────────────

  /// Current streak with a 1-day grace period.
  /// Missing today is fine as long as you checked in yesterday.
  static int currentStreak(List<String> raw) {
    final days = _uniqueDays(raw);
    if (days.isEmpty) return 0;

    final today     = _key(DateTime.now());
    final yesterday = _key(DateTime.now().subtract(const Duration(days: 1)));

    if (!days.contains(today) && !days.contains(yesterday)) return 0;

    int streak = 0;
    var cursor = days.contains(today)
        ? DateTime.now()
        : DateTime.now().subtract(const Duration(days: 1));

    while (days.contains(_key(cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// All-time longest consecutive streak.
  static int longestStreak(List<String> raw) {
    final days = _uniqueDays(raw).toList()..sort();
    if (days.isEmpty) return 0;

    int best = 1, run = 1;
    for (int i = 1; i < days.length; i++) {
      final diff = DateTime.parse(days[i])
          .difference(DateTime.parse(days[i - 1]))
          .inDays;
      run = diff == 1 ? run + 1 : 1;
      if (run > best) best = run;
    }
    return best;
  }

  /// Number of unique calendar days with at least one check-in.
  static int totalUniqueDays(List<String> raw) => _uniqueDays(raw).length;

  /// Map of date-key → average mood score for all dates.
  static Map<String, double> moodByDay(List<String> raw) {
    final buckets = <String, List<double>>{};
    for (final e in raw) {
      try {
        final map  = jsonDecode(e) as Map<String, dynamic>;
        final ts   = DateTime.parse(map['timestamp'] as String);
        final mood = (map['mood_score'] as num?)?.toDouble();
        if (mood != null) {
          (buckets[_key(ts)] ??= []).add(mood);
        }
      } catch (_) {}
    }
    return buckets.map(
      (k, v) => MapEntry(k, v.reduce((a, b) => a + b) / v.length),
    );
  }

  // ── Milestone helpers ────────────────────────────────────────────────────

  /// Check for newly-unlocked milestones, persist them, and return the new ones.
  /// Safe to call repeatedly — already-earned milestones are never returned twice.
  static Future<List<Milestone>> checkAndSaveNew(
    int totalCheckIns,
    int streak,
  ) async {
    final prefs   = await SharedPreferences.getInstance();
    final earned  = Set<String>.from(prefs.getStringList(_earnedKey) ?? []);
    final newOnes = <Milestone>[];

    for (final m in milestones) {
      if (earned.contains(m.id)) continue;
      final met = m.isStreak
          ? streak        >= m.threshold
          : totalCheckIns >= m.threshold;
      if (met) {
        newOnes.add(m);
        earned.add(m.id);
      }
    }

    if (newOnes.isNotEmpty) {
      await prefs.setStringList(_earnedKey, earned.toList());
    }
    return newOnes;
  }

  /// Returns the set of earned milestone IDs.
  static Future<Set<String>> earnedIds() async {
    final prefs = await SharedPreferences.getInstance();
    return Set<String>.from(prefs.getStringList(_earnedKey) ?? []);
  }

  // ── Next milestone ───────────────────────────────────────────────────────

  /// Returns the next unearned milestone and how far along the user is.
  static Future<({Milestone? milestone, int progress, int total})> nextMilestone(
    int totalCheckIns,
    int streak,
  ) async {
    final earned = await earnedIds();
    for (final m in milestones) {
      if (earned.contains(m.id)) continue;
      final progress = m.isStreak ? streak : totalCheckIns;
      return (milestone: m, progress: progress, total: m.threshold);
    }
    return (milestone: null, progress: 0, total: 0);
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  static Set<String> _uniqueDays(List<String> raw) {
    final days = <String>{};
    for (final e in raw) {
      try {
        final map = jsonDecode(e) as Map<String, dynamic>;
        final ts  = DateTime.parse(map['timestamp'] as String);
        days.add(_key(ts));
      } catch (_) {}
    }
    return days;
  }

  static String _key(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
