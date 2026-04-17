import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../widgets/completion_dialog.dart';

// ── Data models ───────────────────────────────────────────────────────────────

class _Idea {
  final String title;
  final String description;
  final IconData icon;
  const _Idea(this.title, this.description, this.icon);
}

class _Category {
  final String name;
  final IconData icon;
  final List<_Idea> ideas;
  const _Category(this.name, this.icon, this.ideas);
}

// ── Screen ────────────────────────────────────────────────────────────────────

class SelfCareIdeasScreen extends StatefulWidget {
  const SelfCareIdeasScreen({super.key});

  @override
  State<SelfCareIdeasScreen> createState() => _SelfCareIdeasScreenState();
}

class _SelfCareIdeasScreenState extends State<SelfCareIdeasScreen> {
  static const _categories = [
    _Category('Quick Resets', Icons.bolt_rounded, [
      _Idea('Drink a glass of water',
          'Hydration restores your energy and focus',
          Icons.local_drink_rounded),
      _Idea('Step outside for 2 minutes',
          'Breathe fresh air and feel the ground beneath you',
          Icons.nature_rounded),
      _Idea('Listen to one favourite song',
          'Music shifts your emotional tone instantly',
          Icons.music_note_rounded),
      _Idea('Take 5 deep breaths',
          'Slow your heart rate and calm your mind',
          Icons.air_rounded),
      _Idea('Stretch your body',
          'Release physical tension and reconnect with yourself',
          Icons.accessibility_new_rounded),
    ]),
    _Category('Comfort & Care', Icons.favorite_rounded, [
      _Idea('Make a warm drink',
          'Comfort and warmth in a cup',
          Icons.coffee_rounded),
      _Idea('Wrap up in a cosy blanket',
          'Offer yourself gentle safety and rest',
          Icons.hotel_rounded),
      _Idea('Read something uplifting',
          'Feed your mind with kindness and hope',
          Icons.menu_book_rounded),
      _Idea('Take a warm shower',
          'Wash away the weight of the day',
          Icons.shower_rounded),
      _Idea('Dim the lights and rest',
          'Soften your environment and your thoughts',
          Icons.light_mode_rounded),
    ]),
    _Category('Mental Space', Icons.psychology_rounded, [
      _Idea('Write down your worries',
          'Externalise what is on your mind',
          Icons.edit_note_rounded),
      _Idea('Meditate for 5 minutes',
          'Invite stillness and inner quiet',
          Icons.self_improvement_rounded),
      _Idea('Take a digital break',
          'Rest from screens, news, and noise',
          Icons.do_not_disturb_on_rounded),
      _Idea('Practice self-compassion',
          'Be as kind to yourself as you would a friend',
          Icons.spa_rounded),
      _Idea('Visualise a peaceful place',
          'Anchor your nervous system with calm imagery',
          Icons.landscape_rounded),
    ]),
    _Category('Gentle Movement', Icons.directions_walk_rounded, [
      _Idea('Gentle yoga stretches',
          'Move your body slowly and with care',
          Icons.sports_gymnastics_rounded),
      _Idea('Walk mindfully',
          'Notice sights, sounds, and sensations around you',
          Icons.directions_walk_rounded),
      _Idea('Dance to one song',
          'Celebrate being alive in your body',
          Icons.music_video_rounded),
      _Idea('Neck and shoulder rolls',
          'Loosen the places where you carry stress',
          Icons.rotate_right_rounded),
      _Idea('Stand up and shake it out',
          'Release pent-up tension from head to toe',
          Icons.swap_vert_rounded),
    ]),
  ];

  // Tracks completed idea titles (session only)
  final Set<String> _completed = {};

  void _completeIdea(_Idea idea) {
    setState(() => _completed.add(idea.title));
    CompletionDialog.show(
      context: context,
      title: 'Great Choice',
      message:
          'Taking a small moment for yourself matters.\nEvery mindful act supports your wellbeing.',
      color: AppTheme.primary,
      icon: Icons.self_improvement_rounded,
      primaryLabel: 'Done',
      secondaryLabel: 'Keep Going',
      onPrimary: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      appBar: AppBar(
        title: const Text('Self-Care Ideas'),
        actions: [
          if (_completed.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${_completed.length} done',
                      style:
                          AppTheme.bodySm.copyWith(color: Colors.white)),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Gradient header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 22),
            decoration: const BoxDecoration(
                gradient: AppTheme.headerGradient),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nourish Yourself',
                    style: AppTheme.headingMd
                        .copyWith(color: Colors.white)),
                const SizedBox(height: 6),
                Text(
                  'Pick what feels right right now.\nSmall acts of care ripple into wellbeing.',
                  style: AppTheme.bodyMd.copyWith(
                      color: Colors.white.withValues(alpha: 0.85)),
                ),
              ],
            ),
          ),

          // Categories
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppTheme.pagePadding),
              itemCount: _categories.length,
              itemBuilder: (_, i) => _CategoryCard(
                category: _categories[i],
                completed: _completed,
                onComplete: _completeIdea,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category card (expandable) ────────────────────────────────────────────────

class _CategoryCard extends StatefulWidget {
  final _Category category;
  final Set<String> completed;
  final void Function(_Idea) onComplete;

  const _CategoryCard({
    required this.category,
    required this.completed,
    required this.onComplete,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final doneCount = widget.category.ideas
        .where((i) => widget.completed.contains(i.title))
        .length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(AppTheme.cornerRadius),
        border: Border.all(color: AppTheme.bgBorder),
      ),
      child: Column(
        children: [
          // Header row
          InkWell(
            borderRadius: BorderRadius.circular(AppTheme.cornerRadius),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primarySurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(widget.category.icon,
                        color: AppTheme.primary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.category.name,
                            style: AppTheme.headingSm),
                        if (doneCount > 0)
                          Text('$doneCount completed',
                              style: AppTheme.bodySm.copyWith(
                                  color: AppTheme.success)),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppTheme.textMuted,
                  ),
                ],
              ),
            ),
          ),

          // Expandable ideas list
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _expanded
                ? Column(children: [
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ...widget.category.ideas.map((idea) {
                      final done =
                          widget.completed.contains(idea.title);
                      return _IdeaTile(
                        idea: idea,
                        done: done,
                        onTap:
                            done ? null : () => widget.onComplete(idea),
                      );
                    }),
                    const SizedBox(height: 8),
                  ])
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ── Idea tile ─────────────────────────────────────────────────────────────────

class _IdeaTile extends StatelessWidget {
  final _Idea idea;
  final bool done;
  final VoidCallback? onTap;
  const _IdeaTile(
      {required this.idea, required this.done, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: done
              ? AppTheme.success.withValues(alpha: 0.12)
              : AppTheme.primarySurface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          done ? Icons.check_rounded : idea.icon,
          color: done ? AppTheme.success : AppTheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        idea.title,
        style: AppTheme.bodyMd.copyWith(
          color: done ? AppTheme.textMuted : AppTheme.textDark,
          fontWeight: FontWeight.w500,
          decoration: done ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Text(idea.description, style: AppTheme.bodySm),
      trailing: done
          ? null
          : IconButton(
              icon: const Icon(Icons.check_circle_outline_rounded,
                  color: AppTheme.primary),
              onPressed: onTap,
              tooltip: 'Mark done',
            ),
    );
  }
}
