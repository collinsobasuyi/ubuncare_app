import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';

class WellnessHubScreen extends StatelessWidget {
  const WellnessHubScreen({super.key});

  static const List<_Category> _categories = [
    _Category(
      label: 'BREATHE',
      items: [
        _WellnessItem(
          icon: Icons.air_rounded,
          title: 'Guided Breathing',
          sub: 'Slow breath to restore calm',
          route: '/breathing_exercise',
          gradient: [Color(0xFF3A6B82), Color(0xFF5BAECF)],
          duration: '3 min',
        ),
        _WellnessItem(
          icon: Icons.self_improvement_rounded,
          title: 'Quick Calm',
          sub: '60-second breathing reset',
          route: '/quick_calm',
          gradient: [Color(0xFF2E7A5A), Color(0xFF4BAF8A)],
          duration: '1 min',
        ),
      ],
    ),
    _Category(
      label: 'GROUND',
      items: [
        _WellnessItem(
          icon: Icons.filter_5_rounded,
          title: 'Sensory Grounding',
          sub: '5-4-3-2-1 technique',
          route: '/54321',
          gradient: [Color(0xFF4E6B2A), Color(0xFF7BA844)],
          duration: '5 min',
        ),
        _WellnessItem(
          icon: Icons.accessibility_new_rounded,
          title: 'Body Scan',
          sub: 'Tune in to how you feel',
          route: '/body_scan',
          gradient: [Color(0xFF6B4E82), Color(0xFF9B78C2)],
          duration: '8 min',
        ),
        _WellnessItem(
          icon: Icons.emergency_rounded,
          title: 'Emergency Calm',
          sub: 'Relief when overwhelmed',
          route: '/emergency_calm',
          gradient: [Color(0xFF822A2A), Color(0xFFB85050)],
          duration: '3 min',
        ),
      ],
    ),
    _Category(
      label: 'REFLECT',
      items: [
        _WellnessItem(
          icon: Icons.favorite_rounded,
          title: 'Gratitude Journal',
          sub: 'Count your blessings',
          route: '/gratitude',
          gradient: [Color(0xFFBF7424), Color(0xFFE9963A)],
          duration: '5 min',
        ),
        _WellnessItem(
          icon: Icons.event_note_rounded,
          title: 'Weekly Intention',
          sub: 'Set your focus & guide your week',
          route: '/planning_tools',
          gradient: [Color(0xFF1D6B52), Color(0xFF2E9B78)],
          duration: '10 min',
        ),
        _WellnessItem(
          icon: Icons.spa_rounded,
          title: 'Self-Care Ideas',
          sub: 'Gentle acts of kindness',
          route: '/self_care',
          gradient: [Color(0xFF82453A), Color(0xFFB87062)],
          duration: '5 min',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ─────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 64, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TOOLS', style: AppTheme.overline),
                  const SizedBox(height: 4),
                  Text('Wellness Hub', style: AppTheme.displayLg.copyWith(
                    fontSize: 34,
                  )),
                  const SizedBox(height: 6),
                  Text(
                    'Tools to help you breathe, ground, and reflect.',
                    style: AppTheme.bodyMd,
                  ),
                ],
              ),
            ),
          ),

          // ── Categories ─────────────────────────────────────────────────────
          ..._categories.map((cat) => _CategorySliver(category: cat)),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _CategorySliver extends StatelessWidget {
  final _Category category;
  const _CategorySliver({required this.category});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
            child: Text(category.label, style: AppTheme.overline),
          ),
          SizedBox(
            height: 160,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: category.items.length,
              itemBuilder: (_, i) => _WellnessCard(item: category.items[i]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _WellnessCard extends StatelessWidget {
  final _WellnessItem item;
  const _WellnessCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${item.title} — ${item.duration}',
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          context.push(item.route);
        },
        child: Container(
          width: 160,
          margin: const EdgeInsets.only(right: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: item.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppTheme.cornerRadiusMd),
            boxShadow: [
              BoxShadow(
                color: item.gradient.first.withValues(alpha: 0.30),
                blurRadius: 18,
                offset: const Offset(0, 8),
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
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item.icon, color: Colors.white, size: 18),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.duration,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                item.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                item.sub,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontSize: 11,
                  height: 1.4,
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
class _WellnessItem {
  final IconData icon;
  final String title, sub, route, duration;
  final List<Color> gradient;
  const _WellnessItem({
    required this.icon,
    required this.title,
    required this.sub,
    required this.route,
    required this.gradient,
    required this.duration,
  });
}

class _Category {
  final String label;
  final List<_WellnessItem> items;
  const _Category({required this.label, required this.items});
}
