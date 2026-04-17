import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme.dart';

class DailyReflectionScreen extends StatefulWidget {
  const DailyReflectionScreen({super.key});

  @override
  State<DailyReflectionScreen> createState() => _DailyReflectionScreenState();
}

class _DailyReflectionScreenState extends State<DailyReflectionScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  bool _isSaved = false;
  bool _hasText = false;

  final List<String> _prompts = [
    "What went well for you today?",
    "How are you feeling right now — really?",
    "What challenged you today, and what did you learn?",
    "Who or what are you grateful for today?",
    "What moment made you smile or pause today?",
    "If you could change one thing about today, what would it be?",
    "What do you need most right now — rest, support, or reflection?",
  ];

  late String _selectedPrompt;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  int _promptIndex = 0;

  @override
  void initState() {
    super.initState();
    _prompts.shuffle();
    _selectedPrompt = _prompts[_promptIndex];
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _nextPrompt() {
    setState(() {
      _promptIndex = (_promptIndex + 1) % _prompts.length;
      _selectedPrompt = _prompts[_promptIndex];
    });
  }

  Future<void> _saveReflection() async {
    final prefs = await SharedPreferences.getInstance();
    final reflections = prefs.getStringList('daily_reflections') ?? [];

    final entry = {
      'timestamp': DateTime.now().toIso8601String(),
      'prompt': _selectedPrompt,
      'note': _controller.text.trim(),
    };

    reflections.add(jsonEncode(entry));
    await prefs.setStringList('daily_reflections', reflections);

    setState(() => _isSaved = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      appBar: AppBar(title: const Text('Daily Reflection')),
      body: AnimatedBuilder(
        animation: _fadeAnim,
        builder: (context, child) => Opacity(opacity: _fadeAnim.value, child: child),
        child: _isSaved ? _buildSuccessView() : _buildReflectionView(),
      ),
    );
  }

  Widget _buildReflectionView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryMid],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.18),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.self_improvement_rounded, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Take a mindful moment to reflect on your day",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Prompt heading + refresh button
          Row(
            children: [
              const Text(
                "Reflection Prompt",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
              const Spacer(),
              Semantics(
                button: true,
                label: 'New prompt',
                child: InkWell(
                  onTap: _nextPrompt,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Row(
                      children: [
                        Icon(Icons.refresh_rounded,
                            size: 16, color: AppTheme.primary),
                        const SizedBox(width: 4),
                        const Text(
                          "New prompt",
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Prompt card
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
            child: Container(
              key: ValueKey(_promptIndex),
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primarySurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Text(
                _selectedPrompt,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppTheme.textDark,
                  height: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Text input
          const Text(
            "Your Reflection",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            maxLines: 8,
            minLines: 5,
            textInputAction: TextInputAction.newline,
            style: const TextStyle(
              fontSize: 15,
              color: AppTheme.textDark,
              height: 1.55,
            ),
            decoration: const InputDecoration(
              hintText: "Write your thoughts here...",
              contentPadding: EdgeInsets.all(20),
            ),
          ),
          const SizedBox(height: 28),

          // Save button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _hasText ? _saveReflection : null,
              child: const Text('Save Reflection'),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 500),
              scale: _isSaved ? 1.0 : 0.8,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppTheme.primary,
                  size: 52,
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              "Reflection Saved",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "You took a mindful step today.\nKeep showing up for yourself.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.textBody,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                setState(() {
                  _isSaved = false;
                  _hasText = false;
                  _controller.clear();
                  _nextPrompt();
                });
              },
              child: const Text('Reflect Again'),
            ),
          ],
        ),
      ),
    );
  }
}
