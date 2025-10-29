import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../app/consent_state.dart';

// Screens
import '../features/onboarding/splash_screen.dart';
import '../features/onboarding/welcome_screen.dart';
import '../features/onboarding/age_gate_screen.dart';
import '../features/onboarding/consent_screen.dart';
import '../features/avatar/avatar_screen.dart';
import '../features/home/home_screen.dart';
import '../features/mood/mood_checkin_screen.dart';
import '../features/mood/mood_history_screen.dart'; // ✅ make sure this is imported
import '../features/chat/ai_reflection_chat_screen.dart';
import '../features/summary/session_summary_screen.dart';
import '../features/crisis/crisis_support_screen.dart';
import '../features/feedback/feedback_screen.dart';
import '../features/settings/settings_screen.dart';

GoRouter buildRouter(ConsentState consent) => GoRouter(
      debugLogDiagnostics: false,
      initialLocation: '/welcome',
      refreshListenable: consent,
      routes: [
        GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
        GoRoute(path: '/welcome', builder: (_, __) => const WelcomeScreen()),
        GoRoute(path: '/age', builder: (_, __) => const AgeGateScreen()),
        GoRoute(path: '/consent', builder: (_, __) => const ConsentScreen()),
        GoRoute(path: '/avatar', builder: (_, __) => const AvatarScreen()),
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/mood', builder: (_, __) => const MoodCheckInScreen()),
        GoRoute(path: '/history', builder: (_, __) => const MoodHistoryScreen()), // ✅ this must exist
        GoRoute(path: '/chat', builder: (_, __) => const AIReflectionChatScreen()),
        GoRoute(path: '/summary', builder: (_, __) => const SessionSummaryScreen()),
        GoRoute(path: '/feedback', builder: (_, __) => const FeedbackScreen()),
        GoRoute(path: '/crisis', builder: (_, __) => const CrisisSupportScreen()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      ],

      redirect: (ctx, state) {
        final appState = ctx.read<ConsentState>();
        final accepted = appState.accepted;
        final avatar = appState.selectedAvatar;

        final onboarding = {
          '/splash', '/welcome', '/age', '/consent', '/avatar'
        }.contains(state.uri.path);

        // Case 1: No consent yet → stay in onboarding
        if (!accepted && !onboarding) return '/welcome';

        // Case 2: Consent done but no avatar yet → go to Avatar
        if (accepted && avatar == null && state.uri.path != '/avatar') {
          return '/avatar';
        }

        // Case 3: All onboarding done → skip onboarding
        if (accepted && avatar != null && onboarding) return '/home';

        return null;
      },
    );
