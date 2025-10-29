import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/consent_state.dart';

class AvatarScreen extends StatefulWidget {
  const AvatarScreen({super.key});

  @override
  State<AvatarScreen> createState() => _AvatarScreenState();
}

class _AvatarScreenState extends State<AvatarScreen> {
  String? _selectedAvatar;

  final List<Map<String, String>> _avatars = [
    {'name': 'Amani', 'emoji': '🌿', 'desc': 'Grounded and calming'},
    {'name': 'Kora', 'emoji': '🔥', 'desc': 'Warm and encouraging'},
    {'name': 'Nova', 'emoji': '🌙', 'desc': 'Reflective and insightful'},
    {'name': 'Zuri', 'emoji': '💫', 'desc': 'Gentle and uplifting'},
  ];

  @override
  void initState() {
    super.initState();
    // Load previous avatar if any
    final saved = context.read<ConsentState>().selectedAvatar;
    if (saved != null) _selectedAvatar = saved;
  }

  Future<void> _saveAvatarAndContinue(BuildContext context) async {
    final state = context.read<ConsentState>();
    await state.selectAvatar(_selectedAvatar!);
    if (context.mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF0D896C);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => context.go('/consent'),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: primaryTeal, size: 18),
                  label: const Text(
                    'Back',
                    style: TextStyle(
                        color: primaryTeal,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Logo icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF0D896C),
                      Color(0xFF11A985),
                      Color(0xFF4FE2B5),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryTeal.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.psychology_alt_rounded,
                  color: Colors.white,
                  size: 44,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Choose Your Guide',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryTeal,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Pick an avatar that feels right for you.\nEach brings a gentle tone and energy.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 32),

              // Avatar Grid
              GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 1.1,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: _avatars.map((avatar) {
                  final isSelected = _selectedAvatar == avatar['name'];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedAvatar = avatar['name']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [
                                  Color(0xFF0D896C),
                                  Color(0xFF11A985),
                                  Color(0xFF4FE2B5),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : const LinearGradient(
                                colors: [Colors.white, Color(0xFFF6F6F6)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        border: Border.all(
                          color:
                              isSelected ? primaryTeal : Colors.grey.shade300,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(avatar['emoji']!,
                                style: const TextStyle(fontSize: 40)),
                            const SizedBox(height: 8),
                            Text(
                              avatar['name']!,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              avatar['desc']!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color:
                                    isSelected ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _selectedAvatar != null
                        ? primaryTeal
                        : primaryTeal.withOpacity(0.4),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  onPressed: _selectedAvatar != null
                      ? () => _saveAvatarAndContinue(context)
                      : null,
                  child: const Text('Continue'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
