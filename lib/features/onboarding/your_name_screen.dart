import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../app/consent_state.dart';
import '../../app/theme.dart';

class YourNameScreen extends StatefulWidget {
  const YourNameScreen({super.key});

  @override
  State<YourNameScreen> createState() => _YourNameScreenState();
}

class _YourNameScreenState extends State<YourNameScreen>
    with SingleTickerProviderStateMixin {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();

  late final AnimationController _animCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fade  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool get _fromSettings =>
      GoRouterState.of(context).uri.queryParameters['from'] == 'settings';

  Future<void> _continue() async {
    final name = _ctrl.text.trim();
    if (name.isNotEmpty) {
      await context.read<ConsentState>().setUserName(name);
    }
    if (!mounted) return;
    context.go(_fromSettings ? '/settings' : '/consent');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Column(
              children: [
                // ── Scrollable content ──────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Back
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () => context.go(
                                _fromSettings ? '/settings' : '/feature_tour'),
                            icon: const Icon(
                                Icons.arrow_back_ios_new_rounded, size: 16),
                            label: const Text('Back'),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Icon
                        Container(
                          width: 90,
                          height: 90,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppTheme.primaryGradient,
                          ),
                          child: const Icon(
                            Icons.waving_hand_rounded,
                            color: Colors.white,
                            size: 44,
                            semanticLabel: 'Hello, welcome to Ubuncare',
                          ),
                        ),

                        const SizedBox(height: 28),

                        Text(
                          'What should we call you?',
                          textAlign: TextAlign.center,
                          style: AppTheme.headingMd,
                        ),

                        const SizedBox(height: 10),

                        Text(
                          'Your first name helps us make your\nexperience feel a little more personal.',
                          textAlign: TextAlign.center,
                          style: AppTheme.bodyMd,
                        ),

                        const SizedBox(height: 36),

                        // Name field
                        TextField(
                          controller: _ctrl,
                          focusNode: _focus,
                          autofocus: false,
                          textCapitalization: TextCapitalization.words,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _continue(),
                          style: AppTheme.headingSm
                              .copyWith(color: AppTheme.textDark),
                          decoration: InputDecoration(
                            hintText: 'e.g. Alex',
                            prefixIcon: const Icon(
                                Icons.person_outline_rounded,
                                color: AppTheme.primary),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 18),
                          ),
                        ),

                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),

                // ── Pinned CTA ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: _continue,
                          icon: const Icon(Icons.arrow_forward_rounded,
                              size: 20),
                          label: const Text('Continue'),
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextButton(
                        onPressed: () => context.go(
                            _fromSettings ? '/settings' : '/consent'),
                        style: TextButton.styleFrom(
                          minimumSize: const Size(88, 44),
                        ),
                        child: const Text('Skip for now'),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Your name is stored only on your device.',
                        textAlign: TextAlign.center,
                        style: AppTheme.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
