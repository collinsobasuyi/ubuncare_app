import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme.dart';
import '../../services/streak_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {

  // ── Animated header gradient ─────────────────────────────────────────────
  late final AnimationController _gradCtrl;
  late final Animation<double> _phase;

  // ── Rotating tips ────────────────────────────────────────────────────────
  static const List<String> _tips = [
    'Remember to breathe deeply when feeling overwhelmed.',
    'Small moments of mindfulness can make a big difference.',
    "It's okay to not be okay — be gentle with yourself today.",
    'Progress isn\'t always linear — celebrate small steps.',
    'Your feelings are valid — allow yourself to feel them.',
  ];
  int _tipIndex = 0;
  Timer? _tipTimer;

  // ── Derived stats from mood_history ─────────────────────────────────────
  int _sessionCount  = 0;
  int _dayStreak     = 0;
  int _longestStreak = 0;
  ({Milestone? milestone, int progress, int total})? _nextMilestone;

  // ── Grid items ───────────────────────────────────────────────────────────
  static const List<_GridItem> _gridItems = [
    _GridItem(Icons.psychology_alt_rounded,   'Mood Chat',        'How are you feeling?',   '/chatmood'),
    _GridItem(Icons.favorite_rounded,         'Gratitude',        'Count your blessings',   '/gratitude'),
    _GridItem(Icons.history_rounded,          'Mood History',     'Past reflections',       '/history'),
    _GridItem(Icons.insights_rounded,         'Insights',         'View your journey',      '/summary'),
    _GridItem(Icons.spa_rounded,              'Wellness Tools',   'Relax, plan & recharge', '/wellness'),
    _GridItem(Icons.self_improvement_rounded, 'Quick Calm',       '60-second breathing',    '/quick_calm'),
  ];

  @override
  void initState() {
    super.initState();

    _gradCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _phase = CurvedAnimation(parent: _gradCtrl, curve: Curves.easeInOut);

    _tipTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (mounted) setState(() => _tipIndex = (_tipIndex + 1) % _tips.length);
    });

    _initData();
  }

  Future<void> _initData() async {
    try {
      final prefs  = await SharedPreferences.getInstance();
      final raw    = prefs.getStringList('mood_history') ?? [];
      final streak = StreakService.currentStreak(raw);
      final total  = raw.length;

      // Check for newly unlocked milestones
      final newMilestones = await StreakService.checkAndSaveNew(total, streak);
      final next = await StreakService.nextMilestone(total, streak);

      if (mounted) {
        setState(() {
          _sessionCount  = total;
          _dayStreak     = streak;
          _longestStreak = StreakService.longestStreak(raw);
          _nextMilestone = next;
        });
        if (newMilestones.isNotEmpty) {
          _showMilestoneCelebration(newMilestones);
        }
      }
    } catch (_) {}
  }

  void _showMilestoneCelebration(List<Milestone> milestones) {
    // Show one at a time; if multiple unlocked, show the first
    final m = milestones.first;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.15),
                blurRadius: 40,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppTheme.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(m.emoji,
                      style: const TextStyle(fontSize: 44)),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Achievement Unlocked!',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: AppTheme.primary.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                m.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1C2B2A),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                m.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Keep Going 🎉'),
                ),
              ),
              if (milestones.length > 1) ...[
                const SizedBox(height: 8),
                Text(
                  '+${milestones.length - 1} more achievement${milestones.length > 2 ? 's' : ''} unlocked!',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _gradCtrl.dispose();
    _tipTimer?.cancel();
    super.dispose();
  }

  // ── Text scale helper (non-deprecated) ──────────────────────────────────
  double _textScale(BuildContext context) =>
      MediaQuery.textScalerOf(context).scale(1.0).clamp(1.0, 1.4);

  @override
  Widget build(BuildContext context) {
    final ts = _textScale(context);

    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _initData,
          color: AppTheme.primary,
          backgroundColor: AppTheme.bgSurface,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(ts)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24 * ts, 20 * ts, 24 * ts, 8 * ts),
                  child: _buildProgressOverview(ts),
                ),
              ),

              SliverToBoxAdapter(child: _buildSectionHeading(ts)),

              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: 24 * ts, vertical: 12 * ts,
                ),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _buildActionCard(context, _gridItems[i], ts),
                    childCount: _gridItems.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.0,
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    24 * ts, 16 * ts, 24 * ts, 36 * ts,
                  ),
                  child: _buildCrisisSupport(ts),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────
  Widget _buildHeader(double ts) {
    return AnimatedBuilder(
      animation: _phase,
      builder: (context, _) {
        final c1 = Color.lerp(AppTheme.primary, AppTheme.primaryMid, _phase.value)!;
        final c2 = Color.lerp(AppTheme.primaryMid, AppTheme.primaryLight, 1 - _phase.value)!;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 24 * ts, vertical: 20 * ts),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [c1, c2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Semantics(
                    button: true,
                    label: 'Quick exit — close app immediately',
                    child: Tooltip(
                      message: 'Quick exit',
                      child: IconButton(
                        icon: Icon(Icons.exit_to_app_rounded,
                            color: Colors.white70, size: 24 * ts),
                        onPressed: () => _showQuickExitDialog(context),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Welcome to',
                          style: TextStyle(
                            fontSize: 15 * ts,
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Ubuncare',
                          style: TextStyle(
                            fontSize: 30 * ts,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: 'Open settings',
                    child: Tooltip(
                      message: 'Settings',
                      child: IconButton(
                        icon: Icon(Icons.settings_rounded,
                            color: Colors.white, size: 26 * ts),
                        onPressed: () => context.push('/settings'),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16 * ts),

              // Wellbeing tip card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16 * ts),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.eco_rounded, color: Colors.white, size: 16 * ts),
                        SizedBox(width: 8 * ts),
                        Text(
                          'Wellbeing Reminder',
                          style: TextStyle(
                            fontSize: 13 * ts,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8 * ts),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, anim) =>
                          FadeTransition(opacity: anim, child: child),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          _tips[_tipIndex],
                          key: ValueKey(_tipIndex),
                          style: TextStyle(
                            fontSize: 14 * ts,
                            color: Colors.white,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Progress overview ────────────────────────────────────────────────────
  Widget _buildProgressOverview(double ts) {
    final next = _nextMilestone;

    return Semantics(
      button: true,
      label: '$_sessionCount check-in${_sessionCount == 1 ? '' : 's'}, $_dayStreak day streak. Tap to view history.',
      child: GestureDetector(
      onTap: () => context.push('/history'),
      child: Container(
        padding: EdgeInsets.all(16 * ts),
        decoration: BoxDecoration(
          color: AppTheme.bgSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.bgBorder),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top row — streak + stats
            Row(
              children: [
                // Streak badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _dayStreak > 0
                        ? const Color(0xFFFFF3EE)
                        : AppTheme.primarySurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _dayStreak > 0
                          ? const Color(0xFFFF6B35).withValues(alpha: 0.2)
                          : AppTheme.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _dayStreak > 0 ? '🔥' : '✨',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$_dayStreak',
                            style: TextStyle(
                              fontSize: 20 * ts,
                              fontWeight: FontWeight.w800,
                              color: _dayStreak > 0
                                  ? const Color(0xFFFF6B35)
                                  : AppTheme.primary,
                              height: 1,
                            ),
                          ),
                          Text(
                            'day streak',
                            style: TextStyle(
                              fontSize: 10 * ts,
                              color: _dayStreak > 0
                                  ? const Color(0xFFFF6B35)
                                      .withValues(alpha: 0.7)
                                  : AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Check-ins + best streak
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_sessionCount check-in${_sessionCount == 1 ? '' : 's'}',
                        style: TextStyle(
                          fontSize: 14 * ts,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Text(
                        'Best streak: $_longestStreak day${_longestStreak == 1 ? '' : 's'}',
                        style: TextStyle(
                          fontSize: 12 * ts,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(Icons.arrow_forward_ios_rounded,
                    color: AppTheme.primaryMid, size: 14 * ts),
              ],
            ),

            // Next milestone progress
            if (next != null && next.milestone != null) ...[
              const SizedBox(height: 14),
              Divider(color: AppTheme.bgBorder, height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    next.milestone!.emoji,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Next: ${next.milestone!.title}',
                              style: TextStyle(
                                fontSize: 12 * ts,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textDark,
                              ),
                            ),
                            Text(
                              '${next.progress}/${next.total}',
                              style: TextStyle(
                                fontSize: 11 * ts,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: next.total == 0
                                ? 0
                                : (next.progress / next.total).clamp(0.0, 1.0),
                            minHeight: 5,
                            backgroundColor: AppTheme.bgBorder,
                            valueColor: const AlwaysStoppedAnimation(
                                AppTheme.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      ), // GestureDetector
    ); // Semantics
  }

  // ── Section heading ──────────────────────────────────────────────────────
  Widget _buildSectionHeading(double ts) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24 * ts, vertical: 16 * ts),
      child: Row(
        children: [
          Container(
            width: 4 * ts,
            height: 22 * ts,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 12 * ts),
          Text(
            'Reflection Tools',
            style: TextStyle(
              fontSize: 19 * ts,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  // ── Action card ──────────────────────────────────────────────────────────
  Widget _buildActionCard(BuildContext ctx, _GridItem item, double ts) {
    return Card(
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.cornerRadius),
        onTap: () {
          HapticFeedback.lightImpact();
          ctx.push(item.route);
        },
        splashColor: AppTheme.primary.withValues(alpha: 0.08),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 14 * ts, horizontal: 10 * ts,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12 * ts),
                decoration: BoxDecoration(
                  color: AppTheme.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon,
                    color: AppTheme.primary, size: 24 * ts),
              ),
              SizedBox(height: 12 * ts),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14 * ts,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
              SizedBox(height: 4 * ts),
              Flexible(
                child: Text(
                  item.subtitle,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 11 * ts,
                    color: AppTheme.textMuted,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Crisis support ───────────────────────────────────────────────────────
  Widget _buildCrisisSupport(double ts) {
    return Semantics(
      button: true,
      label: 'Crisis Support — Emergency help',
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20 * ts),
        decoration: BoxDecoration(
          color: AppTheme.bgSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.crisisRed.withValues(alpha: 0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.crisisRed.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.volunteer_activism_rounded,
                color: AppTheme.crisisRed, size: 34 * ts),
            SizedBox(height: 10 * ts),
            Text(
              'Need immediate support?',
              style: TextStyle(
                fontSize: 15 * ts,
                fontWeight: FontWeight.w600,
                color: AppTheme.crisisRed,
              ),
            ),
            SizedBox(height: 12 * ts),
            SizedBox(
              width: double.infinity,
              height: 50 * ts,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.crisisRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => context.push('/crisis'),
                child: const Text('Get Crisis Support'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Quick exit dialog ────────────────────────────────────────────────────
  void _showQuickExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Quick Exit', style: AppTheme.headingSm),
        content: Text('This will immediately close Ubuncare.',
            style: AppTheme.bodyMd),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Stay in App'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppTheme.crisisRed),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await SystemNavigator.pop();
            },
            child: const Text('Exit App'),
          ),
        ],
      ),
    );
  }
}

class _GridItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String route;

  const _GridItem(this.icon, this.title, this.subtitle, this.route);
}
