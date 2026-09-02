import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../providers/auth_provider.dart';
import '../providers/command_palette_provider.dart';
import '../providers/focus_session_provider.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/command_palette_modal.dart';

class ShellScaffold extends ConsumerStatefulWidget {
  final Widget child;
  final String currentRoute;

  const ShellScaffold({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  ConsumerState<ShellScaffold> createState() => _ShellScaffoldState();
}

class _ShellScaffoldState extends ConsumerState<ShellScaffold> {
  final FocusNode _keyboardFocusNode = FocusNode();
  bool _isSidebarExpanded = true;

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final isCmdOrCtrl = HardwareKeyboard.instance.isMetaPressed ||
          HardwareKeyboard.instance.isControlPressed;

      // Cmd+K / Ctrl+K: Open Command Palette
      if (isCmdOrCtrl && event.logicalKey == LogicalKeyboardKey.keyK) {
        ref.read(commandPaletteProvider.notifier).toggle();
      }

      // Escape: Close Command Palette
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        if (ref.read(commandPaletteProvider).isOpen) {
          ref.read(commandPaletteProvider.notifier).close();
        }
      }
    }
  }

  String _getRouteTitle(String route) {
    if (route.startsWith('/dashboard')) return 'Mission Control Dashboard';
    if (route.startsWith('/dsa')) return 'Striver A2Z DSA Tracker';
    if (route.startsWith('/cohort')) return 'DSA Cohort War-Room';
    if (route.startsWith('/tasks')) return 'Unified Task Matrix';
    if (route.startsWith('/projects')) return 'Projects & Kanban';
    if (route.startsWith('/calendar')) return 'Time-Blocking & Daily Agenda';
    if (route.startsWith('/habits')) return 'Habit Consistency Vectors';
    if (route.startsWith('/focus')) return 'Deep Work Focus Session';
    if (route.startsWith('/goals')) return 'Strategic Goals & Milestones';
    if (route.startsWith('/knowledge')) return 'Markdown Knowledge Base';
    if (route.startsWith('/resources')) return 'Learning Library & Curriculum';
    if (route.startsWith('/coach')) return 'AI Cognitive Coach';
    if (route.startsWith('/analytics')) return 'Life Telemetry & Velocity';
    if (route.startsWith('/settings')) return 'System Settings';
    return 'Arete OS';
  }

  @override
  Widget build(BuildContext context) {
    final paletteState = ref.watch(commandPaletteProvider);
    final focusState = ref.watch(focusSessionProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isFocusActive = focusState.state == FocusModeState.active;

    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        body: Stack(
          children: [
            Row(
              children: [
                // Slideable / Collapsible Detailed Sidebar
                AppSidebar(
                  currentRoute: widget.currentRoute,
                  isExpanded: _isSidebarExpanded,
                  onToggleExpanded: () {
                    setState(() => _isSidebarExpanded = !_isSidebarExpanded);
                  },
                ),
                // Main Content Stage with Top App Bar
                Expanded(
                  child: Column(
                    children: [
                      // Top Universal Navigation Header
                      _buildTopHeader(context, user, isFocusActive),
                      // View Content Body
                      Expanded(child: widget.child),
                    ],
                  ),
                ),
              ],
            ),
            // Global Raycast-style Command Palette Overlay
            if (paletteState.isOpen)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    ref.read(commandPaletteProvider.notifier).close();
                  },
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.65),
                    child: const CommandPaletteModal(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context, dynamic user, bool isFocusActive) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: AppColors.surfaceTier1,
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          // Slideable Menu Hamburger Toggle Button
          IconButton(
            icon: Icon(
              _isSidebarExpanded ? Icons.menu_open_rounded : Icons.menu_rounded,
              color: AppColors.cyan,
              size: 20,
            ),
            tooltip: _isSidebarExpanded ? 'Collapse Menu' : 'Slide Open Detailed Menu',
            onPressed: () {
              setState(() => _isSidebarExpanded = !_isSidebarExpanded);
            },
          ),
          const SizedBox(width: 10),

          // Route Title Breadcrumb
          Text(
            _getRouteTitle(widget.currentRoute),
            style: AppTypography.heading2.copyWith(fontSize: 15),
          ),
          const Spacer(),

          // Active Focus Timer Indicator (if active)
          if (isFocusActive) ...[
            InkWell(
              onTap: () => context.go('/focus'),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.amberBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.amber.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.amber,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'FOCUS ACTIVE',
                      style: AppTypography.monoBadge.copyWith(color: AppColors.amber, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],

          // Quick Search Button (Cmd+K)
          InkWell(
            onTap: () => ref.read(commandPaletteProvider.notifier).open(),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surfaceTier2,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Text('Search anything (Cmd+K)', style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),

          // User Avatar Pill
          if (user != null)
            InkWell(
              onTap: () => context.go('/settings'),
              borderRadius: BorderRadius.circular(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: user.avatarColor,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0] : 'U',
                      style: AppTypography.monoBadge.copyWith(
                        color: const Color(0xFF0B0D13),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    user.name,
                    style: AppTypography.bodyMedium.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
