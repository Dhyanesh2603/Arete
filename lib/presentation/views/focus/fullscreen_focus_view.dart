import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/focus_session.dart';
import '../../providers/focus_session_provider.dart';

class FullscreenFocusView extends ConsumerWidget {
  const FullscreenFocusView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusSession = ref.watch(focusSessionProvider);
    final notifier = ref.read(focusSessionProvider.notifier);

    final minutes = (focusSession.remainingSeconds / 60).floor();
    final seconds = focusSession.remainingSeconds % 60;
    final timeFormatted =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    final isPlaying = focusSession.state == FocusModeState.active;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        children: [
          // Subtle Progress Border at Top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              value: focusSession.progress,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.cyan),
              minHeight: 3,
            ),
          ),
          // Main Center Stage
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 680),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Active Task Banner
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.cyanBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: AppColors.cyan.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'ACTIVE DEEP WORK SESSION',
                      style: AppTypography.monoBadge.copyWith(
                        color: AppColors.cyan,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    focusSession.taskTitle,
                    style: AppTypography.heading1.copyWith(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    focusSession.objective,
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Monospaced Timer
                  Text(
                    timeFormatted,
                    style: AppTypography.monoTimer.copyWith(
                      fontSize: 72,
                      color: isPlaying ? AppColors.textHigh : AppColors.amber,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Control Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => notifier.togglePlayPause(),
                        icon: Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 20,
                          color: const Color(0xFF0B0D13),
                        ),
                        label: Text(
                          isPlaying ? 'PAUSE (Space)' : 'RESUME (Space)',
                          style: AppTypography.monoBadge.copyWith(
                            color: const Color(0xFF0B0D13),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isPlaying ? AppColors.cyan : AppColors.amber,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          notifier.completeSession();
                          context.go('/dashboard');
                        },
                        icon: const Icon(Icons.check_rounded,
                            size: 18, color: AppColors.mint),
                        label: Text(
                          'COMPLETE (Cmd+D)',
                          style: AppTypography.monoBadge
                              .copyWith(color: AppColors.mint),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: AppColors.mint.withValues(alpha: 0.4)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),

                  // Acoustic Preset Selector
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceTier1,
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: AppColors.borderSubtle, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.headphones_outlined,
                            size: 16, color: AppColors.amber),
                        const SizedBox(width: 10),
                        Text('Acoustics: ',
                            style: AppTypography.caption
                                .copyWith(color: AppColors.textMuted)),
                        ...AcousticPreset.values.map((preset) {
                          final isSelected =
                              focusSession.acousticPreset == preset;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: InkWell(
                              onTap: () => notifier.setAcousticPreset(preset),
                              borderRadius: BorderRadius.circular(4),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.surfaceHover
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.amber.withValues(alpha: 0.5)
                                        : Colors.transparent,
                                  ),
                                ),
                                child: Text(
                                  _getPresetName(preset),
                                  style: AppTypography.monoBadge.copyWith(
                                    fontSize: 10,
                                    color: isSelected
                                        ? AppColors.amber
                                        : AppColors.textMuted,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Top Exit Button
          Positioned(
            top: 20,
            left: 24,
            child: InkWell(
              onTap: () => context.go('/dashboard'),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceTier1,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_back_rounded,
                        size: 16, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Text('Exit Focus (ESC)',
                        style: AppTypography.caption
                            .copyWith(color: AppColors.textMuted)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPresetName(AcousticPreset preset) {
    switch (preset) {
      case AcousticPreset.binaural40Hz:
        return '40Hz Gamma';
      case AcousticPreset.brownNoise:
        return 'Deep Brown';
      case AcousticPreset.obsidianRain:
        return 'Rain';
      case AcousticPreset.terminalHum:
        return 'Terminal Hum';
      case AcousticPreset.silent:
        return 'Silent';
    }
  }
}
