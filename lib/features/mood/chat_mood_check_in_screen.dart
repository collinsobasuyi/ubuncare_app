import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/consent_state.dart';
import '../../app/theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Guide profile — maps avatar name → icon, colour, personalised copy
// ─────────────────────────────────────────────────────────────────────────────

class _GuideProfile {
  final String name;
  final IconData icon;
  final Color accent;
  final String openingLine;
  final String closingLine;

  const _GuideProfile({
    required this.name,
    required this.icon,
    required this.accent,
    required this.openingLine,
    required this.closingLine,
  });

  String moodEmpathy(double score) {
    if (score <= 3) {
      switch (name) {
        case 'Amani': return 'That sounds really hard. I\'m glad you\'re here — it\'s okay to not be okay.';
        case 'Kora':  return 'Tough days make the good ones sweeter. I\'m here with you right now.';
        case 'Nova':  return 'Low moments carry information. Let\'s gently explore what they\'re saying.';
        default:      return 'Thank you for being honest with yourself. You deserve care today.';
      }
    } else if (score <= 6) {
      switch (name) {
        case 'Amani': return 'There\'s a steadiness in that. Let\'s see what\'s underneath it.';
        case 'Kora':  return 'Middle ground can mean a lot of things. Let\'s find out what it means for you today.';
        case 'Nova':  return 'Interesting. A mid-range often hides the most nuance — let\'s explore.';
        default:      return 'That\'s a thoughtful place to be. Let\'s dig a little deeper together.';
      }
    } else {
      switch (name) {
        case 'Amani': return 'That\'s really good to hear. Let\'s take a moment to appreciate that.';
        case 'Kora':  return 'Amazing! Let\'s capture what\'s making you feel this way — it\'s worth understanding.';
        case 'Nova':  return 'Wonderful. High mood states are just as worth reflecting on as low ones.';
        default:      return 'That\'s lovely! Let\'s celebrate that and understand what\'s behind it.';
      }
    }
  }

  String intentResponse(String intent) {
    final isTough = intent.contains('tough');
    final isOnMind = intent.contains('mind');
    final isRoutine = intent.contains('daily');

    if (isTough) {
      switch (name) {
        case 'Amani': return 'I\'m glad you reached out. You don\'t have to carry this alone.';
        case 'Kora':  return 'You showed up — that\'s already brave. Let\'s work through this together.';
        case 'Nova':  return 'Difficult moments often carry the most to learn from. I\'m here.';
        default:      return 'I\'m really glad you\'re here. Let\'s take this gently, one step at a time.';
      }
    } else if (isOnMind) {
      switch (name) {
        case 'Amani': return 'A clear mind starts with acknowledging what\'s there. Let\'s do that now.';
        case 'Kora':  return 'Good instinct — naming what\'s on your mind is the first step.';
        case 'Nova':  return 'Let\'s explore what\'s occupying your thoughts and bring some clarity.';
        default:      return 'That awareness is a gift. Let\'s look at it together gently.';
      }
    } else if (isRoutine) {
      switch (name) {
        case 'Amani': return 'Consistency is a form of self-care. I\'m glad you\'re here again.';
        case 'Kora':  return 'Love the commitment! Let\'s make this check-in count.';
        case 'Nova':  return 'Tracking your patterns over time is one of the most insightful things you can do.';
        default:      return 'Your regular check-ins are building something beautiful — self-awareness.';
      }
    } else {
      switch (name) {
        case 'Amani': return 'It\'s wonderful to check in even on good days. Let\'s honour how you feel.';
        case 'Kora':  return 'That\'s brilliant! Reflecting when you\'re well helps you understand what\'s working.';
        case 'Nova':  return 'Positive states are just as worth exploring as difficult ones.';
        default:      return 'How lovely! Celebrating the good moments is just as important.';
      }
    }
  }

  static _GuideProfile fromName(String? name) {
    switch (name) {
      case 'Amani':
        return const _GuideProfile(
          name: 'Amani',
          icon: Icons.eco_rounded,
          accent: Color(0xFF2E9B78),
          openingLine:
              'Hello. Let\'s take a quiet moment to check in with how you\'re feeling today.',
          closingLine:
              'I\'ve saved your check-in. Take a breath — you showed up for yourself today.',
        );
      case 'Kora':
        return const _GuideProfile(
          name: 'Kora',
          icon: Icons.local_fire_department_rounded,
          accent: Color(0xFFE9963A),
          openingLine:
              'Hey there! So glad you\'re here. Let\'s check in on how you\'re feeling today.',
          closingLine:
              'Your check-in is saved. You should be proud of taking this step for yourself!',
        );
      case 'Nova':
        return const _GuideProfile(
          name: 'Nova',
          icon: Icons.nights_stay_rounded,
          accent: Color(0xFF5C6BC0),
          openingLine:
              'Welcome. Let\'s pause and reflect on how you\'re truly feeling right now.',
          closingLine:
              'Your check-in is saved. Reflection is a powerful act of self-awareness.',
        );
      case 'Zuri':
      default:
        return const _GuideProfile(
          name: 'Zuri',
          icon: Icons.auto_awesome_rounded,
          accent: Color(0xFF8E44AD),
          openingLine:
              'Hi there! Every check-in is a little gift to yourself. Let\'s see how you\'re doing today.',
          closingLine:
              'All saved! Remember — every small step forward is worth celebrating.',
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class ChatMoodCheckInScreen extends StatefulWidget {
  const ChatMoodCheckInScreen({super.key});

  @override
  State<ChatMoodCheckInScreen> createState() => _ChatMoodCheckInScreenState();
}

class _ChatMoodCheckInScreenState extends State<ChatMoodCheckInScreen> {
  final List<ChatMessage> _messages       = [];
  final TextEditingController _textCtrl   = TextEditingController();
  final ScrollController _scrollCtrl      = ScrollController();

  late _GuideProfile _guide;

  // ── Step tracking ─────────────────────────────────────────────────────────
  int _currentStep = 1; // 1 = Mood, 2 = Feelings, 3 = Context, 4 = Reflect

  // ── Typing indicator ──────────────────────────────────────────────────────
  bool _isTyping = false;

  // ── User responses ────────────────────────────────────────────────────────
  double? _moodValue;
  final List<String> _selectedEmotions   = [];
  final List<String> _selectedInfluences = [];
  double? _energyValue;
  String? _bodyFeel;          // replaces energy slider
  String? _checkInIntent;     // what brought them here today

  // ─── Emotion / influence data ─────────────────────────────────────────────
  static const List<Emotion> _emotions = [
    Emotion('Calm',        '😌', Color(0xFF4FC3F7)),
    Emotion('Happy',       '😊', Color(0xFFFFD54F)),
    Emotion('Sad',         '😔', Color(0xFF64B5F6)),
    Emotion('Anxious',     '😰', Color(0xFFE57373)),
    Emotion('Tired',       '😴', Color(0xFF9575CD)),
    Emotion('Excited',     '🎉', Color(0xFF4DB6AC)),
    Emotion('Frustrated',  '😤', Color(0xFFFF8A65)),
    Emotion('Grateful',    '🙏', Color(0xFF81C784)),
    Emotion('Confused',    '😕', Color(0xFFBA68C8)),
    Emotion('Proud',       '🦁', Color(0xFFFFB74D)),
  ];

  static const List<Influence> _influences = [
    Influence('Work',         '💼'),
    Influence('Health',       '🏥'),
    Influence('Family',       '👨‍👩‍👧‍👦'),
    Influence('Friends',      '👯'),
    Influence('Sleep',        '😴'),
    Influence('Weather',      '☀️'),
    Influence('Money',        '💰'),
    Influence('Social Media', '📱'),
    Influence('Exercise',     '🏃'),
    Influence('Food',         '🍎'),
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _guide = _GuideProfile.fromName(context.read<ConsentState>().selectedAvatar);
    _initializeChat();
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Bot messaging helpers
  // ─────────────────────────────────────────────────────────────────────────

  /// Shows typing indicator, waits, then adds a text message.
  Future<void> _botSay(String text, {int delayMs = 900}) async {
    if (!mounted) return;
    setState(() => _isTyping = true);
    _scrollToBottom();
    await Future.delayed(Duration(milliseconds: delayMs));
    if (!mounted) return;
    setState(() {
      _isTyping = false;
      _messages.add(ChatMessage(
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  /// Shows typing indicator, waits, then adds an embedded-widget message.
  Future<void> _botSayWidget(Widget widget, {int delayMs = 600}) async {
    if (!mounted) return;
    setState(() => _isTyping = true);
    _scrollToBottom();
    await Future.delayed(Duration(milliseconds: delayMs));
    if (!mounted) return;
    setState(() {
      _isTyping = false;
      _messages.add(ChatMessage(
        isUser: false,
        timestamp: DateTime.now(),
        widget: widget,
      ));
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _removeLastWidget() {
    // Removes the last bot message that contains an embedded widget (the answered step).
    for (int i = _messages.length - 1; i >= 0; i--) {
      if (!_messages[i].isUser && _messages[i].widget != null) {
        setState(() => _messages.removeAt(i));
        return;
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Chat flow
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _initializeChat() async {
    await _botSay(_guide.openingLine, delayMs: 400);
    await _botSay(
      'Before we begin — what brings you here today?',
      delayMs: 800,
    );
    await _botSayWidget(_buildIntentPicker());
  }

  // ── Intent picker (pre-step) ──────────────────────────────────────────────

  static const _intents = [
    ('😔', 'I\'m having a tough moment'),
    ('🤔', 'Something is on my mind'),
    ('🔁', 'Just my daily check-in'),
    ('😊', 'I\'m doing well and want to reflect'),
  ];

  Widget _buildIntentPicker() {
    return _StepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._intents.map((t) {
            final (emoji, label) = t;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => _handleIntentSelect(label),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.bgSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.bgBorder, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Text(emoji,
                          style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          label,
                          style: AppTheme.bodyMd.copyWith(
                              color: AppTheme.textDark),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          size: 18, color: AppTheme.textMuted),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _handleIntentSelect(String intent) async {
    HapticFeedback.selectionClick();
    _checkInIntent = intent;
    _removeLastWidget();
    _addUserMessage(intent);
    await _botSay(_guide.intentResponse(intent), delayMs: 700);
    await _botSay(
        'On a scale of 1–10, where is your mood sitting right now?');
    await _botSayWidget(_buildMoodSlider());
  }

  // ── Step 1: Mood ──────────────────────────────────────────────────────────

  Widget _buildMoodSlider() {
    double currentValue = _moodValue ?? 5.5;

    return StatefulBuilder(
      builder: (context, setLocal) {
        final cfg = _getMoodConfig(currentValue);

        return _StepCard(
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cfg.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(cfg.icon, size: 32, color: cfg.color),
              ),
              const SizedBox(height: 18),
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 6,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                  activeTrackColor: cfg.color,
                  inactiveTrackColor: AppTheme.bgBorder,
                  thumbColor: cfg.color,
                  overlayColor: cfg.color.withValues(alpha: 0.2),
                ),
                child: Slider(
                  min: 1,
                  max: 10,
                  divisions: 9,
                  value: currentValue,
                  onChanged: (v) => setLocal(() {
                    currentValue = v;
                    _moodValue = v;
                  }),
                ),
              ),
              const SizedBox(height: 10),
              _ScorePill(label: cfg.label, color: cfg.color),
              const SizedBox(height: 6),
              Text(
                cfg.description,
                textAlign: TextAlign.center,
                style: AppTheme.bodySm,
              ),
              const SizedBox(height: 18),
              _ContinueButton(
                enabled: true,
                onTap: () => _handleMoodSubmit(currentValue),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleMoodSubmit(double value) {
    HapticFeedback.lightImpact();
    _moodValue = value;
    _removeLastWidget();
    final cfg = _getMoodConfig(value);
    _addUserMessage('${value.round()}/10 — ${cfg.label}');
    setState(() => _currentStep = 2);
    _askEmotions(value);
  }

  // ── Step 2: Feelings ──────────────────────────────────────────────────────

  Future<void> _askEmotions(double moodScore) async {
    final empathy = _guide.moodEmpathy(moodScore);
    await _botSay(empathy, delayMs: 700);
    await _botSay(
        'Which of these feelings resonate with you right now? Choose up to 3.',
        delayMs: 800);
    await _botSayWidget(_buildEmotionsGrid());
  }

  Widget _buildEmotionsGrid() {
    const max = 3;
    return StatefulBuilder(
      builder: (context, setLocal) {
        return _StepCard(
          child: Column(
            children: [
              Text(
                '${_selectedEmotions.length}/$max selected',
                style: AppTheme.bodySm.copyWith(
                  color: _selectedEmotions.length >= max
                      ? AppTheme.crisisRed
                      : AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.15,
                ),
                itemCount: _emotions.length,
                itemBuilder: (_, i) {
                  final e = _emotions[i];
                  final selected  = _selectedEmotions.contains(e.name);
                  final disabled  = _selectedEmotions.length >= max && !selected;

                  return GestureDetector(
                    onTap: disabled
                        ? null
                        : () {
                            HapticFeedback.selectionClick();
                            setLocal(() {
                              selected
                                  ? _selectedEmotions.remove(e.name)
                                  : _selectedEmotions.add(e.name);
                            });
                          },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: selected
                            ? e.color.withValues(alpha: 0.14)
                            : AppTheme.bgSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected ? e.color : AppTheme.bgBorder,
                          width: selected ? 2 : 1.5,
                        ),
                        boxShadow: selected
                            ? [BoxShadow(
                                color: e.color.withValues(alpha: 0.18),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(e.emoji, style: const TextStyle(fontSize: 22)),
                          const SizedBox(height: 5),
                          Text(
                            e.name,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: disabled
                                  ? AppTheme.textMuted
                                  : AppTheme.textDark,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              _ContinueButton(
                enabled: _selectedEmotions.isNotEmpty,
                onTap: _handleEmotionsSubmit,
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleEmotionsSubmit() {
    HapticFeedback.lightImpact();
    _removeLastWidget();
    _addUserMessage('I\'m feeling: ${_selectedEmotions.join(', ')}');
    setState(() => _currentStep = 3);
    _askInfluences();
  }

  // ── Step 3: Context ───────────────────────────────────────────────────────

  Future<void> _askInfluences() async {
    await _botSay(
        'Thank you for sharing that. What\'s been on your mind — what\'s shaping how you feel today?',
        delayMs: 700);
    await _botSay(
        'Select everything that feels relevant. You can skip if nothing stands out.',
        delayMs: 600);
    await _botSayWidget(_buildInfluencesGrid());
  }

  Widget _buildInfluencesGrid() {
    const max = 5;
    return StatefulBuilder(
      builder: (context, setLocal) {
        return _StepCard(
          child: Column(
            children: [
              Text(
                '${_selectedInfluences.length}/$max selected',
                style: AppTheme.bodySm.copyWith(
                  color: _selectedInfluences.length >= max
                      ? AppTheme.crisisRed
                      : AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.15,
                ),
                itemCount: _influences.length,
                itemBuilder: (_, i) {
                  final inf     = _influences[i];
                  final selected = _selectedInfluences.contains(inf.name);
                  final disabled = _selectedInfluences.length >= max && !selected;

                  return GestureDetector(
                    onTap: disabled
                        ? null
                        : () {
                            HapticFeedback.selectionClick();
                            setLocal(() {
                              selected
                                  ? _selectedInfluences.remove(inf.name)
                                  : _selectedInfluences.add(inf.name);
                            });
                          },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.primarySurface
                            : AppTheme.bgSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected ? AppTheme.primary : AppTheme.bgBorder,
                          width: selected ? 2 : 1.5,
                        ),
                        boxShadow: selected
                            ? [BoxShadow(
                                color: AppTheme.primary.withValues(alpha: 0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(inf.emoji, style: const TextStyle(fontSize: 22)),
                          const SizedBox(height: 5),
                          Text(
                            inf.name,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: disabled
                                  ? AppTheme.textMuted
                                  : AppTheme.textDark,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              _ContinueButton(
                enabled: true,
                label: _selectedInfluences.isEmpty ? 'Skip' : 'Continue',
                onTap: _handleInfluencesSubmit,
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleInfluencesSubmit() {
    HapticFeedback.lightImpact();
    _removeLastWidget();
    final response = _selectedInfluences.isEmpty
        ? 'Nothing specific on my mind today'
        : 'On my mind: ${_selectedInfluences.join(', ')}';
    _addUserMessage(response);
    setState(() => _currentStep = 4);
    _askBodyAndReflect();
  }

  // ── Step 4: Body feel + Reflection ───────────────────────────────────────

  Future<void> _askBodyAndReflect() async {
    await _botSay(
        'Now let\'s check in with your body. How does it feel right now?',
        delayMs: 700);
    await _botSayWidget(_buildBodyFeel());
  }

  static const _bodyOptions = [
    ('😣', 'Tense / Tight',    Color(0xFFEF5350)),
    ('😴', 'Tired / Heavy',    Color(0xFF78909C)),
    ('😐', 'Neutral / Okay',   Color(0xFF8EA89F)),
    ('😌', 'Relaxed / Calm',   Color(0xFF4CAF50)),
    ('⚡', 'Energised / Light', Color(0xFF66BB6A)),
  ];

  Widget _buildBodyFeel() {
    return StatefulBuilder(
      builder: (ctx, setLocal) {
        String? localSelection = _bodyFeel;
        return _StepCard(
          child: Column(
            children: [
              ..._bodyOptions.map((opt) {
                final (emoji, label, color) = opt;
                final selected = localSelection == label;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setLocal(() {
                        localSelection = label;
                        _bodyFeel = label;
                        _energyValue = _bodyOptions.indexOf(opt).toDouble() + 1;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 13),
                      decoration: BoxDecoration(
                        color: selected
                            ? color.withValues(alpha: 0.1)
                            : AppTheme.bgSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected ? color : AppTheme.bgBorder,
                          width: selected ? 2 : 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(emoji,
                              style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 14),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: selected ? color : AppTheme.textDark,
                            ),
                          ),
                          const Spacer(),
                          if (selected)
                            Icon(Icons.check_circle_rounded,
                                color: color, size: 18),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              _ContinueButton(
                enabled: localSelection != null,
                onTap: () => _handleBodyFeel(localSelection!),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleBodyFeel(String feel) async {
    HapticFeedback.lightImpact();
    _bodyFeel = feel;
    _removeLastWidget();
    _addUserMessage('My body feels: $feel');
    await _botSay(
        'Last step — a moment just for you. There are no right or wrong answers here.',
        delayMs: 700);
    await _botSayWidget(_buildNoteInput());
  }

  static const _reflectionPrompts = [
    'What would make today feel a little better?',
    'What is one thing you\'re grateful for right now?',
    'What do you need most in this moment?',
  ];

  Widget _buildNoteInput() {
    return StatefulBuilder(builder: (ctx, setLocal) {
      return _StepCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tap a prompt or write freely:',
                style: AppTheme.bodySm),
            const SizedBox(height: 10),

            // Prompt chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _reflectionPrompts.map((p) {
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _textCtrl.text = p;
                    _textCtrl.selection = TextSelection.fromPosition(
                      TextPosition(offset: p.length),
                    );
                    setLocal(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primarySurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppTheme.primary
                              .withValues(alpha: 0.25)),
                    ),
                    child: Text(
                      p,
                      style: AppTheme.bodySm.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 14),

            TextField(
              controller: _textCtrl,
              maxLines: 4,
              style: AppTheme.bodyMd,
              decoration: InputDecoration(
                hintText: 'Write your thoughts here…',
                hintStyle: AppTheme.bodySm,
                filled: true,
                fillColor: AppTheme.bgPage,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppTheme.bgBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppTheme.bgBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                      color: AppTheme.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 18),
            _ContinueButton(
              enabled: true,
              label: 'Complete My Check-in',
              onTap: _handleFinalSubmit,
            ),
          ],
        ),
      );
    });
  }

  void _handleFinalSubmit() {
    HapticFeedback.lightImpact();
    _removeLastWidget();
    final note = _textCtrl.text.trim();
    _addUserMessage(note.isNotEmpty ? note : 'No additional thoughts today.');
    _saveMoodEntry();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Save + insights
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _saveMoodEntry() async {
    await _botSay(_guide.closingLine, delayMs: 1000);

    final prefs    = await SharedPreferences.getInstance();
    final moodData = {
      'timestamp':    DateTime.now().toIso8601String(),
      'mood_score':   _moodValue,
      'emotions':     _selectedEmotions,
      'influences':   _selectedInfluences,
      'energy_level': _energyValue,
      'body_feel':    _bodyFeel,
      'intent':       _checkInIntent,
      'note':         _textCtrl.text.trim(),
    };
    final List<String> existing = prefs.getStringList('mood_history') ?? [];
    existing.add(jsonEncode(moodData));
    await prefs.setStringList('mood_history', existing);

    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) _showInsightsSheet();
  }

  void _showInsightsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _InsightsSheet(
        moodValue:    _moodValue!,
        emotions:     _selectedEmotions,
        influences:   _selectedInfluences,
        energyValue:  _energyValue!,
        onAction: (action) {
          Navigator.pop(context);
          _handleAction(action);
        },
      ),
    );
  }

  void _handleAction(String action) {
    switch (action) {
      case 'breathing':    context.go('/breathing_exercise'); break;
      case 'gratitude':    context.go('/gratitude');          break;
      case 'quick_calm':   context.go('/quick_calm');         break;
      case 'planning':     context.go('/planning_tools');     break;
      case 'self_care':    context.go('/self_care');          break;
      case 'history':      context.go('/history');            break;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Config helpers
  // ─────────────────────────────────────────────────────────────────────────

  static MoodConfig _getMoodConfig(double v) {
    if (v <= 2) return const MoodConfig(Icons.sentiment_very_dissatisfied_rounded, 'Very Low',  'Feeling really down today',      Color(0xFFEF5350));
    if (v <= 4) return const MoodConfig(Icons.sentiment_dissatisfied_rounded,      'Low',       'A bit off today',                Color(0xFFFF8A65));
    if (v <= 6) return const MoodConfig(Icons.sentiment_neutral_rounded,           'Neutral',   'Steady and balanced',            Color(0xFF78909C));
    if (v <= 8) return const MoodConfig(Icons.sentiment_satisfied_rounded,         'Good',      'Feeling positive',               Color(0xFF66BB6A));
    return       const MoodConfig(Icons.sentiment_very_satisfied_rounded,          'Great',     'Wonderful and uplifted',         Color(0xFF43A047));
  }


  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final userName = context.watch<ConsentState>().userName;
    final userInitial = (userName != null && userName.isNotEmpty)
        ? userName[0].toUpperCase()
        : 'U';

    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          tooltip: 'Go back',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mood Check-in'),
            Text(
              'with ${_guide.name}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _StepProgressBar(currentStep: _currentStep),
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, i) {
                if (_isTyping && i == _messages.length) {
                  return _TypingBubble(guide: _guide);
                }
                return _ChatBubble(
                  message: _messages[i],
                  guide: _guide,
                  userInitial: userInitial,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step progress bar
// ─────────────────────────────────────────────────────────────────────────────

class _StepProgressBar extends StatelessWidget {
  final int currentStep;
  const _StepProgressBar({required this.currentStep});

  static const _labels = ['Mood', 'Feelings', 'Context', 'Reflect'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.bgSurface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: List.generate(_labels.length, (i) {
          final step      = i + 1;
          final done      = step < currentStep;
          final active    = step == currentStep;

          return Expanded(
            child: Row(
              children: [
                if (i > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: done ? AppTheme.primary : AppTheme.bgBorder,
                    ),
                  ),
                Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done || active
                            ? AppTheme.primary
                            : AppTheme.bgBorder,
                      ),
                      child: Center(
                        child: done
                            ? const Icon(Icons.check_rounded,
                                color: Colors.white, size: 14)
                            : Text(
                                '$step',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: active
                                      ? Colors.white
                                      : AppTheme.textMuted,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _labels[i],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: active
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: active
                            ? AppTheme.primary
                            : AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
                if (i < _labels.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: done ? AppTheme.primary : AppTheme.bgBorder,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Typing indicator bubble
// ─────────────────────────────────────────────────────────────────────────────

class _TypingBubble extends StatefulWidget {
  final _GuideProfile guide;
  const _TypingBubble({required this.guide});

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BotAvatar(guide: widget.guide),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: widget.guide.accent.withValues(alpha: 0.09),
              borderRadius: const BorderRadius.only(
                topLeft:     Radius.circular(4),
                topRight:    Radius.circular(16),
                bottomLeft:  Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _ctrl,
                  builder: (_, __) {
                    final phase  = (_ctrl.value - i * 0.2).clamp(0.0, 1.0);
                    final bounce = (phase < 0.5 ? phase : 1 - phase) * 2;
                    return Container(
                      margin: EdgeInsets.only(
                        right: i < 2 ? 4 : 0,
                        bottom: bounce * 6,
                      ),
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: widget.guide.accent.withValues(alpha: 0.5 + bounce * 0.5),
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chat bubble
// ─────────────────────────────────────────────────────────────────────────────

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final _GuideProfile guide;
  final String userInitial;

  const _ChatBubble({
    required this.message,
    required this.guide,
    required this.userInitial,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _BotAvatar(guide: guide),
          if (!isUser) const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (message.text != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isUser
                          ? AppTheme.primary
                          : guide.accent.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.only(
                        topLeft:     Radius.circular(isUser ? 16 : 4),
                        topRight:    Radius.circular(isUser ? 4 : 16),
                        bottomLeft:  const Radius.circular(16),
                        bottomRight: const Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      message.text!,
                      style: AppTheme.bodyMd.copyWith(
                        color: isUser ? Colors.white : AppTheme.textDark,
                      ),
                    ),
                  ),
                if (message.widget != null) ...[
                  const SizedBox(height: 8),
                  message.widget!,
                ],
                const SizedBox(height: 4),
                Text(
                  _fmt(message.timestamp),
                  style: AppTheme.bodySm.copyWith(
                    fontSize: 10,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser) _UserAvatar(initial: userInitial),
        ],
      ),
    );
  }

  String _fmt(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

class _BotAvatar extends StatelessWidget {
  final _GuideProfile guide;
  const _BotAvatar({required this.guide});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: guide.accent,
        shape: BoxShape.circle,
      ),
      child: Icon(guide.icon, color: Colors.white, size: 18),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final String initial;
  const _UserAvatar({required this.initial});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: AppTheme.accent,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable step card wrapper
// ─────────────────────────────────────────────────────────────────────────────

class _StepCard extends StatelessWidget {
  final Widget child;
  const _StepCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.bgBorder),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable score pill
// ─────────────────────────────────────────────────────────────────────────────

class _ScorePill extends StatelessWidget {
  final String label;
  final Color color;
  const _ScorePill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable continue button
// ─────────────────────────────────────────────────────────────────────────────

class _ContinueButton extends StatelessWidget {
  final bool enabled;
  final String label;
  final VoidCallback onTap;

  const _ContinueButton({
    required this.enabled,
    required this.onTap,
    this.label = 'Continue',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton(
        onPressed: enabled ? onTap : null,
        child: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data models
// ─────────────────────────────────────────────────────────────────────────────

class ChatMessage {
  final String? text;
  final bool isUser;
  final DateTime timestamp;
  final Widget? widget;

  const ChatMessage({
    this.text,
    required this.isUser,
    required this.timestamp,
    this.widget,
  });
}

class Emotion {
  final String name;
  final String emoji;
  final Color  color;
  const Emotion(this.name, this.emoji, this.color);
}

class Influence {
  final String name;
  final String emoji;
  const Influence(this.name, this.emoji);
}

class MoodConfig {
  final IconData icon;
  final String   label;
  final String   description;
  final Color    color;
  const MoodConfig(this.icon, this.label, this.description, this.color);
}


class Insight {
  final String title;
  final String description;
  final String emoji;
  const Insight(this.title, this.description, this.emoji);
}

class ActionItem {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final Color  color;
  const ActionItem(this.id, this.title, this.description, this.emoji, this.color);
}

// ─────────────────────────────────────────────────────────────────────────────
// Insights bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _InsightsSheet extends StatelessWidget {
  final double moodValue;
  final List<String> emotions;
  final List<String> influences;
  final double energyValue;
  final void Function(String) onAction;

  const _InsightsSheet({
    required this.moodValue,
    required this.emotions,
    required this.influences,
    required this.energyValue,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final insights = _buildInsights();
    final actions  = _buildActions();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // ── Handle + header ───────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
            decoration: BoxDecoration(
              color: AppTheme.primarySurface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                ),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Your Check-in Insights', style: AppTheme.headingSm),
                const SizedBox(height: 4),
                Text(
                  'Based on how you are feeling today',
                  style: AppTheme.bodySm,
                ),
              ],
            ),
          ),

          // ── Scrollable content ────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('What We Notice', style: AppTheme.headingSm),
                  const SizedBox(height: 14),
                  ...insights.map((i) => _InsightCard(insight: i)),
                  const SizedBox(height: 28),
                  Text('What Might Help', style: AppTheme.headingSm),
                  const SizedBox(height: 6),
                  Text(
                    'Try one of these based on how you feel right now',
                    style: AppTheme.bodySm,
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.3,
                    ),
                    itemCount: actions.length,
                    itemBuilder: (_, i) => _ActionCard(
                      action: actions[i],
                      onTap: () => onAction(actions[i].id),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => onAction('history'),
                      child: const Text('View My Mood History'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Insight> _buildInsights() {
    final list = <Insight>[];

    if (moodValue <= 4) {
      list.add(const Insight(
        'Your mood is lower today',
        'This is a perfect time for self-care and compassion.',
        '🌱',
      ));
    } else if (moodValue >= 8) {
      list.add(const Insight(
        'You are feeling great!',
        'Consider channelling this positive energy into something creative.',
        '🌟',
      ));
    }

    if (energyValue <= 4) {
      list.add(const Insight(
        'Your energy is low',
        'Short movement breaks can gently revive your vitality.',
        '⚡',
      ));
    }

    if (emotions.contains('Anxious') || emotions.contains('Frustrated')) {
      list.add(const Insight(
        'You are carrying some tension',
        'Breathing exercises can calm your nervous system quickly.',
        '🌀',
      ));
    }

    if (emotions.contains('Grateful') || emotions.contains('Proud')) {
      list.add(const Insight(
        'Positive emotions are present',
        'Savour these moments — they strengthen positive neural pathways.',
        '✨',
      ));
    }

    if (influences.contains('Work')) {
      list.add(const Insight(
        'Work is on your mind',
        'Setting clear boundaries can help maintain a healthy balance.',
        '💼',
      ));
    }

    if (influences.contains('Sleep')) {
      list.add(const Insight(
        'Sleep is affecting you',
        'A consistent sleep routine improves both mood and energy.',
        '😴',
      ));
    }

    if (list.isEmpty) {
      list.add(const Insight(
        'Thanks for checking in',
        'Regular reflection builds emotional awareness over time.',
        '📝',
      ));
    }

    return list;
  }

  List<ActionItem> _buildActions() {
    final list = <ActionItem>[
      const ActionItem(
        'breathing', 'Calm Breathing',
        '5-min reset for your nervous system', '🌀',
        Color(0xFF4FC3F7),
      ),
      const ActionItem(
        'gratitude', 'Gratitude Moment',
        'Shift your perspective gently', '🙏',
        Color(0xFFFFD54F),
      ),
    ];

    if (moodValue <= 5 ||
        emotions.contains('Sad') ||
        emotions.contains('Anxious')) {
      list.add(const ActionItem(
        'self_care', 'Self-Care Ideas',
        'Gentle activities to nurture yourself', '💖',
        Color(0xFFE57373),
      ));
    }

    // Was energy_boost (removed) — now routes to Quick Calm
    if (energyValue <= 5) {
      list.add(const ActionItem(
        'quick_calm', 'Quick Calm',
        '60-second grounding when you need it', '🍃',
        Color(0xFF4DB6AC),
      ));
    }

    if (moodValue >= 6 && energyValue >= 6) {
      list.add(const ActionItem(
        'planning', 'Set Intentions',
        'Focus your energy for the week ahead', '⭐',
        Color(0xFFBA68C8),
      ));
    }

    return list;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Insight card
// ─────────────────────────────────────────────────────────────────────────────

class _InsightCard extends StatelessWidget {
  final Insight insight;
  const _InsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primarySurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(insight.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: AppTheme.bodyMd.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(insight.description, style: AppTheme.bodySm),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Action card
// ─────────────────────────────────────────────────────────────────────────────

class _ActionCard extends StatelessWidget {
  final ActionItem action;
  final VoidCallback onTap;
  const _ActionCard({required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.cornerRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(action.emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 8),
                  Text(
                    action.title,
                    style: AppTheme.bodyMd.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(action.description, style: AppTheme.bodySm),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 3,
                decoration: BoxDecoration(
                  color: action.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
