import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MoodCheckInScreen extends StatefulWidget {
  const MoodCheckInScreen({super.key});

  @override
  State<MoodCheckInScreen> createState() => _MoodCheckInScreenState();
}

class _MoodCheckInScreenState extends State<MoodCheckInScreen>
    with SingleTickerProviderStateMixin {
  int _step = 0;
  double _moodValue = 5;
  double _energyValue = 5;
  List<String> _selectedEmotions = [];
  List<String> _selectedInfluences = [];
  final TextEditingController _noteController = TextEditingController();
  bool _isSubmitting = false;

  final List<Emotion> emotions = [
    Emotion('Calm', '😌', const Color(0xFF4FC3F7)),
    Emotion('Happy', '😊', const Color(0xFFFFD54F)),
    Emotion('Sad', '😔', const Color(0xFF64B5F6)),
    Emotion('Anxious', '😰', const Color(0xFFE57373)),
    Emotion('Tired', '😴', const Color(0xFF9575CD)),
    Emotion('Excited', '🎉', const Color(0xFF4DB6AC)),
    Emotion('Frustrated', '😤', const Color(0xFFFF8A65)),
    Emotion('Grateful', '🙏', const Color(0xFF81C784)),
    Emotion('Confused', '😕', const Color(0xFFBA68C8)),
    Emotion('Proud', '🦁', const Color(0xFFFFB74D)),
  ];

  final List<Influence> influences = [
    Influence('Work', '💼', Icons.work_rounded),
    Influence('Health', '🏥', Icons.favorite_rounded),
    Influence('Family', '👨‍👩‍👧‍👦', Icons.family_restroom_rounded),
    Influence('Friends', '👯', Icons.people_rounded),
    Influence('Sleep', '😴', Icons.nightlight_rounded),
    Influence('Weather', '☀️', Icons.wb_sunny_rounded),
    Influence('Money', '💰', Icons.attach_money_rounded),
    Influence('Social Media', '📱', Icons.phone_iphone_rounded),
    Influence('Exercise', '🏃', Icons.directions_run_rounded),
    Influence('Food', '🍎', Icons.restaurant_rounded),
  ];

  // SINGLE AnimationController for the entire screen
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Step titles and descriptions
  final List<StepInfo> _stepInfo = [
    StepInfo('How are you feeling?', 'Rate your current mood'),
    StepInfo('Emotional landscape', 'Select up to 3 primary emotions'),
    StepInfo('Mood influences', 'What might be affecting you?'),
    StepInfo('Energy check', 'How energized do you feel?'),
    StepInfo('Final thoughts', 'Add any notes (optional)'),
  ];

  @override
  void initState() {
    super.initState();
    
    // Create only ONE AnimationController
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.5, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _startAnimations();
  }

  void _startAnimations() {
    _animationController.forward();
  }

  void _nextStep() {
    if (_step < 4) {
      setState(() {
        _animationController.reverse().then((_) {
          setState(() {
            _step++;
          });
          _animationController.forward();
        });
      });
    } else {
      _saveMoodEntry();
    }
  }

  void _prevStep() {
    if (_step > 0) {
      setState(() {
        _animationController.reverse().then((_) {
          setState(() {
            _step--;
          });
          _animationController.forward();
        });
      });
    }
  }

  Future<void> _saveMoodEntry() async {
    setState(() => _isSubmitting = true);
    
    await Future.delayed(const Duration(milliseconds: 800));
    
    final prefs = await SharedPreferences.getInstance();
    final moodData = {
      'timestamp': DateTime.now().toIso8601String(),
      'mood_score': _moodValue,
      'emotions': _selectedEmotions,
      'influences': _selectedInfluences,
      'energy_level': _energyValue,
      'note': _noteController.text.trim(),
    };

    final List<String> existing = prefs.getStringList('mood_history') ?? [];
    existing.add(jsonEncode(moodData));
    await prefs.setStringList('mood_history', existing);

    if (!mounted) return;
    
    _showSuccessAnimation();
  }

  void _showSuccessAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _SuccessDialog(),
    );
    
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context).pop();
        context.go('/history');
      }
    });
  }

  @override
  void dispose() {
    // Dispose only ONE controller
    _animationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF0D896C);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D896C), Color(0xFF11A985), Color(0xFF4FE2B5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Enhanced Header with Progress
              _buildEnhancedHeader(primaryTeal),
              
              // Animated content
              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 25,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: _buildCurrentStep(),
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

  Widget _buildEnhancedHeader(Color primaryTeal) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  _step > 0 ? Icons.arrow_back_ios_new_rounded : Icons.close_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: _step > 0 ? _prevStep : () => context.go('/home'),
              ),
              _buildProgressIndicator(),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _stepInfo[_step].title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            _stepInfo[_step].description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == _step ? 24 : 8,
          height: 4,
          decoration: BoxDecoration(
            color: index <= _step ? Colors.white : Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0: return _buildMoodStep();
      case 1: return _buildEmotionStep();
      case 2: return _buildInfluenceStep();
      case 3: return _buildEnergyStep();
      case 4: return _buildNoteStep();
      default: return const SizedBox();
    }
  }

  // STEP 1 - Mood
  Widget _buildMoodStep() {
    final moodConfig = _getMoodConfig(_moodValue);
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: moodConfig.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                moodConfig.emoji,
                style: const TextStyle(fontSize: 64),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              moodConfig.label,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              moodConfig.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
          ],
        ),
        
        Column(
          children: [
            Slider(
              min: 0,
              max: 10,
              divisions: 10,
              value: _moodValue,
              activeColor: moodConfig.color,
              inactiveColor: Colors.grey.shade300,
              onChanged: (v) => setState(() => _moodValue = v),
            ),
            const SizedBox(height: 24),
            _buildNextButton(),
          ],
        ),
      ],
    );
  }

  // STEP 2 - Emotions
  Widget _buildEmotionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select up to 3 emotions",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "${_selectedEmotions.length}/3 selected",
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF0D896C),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 24),
        
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
            ),
            itemCount: emotions.length,
            itemBuilder: (context, index) {
              final emotion = emotions[index];
              final isSelected = _selectedEmotions.contains(emotion.name);
              final isDisabled = _selectedEmotions.length >= 3 && !isSelected;
              
              return _EmotionChip(
                emotion: emotion,
                isSelected: isSelected,
                isDisabled: isDisabled,
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedEmotions.remove(emotion.name);
                    } else if (_selectedEmotions.length < 3) {
                      _selectedEmotions.add(emotion.name);
                    }
                  });
                },
              );
            },
          ),
        ),
        
        const SizedBox(height: 16),
        _buildNextButton(),
      ],
    );
  }

  // STEP 3 - Influences
  Widget _buildInfluenceStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "What's affecting your mood today?",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 24),
        
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.2,
            ),
            itemCount: influences.length,
            itemBuilder: (context, index) {
              final influence = influences[index];
              final isSelected = _selectedInfluences.contains(influence.name);
              
              return _InfluenceChip(
                influence: influence,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedInfluences.remove(influence.name);
                    } else {
                      _selectedInfluences.add(influence.name);
                    }
                  });
                },
              );
            },
          ),
        ),
        
        const SizedBox(height: 16),
        _buildNextButton(),
      ],
    );
  }

  // STEP 4 - Energy
  Widget _buildEnergyStep() {
    final energyConfig = _getEnergyConfig(_energyValue);
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: energyConfig.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                energyConfig.icon,
                size: 64,
                color: energyConfig.color,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              energyConfig.label,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              energyConfig.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
          ],
        ),
        
        Column(
          children: [
            Slider(
              min: 0,
              max: 10,
              divisions: 10,
              value: _energyValue,
              activeColor: energyConfig.color,
              inactiveColor: Colors.grey.shade300,
              onChanged: (v) => setState(() => _energyValue = v),
            ),
            const SizedBox(height: 24),
            _buildNextButton(),
          ],
        ),
      ],
    );
  }

  // STEP 5 - Notes
  Widget _buildNoteStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Any thoughts you'd like to remember?",
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "This is just for you - write as much or as little as you like",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 24),
        
        Expanded(
          child: TextField(
            controller: _noteController,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            decoration: InputDecoration(
              hintText: "Today I felt...\nWhat helped...\nI noticed...",
              hintStyle: TextStyle(color: Colors.grey[500]),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildNextButton() {
    bool isEnabled = true;
    
    if (_step == 1 && _selectedEmotions.isEmpty) isEnabled = false;
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: isEnabled ? const Color(0xFF0D896C) : Colors.grey[400],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        onPressed: isEnabled ? _nextStep : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _step == 4 ? 'Complete Reflection' : 'Continue',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_step < 4) ...[
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, size: 20),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF0D896C),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        onPressed: _isSubmitting ? null : _saveMoodEntry,
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_rounded, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Save Reflection',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // Helper methods for mood and energy configurations
  MoodConfig _getMoodConfig(double value) {
    if (value <= 2) return MoodConfig('😞', 'Very Low', 'Feeling really down', Colors.red);
    if (value <= 4) return MoodConfig('😕', 'Low', 'A bit off today', Colors.orange);
    if (value <= 6) return MoodConfig('😐', 'Neutral', 'Steady and balanced', Colors.blueGrey);
    if (value <= 8) return MoodConfig('🙂', 'Good', 'Feeling positive', Colors.lightGreen);
    return MoodConfig('😄', 'Great', 'Wonderful and uplifted', Colors.green);
  }

  EnergyConfig _getEnergyConfig(double value) {
    if (value <= 2) return EnergyConfig(Icons.battery_0_bar_rounded, 'Drained', 'Completely exhausted', Colors.red);
    if (value <= 4) return EnergyConfig(Icons.battery_2_bar_rounded, 'Low', 'Feeling tired', Colors.orange);
    if (value <= 6) return EnergyConfig(Icons.battery_4_bar_rounded, 'Moderate', 'Steady energy', Colors.blueGrey);
    if (value <= 8) return EnergyConfig(Icons.battery_6_bar_rounded, 'Good', 'Feeling energized', Colors.lightGreen);
    return EnergyConfig(Icons.battery_full_rounded, 'High', 'Full of energy!', Colors.green);
  }
}

// Data Models (keep the same)
class Emotion {
  final String name;
  final String emoji;
  final Color color;

  const Emotion(this.name, this.emoji, this.color);
}

class Influence {
  final String name;
  final String emoji;
  final IconData icon;

  const Influence(this.name, this.emoji, this.icon);
}

class StepInfo {
  final String title;
  final String description;

  const StepInfo(this.title, this.description);
}

class MoodConfig {
  final String emoji;
  final String label;
  final String description;
  final Color color;

  const MoodConfig(this.emoji, this.label, this.description, this.color);
}

class EnergyConfig {
  final IconData icon;
  final String label;
  final String description;
  final Color color;

  const EnergyConfig(this.icon, this.label, this.description, this.color);
}

// Custom Emotion Chip Widget (keep the same)
class _EmotionChip extends StatelessWidget {
  final Emotion emotion;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  const _EmotionChip({
    required this.emotion,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isSelected ? emotion.color.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? emotion.color : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isDisabled ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(
                  emotion.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    emotion.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDisabled ? Colors.grey[400] : Colors.black87,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: emotion.color,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Influence Chip Widget (keep the same)
class _InfluenceChip extends StatelessWidget {
  final Influence influence;
  final bool isSelected;
  final VoidCallback onTap;

  const _InfluenceChip({
    required this.influence,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF0D896C).withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF0D896C) : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(
                  influence.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    influence.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF0D896C),
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Success Dialog (keep the same)
class _SuccessDialog extends StatelessWidget {
  const _SuccessDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0D896C).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Color(0xFF0D896C),
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Reflection Saved!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your mood check-in has been recorded',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}