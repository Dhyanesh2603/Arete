import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../providers/command_palette_provider.dart';
import '../providers/focus_session_provider.dart';

class AppSidebar extends ConsumerWidget {
  final String currentRoute;

  const AppSidebar({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusState = ref.watch(focusSessionProvider);
    final isFocusActive = focusState.state == FocusModeState.active;

    return Container(
      width: 64,
      decoration: const BoxDecoration(
        color: AppColors.surfaceTier1,
        border: Border(
          right: BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 14),
          // App Logo / Symbol
          InkWell(
            onTap: () => context.go('/dashboard'),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.cyanBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.cyan.withValues(alpha: 0.4), width: 1),
              ),
              child: Center(
                child: Text(
                  'A',
                  style: AppTypography.heading2.copyWith(
                    color: AppColors.cyan,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Nav Items Scrollable Rail
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildNavItem(
                    context,
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard_rounded,
                    route: '/dashboard',
                    tooltip: 'Mission Control HUD',
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.code_rounded,
                    activeIcon: Icons.code_rounded,
                    route: '/dsa',
                    tooltip: 'Striver A2Z DSA Tracker',
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.groups_outlined,
                    activeIcon: Icons.groups_rounded,
                    route: '/cohort',
                    tooltip: 'DSA Cohort War-Room',
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.flag_outlined,
                    activeIcon: Icons.flag_rounded,
                    route: '/goals',
                    tooltip: 'Strategic Goals & DAG',
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.view_kanban_outlined,
                    activeIcon: Icons.view_kanban_rounded,
                    route: '/projects',
                    tooltip: 'Projects & Kanban Matrix',
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.checklist_rounded,
                    activeIcon: Icons.checklist_rounded,
                    route: '/tasks',
                    tooltip: 'Unified Task Matrix',
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.calendar_month_outlined,
                    activeIcon: Icons.calendar_month_rounded,
                    route: '/calendar',
                    tooltip: 'Time-Blocking & Agenda',
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.repeat_rounded,
                    activeIcon: Icons.repeat_rounded,
                    route: '/habits',
                    tooltip: 'Habit Consistency Vectors',
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.timer_outlined,
                    activeIcon: Icons.timer_rounded,
                    route: '/focus',
                    tooltip: 'Deep Work Focus Mode',
                    isPulseGlow: isFocusActive,
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.menu_book_outlined,
                    activeIcon: Icons.menu_book_rounded,
                    route: '/knowledge',
                    tooltip: 'Markdown Knowledge Base',
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.school_outlined,
                    activeIcon: Icons.school_rounded,
                    route: '/resources',
                    tooltip: 'Learning Curriculum',
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.auto_awesome_outlined,
                    activeIcon: Icons.auto_awesome_rounded,
                    route: '/coach',
                    tooltip: 'AI Cognitive Coach',
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.analytics_outlined,
                    activeIcon: Icons.analytics_rounded,
                    route: '/analytics',
                    tooltip: 'Life Telemetry',
                  ),
                ],
              ),
            ),
          ),
          // Command Palette Trigger (Cmd+K)
          Tooltip(
            message: 'Command Palette (Cmd+K)',
            child: InkWell(
              onTap: () {
                ref.read(commandPaletteProvider.notifier).open();
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 42,
                height: 42,
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceTier2,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderSubtle, width: 1),
                ),
                child: const Center(
                  child: Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: AppColors.cyan,
                  ),
                ),
              ),
            ),
          ),
          _buildNavItem(
            context,
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings_rounded,
            route: '/settings',
            tooltip: 'Settings',
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String route,
    required String tooltip,
    bool isPulseGlow = false,
  }) {
    final isActive = currentRoute == route;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: () {
            if (currentRoute != route) {
              context.go(route);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isActive ? AppColors.surfaceHover : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isActive
                    ? AppColors.cyan.withValues(alpha: 0.3)
                    : isPulseGlow
                        ? AppColors.amber.withValues(alpha: 0.4)
                        : Colors.transparent,
                width: 1,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  size: 19,
                  color: isActive
                      ? AppColors.cyan
                      : isPulseGlow
                          ? AppColors.amber
                          : AppColors.textMuted,
                ),
                if (isPulseGlow)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.amber,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                if (isActive)
                  Positioned(
                    left: 0,
                    top: 8,
                    bottom: 8,
                    child: Container(
                      width: 3,
                      decoration: BoxDecoration(
                        color: AppColors.cyan,
                        borderRadius: BorderRadius.circular(2),
                      ),
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
