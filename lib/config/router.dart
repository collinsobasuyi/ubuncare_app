import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../app/consent_state.dart';

import '../features/mood/mood_reflection_summary_screen.dart';
import '../features/onboarding/splash_screen.dart';
import '../features/onboarding/welcome_screen.dart';
import '../features/onboarding/age_gate_screen.dart';
import '../features/onboarding/feature_tour_screen.dart';
import '../features/onboarding/your_name_screen.dart';
import '../features/onboarding/consent_screen.dart';
import '../features/avatar/avatar_screen.dart';
import '../features/mood/mood_checkin_screen.dart';
import '../features/mood/chat_mood_check_in_screen.dart';
import '../features/mood/mood_history_screen.dart';
import '../features/summary/session_summary_screen.dart';
import '../widgets/app_shell.dart';
import '../features/crisis/crisis_support_screen.dart';
import '../features/feedback/feedback_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/legal/terms_screen.dart';
import '../features/legal/privacy_screen.dart';
import '../features/wellness/body_scan_screen.dart';
import '../features/wellness/breathing_exercise_screen.dart';
import '../features/wellness/emergency_calm_screen.dart';
import '../features/wellness/five_four_three_two_one_screen.dart';
import '../features/wellness/gratitude_journal_screen.dart';
import '../features/wellness/planning_tools_screen.dart';
import '../features/wellness/quick_calm_screen.dart';
import '../features/wellness/self_care_screen.dart';
import '../features/wellness/wellness_hub_screen.dart';

GoRouter buildRouter(ConsentState consent) => GoRouter(
      debugLogDiagnostics: false,
      initialLocation: '/splash',
      refreshListenable: consent,

      routes: [
        // ── Onboarding ──────────────────────────────────────────────────────
        GoRoute(path: '/splash',        builder: (_, __) => const SplashScreen()),
        GoRoute(path: '/welcome',       builder: (_, __) => const WelcomeScreen()),
        GoRoute(path: '/age',           builder: (_, __) => const AgeGateScreen()),
        GoRoute(path: '/feature_tour',  builder: (_, __) => const FeatureTourScreen()),
        GoRoute(path: '/your_name',     builder: (_, __) => const YourNameScreen()),
        GoRoute(path: '/consent',       builder: (_, __) => const ConsentScreen()),
        GoRoute(path: '/avatar',        builder: (_, __) => const AvatarScreen()),

        // ── Core ────────────────────────────────────────────────────────────
        GoRoute(path: '/home',     builder: (_, __) => const AppShell()),
        GoRoute(path: '/summary',  builder: (_, __) => const SessionSummaryScreen()),
        GoRoute(path: '/feedback', builder: (_, __) => const FeedbackScreen()),
        GoRoute(path: '/crisis',   builder: (_, __) => const CrisisSupportScreen()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
        GoRoute(path: '/terms',    builder: (_, __) => const TermsScreen()),
        GoRoute(path: '/privacy',  builder: (_, __) => const PrivacyScreen()),

        // ── Mood check-in (canonical: /chatmood; /mood is the detailed flow) ─
        GoRoute(path: '/chatmood',  builder: (_, __) => const ChatMoodCheckInScreen()),
        GoRoute(path: '/mood',      builder: (_, __) => const MoodCheckInScreen()),
        GoRoute(path: '/history',   builder: (_, __) => const MoodHistoryScreen()),

        GoRoute(
          path: '/reflection_summary',
          builder: (_, state) =>
              MoodReflectionSummaryScreen(entry: state.extra as Map<String, dynamic>),
        ),

        // ── Wellness hub ────────────────────────────────────────────────────
        GoRoute(path: '/wellness',           builder: (_, __) => const WellnessHubScreen()),
        GoRoute(path: '/breathing_exercise', builder: (_, __) => const BreathingExerciseScreen()),
        GoRoute(path: '/gratitude',          builder: (_, __) => const GratitudeJournalScreen()),
        GoRoute(path: '/planning_tools',     builder: (_, __) => const PlanningToolsScreen()),
        GoRoute(path: '/self_care',          builder: (_, __) => const SelfCareIdeasScreen()),
        GoRoute(path: '/body_scan',          builder: (_, __) => const BodyScanScreen()),
        GoRoute(path: '/54321',              builder: (_, __) => const FiveFourThreeTwoOneScreen()),
        GoRoute(path: '/quick_calm',         builder: (_, __) => const QuickCalmScreen()),
        GoRoute(path: '/emergency_calm',     builder: (_, __) => const EmergencyCalmScreen()),
      ],

      redirect: (ctx, state) {
        final consent  = ctx.read<ConsentState>();
        final accepted = consent.accepted;
        final avatar   = consent.selectedAvatar;
        final path     = state.uri.path;

        // Routes always accessible regardless of onboarding state
        final alwaysAccessible = {'/your_name', '/avatar', '/terms', '/privacy'};

        final isOnboarding = {
          '/splash', '/welcome', '/age', '/feature_tour',
          '/your_name', '/consent', '/avatar',
        }.contains(path);

        // No consent yet → stay in onboarding (legal screens always allowed)
        if (!accepted && !isOnboarding && !alwaysAccessible.contains(path)) {
          return '/welcome';
        }

        // Consent done but no avatar → go to avatar picker
        if (accepted && avatar == null && path != '/avatar') {
          return '/avatar';
        }

        // Fully onboarded → skip pure onboarding screens, but allow
        // your_name and avatar so users can edit them from settings
        if (accepted && avatar != null && isOnboarding &&
            !alwaysAccessible.contains(path)) {
          return '/home';
        }

        return null;
      },
    );
