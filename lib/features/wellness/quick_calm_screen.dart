import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import '../../app/theme.dart';
import 'emergency_calm_screen.dart';
import 'five_four_three_two_one_screen.dart';
import 'body_scan_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enums & data
// ─────────────────────────────────────────────────────────────────────────────

enum _Phase { ready, inhale, hold, exhale }

class _Tool {
  final String   title;
  final String   duration;
  final String   description;
  final IconData icon;
  final Color    color;
  final List<String>? steps; // null → navigate to screen

  const _Tool({
    required this.title,
    required this.duration,
    required this.description,
    required this.icon,
    required this.color,
    this.steps,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class QuickCalmScreen extends StatefulWidget {
  const QuickCalmScreen({super.key});

  @override
  State<QuickCalmScreen> createState() => _QuickCalmScreenState();
}

class _QuickCalmScreenState extends State<QuickCalmScreen>
    with SingleTickerProviderStateMixin {

  // ── Animation ──────────────────────────────────────────────────────────────
  late final AnimationController _ctrl;
  late final Animation<double>   _scale;

  // ── Breathing state ────────────────────────────────────────────────────────
  bool   _isActive      = false;
  bool   _cycleRunning  = false;
  _Phase _phase         = _Phase.ready;
  int    _countdown     = 0;
  int    _breathCount   = 0;
  Timer? _countdownTimer;

  // ── Sound ──────────────────────────────────────────────────────────────────
  final AudioPlayer _player = AudioPlayer();
  bool   _soundEnabled  = true;
  String _selectedSound = 'Calm Waves';

  // ── Tools ──────────────────────────────────────────────────────────────────
  static const List<_Tool> _tools = [
    _Tool(
      title: '5-4-3-2-1 Senses',
      duration: '3–5 min',
      description: 'Anchor in the present moment',
      icon: Icons.explore_rounded,
      color: AppTheme.primary,
    ),
    _Tool(
      title: 'Body Scan',
      duration: '5–7 min',
      description: 'Gentle awareness, head to toe',
      icon: Icons.health_and_safety_rounded,
      color: Color(0xFF5C6BC0),
    ),
    _Tool(
      title: 'Safe Place',
      duration: '2–3 min',
      description: 'Guided imagery for inner peace',
      icon: Icons.landscape_rounded,
      color: Color(0xFF2980B9),
      steps: [
        'Close your eyes or soften your gaze downward.',
        'Picture a place where you feel completely safe — real or imagined.',
        'Notice the colours, light, and shapes around you.',
        'What sounds exist in this place? Let them be calm and gentle.',
        'Feel the temperature on your skin. Are you warm? Cool?',
        'Take a slow, deep breath and let this calm fill your whole body.',
        'You can return to this place any time you need peace.',
      ],
    ),
    _Tool(
      title: 'Tense & Release',
      duration: '2 min',
      description: 'Progressive muscle relaxation',
      icon: Icons.fitness_center_rounded,
      color: Color(0xFFE67E22),
      steps: [
        'Find a comfortable seated or lying position.',
        'Take a slow deep breath in through your nose.',
        'Shrug your shoulders up to your ears — hold for 5 seconds.',
        'Release completely and breathe out. Feel the tension go.',
        'Make tight fists for 5 seconds, then release your hands.',
        'Clench your jaw gently for 5 seconds, then let it fall open.',
        'Notice how different your body feels now.',
      ],
    ),
    _Tool(
      title: 'Humming Breath',
      duration: '1 min',
      description: 'Calming vibration through sound',
      icon: Icons.music_note_rounded,
      color: Color(0xFF8E44AD),
      steps: [
        'Sit comfortably and let your eyes soften or close.',
        'Take a full, slow breath in through your nose.',
        'As you exhale, make a gentle humming sound — "hmmm".',
        'Feel the vibration in your lips, chest, and face.',
        'Let the hum be soft and steady — no effort needed.',
        'Repeat 5–6 times at your own pace.',
        'Notice the quiet that follows each hum.',
      ],
    ),
    _Tool(
      title: 'Butterfly Hug',
      duration: '2 min',
      description: 'Gentle bilateral self-soothing',
      icon: Icons.self_improvement_rounded,
      color: Color(0xFF27AE60),
      steps: [
        'Cross your arms over your chest, hands resting on your shoulders.',
        'Close your eyes or soften your gaze downward.',
        'Begin tapping your shoulders gently — left, right, left, right.',
        'Tap slowly, like a calm, steady heartbeat.',
        'With each tap, breathe slowly in and out.',
        'If a thought comes, let it pass like a cloud.',
        'Continue for 1–2 minutes until you feel a little calmer.',
      ],
    ),
  ];

  // ── Encouraging messages ───────────────────────────────────────────────────
  static const List<String> _messages = [
    "You're safe here.",
    "This feeling will pass.",
    "Be gentle with yourself.",
    "One breath at a time.",
    "You're doing great.",
    "Let your body relax.",
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _scale = Tween<double>(begin: 0.72, end: 1.18)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _ctrl.dispose();
    _player.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Breathing logic
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _startBreathing() async {
    if (_cycleRunning) return;
    HapticFeedback.lightImpact();
    setState(() {
      _isActive    = true;
      _breathCount = 0;
      _phase       = _Phase.inhale;
    });

    if (_soundEnabled && _selectedSound != 'Silence') {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource(_soundFile()), volume: 0.25);
    }

    _runCycle();
  }

  Future<void> _stopBreathing() async {
    HapticFeedback.lightImpact();
    _countdownTimer?.cancel();
    setState(() {
      _isActive  = false;
      _phase     = _Phase.ready;
      _countdown = 0;
    });
    _ctrl.stop();
    await _ctrl.animateTo(0.0, duration: const Duration(milliseconds: 700));
    await _player.stop();
  }

  Future<void> _runCycle() async {
    _cycleRunning = true;
    while (_isActive && mounted) {
      // ── Inhale 4 s ──────────────────────────────────────────────────────
      setState(() { _phase = _Phase.inhale; });
      _startCountdown(4);
      await _ctrl.animateTo(1.0,
          duration: const Duration(seconds: 4), curve: Curves.easeIn);
      if (!_isActive || !mounted) break;

      // ── Hold 3 s ────────────────────────────────────────────────────────
      setState(() { _phase = _Phase.hold; });
      _startCountdown(3);
      await Future.delayed(const Duration(seconds: 3));
      if (!_isActive || !mounted) break;

      // ── Exhale 6 s ──────────────────────────────────────────────────────
      setState(() { _phase = _Phase.exhale; });
      _startCountdown(6);
      await _ctrl.animateTo(0.0,
          duration: const Duration(seconds: 6), curve: Curves.easeOut);
      if (!_isActive || !mounted) break;

      // ── Cycle complete ───────────────────────────────────────────────────
      if (mounted) setState(() => _breathCount++);
    }
    _cycleRunning = false;
  }

  void _startCountdown(int seconds) {
    _countdownTimer?.cancel();
    setState(() => _countdown = seconds);
    int remaining = seconds;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      remaining--;
      if (!mounted || !_isActive || remaining <= 0) { t.cancel(); return; }
      setState(() => _countdown = remaining);
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Sound helpers
  // ─────────────────────────────────────────────────────────────────────────

  String _soundFile() {
    switch (_selectedSound) {
      case 'Deep Breath': return 'sounds/deep_breath.mp3';
      case 'Soft Chime':  return 'sounds/soft_chime.mp3';
      default:            return 'sounds/calm_waves.mp3';
    }
  }

  IconData _soundIcon(String s) {
    switch (s) {
      case 'Deep Breath': return Icons.air_rounded;
      case 'Soft Chime':  return Icons.notifications_rounded;
      case 'Silence':     return Icons.volume_off_rounded;
      default:            return Icons.waves_rounded;
    }
  }

  void _showSoundPicker() {
    const sounds = ['Calm Waves', 'Deep Breath', 'Soft Chime', 'Silence'];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ambient Sound',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark)),
              const SizedBox(height: 4),
              const Text('Choose a gentle background sound',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
              const SizedBox(height: 16),
              ...sounds.map((s) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 40, height: 40,
                      decoration: const BoxDecoration(
                          color: AppTheme.primarySurface, shape: BoxShape.circle),
                      child: Icon(_soundIcon(s), color: AppTheme.primary, size: 18),
                    ),
                    title: Text(s,
                        style: TextStyle(
                            fontWeight: s == _selectedSound
                                ? FontWeight.w700
                                : FontWeight.normal,
                            color: AppTheme.textDark)),
                    trailing: s == _selectedSound
                        ? const Icon(Icons.check_rounded, color: AppTheme.primary)
                        : null,
                    onTap: () async {
                      Navigator.pop(context);
                      setState(() => _selectedSound = s);
                      await _player.stop();
                      if (s != 'Silence' && _soundEnabled && _isActive) {
                        await _player.setReleaseMode(ReleaseMode.loop);
                        await _player.play(AssetSource(_soundFile()), volume: 0.25);
                      }
                    },
                  )),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tool helpers
  // ─────────────────────────────────────────────────────────────────────────

  void _onToolTap(int index) {
    final tool = _tools[index];
    if (tool.steps != null) {
      _showStepsSheet(tool);
      return;
    }
    switch (index) {
      case 0:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const FiveFourThreeTwoOneScreen()));
      case 1:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const BodyScanScreen()));
    }
  }

  void _showStepsSheet(_Tool tool) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, sc) => SingleChildScrollView(
          controller: sc,
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: AppTheme.bgBorder,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                        color: tool.color.withValues(alpha: 0.12),
                        shape: BoxShape.circle),
                    child: Icon(tool.icon, color: tool.color, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tool.title,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textDark)),
                        Text('${tool.duration} · ${tool.description}',
                            style: const TextStyle(
                                fontSize: 13, color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Steps',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textBody,
                      letterSpacing: 0.5)),
              const SizedBox(height: 14),
              ...tool.steps!.asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 26, height: 26,
                          decoration: BoxDecoration(
                              color: tool.color.withValues(alpha: 0.12),
                              shape: BoxShape.circle),
                          child: Center(
                            child: Text('${e.key + 1}',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: tool.color)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(e.value,
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textBody,
                                  height: 1.5)),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Phase display helpers
  // ─────────────────────────────────────────────────────────────────────────

  String get _phaseLabel {
    switch (_phase) {
      case _Phase.inhale:  return 'Breathe In';
      case _Phase.hold:    return 'Hold';
      case _Phase.exhale:  return 'Breathe Out';
      case _Phase.ready:   return 'Ready when you are';
    }
  }

  String get _encouragement =>
      _messages[_breathCount % _messages.length];

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      appBar: AppBar(title: const Text('Quick Calm')),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHero()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            sliver: SliverToBoxAdapter(child: _buildToolsHeading()),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _ToolCard(
                  tool: _tools[i],
                  onTap: () => _onToolTap(i),
                ),
                childCount: _tools.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: 118,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            sliver: SliverToBoxAdapter(child: _buildEmergency()),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            sliver: SliverToBoxAdapter(child: _buildSafetyNotice()),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Hero breathing section
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryMid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // Phase label
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Text(
              _phaseLabel,
              key: ValueKey(_phase),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.9),
                letterSpacing: 0.3,
              ),
            ),
          ),

          // Countdown
          const SizedBox(height: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              _isActive ? '$_countdown' : '·',
              key: ValueKey(_isActive ? _countdown : 'dot'),
              style: TextStyle(
                fontSize: _isActive ? 52 : 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.1,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Animated circle
          AnimatedBuilder(
            animation: _scale,
            builder: (_, __) {
              return SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer ring
                    Transform.scale(
                      scale: _isActive ? _scale.value * 1.12 : 1.0,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    // Main circle
                    Transform.scale(
                      scale: _isActive ? _scale.value : 1.0,
                      child: Container(
                        width: 158,
                        height: 158,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(
                              alpha: _isActive ? 0.16 : 0.1),
                          border: Border.all(
                            color: Colors.white.withValues(
                                alpha: _isActive ? 0.55 : 0.35),
                            width: 2,
                          ),
                        ),
                        child: _isActive
                            ? null
                            : const Icon(Icons.air_rounded,
                                color: Colors.white, size: 46),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Breath counter / encouragement
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _isActive
                  ? (_breathCount > 0
                      ? '$_breathCount ${_breathCount == 1 ? 'breath' : 'breaths'} · $_encouragement'
                      : _encouragement)
                  : 'Inhale 4 · Hold 3 · Exhale 6',
              key: ValueKey('$_breathCount$_isActive'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Sound chip
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Switch(
                activeThumbColor: Colors.white,
                activeTrackColor: Colors.white.withValues(alpha: 0.35),
                inactiveThumbColor: Colors.white60,
                inactiveTrackColor: Colors.white24,
                value: _soundEnabled,
                onChanged: (val) async {
                  setState(() => _soundEnabled = val);
                  if (!val) {
                    await _player.stop();
                  } else if (_isActive && _selectedSound != 'Silence') {
                    await _player.setReleaseMode(ReleaseMode.loop);
                    await _player.play(AssetSource(_soundFile()), volume: 0.25);
                  }
                },
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: _showSoundPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_soundIcon(_selectedSound),
                          color: Colors.white, size: 13),
                      const SizedBox(width: 6),
                      Text(
                        _soundEnabled ? _selectedSound : 'Sound off',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down_rounded,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 14),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Start / Stop button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor:
                    _isActive ? Colors.white.withValues(alpha: 0.2) : Colors.white,
                foregroundColor:
                    _isActive ? Colors.white : AppTheme.primary,
                side: _isActive
                    ? BorderSide(
                        color: Colors.white.withValues(alpha: 0.5))
                    : null,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed:
                  _isActive ? _stopBreathing : _startBreathing,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isActive
                        ? Icons.stop_rounded
                        : Icons.play_arrow_rounded,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isActive ? 'Stop' : 'Start Breathing',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tools section
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildToolsHeading() {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'Relief Tools',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          '· tap any to explore',
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Emergency card
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildEmergency() {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(context,
            MaterialPageRoute(
                builder: (_) => const EmergencyCalmScreen()));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bgSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppTheme.crisisRed.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.crisisRed.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                  color: AppTheme.crisisRedSurface, shape: BoxShape.circle),
              child: const Icon(Icons.emergency_rounded,
                  color: AppTheme.crisisRed, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Need immediate support?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.crisisRed,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap for guided emergency calm',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.crisisRed.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppTheme.crisisRed.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Safety notice
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSafetyNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primarySurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.bgBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded,
              color: AppTheme.primary.withValues(alpha: 0.6), size: 15),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'These tools support self-management and are not a substitute '
              'for professional mental health care. If you are in crisis, '
              'please contact emergency services.',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textBody,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tool card
// ─────────────────────────────────────────────────────────────────────────────

class _ToolCard extends StatelessWidget {
  final _Tool        tool;
  final VoidCallback onTap;
  const _ToolCard({required this.tool, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppTheme.bgSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppTheme.bgBorder),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: tool.color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(tool.icon, color: tool.color, size: 18),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: tool.color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tool.duration,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: tool.color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                tool.title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                tool.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
