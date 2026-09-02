import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/auth_provider.dart';

class AuthView extends ConsumerStatefulWidget {
  const AuthView({super.key});

  @override
  ConsumerState<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends ConsumerState<AuthView> {
  bool _isSignUp = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    final notifier = ref.read(authProvider.notifier);
    bool success;

    if (_isSignUp) {
      success = await notifier.signup(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
      );
    } else {
      success = await notifier.login(
        _emailController.text,
        _passwordController.text,
      );
    }

    if (success && mounted) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Container(
            width: 440,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surfaceTier1,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderSubtle, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 32,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Brand Mark
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.cyanBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.4)),
                      ),
                      child: Center(
                        child: Text(
                          'A',
                          style: AppTypography.heading2.copyWith(color: AppColors.cyan, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('ARETE', style: AppTypography.heading2.copyWith(fontSize: 16)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
                      onPressed: () => context.go('/'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Text(
                  _isSignUp ? 'Create Your Account' : 'Welcome Back',
                  style: AppTypography.heading1.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 6),
                Text(
                  _isSignUp
                      ? 'Initialize your personal workspace.'
                      : 'Sign in to resume your daily focus and DSA tracking.',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 24),

                if (authState.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.roseBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.rose.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      authState.errorMessage!,
                      style: AppTypography.caption.copyWith(color: AppColors.rose),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Name Field (if Sign Up)
                if (_isSignUp) ...[
                  Text('Your Name', style: AppTypography.caption.copyWith(color: AppColors.textMedium)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceTier2,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: TextField(
                      controller: _nameController,
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textHigh),
                      decoration: const InputDecoration(
                        hintText: 'e.g. Dhyanesh',
                        hintStyle: TextStyle(fontSize: 13, color: AppColors.textMuted),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Email Field
                Text('Email Address', style: AppTypography.caption.copyWith(color: AppColors.textMedium)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceTier2,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: TextField(
                    controller: _emailController,
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textHigh),
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'name@example.com',
                      hintStyle: TextStyle(fontSize: 13, color: AppColors.textMuted),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Password Field
                Text('Password', style: AppTypography.caption.copyWith(color: AppColors.textMedium)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceTier2,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textHigh),
                    decoration: const InputDecoration(
                      hintText: '••••••••',
                      hintStyle: TextStyle(fontSize: 13, color: AppColors.textMuted),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Primary Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _handleAuth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cyan,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: authState.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0B0D13)),
                          )
                        : Text(
                            _isSignUp ? 'CREATE ACCOUNT' : 'SIGN IN',
                            style: AppTypography.monoBadge.copyWith(
                              color: const Color(0xFF0B0D13),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Instant Guest Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(authProvider.notifier).guestLogin();
                      context.go('/dashboard');
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.borderActive),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      'EXPLORE AS GUEST (1-CLICK)',
                      style: AppTypography.monoBadge.copyWith(color: AppColors.textHigh),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Toggle Sign In / Sign Up
                Center(
                  child: InkWell(
                    onTap: () {
                      setState(() => _isSignUp = !_isSignUp);
                    },
                    child: Text(
                      _isSignUp
                          ? 'Already have an account? Sign In'
                          : 'Don\'t have an account? Sign Up',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.cyan,
                        fontWeight: FontWeight.w500,
                      ),
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
