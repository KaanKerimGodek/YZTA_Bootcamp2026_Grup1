import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shapes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/providers/auth_providers.dart';
import '../../data/services/api_client.dart';
import '../../shared/widgets/auth_field.dart';
import '../../shared/widgets/google_sign_in_button.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/or_divider.dart';

/// Ekran 3 — Giriş Yap.
///
/// Alanlar: E-posta, Şifre (göster/gizle). Sağ üstte "Şifremi mi unuttun?"
/// linki. Birincil "Giriş Yap" butonu form geçerli olana kadar disabled.
/// Başarı → Ana Sayfa.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  static final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    return _emailRegex.hasMatch(email) && password.length >= 6;
  }

  Future<void> _submit() async {
    if (!_isFormValid || _submitting) return;
    setState(() => _submitting = true);
    try {
      await ref.read(sessionProvider.notifier).signIn(
            email: _emailController.text,
            password: _passwordController.text,
          );
      if (!mounted) return;
      context.go('/home');
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Beklenmeyen bir hata oluştu. Tekrar dene.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.error,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppShapes.md),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSlate50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenEdge,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Geri butonu
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: () => context.go('/welcome'),
                  // 44x44 dokunma alanı
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Başlık
              Text(
                'Hoş geldin!',
                style: AppTypography.headlineSection.copyWith(
                  fontSize: 26,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs + 2),
              Text(
                'Hesabına Giriş Yap',
                style: AppTypography.bodyMain.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // E-posta
              AuthField(
                label: 'E-posta',
                controller: _emailController,
                hintText: 'ornek@email.com',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.md),

              // Şifre + Şifremi unuttum
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Şifre',
                    style: AppTypography.labelCaps.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Şifre sıfırlama yakında 🚧'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AppColors.textPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppShapes.md),
                          ),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryContainer,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      minimumSize: const Size(44, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Şifremi mi unuttun?',
                      style: AppTypography.labelSubtext.copyWith(
                        color: AppColors.primaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs + 2),
              AuthField(
                label: '',
                controller: _passwordController,
                hintText: '••••••••',
                prefixIcon: Icons.lock_outline_rounded,
                obscure: true,
                textInputAction: TextInputAction.done,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Giriş Yap butonu
              GradientButton(
                label: 'Giriş Yap',
                icon: Icons.login_rounded,
                isLoading: _submitting,
                onPressed: _isFormValid ? _submit : null,
              ),
              const SizedBox(height: AppSpacing.md),

              // VEYA ayracı + Google
              const OrDivider(),
              const SizedBox(height: AppSpacing.md),
              const GoogleSignInButton(label: 'Google ile Giriş Yap'),
              const SizedBox(height: AppSpacing.md),

              // Hızlı giriş (Geliştirici modu)
              const _QuickLoginButton(),
              const SizedBox(height: AppSpacing.lg),

              // Alt link
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Hesabın yok mu? ',
                      style: AppTypography.bodyMain.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/register'),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 2,
                        ),
                        child: Text(
                          'Kayıt Ol',
                          style: AppTypography.bodyMain.copyWith(
                            color: AppColors.primaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
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
    );
  }
}

/// Geliştirici modunda hızlı giriş butonu.
///
/// Test kullanıcısı (yacolak@test.com / yacolak123) ile tek tıkla giriş yapar.
class _QuickLoginButton extends ConsumerWidget {
  const _QuickLoginButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const testEmail = 'yacolak@test.com';
    const testPassword = 'yacolak123';

    return TextButton.icon(
      onPressed: () async {
        final notifier = ref.read(sessionProvider.notifier);
        if (notifier.isLoading) return;

        try {
          await notifier.signIn(email: testEmail, password: testPassword);
          if (!context.mounted) return;
          context.go('/home');
        } on Exception catch (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hızlı giriş hatası: $e'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppShapes.md),
              ),
            ),
          );
        }
      },
      icon: const Icon(Icons.flash_on_rounded, size: 18),
      label: const Text('Hızlı Giriş (Test Kullanıcısı)'),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppShapes.md),
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
      ),
    );
  }
}
