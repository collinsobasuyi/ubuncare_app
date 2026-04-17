import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/consent_state.dart';
import '../../app/theme.dart';
import '../../services/streak_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  int  _sessionCount  = 0;
  int  _dayStreak     = 0;
  int  _uniqueDays    = 0;
  bool _loadedData    = false;
  ({Milestone? milestone, int progress, int total})? _nextMilestone;

  static const List<_ToolCard> _tools = [
    _ToolCard(
      icon: Icons.psychology_alt_rounded,
      label: 'Mood Chat',
      sub: 'How are you feeling?',
      route: '/chatmood',
      gradient: [Color(0xFF1D6B52), Color(0xFF2E9B78)],
    ),
    _ToolCard(
      icon: Icons.favorite_rounded,
      label: 'Gratitude',
      sub: 'Count your blessings',
      route: '/gratitude',
      gradient: [Color(0xFFBF7424), Color(0xFFE9963A)],
    ),
    _ToolCard(
      icon: Icons.air_rounded,
      label: 'Breathing',
      sub: 'Restore calm',
      route: '/breathing_exercise',
      gradient: [Color(0xFF3A6B82), Color(0xFF62B0C8)],
    ),
    _ToolCard(
      icon: Icons.self_improvement_rounded,
      label: 'Body Scan',
      sub: 'Tune in to yourself',
      route: '/body_scan',
      gradient: [Color(0xFF6B4E82), Color(0xFF9B78C2)],
    ),
    _ToolCard(
      icon: Icons.filter_5_rounded,
      label: 'Grounding',
      sub: '5-4-3-2-1 technique',
      route: '/54321',
      gradient: [Color(0xFF4E6B2A), Color(0xFF7BA844)],
    ),
    _ToolCard(
      icon: Icons.insights_rounded,
      label: 'Insights',
      sub: 'Your journey',
      route: '/summary',
      gradient: [Color(0xFF82453A), Color(0xFFB87062)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs  = await SharedPreferences.getInstance();
      final raw    = prefs.getStringList('mood_history') ?? [];
      final streak = StreakService.currentStreak(raw);
      final total  = raw.length;
      final newMilestones = await StreakService.checkAndSaveNew(total, streak);
      final next = await StreakService.nextMilestone(total, streak);
      if (mounted) {
        setState(() {
          _sessionCount = total;
          _dayStreak    = streak;
          _uniqueDays   = StreakService.totalUniqueDays(raw);
          _nextMilestone= next;
          _loadedData   = true;
        });
        if (newMilestones.isNotEmpty) _celebrateMilestone(newMilestones.first);
      }
    } catch (_) {
      if (mounted) setState(() => _loadedData = true);
    }
  }

  void _celebrateMilestone(Milestone m) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => _MilestoneCelebration(milestone: m),
    );
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get _greetingEmoji {
    final h = DateTime.now().hour;
    if (h < 12) return '🌤';
    if (h < 17) return '☀️';
    return '🌙';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final name = context.watch<ConsentState>().userName;
    final firstName = (name != null && name.isNotEmpty)
        ? name.split(' ').first
        : null;

    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppTheme.primary,
        backgroundColor: AppTheme.bgSurface,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // ── Top greeting ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _buildGreeting(firstName),
            ),

            // ── Stats row ───────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                child: _buildStatsRow(),
              ),
            ),

            // ── Hero check-in card ───────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: _buildHeroCard(),
              ),
            ),

            // ── Next milestone ───────────────────────────────────────────────
            if (_loadedData &&
                _nextMilestone != null &&
                _nextMilestone!.milestone != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: _buildMilestoneCard(),
                ),
              ),

            // ── Tools section ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 0, 12),
                child: Row(
                  children: [
                    Text(
                      'YOUR TOOLS',
                      style: AppTheme.overline,
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 148,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _tools.length,
                  itemBuilder: (_, i) => _HorizontalToolCard(tool: _tools[i]),
                ),
              ),
            ),

            // ── Daily reminder ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: _buildDailyReminder(),
              ),
            ),

            // ── Crisis support ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 110),
                child: _buildCrisisBar(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Greeting ──────────────────────────────────────────────────────────────
  Widget _buildGreeting(String? firstName) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('$_greetingEmoji  ', style: const TextStyle(fontSize: 18)),
                    Text(
                      '$_greeting${firstName != null ? ', $firstName' : ''}',
                      style: AppTheme.bodyMd.copyWith(
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'How are you\ntoday?',
                  style: AppTheme.displayLg.copyWith(
                    color: AppTheme.textDark,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
          // Settings icon
          Semantics(
            button: true,
            label: 'Quick exit',
            child: GestureDetector(
              onTap: () => _showQuickExitDialog(),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.bgSurface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.bgBorder),
                  boxShadow: AppTheme.shadowXs,
                ),
                child: const Icon(Icons.exit_to_app_rounded,
                    size: 20, color: AppTheme.textMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats row ─────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Row(
      children: [
        _StatPill(
          value: '$_dayStreak',
          label: _dayStreak == 1 ? 'day streak' : 'day streak',
          icon: _dayStreak > 0 ? '🔥' : '✨',
          color: _dayStreak > 0 ? const Color(0xFFE8580A) : AppTheme.primary,
          bg: _dayStreak > 0 ? const Color(0xFFFFF1EC) : AppTheme.primarySurface,
        ),
        const SizedBox(width: 10),
        _StatPill(
          value: '$_sessionCount',
          label: _sessionCount == 1 ? 'check-in' : 'check-ins',
          icon: '📋',
          color: AppTheme.primary,
          bg: AppTheme.primarySurface,
        ),
        const SizedBox(width: 10),
        _StatPill(
          value: '$_uniqueDays',
          label: 'days active',
          icon: '📅',
          color: const Color(0xFF5B4FA3),
          bg: const Color(0xFFF0EEFF),
          onTap: () => context.push('/history'),
        ),
      ],
    );
  }

  // ── Hero card ─────────────────────────────────────────────────────────────
  Widget _buildHeroCard() {
    return Semantics(
      button: true,
      label: 'Start mood check-in',
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          context.push('/chatmood');
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF164E3C), Color(0xFF1D6B52), Color(0xFF2E9B78)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.circular(AppTheme.cornerRadiusXl),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.35),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _sessionCount == 0
                          ? 'Start your journey'
                          : 'Daily check-in',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                'Reflect on\nyour mood',
                style: AppTheme.headingMd.copyWith(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'A guided, compassionate space to understand how you\'re feeling right now.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.psychology_alt_rounded,
                        color: AppTheme.primary, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _sessionCount == 0 ? 'Begin Check-in' : 'Check In Now',
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Milestone card ────────────────────────────────────────────────────────
  Widget _buildMilestoneCard() {
    final next = _nextMilestone!;
    final m    = next.milestone!;
    final pct  = next.total == 0 ? 0.0 : (next.progress / next.total).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(AppTheme.cornerRadiusMd),
        border: Border.all(color: AppTheme.bgBorder),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.accentSurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(m.emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'UP NEXT',
                      style: AppTheme.overline.copyWith(
                        color: AppTheme.accent,
                        fontSize: 10,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${next.progress}/${next.total}',
                      style: AppTheme.bodySm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  m.title,
                  style: AppTheme.headingXs,
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 6,
                    backgroundColor: AppTheme.bgBorder,
                    valueColor: const AlwaysStoppedAnimation(AppTheme.accent),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Daily reminder ────────────────────────────────────────────────────────
  Widget _buildDailyReminder() {
    const reminders = [
      'Progress isn\'t always linear — celebrate small steps.',
      'It\'s okay to not be okay — be gentle with yourself.',
      'Small moments of mindfulness make a real difference.',
      'Your feelings are valid — allow yourself to feel them.',
      'Rest is productive. You don\'t have to earn it.',
    ];
    final reminder = reminders[DateTime.now().day % reminders.length];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.accentSurface,
        borderRadius: BorderRadius.circular(AppTheme.cornerRadiusMd),
        border: Border.all(
          color: AppTheme.accent.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.format_quote_rounded,
                color: AppTheme.accent, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TODAY\'S REMINDER',
                  style: AppTheme.overline.copyWith(
                    color: AppTheme.accentDark,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reminder,
                  style: AppTheme.bodyMd.copyWith(
                    color: AppTheme.textDark,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Crisis bar ────────────────────────────────────────────────────────────
  Widget _buildCrisisBar() {
    return Semantics(
      button: true,
      label: 'Get crisis support',
      child: GestureDetector(
        onTap: () => context.push('/crisis'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.bgSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppTheme.crisisRed.withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.volunteer_activism_rounded,
                  color: AppTheme.crisisRed.withValues(alpha: 0.8), size: 20),
              const SizedBox(width: 12),
              Text(
                'Need immediate support?',
                style: AppTheme.bodyMd.copyWith(
                  color: AppTheme.crisisRed.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(Icons.chevron_right_rounded,
                  color: AppTheme.crisisRed.withValues(alpha: 0.5), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Quick exit dialog ─────────────────────────────────────────────────────
  void _showQuickExitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.bgSurface,
            borderRadius: BorderRadius.circular(AppTheme.cornerRadiusLg),
            boxShadow: AppTheme.shadowLg,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 4),
                  Container(
                    width: 64, height: 64,
                    decoration: const BoxDecoration(
                      color: AppTheme.crisisRedSurface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.exit_to_app_rounded,
                        color: AppTheme.crisisRed, size: 30),
                  ),
                  const SizedBox(height: 16),
                  Text('Quick Exit', style: AppTheme.headingSm),
                  const SizedBox(height: 8),
                  Text(
                    'This will immediately close Ubuncare.',
                    textAlign: TextAlign.center,
                    style: AppTheme.bodyMd,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.exit_to_app_rounded, size: 18),
                      label: const Text('Exit App'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.crisisRed,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        await SystemNavigator.pop();
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppTheme.bgBorder),
                      ),
                      child: const Text('Stay in App'),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: -8, right: -8,
                child: InkWell(
                  onTap: () => Navigator.pop(ctx),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 32, height: 32,
                    decoration: const BoxDecoration(
                      color: AppTheme.bgBorder,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 16, color: AppTheme.textMuted),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Horizontal tool card
// ─────────────────────────────────────────────────────────────────────────────

class _HorizontalToolCard extends StatelessWidget {
  final _ToolCard tool;
  const _HorizontalToolCard({required this.tool});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tool.label,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          context.push(tool.route);
        },
        child: Container(
          width: 120,
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: tool.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppTheme.cornerRadiusMd),
            boxShadow: [
              BoxShadow(
                color: tool.gradient.first.withValues(alpha: 0.28),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(tool.icon, color: Colors.white, size: 20),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tool.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tool.sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 10,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat pill
// ─────────────────────────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  final String value, label, icon;
  final Color color, bg;
  final VoidCallback? onTap;

  const _StatPill({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.bg,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: color.withValues(alpha: 0.65),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Milestone celebration dialog
// ─────────────────────────────────────────────────────────────────────────────

class _MilestoneCelebration extends StatelessWidget {
  final Milestone milestone;
  const _MilestoneCelebration({required this.milestone});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppTheme.bgSurface,
          borderRadius: BorderRadius.circular(AppTheme.cornerRadiusLg),
          boxShadow: AppTheme.shadowLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88, height: 88,
              decoration: BoxDecoration(
                color: AppTheme.accentSurface,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(milestone.emoji,
                    style: const TextStyle(fontSize: 44)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'ACHIEVEMENT UNLOCKED',
              style: AppTheme.overline.copyWith(
                color: AppTheme.accent,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              milestone.title,
              textAlign: TextAlign.center,
              style: AppTheme.headingSm,
            ),
            const SizedBox(height: 6),
            Text(
              milestone.subtitle,
              textAlign: TextAlign.center,
              style: AppTheme.bodyMd,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Keep Going 🎉'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data classes
// ─────────────────────────────────────────────────────────────────────────────

class _ToolCard {
  final IconData icon;
  final String label, sub, route;
  final List<Color> gradient;
  const _ToolCard({
    required this.icon,
    required this.label,
    required this.sub,
    required this.route,
    required this.gradient,
  });
}

