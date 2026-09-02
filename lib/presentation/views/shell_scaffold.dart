import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../providers/command_palette_provider.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/command_palette_modal.dart';

class ShellScaffold extends ConsumerWidget {
  final Widget child;
  final String currentRoute;

  const ShellScaffold({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paletteState = ref.watch(commandPaletteProvider);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): () {
          ref.read(commandPaletteProvider.notifier).toggle();
        },
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): () {
          ref.read(commandPaletteProvider.notifier).toggle();
        },
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (paletteState.isOpen) {
            ref.read(commandPaletteProvider.notifier).close();
          }
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: AppColors.canvas,
          body: Stack(
            children: [
              Row(
                children: [
                  AppSidebar(currentRoute: currentRoute),
                  Expanded(
                    child: Container(
                      color: AppColors.canvas,
                      child: child,
                    ),
                  ),
                ],
              ),
              // Global Command Palette Modal Overlay
              if (paletteState.isOpen)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      ref.read(commandPaletteProvider.notifier).close();
                    },
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.65),
                      alignment: const Alignment(0, -0.4),
                      child: GestureDetector(
                        onTap: () {}, // Prevent tap through
                        child: const CommandPaletteModal(),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
