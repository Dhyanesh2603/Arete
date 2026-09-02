import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../providers/auth_provider.dart';

class GoogleAccountPickerModal extends ConsumerStatefulWidget {
  const GoogleAccountPickerModal({super.key});

  @override
  ConsumerState<GoogleAccountPickerModal> createState() =>
      _GoogleAccountPickerModalState();
}

class _GoogleAccountPickerModalState
    extends ConsumerState<GoogleAccountPickerModal> {
  bool _isCustomInputOpen = false;
  final TextEditingController _customNameCtrl = TextEditingController();
  final TextEditingController _customEmailCtrl = TextEditingController();

  @override
  void dispose() {
    _customNameCtrl.dispose();
    _customEmailCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectAccount(String name, String email) async {
    Navigator.of(context).pop(); // Close modal
    await ref
        .read(authProvider.notifier)
        .loginWithGoogleAccount(name: name, email: email);
    if (mounted && context.mounted) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.surfaceTier1,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderActive, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 36,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Google Brand Header
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.cyan.withValues(alpha: 0.5), width: 1.5),
                  ),
                  child: const Center(
                    child: Text(
                      'G',
                      style: TextStyle(
                        color: AppColors.cyan,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Sign in with Google',
                  style: AppTypography.heading2.copyWith(fontSize: 17),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      size: 18, color: AppColors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close',
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Choose an account to continue to Arete',
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 20),
            const Divider(color: AppColors.borderSubtle, height: 1),
            const SizedBox(height: 12),

            // Account 1: Personal Profile
            _buildAccountTile(
              name: 'Dhyanesh',
              email: 'dhyanesh2603@gmail.com',
              avatarChar: 'D',
              avatarColor: const Color(0xFF38BDF8),
            ),

            const SizedBox(height: 8),

            // Account 2: Developer Profile
            _buildAccountTile(
              name: 'Dhyanesh (Developer)',
              email: 'dhyanesh.arete@gmail.com',
              avatarChar: 'A',
              avatarColor: const Color(0xFF818CF8),
            ),

            const SizedBox(height: 8),

            // Use Another Account
            InkWell(
              onTap: () {
                setState(() => _isCustomInputOpen = !_isCustomInputOpen);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceTier2,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceTier1,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_add_alt_1_rounded,
                          size: 16, color: AppColors.textMedium),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Use another Google account',
                        style: AppTypography.bodyMedium
                            .copyWith(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Icon(
                      _isCustomInputOpen
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),

            // Expandable Custom Google Account Input
            if (_isCustomInputOpen) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceTier2,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _customNameCtrl,
                      style: AppTypography.bodyMedium,
                      decoration: const InputDecoration(
                        isDense: true,
                        hintText: 'Your Name (e.g. Dhyanesh)',
                        hintStyle: TextStyle(
                            fontSize: 12, color: AppColors.textMuted),
                        border: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColors.borderSubtle)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _customEmailCtrl,
                      style: AppTypography.bodyMedium,
                      decoration: const InputDecoration(
                        isDense: true,
                        hintText: 'Google Email (e.g. you@gmail.com)',
                        hintStyle: TextStyle(
                            fontSize: 12, color: AppColors.textMuted),
                        border: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColors.borderSubtle)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final name = _customNameCtrl.text.trim().isNotEmpty
                              ? _customNameCtrl.text.trim()
                              : 'Google User';
                          final email = _customEmailCtrl.text.trim().isNotEmpty
                              ? _customEmailCtrl.text.trim()
                              : 'google@arete.app';
                          _selectAccount(name, email);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.cyan,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ),
                        child: Text(
                          'CONTINUE WITH THIS ACCOUNT',
                          style: AppTypography.monoBadge.copyWith(
                            color: const Color(0xFF0B0D13),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),
            const Divider(color: AppColors.borderSubtle, height: 1),
            const SizedBox(height: 12),

            // Live Supabase OAuth Redirect Option
            InkWell(
              onTap: () async {
                Navigator.of(context).pop();
                try {
                  await SupabaseService.signInWithGoogle();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Supabase OAuth notice: $e'),
                        backgroundColor: AppColors.surfaceTier2,
                      ),
                    );
                  }
                }
              },
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: Row(
                  children: [
                    const Icon(Icons.open_in_new_rounded,
                        size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Open live Supabase Google redirect (requires enabled provider in dashboard)',
                        style: AppTypography.caption
                            .copyWith(color: AppColors.textMuted, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTile({
    required String name,
    required String email,
    required String avatarChar,
    required Color avatarColor,
  }) {
    return InkWell(
      onTap: () => _selectAccount(name, email),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceTier2,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: avatarColor,
              child: Text(
                avatarChar,
                style: AppTypography.monoBadge.copyWith(
                  color: const Color(0xFF0B0D13),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: AppTypography.bodyMedium
                          .copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(email,
                      style: AppTypography.caption
                          .copyWith(color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
