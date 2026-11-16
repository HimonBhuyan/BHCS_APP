import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../../data/repositories/agency_store.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/auth/onboarding_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/dashboard/founder_dashboard_screen.dart';
import '../../features/leads/leads_screen.dart';
import '../../features/leads/lead_detail_screen.dart';
import '../../features/chat/chat_screen.dart';
import '../../features/projects/projects_screen.dart';
import '../../features/calendar/meeting_calendar_screen.dart';
import '../../features/notifications/notification_centre_screen.dart';
import '../../features/finance/finance_and_clients_screen.dart';
import '../../features/profile/profile_settings_screen.dart';

CustomTransitionPage<void> _bhSmoothPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 360),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      pageBuilder: (context, state) =>
          _bhSmoothPage(state, const SplashScreen()),
    ),
    GoRoute(
      path: '/onboarding',
      pageBuilder: (context, state) =>
          _bhSmoothPage(state, const OnboardingScreen()),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) =>
          _bhSmoothPage(state, const LoginScreen()),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShellScaffold(navigationShell: navigationShell);
      },
      branches: [
        // 1. Home (Founder Dashboard)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              pageBuilder: (context, state) =>
                  _bhSmoothPage(state, const FounderDashboardScreen()),
            ),
          ],
        ),
        // 2. Leads (CRM)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/leads',
              pageBuilder: (context, state) =>
                  _bhSmoothPage(state, const LeadsScreen()),
              routes: [
                GoRoute(
                  path: ':id',
                  pageBuilder: (context, state) => _bhSmoothPage(
                    state,
                    LeadDetailScreen(
                      leadId: state.pathParameters['id'] ?? 'lead-101',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        // 3. Chat (Internal Real-Time Reverb Chat)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/chat',
              pageBuilder: (context, state) =>
                  _bhSmoothPage(state, const ChatListScreen()),
            ),
          ],
        ),
        // 4. Projects
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/projects',
              pageBuilder: (context, state) =>
                  _bhSmoothPage(state, const ProjectsScreen()),
            ),
          ],
        ),
        // 5. Profile & More Hub
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              pageBuilder: (context, state) =>
                  _bhSmoothPage(state, const ProfileAndSettingsScreen()),
            ),
          ],
        ),
      ],
    ),
    // Secondary / Contextual Operational Routes
    GoRoute(
      path: '/calendar',
      pageBuilder: (context, state) =>
          _bhSmoothPage(state, const MeetingCalendarScreen()),
    ),
    GoRoute(
      path: '/notifications',
      pageBuilder: (context, state) =>
          _bhSmoothPage(state, const NotificationCentreScreen()),
    ),
    GoRoute(
      path: '/finance',
      pageBuilder: (context, state) =>
          _bhSmoothPage(state, const FinanceAndProposalsScreen()),
    ),
    GoRoute(
      path: '/clients',
      pageBuilder: (context, state) =>
          _bhSmoothPage(state, const ClientsScreen()),
    ),
    GoRoute(
      path: '/tasks',
      pageBuilder: (context, state) =>
          _bhSmoothPage(state, const TasksBoardScreen()),
    ),
  ],
);

class MainShellScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellScaffold({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(agencyStoreProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: KeyedSubtree(
          key: ValueKey<int>(navigationShell.currentIndex),
          child: navigationShell,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          height: 68,
          animationDuration: const Duration(milliseconds: 420),
          backgroundColor:
              isDark ? AppColors.darkSurface : AppColors.lightSurface,
          indicatorColor: AppColors.electricBlue.withValues(alpha: 0.18),
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.space_dashboard_outlined),
              selectedIcon: Icon(
                Icons.space_dashboard_rounded,
                color: AppColors.electricBlue,
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: state.newLeadsCount > 0,
                label: Text('${state.newLeadsCount}'),
                backgroundColor: AppColors.electricBlue,
                child: const Icon(Icons.view_kanban_outlined),
              ),
              selectedIcon: const Icon(
                Icons.view_kanban_rounded,
                color: AppColors.electricBlue,
              ),
              label: 'Leads',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: state.totalUnreadChatCount > 0,
                label: Text('${state.totalUnreadChatCount}'),
                backgroundColor: AppColors.error,
                child: const Icon(Icons.forum_outlined),
              ),
              selectedIcon: const Icon(
                Icons.forum_rounded,
                color: AppColors.electricBlue,
              ),
              label: 'Chat',
            ),
            const NavigationDestination(
              icon: Icon(Icons.rocket_launch_outlined),
              selectedIcon: Icon(
                Icons.rocket_launch_rounded,
                color: AppColors.electricBlue,
              ),
              label: 'Projects',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(
                Icons.person_rounded,
                color: AppColors.electricBlue,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
