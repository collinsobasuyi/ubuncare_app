import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class RecommendationCard extends StatefulWidget {
  const RecommendationCard({super.key});

  @override
  State<RecommendationCard> createState() => _RecommendationCardState();
}

class _RecommendationCardState extends State<RecommendationCard>
    with SingleTickerProviderStateMixin {
  String? _recommendation;
  String? _targetRoute;
  String? _actionLabel;
  String? _emoji;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  static const Color primaryTeal = Color(0xFF0D896C);

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);
    _loadLastMood();
  }

  Future<void> _loadLastMood() async {
    final prefs = await SharedPreferences.getInstance();
    final mood = prefs.getString('last_mood');

    if (mood != null) {
      final rec = _generateRecommendation(mood);
      setState(() {
          _recommendation = rec['message'];
        _targetRoute = rec['route'];
        _actionLabel = rec['action'];
        _emoji = rec['emoji'];
      });
      _fadeCtrl.forward();
    }
  }

  Map<String, String> _generateRecommendation(String mood) {
    // Simple rule-based mapping — easy to extend later
    switch (mood.toLowerCase()) {
      case 'stressed':
      case 'anxious':
        return {
          'message': 'You’ve been feeling anxious — try a short breathing reset.',
          'route': '/breathing',
          'action': 'Try Breathing Exercise',
          'emoji': '🌬️'
        };
      case 'tired':
      case 'exhausted':
        return {
          'message': 'You’ve felt low on energy — how about a 3-min boost?',
          'route': '/energy',
          'action': 'Do Energy Boost',
          'emoji': '⚡'
        };
      case 'sad':
      case 'down':
        return {
          'message': 'You’ve been feeling low — a gratitude moment might help.',
          'route': '/gratitude',
          'action': 'Open Gratitude Journal',
          'emoji': '🌻'
        };
      case 'angry':
      case 'frustrated':
        return {
          'message': 'Tension detected — gentle stretches can help release it.',
          'route': '/selfcare',
          'action': 'Explore Self-Care Ideas',
          'emoji': '🧘'
        };
      case 'okay':
      case 'neutral':
        return {
          'message': 'You’re balanced — maybe plan something meaningful today.',
          'route': '/planning',
          'action': 'Set an Intention',
          'emoji': '🎯'
        };
      case 'happy':
      case 'grateful':
        return {
          'message': 'You’re feeling good — channel that joy into reflection.',
          'route': '/journal',
          'action': 'Write a Gratitude Entry',
          'emoji': '✨'
        };
      default:
        return {
          'message': 'Take a mindful moment — pick what feels right today.',
          'route': '/wellness',
          'action': 'Browse Wellness Tools',
          'emoji': '🌿'
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_recommendation == null) return const SizedBox.shrink();

    final textScale = MediaQuery.textScalerOf(context).scale(1.0).clamp(1.0, 1.4);

    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20 * textScale),
        decoration: BoxDecoration(
          color: primaryTeal.withValues(alpha:0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryTeal.withValues(alpha:0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _emoji ?? '🌿',
                  style: TextStyle(fontSize: 20 * textScale),
                ),
                SizedBox(width: 8 * textScale),
                Text(
                  'Personalized Recommendation',
                  style: TextStyle(
                    fontSize: 14 * textScale,
                    fontWeight: FontWeight.w600,
                    color: primaryTeal,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10 * textScale),
            Text(
              _recommendation!,
              style: TextStyle(
                fontSize: 15 * textScale,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            SizedBox(height: 14 * textScale),
            SizedBox(
              width: double.infinity,
              height: 44 * textScale,
              child: FilledButton(
                onPressed: () => context.push(_targetRoute ?? '/wellness'),
                style: FilledButton.styleFrom(
                  backgroundColor: primaryTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _actionLabel ?? 'Explore Wellness Tools',
                  style: TextStyle(
                    fontSize: 15 * textScale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }
}
