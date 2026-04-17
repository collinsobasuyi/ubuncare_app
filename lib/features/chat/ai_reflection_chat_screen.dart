import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme.dart';

class AIReflectionChatScreen extends StatefulWidget {
  const AIReflectionChatScreen({super.key});

  @override
  State<AIReflectionChatScreen> createState() => _AIReflectionChatScreenState();
}

class _AIReflectionChatScreenState extends State<AIReflectionChatScreen> {
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<_ChatMessage> _messages = [];
  Map<String, dynamic>? _latestMood;
  bool _aiTyping = false;

  @override
  void initState() {
    super.initState();
    _loadAndStart();
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAndStart() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('mood_history') ?? [];

    if (history.isNotEmpty) {
      final last = jsonDecode(history.last) as Map<String, dynamic>;
      if (mounted) setState(() => _latestMood = last);
    }

    final greeting = _personalizedGreeting(_latestMood);
    if (mounted) {
      setState(() => _messages.add(_ChatMessage(isAI: true, text: greeting)));
    }
  }

  String _personalizedGreeting(Map<String, dynamic>? mood) {
    if (mood == null) {
      return "Hey there 👋\nI'm here to chat and help you reflect on how you're feeling today.";
    }
    final score    = (mood['mood_score'] ?? 5.0) as double;
    final emotions = List<String>.from(mood['emotions'] ?? []);
    final energy   = (mood['energy_level'] ?? 5.0) as double;

    if (score <= 3) {
      return "Hey there 👋\nI noticed your last check-in showed you were feeling quite low.\nWould you like to talk about what's been hardest lately?";
    } else if (emotions.contains('Anxious')) {
      return "Welcome back 💬\nYou mentioned feeling anxious last time — how have things been since then?";
    } else if (energy <= 4) {
      return "Hi again 🌱\nYou seemed a bit drained in your last check-in.\nHave you had any time to rest or recharge?";
    } else if (score >= 8) {
      return "Hey there ☀️\nYour last check-in looked really positive! What's been helping you feel good lately?";
    } else {
      return "Welcome back 👋\nI saw your last reflection was balanced — how are you feeling compared to that?";
    }
  }

  void _sendMessage() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(isAI: false, text: text));
      _inputCtrl.clear();
      _aiTyping = true;
    });
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _aiTyping = false;
        _messages.add(_ChatMessage(isAI: true, text: _generateResponse(text)));
      });
      _scrollToBottom();
    });
  }

  String _generateResponse(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('tired') || lower.contains('drained') || lower.contains('exhausted')) {
      return "It sounds like your energy is running low 💭\nWould a short breathing break or a gentle stretch help right now?";
    } else if (lower.contains('good') || lower.contains('happy') || lower.contains('great')) {
      return "That's really good to hear! 🌼\nWhat's been bringing you that joy?";
    } else if (lower.contains('sad') || lower.contains('lonely') || lower.contains('down')) {
      return "I'm sorry to hear that 💙\nWould it help to talk about what triggered this, or would you prefer a self-care activity?";
    } else if (lower.contains('anxious') || lower.contains('stress') || lower.contains('worry')) {
      return "I hear you — anxiety can feel really heavy 😔\nWould you like me to walk you through a 3-minute grounding exercise?";
    } else if (lower.contains('angry') || lower.contains('frustrated')) {
      return "Those feelings make sense 🌊\nWhen you're ready, try taking three slow breaths. What's been building up?";
    } else {
      return "Thank you for sharing that with me 🙏\nHow do you usually take care of yourself when you feel this way?";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      appBar: AppBar(title: const Text('Reflection Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_aiTyping ? 1 : 0),
              itemBuilder: (context, i) {
                if (_aiTyping && i == _messages.length) {
                  return _buildTypingIndicator();
                }
                return _buildBubble(_messages[i]);
              },
            ),
          ),
          const Divider(height: 1),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildBubble(_ChatMessage msg) {
    return Padding(
      padding: EdgeInsets.only(
        top: 6, bottom: 6,
        left: msg.isAI ? 0 : 56,
        right: msg.isAI ? 56 : 0,
      ),
      child: Align(
        alignment: msg.isAI ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: msg.isAI ? AppTheme.bgSurface : AppTheme.primary,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(msg.isAI ? 4 : 16),
              bottomRight: Radius.circular(msg.isAI ? 16 : 4),
            ),
            border: msg.isAI
                ? Border.all(color: AppTheme.bgBorder)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            msg.text,
            style: AppTheme.bodyMd.copyWith(
              color: msg.isAI ? AppTheme.textDark : Colors.white,
              height: 1.45,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.bgSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.bgBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) => Padding(
              padding: EdgeInsets.only(left: i > 0 ? 4 : 0),
              child: _TypingDot(delay: Duration(milliseconds: i * 160)),
            )),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputCtrl,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
                decoration: const InputDecoration(
                  hintText: 'Type your reflection…',
                ),
              ),
            ),
            const SizedBox(width: 10),
            FilledButton(
              style: FilledButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(14),
                minimumSize: Size.zero,
              ),
              onPressed: _sendMessage,
              child: const Icon(Icons.send_rounded, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingDot extends StatefulWidget {
  final Duration delay;
  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
    _anim = Tween(begin: 0.0, end: -5.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _anim.value),
        child: Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: AppTheme.textMuted,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _ChatMessage {
  final bool isAI;
  final String text;
  const _ChatMessage({required this.isAI, required this.text});
}
