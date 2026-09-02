import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../providers/auth_provider.dart';
import '../providers/command_palette_provider.dart';
import '../providers/focus_session_provider.dart';

class AppSidebar extends ConsumerWidget {
  final String currentRoute;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;

  const AppSidebar({
    super.key,
    required this.currentRoute,
    required this.isExpanded,
    required this.onToggleExpanded,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusState = ref.watch(focusSessionProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isFocusActive = focusState.state == FocusModeState.active;

    final sidebarWidth = isExpanded ? 260.0 : 64.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: sidebarWidth,
      decoration: const BoxDecoration(
        color: AppColors.surfaceTier1,
        border: Border(
          right: BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          // Top Header: Logo & Toggle
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isExpanded ? 16 : 12),
            child: Row(
              children: [
                InkWell(
                  onTap: () => context.go('/dashboard'),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.cyanBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.cyan.withValues(alpha: 0.4)),
                    ),
                    child: Center(
                      child: Text(
                        'A',
                        style: AppTypography.heading2.copyWith(
                          color: AppColors.cyan,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                if (isExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ARETE',
                          style: AppTypography.heading2.copyWith(
                            fontSize: 15,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          'Productivity Platform',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // User Profile Card (when expanded)
          if (isExpanded && user != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceTier2,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: user.avatarColor,
                      child: Text(
                        user.name.isNotEmpty ? user.name[0] : 'U',
                        style: AppTypography.monoBadge.copyWith(
                          color: const Color(0xFF0B0D13),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            user.email,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          const Divider(color: AppColors.borderSubtle, height: 1),

          // Nav Items Scrollable Rail
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildNavItem(
                  context,
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard_rounded,
                  title: 'Mission Control',
                  subtitle: 'Daily command HUD',
                  route: '/dashboard',
                ),
                _buildNavItem(
                  context,
                  icon: Icons.code_rounded,
                  activeIcon: Icons.code_rounded,
                  title: 'DSA Roadmap',
                  subtitle: 'Striver A2Z Sheet',
                  route: '/dsa',
                ),
                _buildNavItem(
                  context,
                  icon: Icons.groups_outlined,
                  activeIcon: Icons.groups_rounded,
                  title: 'Study Squad',
                  subtitle: 'Live peer war-room',
                  route: '/cohort',
                ),
                _buildNavItem(
                  context,
                  icon: Icons.checklist_rounded,
                  activeIcon: Icons.checklist_rounded,
                  title: 'Tasks & Matrix',
                  subtitle: 'High/Med/Low priority',
                  route: '/tasks',
                ),
                _buildNavItem(
                  context,
                  icon: Icons.view_kanban_outlined,
                  activeIcon: Icons.view_kanban_rounded,
                  title: 'Projects & Kanban',
                  subtitle: 'Linear-style boards',
                  route: '/projects',
                ),
                _buildNavItem(
                  context,
                  icon: Icons.calendar_month_outlined,
                  activeIcon: Icons.calendar_month_rounded,
                  title: 'Calendar & Agenda',
                  subtitle: 'Daily time-blocking',
                  route: '/calendar',
                ),
                _buildNavItem(
                  context,
                  icon: Icons.repeat_rounded,
                  activeIcon: Icons.repeat_rounded,
                  title: 'Habit Vectors',
                  subtitle: '365-day consistency',
                  route: '/habits',
                ),
                _buildNavItem(
                  context,
                  icon: Icons.timer_outlined,
                  activeIcon: Icons.timer_rounded,
                  title: 'Deep Work Focus',
                  subtitle: 'Immersion timer',
                  route: '/focus',
                  isPulseGlow: isFocusActive,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.flag_outlined,
                  activeIcon: Icons.flag_rounded,
                  title: 'Strategic Goals',
                  subtitle: 'Long-term milestones',
                  route: '/goals',
                ),
                _buildNavItem(
                  context,
                  icon: Icons.menu_book_outlined,
                  activeIcon: Icons.menu_book_rounded,
                  title: 'Knowledge Base',
                  subtitle: 'Markdown notes',
                  route: '/knowledge',
                ),
                _buildNavItem(
                  context,
                  icon: Icons.school_outlined,
                  activeIcon: Icons.school_rounded,
                  title: 'Learning Library',
                  subtitle: 'Curriculum & papers',
                  route: '/resources',
                ),
                _buildNavItem(
                  context,
                  icon: Icons.auto_awesome_outlined,
                  activeIcon: Icons.auto_awesome_rounded,
                  title: 'AI Coach',
                  subtitle: 'Evening retrospective',
                  route: '/coach',
                ),
                _buildNavItem(
                  context,
                  icon: Icons.analytics_outlined,
                  activeIcon: Icons.analytics_rounded,
                  title: 'Life Telemetry',
                  subtitle: 'Velocity curves',
                  route: '/analytics',
                ),
              ],
            ),
          ),

          const Divider(color: AppColors.borderSubtle, height: 1),

          // Bottom Action: Command Palette & Settings & Logout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              children: [
                // Quick Search Trigger
                InkWell(
                  onTap: () => ref.read(commandPaletteProvider.notifier).open(),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isExpanded ? 12 : 8,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceTier2,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      mainAxisAlignment:
                          isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_rounded, size: 16, color: AppColors.cyan),
                        if (isExpanded) ...[
                          const SizedBox(width: 8),
                          Text('Command Deck', style: AppTypography.caption),
                          const Spacer(),
                          Text('Cmd+K', style: AppTypography.monoBadge.copyWith(fontSize: 9)),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Settings
                InkWell(
                  onTap: () => context.go('/settings'),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isExpanded ? 12 : 8,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment:
                          isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.settings_outlined, size: 16, color: AppColors.textMuted),
                        if (isExpanded) ...[
                          const SizedBox(width: 10),
                          Text('Settings', style: AppTypography.bodyMedium.copyWith(fontSize: 13)),
                        ],
                      ],
                    ),
                  ),
                ),

                if (isExpanded) ...[
                  // Logout
                  InkWell(
                    onTap: () {
                      ref.read(authProvider.notifier).logout();
                      context.go('/');
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.logout_rounded, size: 16, color: AppColors.rose),
                          const SizedBox(width: 10),
                          Text(
                            'Sign Out',
                            style: AppTypography.bodyMedium.copyWith(
                              fontSize: 13,
                              color: AppColors.rose,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required String subtitle,
    required String route,
    bool isPulseGlow = false,
  }) {
    final isActive = currentRoute == route;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isExpanded ? 10 : 8,
        vertical: 2,
      ),
      child: Tooltip(
        message: isExpanded ? '' : '$title — $subtitle',
        child: InkWell(
          onTap: () {
            if (currentRoute != route) {
              context.go(route);
            }
          },
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isExpanded ? 10 : 0,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: isActive ? AppColors.surfaceHover : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isActive
                    ? AppColors.cyan.withValues(alpha: 0.3)
                    : isPulseGlow
                        ? AppColors.amber.withValues(alpha: 0.4)
                        : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisAlignment:
                  isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  size: 18,
                  color: isActive
                      ? AppColors.cyan
                      : isPulseGlow
                          ? AppColors.amber
                          : AppColors.textMuted,
                ),
                if (isExpanded) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTypography.bodyMedium.copyWith(
                            color: isActive ? AppColors.cyan : AppColors.textHigh,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          subtitle,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSubtle,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
