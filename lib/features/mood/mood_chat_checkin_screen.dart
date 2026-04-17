import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme.dart';

class MoodChatCheckInScreen extends StatefulWidget {
  const MoodChatCheckInScreen({super.key});

  @override
  State<MoodChatCheckInScreen> createState() => _MoodChatCheckInScreenState();
}

class _MoodChatCheckInScreenState extends State<MoodChatCheckInScreen>
    with SingleTickerProviderStateMixin {

  final PageController _pageCtrl = PageController();
  final TextEditingController _noteCtrl = TextEditingController();

  double _mood   = 5;
  double _energy = 5;
  final List<String> _emotions   = [];
  final List<String> _influences = [];
  bool _saving = false;
  int _step = 0;

  static const List<String> _emotionOptions = [
    'Calm', 'Happy', 'Anxious', 'Tired', 'Sad', 'Grateful', 'Angry', 'Content',
  ];
  static const List<String> _influenceOptions = [
    'Work', 'Health', 'Sleep', 'Friends', 'Family', 'Money', 'Weather', 'Food',
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < 4) {
      setState(() => _step++);
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _save();
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    final entry = {
      'timestamp':    DateTime.now().toIso8601String(),
      'mood_score':   _mood,
      'energy_level': _energy,
      'emotions':     _emotions,
      'influences':   _influences,
      'note':         _noteCtrl.text.trim(),
    };

    final prefs    = await SharedPreferences.getInstance();
    final existing = prefs.getStringList('mood_history') ?? [];
    existing.add(jsonEncode(entry));
    await prefs.setStringList('mood_history', existing);

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _saving = false);
    context.go('/reflection_summary', extra: entry);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      appBar: AppBar(
        title: const Text('Mood Check-In'),
        backgroundColor: AppTheme.bgSurface,
        foregroundColor: AppTheme.primary,
        iconTheme: const IconThemeData(color: AppTheme.primary),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Step progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: List.generate(5, (i) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 4,
                      decoration: BoxDecoration(
                        color: i <= _step
                            ? AppTheme.primary
                            : AppTheme.primarySurface,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _Step(
                    question: "Hi 👋 Let's start your check-in.\nHow's your mood today?",
                    child: _SliderWidget(
                      label: 'Mood',
                      value: _mood,
                      onChanged: (v) => setState(() => _mood = v),
                    ),
                  ),
                  _Step(
                    question: 'Thanks! How is your energy level right now?',
                    child: _SliderWidget(
                      label: 'Energy',
                      value: _energy,
                      onChanged: (v) => setState(() => _energy = v),
                    ),
                  ),
                  _Step(
                    question: 'Which emotions describe you best today?',
                    child: _ChipGrid(
                      options: _emotionOptions,
                      selected: _emotions,
                      onToggle: (item) => setState(() {
                        _emotions.contains(item)
                            ? _emotions.remove(item)
                            : _emotions.add(item);
                      }),
                    ),
                  ),
                  _Step(
                    question: "What's influencing how you feel?",
                    child: _ChipGrid(
                      options: _influenceOptions,
                      selected: _influences,
                      onToggle: (item) => setState(() {
                        _influences.contains(item)
                            ? _influences.remove(item)
                            : _influences.add(item);
                      }),
                    ),
                  ),
                  _Step(
                    question: 'Would you like to add a short reflection?',
                    child: TextField(
                      controller: _noteCtrl,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Write a note (optional)…',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Next / Finish button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _saving ? null : _next,
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.2,
                          ),
                        )
                      : Text(_step == 4 ? 'Finish' : 'Next'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable step wrapper ────────────────────────────────────────────────────
class _Step extends StatelessWidget {
  final String question;
  final Widget child;
  const _Step({required this.question, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.bgSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.bgBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              question,
              style: AppTheme.bodyLg.copyWith(color: AppTheme.textDark),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(child: SingleChildScrollView(child: child)),
        ],
      ),
    );
  }
}

// ── Slider ───────────────────────────────────────────────────────────────────
class _SliderWidget extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  const _SliderWidget({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Slider(
          min: 0, max: 10, divisions: 10,
          value: value,
          label: value.toStringAsFixed(0),
          onChanged: onChanged,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            '$label: ${value.toStringAsFixed(0)} / 10',
            style: AppTheme.bodyMd.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

// ── Chip grid ────────────────────────────────────────────────────────────────
class _ChipGrid extends StatelessWidget {
  final List<String> options;
  final List<String> selected;
  final ValueChanged<String> onToggle;
  const _ChipGrid({required this.options, required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 10,
      children: options.map((item) {
        final on = selected.contains(item);
        return ChoiceChip(
          label: Text(item),
          selected: on,
          selectedColor: AppTheme.primarySurface,
          backgroundColor: AppTheme.bgSurface,
          side: BorderSide(
            color: on ? AppTheme.primary : AppTheme.bgBorder,
            width: on ? 1.5 : 1,
          ),
          labelStyle: AppTheme.bodyMd.copyWith(
            color: on ? AppTheme.primary : AppTheme.textBody,
            fontWeight: on ? FontWeight.w600 : FontWeight.w400,
          ),
          onSelected: (_) => onToggle(item),
        );
      }).toList(),
    );
  }
}
