import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme.dart';
import '../../widgets/completion_dialog.dart';

// ── Sense model ───────────────────────────────────────────────────────────────

class _Sense {
  final int count;
  final String prompt;
  final String hint;
  final IconData icon;
  const _Sense(this.count, this.prompt, this.hint, this.icon);
}

// ── Screen ────────────────────────────────────────────────────────────────────

class FiveFourThreeTwoOneScreen extends StatefulWidget {
  const FiveFourThreeTwoOneScreen({super.key});

  @override
  State<FiveFourThreeTwoOneScreen> createState() =>
      _FiveFourThreeTwoOneScreenState();
}

class _FiveFourThreeTwoOneScreenState
    extends State<FiveFourThreeTwoOneScreen> {
  static const _senses = [
    _Sense(5, 'things you can SEE',
        'A plant, a window, your hands, a colour on the wall...',
        Icons.visibility_rounded),
    _Sense(4, 'things you can TOUCH',
        'Your chair, your clothes, the floor, a surface nearby...',
        Icons.touch_app_rounded),
    _Sense(3, 'things you can HEAR',
        'Traffic outside, your breath, a fan, birdsong...',
        Icons.hearing_rounded),
    _Sense(2, 'things you can SMELL',
        'The air, fabric, coffee, something nearby...',
        Icons.local_florist_rounded),
    _Sense(1, 'thing you can TASTE',
        'The inside of your mouth, a recent drink or meal...',
        Icons.restaurant_rounded),
  ];

  // per-sense text input controllers
  late final List<TextEditingController> _ctrls;
  final Map<int, bool> _done = {};
  int? _expanded;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(_senses.length, (_) => TextEditingController());
    for (var i = 0; i < _senses.length; i++) {
      _done[i] = false;
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls) { c.dispose(); }
    super.dispose();
  }

  bool get _allDone => _done.values.every((v) => v);

  void _acknowledge(int i) {
    setState(() {
      _done[i] = true;
      _expanded = null;
    });
    HapticFeedback.selectionClick();
  }

  void _reset() {
    setState(() {
      for (var i = 0; i < _senses.length; i++) {
        _ctrls[i].clear();
        _done[i] = false;
      }
      _expanded = null;
    });
  }

  void _finish() {
    HapticFeedback.mediumImpact();
    CompletionDialog.show(
      context: context,
      title: 'You Are Present',
      message:
          'You have anchored yourself in this moment.\nCarry this awareness with you.',
      color: AppTheme.primary,
      icon: Icons.spa_rounded,
      primaryLabel: 'Done',
      secondaryLabel: 'Go Again',
      onPrimary: () => Navigator.pop(context),
      onSecondary: _reset,
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _done.values.where((v) => v).length;

    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      appBar: AppBar(title: const Text('5-4-3-2-1 Grounding')),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.fromLTRB(24, 20, 24, 20),
            decoration:
                const BoxDecoration(gradient: AppTheme.headerGradient),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Ground Yourself',
                        style: AppTheme.headingMd
                            .copyWith(color: Colors.white)),
                    const Spacer(),
                    Text('$completedCount / ${_senses.length}',
                        style: AppTheme.bodyLg.copyWith(
                            color: Colors.white.withValues(alpha: 0.75))),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Use your senses to anchor yourself in this moment.\nTap each sense and notice what you find.',
                  style: AppTheme.bodyMd.copyWith(
                      color:
                          Colors.white.withValues(alpha: 0.85)),
                ),
              ],
            ),
          ),

          // Sense list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppTheme.pagePadding),
              itemCount: _senses.length,
              itemBuilder: (_, i) {
                final sense      = _senses[i];
                final isDone     = _done[i]!;
                final isExpanded = _expanded == i;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDone
                        ? AppTheme.success.withValues(alpha: 0.06)
                        : AppTheme.bgSurface,
                    borderRadius:
                        BorderRadius.circular(AppTheme.cornerRadius),
                    border: Border.all(
                      color: isDone
                          ? AppTheme.success.withValues(alpha: 0.4)
                          : AppTheme.bgBorder,
                      width: isDone ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Sense header tap target
                      InkWell(
                        borderRadius:
                            BorderRadius.circular(AppTheme.cornerRadius),
                        onTap: isDone
                            ? null
                            : () => setState(() =>
                                _expanded = isExpanded ? null : i),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Icon badge
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isDone
                                      ? AppTheme.success
                                          .withValues(alpha: 0.12)
                                      : AppTheme.primarySurface,
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  isDone
                                      ? Icons.check_rounded
                                      : sense.icon,
                                  color: isDone
                                      ? AppTheme.success
                                      : AppTheme.primary,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Label + completed note
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        style: AppTheme.bodyLg
                                            .copyWith(
                                                color: AppTheme.textDark),
                                        children: [
                                          TextSpan(
                                            text: '${sense.count} ',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.primary,
                                              fontSize: 18,
                                            ),
                                          ),
                                          TextSpan(text: sense.prompt),
                                        ],
                                      ),
                                    ),
                                    if (isDone &&
                                        _ctrls[i].text.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        _ctrls[i].text,
                                        style: AppTheme.bodySm.copyWith(
                                            fontStyle: FontStyle.italic),
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              // Chevron / check
                              if (!isDone)
                                Icon(
                                  isExpanded
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  color: AppTheme.textMuted,
                                )
                              else
                                const Icon(Icons.check_circle_rounded,
                                    color: AppTheme.success, size: 22),
                            ],
                          ),
                        ),
                      ),

                      // Expandable input area
                      AnimatedSize(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeInOut,
                        child: (isExpanded && !isDone)
                            ? Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    16, 0, 16, 16),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const Divider(),
                                    const SizedBox(height: 10),
                                    TextField(
                                      controller: _ctrls[i],
                                      maxLines: 2,
                                      decoration: InputDecoration(
                                        hintText: sense.hint,
                                        helperText:
                                            'Optional — jot what you notice',
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    FilledButton(
                                      onPressed: () => _acknowledge(i),
                                      child: Text(
                                        'I noticed '
                                        '${sense.count} '
                                        '${sense.count == 1 ? "thing" : "things"}',
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Bottom CTA
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: FilledButton(
                onPressed: _allDone ? _finish : null,
                child: const Text('I Feel Present'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
