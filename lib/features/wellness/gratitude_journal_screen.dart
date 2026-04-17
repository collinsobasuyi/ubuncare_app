import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme.dart';
import '../../widgets/completion_dialog.dart';

class GratitudeJournalScreen extends StatefulWidget {
  const GratitudeJournalScreen({super.key});

  @override
  State<GratitudeJournalScreen> createState() => _GratitudeJournalScreenState();
}

class _GratitudeJournalScreenState extends State<GratitudeJournalScreen> {
  final List<TextEditingController> _controllers =
      List.generate(3, (_) => TextEditingController());

  static const List<_GratitudePrompt> _prompts = [
    _GratitudePrompt(Icons.wb_sunny_rounded,     'One good thing that happened today'),
    _GratitudePrompt(Icons.favorite_rounded,      'Someone I am thankful for'),
    _GratitudePrompt(Icons.auto_awesome_rounded,  'A small joy I noticed'),
  ];

  List<GratitudeEntry> _pastEntries = [];

  @override
  void initState() {
    super.initState();
    // Rebuild button when any field changes
    for (final c in _controllers) {
      c.addListener(() => setState(() {}));
    }
    _loadPastEntries();
  }

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    super.dispose();
  }

  Future<void> _loadPastEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw   = prefs.getStringList('gratitude_entries') ?? [];
    if (!mounted) return;
    setState(() {
      _pastEntries = raw
          .map((e) => GratitudeEntry.fromJson(jsonDecode(e)))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    });
  }

  int get _filledCount =>
      _controllers.where((c) => c.text.trim().isNotEmpty).length;

  Future<void> _saveEntry() async {
    // Pair each non-empty response with its prompt text
    final pairs = <Map<String, String>>[];
    for (int i = 0; i < _controllers.length; i++) {
      final text = _controllers[i].text.trim();
      if (text.isNotEmpty) {
        pairs.add({'prompt': _prompts[i].text, 'response': text});
      }
    }

    if (pairs.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Write at least 2 things you are grateful for'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final entry = GratitudeEntry(date: DateTime.now(), pairs: pairs);
    final prefs = await SharedPreferences.getInstance();
    final raw   = prefs.getStringList('gratitude_entries') ?? [];
    raw.add(jsonEncode(entry.toJson()));
    await prefs.setStringList('gratitude_entries', raw);

    setState(() {
      _pastEntries.insert(0, entry);
      for (final c in _controllers) { c.clear(); }
    });

    if (!mounted) return;
    CompletionDialog.show(
      context: context,
      title: 'Gratitude Saved',
      message: 'You paused to notice what is good.\nThat awareness strengthens calm and joy.',
      color: AppTheme.primary,
      icon: Icons.self_improvement_rounded,
      primaryLabel: 'Close',
      secondaryLabel: 'View Past Entries',
      onPrimary: () => Navigator.pop(context),
      onSecondary: _showPastEntries,
    );
  }

  void _showPastEntries() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PastEntriesSheet(entries: _pastEntries),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _filledCount >= 2;

    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      appBar: AppBar(
        title: const Text('Gratitude Journal'),
        actions: [
          if (_pastEntries.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.history_rounded),
              tooltip: 'Past entries',
              onPressed: _showPastEntries,
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
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
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.self_improvement_rounded,
                        color: Colors.white, size: 28),
                    const SizedBox(height: 8),
                    const Text(
                      'Gratitude Reflection',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Appreciation rewires the mind — it brings peace, presence, and perspective.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Prompt cards
              Expanded(
                child: ListView.builder(
                  itemCount: _prompts.length,
                  itemBuilder: (_, i) => _PromptCard(
                    prompt: _prompts[i],
                    controller: _controllers[i],
                    index: i + 1,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: canSave ? _saveEntry : null,
                  icon: const Icon(Icons.favorite_rounded),
                  label: const Text('Save Reflection'),
                ),
              ),

              // View past entries — prominent CTA
              if (_pastEntries.isNotEmpty) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _showPastEntries,
                    icon: const Icon(Icons.history_rounded),
                    label: Text(
                      'View ${_pastEntries.length} past ${_pastEntries.length == 1 ? 'entry' : 'entries'}',
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Prompt card
// ─────────────────────────────────────────────────────────────────────────────

class _PromptCard extends StatelessWidget {
  final _GratitudePrompt      prompt;
  final TextEditingController controller;
  final int                   index;

  const _PromptCard({
    required this.prompt,
    required this.controller,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.bgBorder),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(prompt.icon, color: AppTheme.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  prompt.text,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLines: 3,
            minLines: 2,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textDark,
              height: 1.5,
            ),
            decoration: const InputDecoration(
              hintText: 'Write your thoughts...',
              contentPadding: EdgeInsets.all(14),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Past entries bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _PastEntriesSheet extends StatelessWidget {
  final List<GratitudeEntry> entries;
  const _PastEntriesSheet({required this.entries});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.bgPage,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      height: MediaQuery.of(context).size.height * 0.82,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle + header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.bgBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppTheme.primarySurface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.auto_awesome_rounded,
                          color: AppTheme.primary, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Gratitude Journey',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Text(
                          '${entries.length} ${entries.length == 1 ? 'entry' : 'entries'} saved',
                          style: const TextStyle(
                              fontSize: 13, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: AppTheme.bgBorder, height: 1),
              ],
            ),
          ),

          // List
          Expanded(
            child: entries.isEmpty
                ? const Center(
                    child: Text(
                      'No entries yet.\nStart journaling today.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: AppTheme.textMuted),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    itemCount: entries.length,
                    itemBuilder: (_, i) => _EntryCard(entry: entries[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  final GratitudeEntry entry;
  const _EntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.bgBorder),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppTheme.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.calendar_today_rounded,
                    color: AppTheme.primary, size: 14),
              ),
              const SizedBox(width: 8),
              Text(
                _formatDate(entry.date),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppTheme.bgBorder, height: 1),
          const SizedBox(height: 12),

          // Question + answer pairs
          ...entry.pairs.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question
                    Text(
                      e.value['prompt'] ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Answer
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.bgPage,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.bgBorder),
                      ),
                      child: Text(
                        e.value['response'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textDark,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day   = DateTime(d.year, d.month, d.day);
    if (day == today) return 'Today';
    if (day == today.subtract(const Duration(days: 1))) return 'Yesterday';
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data models
// ─────────────────────────────────────────────────────────────────────────────

class _GratitudePrompt {
  final IconData icon;
  final String   text;
  const _GratitudePrompt(this.icon, this.text);
}

class GratitudeEntry {
  final DateTime                date;
  final List<Map<String, String>> pairs; // [{prompt, response}, ...]

  GratitudeEntry({required this.date, required this.pairs});

  Map<String, dynamic> toJson() => {
    'date':  date.toIso8601String(),
    'pairs': pairs,
    // Legacy field kept so old read code doesn't break if any exists
    'responses': pairs.map((p) => p['response'] ?? '').toList(),
  };

  factory GratitudeEntry.fromJson(Map<String, dynamic> json) {
    // New format: has 'pairs'
    if (json['pairs'] != null) {
      return GratitudeEntry(
        date:  DateTime.parse(json['date'] as String),
        pairs: (json['pairs'] as List)
            .map((e) => Map<String, String>.from(e as Map))
            .toList(),
      );
    }
    // Legacy format: only 'responses' (no prompt text stored)
    final responses = List<String>.from(json['responses'] ?? []);
    return GratitudeEntry(
      date:  DateTime.parse(json['date'] as String),
      pairs: responses
          .map((r) => <String, String>{'prompt': '', 'response': r})
          .toList(),
    );
  }
}
