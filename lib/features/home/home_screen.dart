import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // ---------- Theme Colors ----------
  static const Color primaryTeal = Color(0xFF0D896C);
  static const Color lighterTeal = Color(0xFF11A985);
  static const Color accentTeal = Color(0xFF4FE2B5);
  static const Color criticalRed = Color(0xFFD32F2F);

  // ---------- Animated Gradient ----------
  late final AnimationController _gradCtrl;
  late final Animation<double> _phase;

  // ---------- Rotating Tips ----------
  final List<String> _tips = const [
    "Remember to breathe deeply when feeling overwhelmed.",
    "Small moments of mindfulness can make a big difference.",
    "It's okay to not be okay — be gentle with yourself today.",
    "Progress isn’t always linear — celebrate small steps.",
    "Your feelings are valid — allow yourself to feel them.",
  ];
  int _tipIndex = 0;
  Timer? _tipTimer;

  @override
  void initState() {
    super.initState();
    _gradCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _phase = CurvedAnimation(parent: _gradCtrl, curve: Curves.easeInOut);

    _tipTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (mounted) {
        setState(() {
          _tipIndex = (_tipIndex + 1) % _tips.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _tipTimer?.cancel();
    _gradCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScaleFactorOf(context).clamp(1.0, 1.6);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ---------- Animated Header ----------
            SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: _phase,
                builder: (context, _) {
                  final c1 = Color.lerp(primaryTeal, lighterTeal, _phase.value)!;
                  final c2 =
                      Color.lerp(lighterTeal, accentTeal, 1 - _phase.value)!;

                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 24 * textScale,
                      vertical: 20 * textScale,
                    ),
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
                        // Top row: Quick Exit • Title • Settings
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(Icons.exit_to_app_rounded,
                                  color: Colors.white70, size: 24 * textScale),
                              onPressed: () => _showQuickExitDialog(context),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Welcome to',
                                    style: TextStyle(
                                      fontSize: 16 * textScale,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'Ubuncare',
                                    style: TextStyle(
                                      fontSize: 32 * textScale,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                      shadows: const [
                                        Shadow(
                                          offset: Offset(1, 1),
                                          blurRadius: 4,
                                          color: Colors.black26,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.settings_rounded,
                                  color: Colors.white, size: 28 * textScale),
                              onPressed: () => context.push('/settings'),
                            ),
                          ],
                        ),
                        SizedBox(height: 16 * textScale),
                        // Daily wellbeing tip
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16 * textScale),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.eco_rounded,
                                      color: Colors.white, size: 18 * textScale),
                                  SizedBox(width: 8 * textScale),
                                  Text(
                                    'Wellbeing Reminder',
                                    style: TextStyle(
                                      fontSize: 14 * textScale,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8 * textScale),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 450),
                                transitionBuilder: (child, anim) =>
                                    FadeTransition(opacity: anim, child: child),
                                child: Text(
                                  _tips[_tipIndex],
                                  key: ValueKey(_tipIndex),
                                  style: TextStyle(
                                    fontSize: 15 * textScale,
                                    color: Colors.white,
                                    height: 1.4,
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
              ),
            ),

            // ---------- Progress Overview ----------
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    24 * textScale, 20 * textScale, 24 * textScale, 8 * textScale),
                child: _buildProgressOverview(
                  context,
                  textScale,
                  primaryTeal,
                  sessionCount: 3,
                  dayStreak: 7,
                ),
              ),
            ),

            // ---------- Section Heading ----------
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 24 * textScale, vertical: 8 * textScale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Reflection Tools',
                      style: TextStyle(
                        fontSize: 20 * textScale,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 6 * textScale),
                    Text(
                      'Choose how you’d like to reflect today',
                      style: TextStyle(
                        fontSize: 14 * textScale,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ---------- 2×2 Action Grid ----------
            SliverPadding(
              padding: EdgeInsets.symmetric(
                  horizontal: 24 * textScale, vertical: 12 * textScale),
              sliver: SliverGrid(
                delegate: SliverChildListDelegate.fixed([
                  _buildActionCard(
                    context,
                    icon: Icons.mood_rounded,
                    title: 'Mood Check',
                    subtitle: 'Track how you feel',
                    color: primaryTeal,
                    route: '/mood',
                    textScale: textScale,
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Reflection Chat',
                    subtitle: 'Gentle conversation',
                    color: primaryTeal,
                    route: '/chat',
                    textScale: textScale,
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.insights_rounded,
                    title: 'Insights',
                    subtitle: 'View your journey',
                    color: primaryTeal,
                    route: '/summary',
                    textScale: textScale,
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.history_rounded,
                    title: 'Mood History',
                    subtitle: 'View past reflections',
                    color: primaryTeal,
                    route: '/history',
                    textScale: textScale,
                  ),
                ]),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
              ),
            ),

            // ---------- Crisis Support CTA (Clean Version) ----------
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    24 * textScale, 16 * textScale, 24 * textScale, 32 * textScale),
                child: _buildCrisisSupport(context, textScale),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Components ----------

  Widget _buildProgressOverview(
    BuildContext context,
    double textScale,
    Color color, {
    required int sessionCount,
    required int dayStreak,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.push('/summary'),
      child: Container(
        padding: EdgeInsets.all(16 * textScale),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.08), color.withOpacity(0.02)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.12)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12 * textScale),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_graph_rounded, color: color),
            ),
            SizedBox(width: 16 * textScale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Reflection Journey',
                    style: TextStyle(
                      fontSize: 16 * textScale,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  SizedBox(height: 4 * textScale),
                  Text(
                    '$sessionCount sessions • $dayStreak-day streak',
                    style: TextStyle(
                      fontSize: 14 * textScale,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: color, size: 16 * textScale),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String route,
    required double textScale,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.12), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push(route),
        splashColor: color.withOpacity(0.08),
        child: Padding(
          padding: EdgeInsets.all(16 * textScale),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12 * textScale),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24 * textScale),
              ),
              SizedBox(height: 12 * textScale),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16 * textScale,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              SizedBox(height: 4 * textScale),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12 * textScale,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCrisisSupport(BuildContext context, double textScale) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20 * textScale),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: criticalRed.withOpacity(0.1),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: criticalRed.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.volunteer_activism_rounded,
              color: criticalRed, size: 36 * textScale),
          const SizedBox(height: 12),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: criticalRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: Size(double.infinity, 52 * textScale),
              textStyle: TextStyle(
                fontSize: 16 * textScale,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () => context.push('/crisis'),
            child: const Text('Crisis Support Resources'),
          ),
        ],
      ),
    );
  }

  void _showQuickExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quick Exit'),
        content: const Text('This will immediately close Ubuncare.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Stay in App'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await SystemNavigator.pop();
            },
            child: const Text(
              'Exit App',
              style: TextStyle(color: criticalRed),
            ),
          ),
        ],
      ),
    );
  }
}
