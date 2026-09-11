import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/soundscape_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/focus_session.dart';
import '../../providers/focus_session_provider.dart';

class FullscreenFocusView extends ConsumerStatefulWidget {
  const FullscreenFocusView({super.key});

  @override
  ConsumerState<FullscreenFocusView> createState() => _FullscreenFocusViewState();
}

class _FullscreenFocusViewState extends ConsumerState<FullscreenFocusView> {
  double _volume = 0.5;

  @override
  void initState() {
    super.initState();
    // Start active preset audio if running
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = ref.read(focusSessionProvider);
      if (session.state == FocusModeState.active) {
        SoundscapeService.playPreset(session.acousticPreset);
      }
    });
  }

  @override
  void dispose() {
    SoundscapeService.stop();
    super.dispose();
  }

  void _onPresetChanged(AcousticPreset preset) {
    ref.read(focusSessionProvider.notifier).setAcousticPreset(preset);
    SoundscapeService.playPreset(preset);
  }

  void _onVolumeChanged(double val) {
    setState(() => _volume = val);
    SoundscapeService.setVolume(val);
  }

  void _exitFocus() {
    SoundscapeService.stop();
    context.go('/dashboard');
  }

  void _completeAndExit() {
    SoundscapeService.stop();
    ref.read(focusSessionProvider.notifier).completeSession();
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final focusSession = ref.watch(focusSessionProvider);
    final notifier = ref.read(focusSessionProvider.notifier);

    final minutes = (focusSession.remainingSeconds / 60).floor();
    final seconds = focusSession.remainingSeconds % 60;
    final timeFormatted =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    final isPlaying = focusSession.state == FocusModeState.active;

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.space) {
            notifier.togglePlayPause();
            if (focusSession.state == FocusModeState.active) {
              SoundscapeService.stop();
            } else {
              SoundscapeService.playPreset(focusSession.acousticPreset);
            }
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.escape) {
            _exitFocus();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.keyD &&
              (HardwareKeyboard.instance.isMetaPressed ||
                  HardwareKeyboard.instance.isControlPressed)) {
            _completeAndExit();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
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

                    // Massive Clean Digital Timer
                    Text(
                      timeFormatted,
                      style: AppTypography.monoTimer.copyWith(
                        fontSize: 84,
                        fontWeight: FontWeight.w300,
                        letterSpacing: -2.0,
                        color: AppColors.textHigh,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Play/Pause & Finish Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Play/Pause
                        InkWell(
                          onTap: () {
                            notifier.togglePlayPause();
                            if (focusSession.state == FocusModeState.active) {
                              SoundscapeService.stop();
                            } else {
                              SoundscapeService.playPreset(focusSession.acousticPreset);
                            }
                          },
                          borderRadius: BorderRadius.circular(36),
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.surfaceTier1,
                              border: Border.all(
                                color: isPlaying
                                    ? AppColors.cyan.withValues(alpha: 0.6)
                                    : AppColors.borderSubtle,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                size: 32,
                                color: isPlaying
                                    ? AppColors.cyan
                                    : AppColors.textHigh,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Complete Session
                        InkWell(
                          onTap: _completeAndExit,
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceTier1,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_rounded,
                                    size: 16, color: AppColors.mint),
                                const SizedBox(width: 8),
                                Text(
                                  'COMPLETE (Cmd+D)',
                                  style: AppTypography.monoBadge.copyWith(
                                    color: AppColors.mint,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),

                    // Functional Acoustic Presets & Volume Control
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceTier1,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderSubtle),
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
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: InkWell(
                                onTap: () => _onPresetChanged(preset),
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
                          const SizedBox(width: 12),
                          // Volume Slider
                          const Icon(Icons.volume_down_rounded, size: 14, color: AppColors.textSubtle),
                          SizedBox(
                            width: 70,
                            child: SliderTheme(
                              data: SliderThemeData(
                                trackHeight: 2,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                                overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                                activeTrackColor: AppColors.amber,
                                inactiveTrackColor: AppColors.surfaceTier2,
                                thumbColor: AppColors.amber,
                              ),
                              child: Slider(
                                value: _volume,
                                onChanged: _onVolumeChanged,
                              ),
                            ),
                          ),
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
                onTap: _exitFocus,
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
