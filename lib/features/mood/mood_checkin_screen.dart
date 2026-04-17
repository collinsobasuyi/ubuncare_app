import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme.dart';

class MoodCheckInScreen extends StatefulWidget {
  const MoodCheckInScreen({super.key});

  @override
  State<MoodCheckInScreen> createState() => _MoodCheckInScreenState();
}

class _MoodCheckInScreenState extends State<MoodCheckInScreen>
    with SingleTickerProviderStateMixin {

  int    _step         = 0;
  double _moodValue    = 5;
  double _energyValue  = 5;
  bool   _isSubmitting = false;

  final List<String> _selectedEmotions   = [];
  final List<String> _selectedInfluences = [];
  final TextEditingController _noteCtrl  = TextEditingController();

  static const List<_Emotion> _emotions = [
    _Emotion('Calm',        '😌', Color(0xFF4FC3F7)),
    _Emotion('Happy',       '😊', Color(0xFFFFD54F)),
    _Emotion('Sad',         '😔', Color(0xFF64B5F6)),
    _Emotion('Anxious',     '😰', Color(0xFFEF9A9A)),
    _Emotion('Tired',       '😴', Color(0xFF9575CD)),
    _Emotion('Excited',     '🎉', Color(0xFF4DB6AC)),
    _Emotion('Frustrated',  '😤', Color(0xFFFF8A65)),
    _Emotion('Grateful',    '🙏', Color(0xFF81C784)),
    _Emotion('Confused',    '😕', Color(0xFFBA68C8)),
    _Emotion('Proud',       '🦁', Color(0xFFFFB74D)),
  ];

  static const List<_Influence> _influences = [
    _Influence('Work',         '💼', Icons.work_rounded),
    _Influence('Health',       '🏥', Icons.favorite_rounded),
    _Influence('Family',       '👨‍👩‍👧‍👦', Icons.family_restroom_rounded),
    _Influence('Friends',      '👯', Icons.people_rounded),
    _Influence('Sleep',        '😴', Icons.nightlight_rounded),
    _Influence('Weather',      '☀️', Icons.wb_sunny_rounded),
    _Influence('Money',        '💰', Icons.attach_money_rounded),
    _Influence('Social Media', '📱', Icons.phone_iphone_rounded),
    _Influence('Exercise',     '🏃', Icons.directions_run_rounded),
    _Influence('Food',         '🍎', Icons.restaurant_rounded),
  ];

  static const List<_StepMeta> _steps = [
    _StepMeta('How are you feeling?',    'Rate your current mood'),
    _StepMeta('Emotional landscape',     'Select up to 3 primary emotions'),
    _StepMeta('Mood influences',         "What might be affecting you?"),
    _StepMeta('Energy check',            'How energised do you feel?'),
    _StepMeta('Final thoughts',          'Add any notes (optional)'),
  ];

  late final AnimationController _ac;
  late final Animation<double>   _fade;
  late final Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..forward();
    _fade  = CurvedAnimation(parent: _ac, curve: Curves.easeInOut);
    _slide = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ac, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _ac.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < 4) {
      _ac.reverse().then((_) {
        if (mounted) {
          setState(() => _step++);
          _ac.forward();
        }
      });
    } else {
      _submit();
    }
  }

  void _prev() {
    if (_step > 0) {
      _ac.reverse().then((_) {
        if (mounted) {
          setState(() => _step--);
          _ac.forward();
        }
      });
    }
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 700));

    final entry = {
      'timestamp':    DateTime.now().toIso8601String(),
      'mood_score':   _moodValue,
      'emotions':     _selectedEmotions,
      'influences':   _selectedInfluences,
      'energy_level': _energyValue,
      'note':         _noteCtrl.text.trim(),
    };

    final prefs    = await SharedPreferences.getInstance();
    final existing = prefs.getStringList('mood_history') ?? [];
    existing.add(jsonEncode(entry));
    await prefs.setStringList('mood_history', existing);

    if (!mounted) return;
    _showSuccess();
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _SuccessDialog(),
    );
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        Navigator.of(context).pop();
        context.go('/history');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.headerGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SlideTransition(
                  position: _slide,
                  child: FadeTransition(
                    opacity: _fade,
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.bgSurface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha:0.1),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: _buildStep(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: _step > 0 ? 'Previous step' : 'Close check-in',
                icon: Icon(
                  _step > 0
                      ? Icons.arrow_back_ios_new_rounded
                      : Icons.close_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed:
                    _step > 0 ? _prev : () => context.go('/home'),
              ),
              // Progress dots
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _step ? 22 : 7,
                    height: 4,
                    decoration: BoxDecoration(
                      color: i <= _step
                          ? Colors.white
                          : Colors.white.withValues(alpha:0.35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _steps[_step].title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _steps[_step].desc,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0: return _buildMoodStep();
      case 1: return _buildEmotionsStep();
      case 2: return _buildInfluencesStep();
      case 3: return _buildEnergyStep();
      case 4: return _buildNoteStep();
      default: return const SizedBox();
    }
  }

  // ── Step 0 — Mood ─────────────────────────────────────────────────────────
  Widget _buildMoodStep() {
    final cfg = _moodConfig(_moodValue);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cfg.color.withValues(alpha:0.1),
                shape: BoxShape.circle,
              ),
              child: Text(cfg.emoji, style: const TextStyle(fontSize: 60)),
            ),
            const SizedBox(height: 20),
            Text(cfg.label,
                style: AppTheme.headingSm.copyWith(color: AppTheme.textDark)),
            const SizedBox(height: 6),
            Text(cfg.desc,
                textAlign: TextAlign.center, style: AppTheme.bodyMd),
          ],
        ),
        Column(
          children: [
            Slider(
              min: 0, max: 10, divisions: 10,
              value: _moodValue,
              activeColor: cfg.color,
              inactiveColor: cfg.color.withValues(alpha: 0.18),
              semanticFormatterCallback: (v) => 'Mood ${v.round()} out of 10',
              onChanged: (v) => setState(() => _moodValue = v),
            ),
            _NextButton(step: _step, onTap: _next),
          ],
        ),
      ],
    );
  }

  // ── Step 1 — Emotions ─────────────────────────────────────────────────────
  Widget _buildEmotionsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select up to 3 emotions · ${_selectedEmotions.length}/3',
          style: AppTheme.bodyMd.copyWith(
            color: AppTheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.6,
            ),
            itemCount: _emotions.length,
            itemBuilder: (_, i) {
              final e  = _emotions[i];
              final on = _selectedEmotions.contains(e.name);
              final disabled = _selectedEmotions.length >= 3 && !on;
              return _ChipTile(
                emoji: e.emoji,
                label: e.name,
                color: e.color,
                selected: on,
                disabled: disabled,
                onTap: () {
                  if (disabled) return;
                  setState(() {
                    on
                        ? _selectedEmotions.remove(e.name)
                        : _selectedEmotions.add(e.name);
                  });
                },
              );
            },
          ),
        ),
        _NextButton(step: _step, onTap: _next),
      ],
    );
  }

  // ── Step 2 — Influences ───────────────────────────────────────────────────
  Widget _buildInfluencesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("What's affecting your mood today?", style: AppTheme.bodyMd),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.4,
            ),
            itemCount: _influences.length,
            itemBuilder: (_, i) {
              final inf = _influences[i];
              final on  = _selectedInfluences.contains(inf.name);
              return _ChipTile(
                emoji: inf.emoji,
                label: inf.name,
                color: AppTheme.primaryLight,
                selected: on,
                disabled: false,
                onTap: () => setState(() {
                  on
                      ? _selectedInfluences.remove(inf.name)
                      : _selectedInfluences.add(inf.name);
                }),
              );
            },
          ),
        ),
        _NextButton(step: _step, onTap: _next),
      ],
    );
  }

  // ── Step 3 — Energy ───────────────────────────────────────────────────────
  Widget _buildEnergyStep() {
    final cfg = _energyConfig(_energyValue);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cfg.color.withValues(alpha:0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(cfg.icon, size: 60, color: cfg.color),
            ),
            const SizedBox(height: 20),
            Text(cfg.label,
                style: AppTheme.headingSm.copyWith(color: AppTheme.textDark)),
            const SizedBox(height: 6),
            Text(cfg.desc,
                textAlign: TextAlign.center, style: AppTheme.bodyMd),
          ],
        ),
        Column(
          children: [
            Slider(
              min: 0, max: 10, divisions: 10,
              value: _energyValue,
              activeColor: cfg.color,
              inactiveColor: cfg.color.withValues(alpha: 0.18),
              semanticFormatterCallback: (v) => 'Energy ${v.round()} out of 10',
              onChanged: (v) => setState(() => _energyValue = v),
            ),
            _NextButton(step: _step, onTap: _next),
          ],
        ),
      ],
    );
  }

  // ── Step 4 — Note ─────────────────────────────────────────────────────────
  Widget _buildNoteStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Any thoughts you'd like to remember?", style: AppTheme.bodyLg),
        const SizedBox(height: 4),
        Text(
          'This is just for you — write as much or as little as you like.',
          style: AppTheme.bodyMd,
        ),
        const SizedBox(height: 20),
        Expanded(
          child: TextField(
            controller: _noteCtrl,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            decoration: const InputDecoration(
              hintText: 'Today I felt…\nWhat helped…\nI noticed…',
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            icon: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.check_rounded, size: 20),
            label: const Text('Save Reflection'),
            onPressed: _isSubmitting ? null : _submit,
          ),
        ),
      ],
    );
  }

  // ── Config helpers ────────────────────────────────────────────────────────
  _MoodCfg _moodConfig(double v) {
    if (v <= 2) return const _MoodCfg('😞', 'Very Low',  'Feeling really down',    Color(0xFFEF5350));
    if (v <= 4) return const _MoodCfg('😕', 'Low',       'A bit off today',        Color(0xFFFF9800));
    if (v <= 6) return const _MoodCfg('😐', 'Neutral',   'Steady and balanced',    Color(0xFF78909C));
    if (v <= 8) return const _MoodCfg('🙂', 'Good',      'Feeling positive',       Color(0xFF66BB6A));
    return       const _MoodCfg('😄', 'Great',      'Wonderful and uplifted', Color(0xFF2E7D32));
  }

  _EnergyCfg _energyConfig(double v) {
    if (v <= 2) return const _EnergyCfg(Icons.battery_0_bar_rounded,  'Drained',   'Completely exhausted', Color(0xFFEF5350));
    if (v <= 4) return const _EnergyCfg(Icons.battery_2_bar_rounded,  'Low',       'Feeling tired',        Color(0xFFFF9800));
    if (v <= 6) return const _EnergyCfg(Icons.battery_4_bar_rounded,  'Moderate',  'Steady energy',        Color(0xFF78909C));
    if (v <= 8) return const _EnergyCfg(Icons.battery_6_bar_rounded,  'Good',      'Feeling energised',    Color(0xFF66BB6A));
    return       const _EnergyCfg(Icons.battery_full_rounded,         'High',      'Full of energy!',      Color(0xFF2E7D32));
  }
}

// ── Shared sub-widgets ─────────────────────────────────────────────────────
class _NextButton extends StatelessWidget {
  final int step;
  final VoidCallback onTap;
  const _NextButton({required this.step, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(step == 4 ? 'Complete' : 'Continue'),
            if (step < 4) ...[
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_rounded, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChipTile extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;

  const _ChipTile({
    required this.emoji,
    required this.label,
    required this.color,
    required this.selected,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$emoji $label',
      button: true,
      selected: selected,
      enabled: !disabled,
      child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: selected ? color.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? color : AppTheme.bgBorder,
          width: selected ? 1.8 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: disabled ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: AppTheme.bodyMd.copyWith(
                      color: disabled
                          ? AppTheme.textMuted
                          : selected
                              ? color
                              : AppTheme.textBody,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle_rounded, color: color, size: 16),
              ],
            ),
          ),
        ),
      ),
      ), // AnimatedContainer
    ); // Semantics
  }
}

class _SuccessDialog extends StatelessWidget {
  const _SuccessDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppTheme.bgSurface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: AppTheme.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  color: AppTheme.primary, size: 44),
            ),
            const SizedBox(height: 20),
            Text('Reflection Saved!',
                style: AppTheme.headingSm, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(
              'Your mood check-in has been recorded.',
              textAlign: TextAlign.center,
              style: AppTheme.bodyMd,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data models ────────────────────────────────────────────────────────────
class _Emotion {
  final String name, emoji;
  final Color color;
  const _Emotion(this.name, this.emoji, this.color);
}

class _Influence {
  final String name, emoji;
  final IconData icon;
  const _Influence(this.name, this.emoji, this.icon);
}

class _StepMeta {
  final String title, desc;
  const _StepMeta(this.title, this.desc);
}

class _MoodCfg {
  final String emoji, label, desc;
  final Color color;
  const _MoodCfg(this.emoji, this.label, this.desc, this.color);
}

class _EnergyCfg {
  final IconData icon;
  final String label, desc;
  final Color color;
  const _EnergyCfg(this.icon, this.label, this.desc, this.color);
}
