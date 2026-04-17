import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';

class WellnessHubScreen extends StatelessWidget {
  const WellnessHubScreen({super.key});

  static const List<_WellnessItem> _items = [
    _WellnessItem('Guided Breathing',    Icons.air_rounded,               '/breathing_exercise',
        'Slow, guided breathing to restore calm'),
    _WellnessItem('Weekly Intention',    Icons.event_note_rounded,        '/planning_tools',
        'Set your focus and guide your week'),
    _WellnessItem('Self-Care Ideas',     Icons.spa_rounded,               '/self_care',
        'Simple, gentle acts of kindness to yourself'),
    _WellnessItem('Body Scan',           Icons.accessibility_new_rounded, '/body_scan',
        'Tune in to how your body feels right now'),
    _WellnessItem('Sensory Grounding',   Icons.filter_5_rounded,          '/54321',
        'Use your senses to anchor in the present'),
    _WellnessItem('Emergency Calm',      Icons.emergency_rounded,         '/emergency_calm',
        'Guided relief when you feel overwhelmed'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      appBar: AppBar(title: const Text('Wellness Tools')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose a tool to relax, recharge, or plan your wellbeing journey.',
              style: AppTheme.bodyMd,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.95,
                ),
                itemCount: _items.length,
                itemBuilder: (context, i) => _WellnessCard(item: _items[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WellnessCard extends StatelessWidget {
  final _WellnessItem item;
  const _WellnessCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.cornerRadius),
        onTap: () {
          HapticFeedback.lightImpact();
          context.push(item.route);
        },
        splashColor: AppTheme.primary.withValues(alpha:0.08),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: AppTheme.primary, size: 26),
              ),
              const SizedBox(height: 12),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: AppTheme.bodyMd.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.bodySm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WellnessItem {
  final String title;
  final IconData icon;
  final String route;
  final String subtitle;

  const _WellnessItem(this.title, this.icon, this.route, this.subtitle);
}
