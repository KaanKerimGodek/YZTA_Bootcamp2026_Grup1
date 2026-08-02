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

/// Ekran 2 — Kayıt Ol.
///
/// Alanlar (referans sırasıyla): Ad, Soyad, E-posta, Şifre, Şifre (Tekrar).
/// Birincil "Kayıt Ol" butonu form geçerli olana kadar disabled.
/// Başarı → Ana Sayfa.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordAgainController = TextEditingController();
  static final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
  bool _submitting = false;
  String? _passwordMatchError;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordAgainController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    final first = _firstNameController.text.trim();
    final last = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final again = _passwordAgainController.text;
    return first.isNotEmpty &&
        last.isNotEmpty &&
        _emailRegex.hasMatch(email) &&
        password.length >= 6 &&
        again == password;
  }

  void _onPasswordAgainChanged(String value) {
    setState(() {
      _passwordMatchError =
          value.isNotEmpty && value != _passwordController.text
              ? 'Şifreler eşleşmiyor.'
              : null;
    });
  }

  Future<void> _submit() async {
    if (!_isFormValid || _submitting) return;
    setState(() => _submitting = true);
    try {
      await ref.read(sessionProvider.notifier).signUp(
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
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
                'Hesap Oluştur',
                style: AppTypography.headlineSection.copyWith(
                  fontSize: 26,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs + 2),
              Text(
                'Vazgeçtiklerin birikime dönüşsün.',
                style: AppTypography.bodyMain.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Ad / Soyad (yan yana)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AuthField(
                      label: 'Ad',
                      controller: _firstNameController,
                      hintText: 'Adın',
                      prefixIcon: Icons.person_outline_rounded,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AuthField(
                      label: 'Soyad',
                      controller: _lastNameController,
                      hintText: 'Soyadın',
                      prefixIcon: Icons.person_outline_rounded,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

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

              // Şifre
              AuthField(
                label: 'Şifre',
                controller: _passwordController,
                hintText: 'En az 6 karakter',
                prefixIcon: Icons.lock_outline_rounded,
                obscure: true,
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.md),

              // Şifre (Tekrar)
              AuthField(
                label: 'Şifre (Tekrar)',
                controller: _passwordAgainController,
                hintText: 'Şifreni tekrar gir',
                prefixIcon: Icons.lock_outline_rounded,
                obscure: true,
                errorText: _passwordMatchError,
                textInputAction: TextInputAction.done,
                onChanged: _onPasswordAgainChanged,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Kullanım Şartları
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text.rich(
                  const TextSpan(
                    children: [
                      TextSpan(text: 'Kayıt olarak '),
                      TextSpan(
                        text: 'Kullanım Şartları',
                        style: TextStyle(
                          color: AppColors.primaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(text: "'nı kabul etmiş olursun."),
                    ],
                  ),
                  style: AppTypography.labelSubtext.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Kayıt Ol butonu
              GradientButton(
                label: 'Kayıt Ol',
                icon: Icons.person_add_rounded,
                isLoading: _submitting,
                onPressed: _isFormValid ? _submit : null,
              ),
              const SizedBox(height: AppSpacing.md),

              // VEYA ayracı + Google
              const OrDivider(),
              const SizedBox(height: AppSpacing.md),
              const GoogleSignInButton(label: 'Google ile Kayıt Ol'),
              const SizedBox(height: AppSpacing.lg),

              // Alt link
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Zaten hesabın var mı? ',
                      style: AppTypography.bodyMain.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 2,
                        ),
                        child: Text(
                          'Giriş Yap',
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
