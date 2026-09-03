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
import '../widgets/glass_container.dart';

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
  bool _isDrawerOpen = false;

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

      // Escape: Close Drawer or Command Palette
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        if (ref.read(commandPaletteProvider).isOpen) {
          ref.read(commandPaletteProvider.notifier).close();
        } else if (_isDrawerOpen) {
          setState(() => _isDrawerOpen = false);
        }
      }
    }
  }

  String _getRouteTitle(String route) {
    if (route.startsWith('/dashboard')) return 'Mission Control Dashboard';
    if (route.startsWith('/dsa')) return 'Striver A2Z DSA Tracker';
    if (route.startsWith('/cohort')) return 'Study Squad';
    if (route.startsWith('/tasks')) return 'Unified Task Matrix';
    if (route.startsWith('/projects')) return 'Projects & Kanban';
    if (route.startsWith('/calendar')) return 'Calendar';
    if (route.startsWith('/habits')) return 'Habit Consistency Vectors';
    if (route.startsWith('/focus')) return 'Deep Work Focus Session';
    if (route.startsWith('/goals')) return 'Strategic Goals & Milestones';
    if (route.startsWith('/knowledge')) return 'Markdown Knowledge Base';
    if (route.startsWith('/resources')) return 'Learning Library & Curriculum';
    if (route.startsWith('/coach')) return 'AI Cognitive Coach';
    if (route.startsWith('/analytics')) return 'Life Telemetry & Velocity';
    if (route.startsWith('/settings')) return 'System Settings';
    return 'Arete';
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
        body: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.8, -0.8),
              radius: 2.0,
              colors: [
                AppColors.cyan.withValues(alpha: 0.15),
                AppColors.canvas,
              ],
            ),
          ),
          child: Stack(
            children: [
            // Main Content Area
            Column(
              children: [
                // Top Universal App Bar with Hamburger Slide Toggle
                _buildTopHeader(context, user, isFocusActive),
                // Main View Body
                Expanded(child: widget.child),
              ],
            ),

            // Dimmed Scrim Backdrop when Slideable Drawer is Open
            if (_isDrawerOpen)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _isDrawerOpen = false);
                  },
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _isDrawerOpen ? 1.0 : 0.0,
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.55),
                    ),
                  ),
                ),
              ),

            // Slideable Animated Left Drawer Navigation
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              top: 0,
              bottom: 0,
              left: _isDrawerOpen ? 0 : -290,
              child: AppSidebar(
                currentRoute: widget.currentRoute,
                onClose: () {
                  setState(() => _isDrawerOpen = false);
                },
              ),
            ),

            // Global Command Palette Overlay
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
    ));
  }

  Widget _buildTopHeader(BuildContext context, dynamic user, bool isFocusActive) {
    return GlassContainer(
      blur: 24,
      borderRadius: 0,
      border: const Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Slideable Menu Hamburger Button
          IconButton(
            icon: const Icon(
              Icons.menu_rounded,
              color: AppColors.cyan,
              size: 22,
            ),
            tooltip: 'Open Menu Drawer',
            onPressed: () {
              setState(() => _isDrawerOpen = !_isDrawerOpen);
            },
          ),
          const SizedBox(width: 8),

          // Logo & Route Title Breadcrumb
          InkWell(
            onTap: () => setState(() => _isDrawerOpen = true),
            borderRadius: BorderRadius.circular(4),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.cyanBg,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3)),
                  ),
                  child: Center(
                    child: Text(
                      'A',
                      style: AppTypography.monoBadge.copyWith(
                        color: AppColors.cyan,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  _getRouteTitle(widget.currentRoute),
                  style: AppTypography.heading2.copyWith(fontSize: 15),
                ),
              ],
            ),
          ),
          const Spacer(),

          // Active Focus Timer Indicator (if running)
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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

          // User Profile Avatar / Menu trigger
          if (user != null)
            InkWell(
              onTap: () => setState(() => _isDrawerOpen = true),
              borderRadius: BorderRadius.circular(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 13,
                    backgroundColor: user.avatarColor,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
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
    ));
  }
}
