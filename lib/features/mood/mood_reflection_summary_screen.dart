import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';

class MoodReflectionSummaryScreen extends StatefulWidget {
  final Map<String, dynamic> entry;
  const MoodReflectionSummaryScreen({super.key, required this.entry});

  @override
  State<MoodReflectionSummaryScreen> createState() =>
      _MoodReflectionSummaryScreenState();
}

class _MoodReflectionSummaryScreenState
    extends State<MoodReflectionSummaryScreen>
    with SingleTickerProviderStateMixin {

  late final AnimationController _ac;
  late final Animation<double>   _fade;

  late final double _mood;
  late final double _energy;
  late final List<String> _emotions;
  late final List<String> _influences;
  late final String _note;
  late final _Advice _advice;

  @override
  void initState() {
    super.initState();
    _ac   = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _fade = CurvedAnimation(parent: _ac, curve: Curves.easeInOut);

    final e   = widget.entry;
    _mood       = (e['mood_score']    as num).toDouble();
    _energy     = (e['energy_level']  as num?)?.toDouble() ?? 5;
    _emotions   = List<String>.from(e['emotions']   ?? []);
    _influences = List<String>.from(e['influences'] ?? []);
    _note       = (e['note']          as String?)?.trim() ?? '';
    _advice     = _generateAdvice();

    _ac.forward();
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      appBar: AppBar(title: const Text('Reflection Summary')),
      body: FadeTransition(
        opacity: _fade,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                if (_emotions.isNotEmpty) ...[
                  _PillCard(
                    title: 'Emotions you noted',
                    items: _emotions,
                    itemColor: const Color(0xFF7B1FA2),
                    itemBg: const Color(0xFFF3E5F5),
                  ),
                  const SizedBox(height: 12),
                ],
                if (_influences.isNotEmpty) ...[
                  _PillCard(
                    title: 'What influenced you',
                    items: _influences,
                    itemColor: AppTheme.accent,
                    itemBg: AppTheme.accentSurface,
                  ),
                  const SizedBox(height: 12),
                ],
                if (_note.isNotEmpty) ...[
                  _NoteCard(note: _note),
                  const SizedBox(height: 12),
                ],
                _RecommendationCard(advice: _advice),
                const SizedBox(height: 24),
                _buildCTA(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    final emoji = _moodEmoji(_mood);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryMid, AppTheme.primaryLight],
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
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha:0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.self_improvement_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'You checked in',
                style: AppTheme.bodyLg.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _StatChip('$emoji  ${_mood.toStringAsFixed(1)}/10', 'Mood'),
              const SizedBox(width: 10),
              _StatChip('⚡ ${_energy.toStringAsFixed(1)}/10', 'Energy'),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Feeling ${_moodLabel(_mood)} with ${_energyLabel(_energy)} energy.',
            style: AppTheme.bodyMd.copyWith(color: Colors.white.withValues(alpha:0.9)),
          ),
        ],
      ),
    );
  }

  // ── CTA row ───────────────────────────────────────────────────────────────
  Widget _buildCTA() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => context.push('/history'),
            child: const Text('View Mood History'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => context.push('/chat'),
            child: const Text('Continue in Chat'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.bgBorder),
              foregroundColor: AppTheme.textBody,
            ),
            onPressed: () => context.go('/home'),
            child: const Text('Back Home'),
          ),
        ),
      ],
    );
  }

  // ── Advice engine ─────────────────────────────────────────────────────────
  _Advice _generateAdvice() {
    final lowMood    = _mood <= 4.0;
    final midMood    = _mood > 4.0 && _mood < 7.0;
    final lowEnergy  = _energy <= 4.0;
    final highEnergy = _energy >= 7.5;

    final work   = _influences.any((i) => i.toLowerCase().contains('work'));
    final sleep  = _influences.any((i) => i.toLowerCase().contains('sleep'));
    final social = _influences.any(
        (i) => i.toLowerCase().contains('friend') || i.toLowerCase().contains('family'));
    final money  = _influences.any((i) => i.toLowerCase().contains('money'));

    String title, body, footer = '';

    if (lowMood && lowEnergy) {
      title = 'Gentle reset';
      body  = 'You\'re running low on both mood and energy. Take the smallest helpful step: '
              '2–5 minutes of slow breathing, a glass of water, or a short stretch.';
      footer = 'If you feel unsafe or overwhelmed, open Crisis Support from the menu.';
    } else if (lowMood && sleep) {
      title = 'Rest first';
      body  = 'Sleep seems part of today\'s story. Aim for a 10–20 minute rest or a quiet wind-down. '
              'If thoughts are racing, try a brain dump: write down everything on your mind for 2 minutes.';
    } else if (work && midMood) {
      title = 'One small win at work';
      body  = 'Work is influencing your mood. Pick the next 10-minute task you can complete end-to-end. '
              'Completing one small win often nudges mood upward.';
    } else if (money && lowMood) {
      title = 'Calm your finance brain';
      body  = 'Money worries can be heavy. Try a 5-minute "facts vs fears" list: '
              'write one fact, then one fear — circle any facts you can act on this week.';
    } else if (social && midMood) {
      title = 'Connection helps';
      body  = 'You mentioned family or friends. Send a simple check-in message to someone you trust. '
              'A tiny connection can lift mood more than we expect.';
    } else if (highEnergy && midMood) {
      title = 'Channel the spark';
      body  = 'Energy is decent — try a brisk 10-minute walk, 20 squats, or tidy a small space. '
              'Moving your body often clarifies the next helpful step.';
    } else if (_emotions.any((e) =>
        e.toLowerCase().contains('anxious') || e.toLowerCase().contains('confused'))) {
      title = 'Bring it back to the body';
      body  = 'Try 4-7-8 breathing for 4 rounds: inhale 4, hold 7, exhale 8. '
              'Then write one thing you can influence in the next hour.';
    } else if (_emotions.any((e) => e.toLowerCase().contains('sad'))) {
      title = 'Kindness first';
      body  = 'Put a hand on your chest and say: "This is hard, and I\'m doing my best." '
              'Do one tiny nourishing thing: warm drink, sunlight by a window, or a 5-minute walk.';
    } else {
      title = 'Keep the momentum';
      body  = 'You checked in — that\'s progress. Choose one tiny action that supports you today: '
              'water, fresh air, movement, or a supportive message to yourself.';
    }

    if (footer.isEmpty) {
      final suffixes = [
        'You can revisit this summary anytime from History.',
        'Tiny is mighty — keep it small and kind.',
        'Saving this pattern helps your future self spot trends.',
      ];
      footer = suffixes[Random().nextInt(suffixes.length)];
    }

    return _Advice(title: title, body: body, footer: footer);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _moodEmoji(double v) {
    if (v <= 2) return '😞';
    if (v <= 4) return '😕';
    if (v <= 6) return '😐';
    if (v <= 8) return '🙂';
    return '😄';
  }

  String _moodLabel(double v) {
    if (v <= 2) return 'very low';
    if (v <= 4) return 'low';
    if (v <= 6) return 'neutral';
    if (v <= 8) return 'good';
    return 'great';
  }

  String _energyLabel(double v) {
    if (v <= 2) return 'very low';
    if (v <= 4) return 'low';
    if (v <= 6) return 'steady';
    if (v <= 8) return 'good';
    return 'high';
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String value, label;
  const _StatChip(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha:0.85), fontSize: 11)),
        ],
      ),
    );
  }
}

class _PillCard extends StatelessWidget {
  final String title;
  final List<String> items;
  final Color itemColor, itemBg;

  const _PillCard({
    required this.title,
    required this.items,
    required this.itemColor,
    required this.itemBg,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      title: title,
      icon: Icons.insights_rounded,
      iconColor: itemColor,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items
            .map((e) => Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: itemBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(e,
                      style: AppTheme.bodySm.copyWith(
                          color: itemColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12)),
                ))
            .toList(),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final String note;
  const _NoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      title: 'Your note',
      icon: Icons.notes_rounded,
      iconColor: AppTheme.textBody,
      child: Text(note, style: AppTheme.bodyMd),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final _Advice advice;
  const _RecommendationCard({required this.advice});

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      title: "Today's suggestion",
      icon: Icons.tips_and_updates_rounded,
      iconColor: AppTheme.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(advice.title,
              style: AppTheme.bodyLg.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark)),
          const SizedBox(height: 6),
          Text(advice.body, style: AppTheme.bodyMd),
          if (advice.footer.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(advice.footer, style: AppTheme.bodySm),
          ],
        ],
      ),
    );
  }
}

class _BaseCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _BaseCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.bgBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.04),
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
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha:0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 8),
              Text(title,
                  style: AppTheme.bodyLg.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _Advice {
  final String title, body, footer;
  const _Advice({required this.title, required this.body, required this.footer});
}
