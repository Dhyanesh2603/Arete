import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/auth_provider.dart';

class LandingView extends ConsumerWidget {
  const LandingView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Navigation Bar
            _buildNavBar(context, ref),

            // Hero Section
            _buildHeroSection(context, ref),

            // 4 Core Value Columns
            _buildFeaturesSection(context),

            // Bottom CTA Banner
            _buildBottomBanner(context, ref),

            // Simple Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBar(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          // Brand Logo
          Container(
            width: 36,
            height: 36,
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
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'ARETE',
            style: AppTypography.heading2.copyWith(
              letterSpacing: 1.5,
              fontSize: 18,
            ),
          ),
          const Spacer(),

          // Auth Actions
          TextButton(
            onPressed: () => context.go('/auth'),
            child: Text(
              'Sign In',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textHigh),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(authProvider.notifier).guestLogin();
              context.go('/dashboard');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cyan,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Launch App',
              style: AppTypography.monoBadge.copyWith(
                color: const Color(0xFF0B0D13),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
      constraints: const BoxConstraints(maxWidth: 1080),
      child: Column(
        children: [
          // Subtitle Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.cyanBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3)),
            ),
            child: Text(
              'THE PLATFORM FOR AMBITIOUS MINDS',
              style: AppTypography.monoBadge.copyWith(
                color: AppColors.cyan,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Main Headline
          Text(
            'Transform Long-Term Ambition\nInto Structured Daily Execution.',
            textAlign: TextAlign.center,
            style: AppTypography.displayLarge.copyWith(
              fontSize: 48,
              height: 1.15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),

          // Paragraph
          Text(
            'A unified, distraction-free control center combining Striver\'s A2Z DSA Sheet, Live Peer Study Squads, Deep Work Focus, and High/Medium/Low Task Management in one fast, beautiful interface.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textMuted,
              fontSize: 17,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 36),

          // Primary & Guest CTAs
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => context.go('/auth'),
                icon: const Icon(Icons.arrow_forward_rounded, size: 18, color: Color(0xFF0B0D13)),
                label: Text(
                  'GET STARTED FREE',
                  style: AppTypography.monoBadge.copyWith(
                    color: const Color(0xFF0B0D13),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cyan,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: () {
                  ref.read(authProvider.notifier).guestLogin();
                  context.go('/dashboard');
                },
                icon: const Icon(Icons.play_circle_outline_rounded, size: 18, color: AppColors.textHigh),
                label: Text(
                  'EXPLORE LIVE DEMO',
                  style: AppTypography.monoBadge.copyWith(color: AppColors.textHigh),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.borderActive),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 48),
      constraints: const BoxConstraints(maxWidth: 1200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'ENGINEERED FOR DELIBERATE MASTERY',
              style: AppTypography.monoBadge.copyWith(color: AppColors.textMuted, fontSize: 12),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFeatureCard(
                icon: Icons.code_rounded,
                color: AppColors.cyan,
                bgColor: AppColors.cyanBg,
                title: 'Striver A2Z DSA Engine',
                description:
                    'All 18 steps with topic filtering, Spaced Repetition (SM-2), Socratic anti-spoiler hints, and 45-minute timed mock interview simulations.',
              ),
              const SizedBox(width: 16),
              _buildFeatureCard(
                icon: Icons.groups_rounded,
                color: AppColors.lavender,
                bgColor: AppColors.lavenderBg,
                title: 'Live Cohort War-Room',
                description:
                    'Study squad telemetry showing active peer focus sessions in real time, synchronized 45m sprints, and weekly velocity leaderboards.',
              ),
              const SizedBox(width: 16),
              _buildFeatureCard(
                icon: Icons.checklist_rounded,
                color: AppColors.amber,
                bgColor: AppColors.amberBg,
                title: 'Clean Task Matrix',
                description:
                    'Natural language quick capture, High (Red), Medium (Yellow), Low (Green) priority sorting, and Pomodoro session tracking.',
              ),
              const SizedBox(width: 16),
              _buildFeatureCard(
                icon: Icons.timer_outlined,
                color: AppColors.mint,
                bgColor: AppColors.mintBg,
                title: 'Distraction-Free Focus',
                description:
                    'Fullscreen digital countdown timer with 5 low-latency ambient soundscapes including 40Hz Gamma beats and Deep Brown noise.',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String title,
    required String description,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.surfaceTier1,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(height: 16),
            Text(title, style: AppTypography.heading2.copyWith(fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              description,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textMuted,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBanner(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 48, vertical: 48),
      padding: const EdgeInsets.all(48),
      constraints: const BoxConstraints(maxWidth: 1100),
      decoration: BoxDecoration(
        color: AppColors.surfaceTier1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            'Ready to Elevate Your Daily Execution?',
            textAlign: TextAlign.center,
            style: AppTypography.heading1.copyWith(fontSize: 28),
          ),
          const SizedBox(height: 12),
          Text(
            'Join the platform designed specifically for ambitious learners and engineers.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref.read(authProvider.notifier).guestLogin();
              context.go('/dashboard');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cyan,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'ENTER ARETE',
              style: AppTypography.monoBadge.copyWith(
                color: const Color(0xFF0B0D13),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Center(
        child: Text(
          'Arete — Built with Flutter Web.',
          style: AppTypography.caption.copyWith(color: AppColors.textSubtle),
        ),
      ),
    );
  }
}
