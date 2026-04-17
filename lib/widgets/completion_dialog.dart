import 'dart:math';
import 'package:flutter/material.dart';

class CompletionDialog {
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    String primaryLabel = 'Finish',
    String secondaryLabel = 'Practice More',
    VoidCallback? onPrimary,
    VoidCallback? onSecondary,
    IconData icon = Icons.celebration_rounded,
    Color color = const Color(0xFF0D896C),
  }) {
    final random = Random();

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Completion Dialog',
      barrierColor: Colors.black.withValues(alpha:0.25),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, _, __) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        final fade = CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic);
        final scale = Tween<double>(begin: 0.95, end: 1.0).animate(
          CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
        );

        return FadeTransition(
          opacity: fade,
          child: ScaleTransition(
            scale: scale,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Confetti background layer
                  IgnorePointer(
                    child: AnimatedOpacity(
                      opacity: anim1.value > 0.7 ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 800),
                      child: CustomPaint(
                        size: const Size(240, 240),
                        painter: _ConfettiPainter(random, color),
                      ),
                    ),
                  ),

                  // Dialog content
                  Dialog(
                    backgroundColor: Colors.white,
                    elevation: 6,
                    insetPadding:
                        const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha:0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, color: color, size: 36),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black54,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    if (onSecondary != null) onSecondary();
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: color),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                  ),
                                  child: Text(
                                    secondaryLabel,
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    if (onPrimary != null) onPrimary();
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: color,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                  ),
                                  child: const Text(
                                    'Finish',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Subtle confetti painter (soft, floating circles)
class _ConfettiPainter extends CustomPainter {
  final Random random;
  final Color mainColor;
  final List<Color> _palette;

  _ConfettiPainter(this.random, this.mainColor)
      : _palette = [
          mainColor,
          const Color(0xFF4FE2B5),
          const Color(0xFF11A985),
          const Color(0xFFB2F0E6),
        ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (int i = 0; i < 20; i++) {
      paint.color = _palette[random.nextInt(_palette.length)].withValues(alpha:0.4);
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 4 + 2;
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => false;
}
