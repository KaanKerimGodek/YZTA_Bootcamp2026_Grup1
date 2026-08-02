import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shapes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatting.dart';
import '../../core/utils/responsive.dart';
import '../../data/providers/savings_providers.dart';
import '../../data/models/app_user.dart';

/// Hedef ayarları ekranı — kullanıcının tasarruf hedeflerini özelleştirmesine izin verir.
class GoalSettingsScreen extends ConsumerStatefulWidget {
  const GoalSettingsScreen({super.key});

  @override
  ConsumerState<GoalSettingsScreen> createState() => _GoalSettingsScreenState();
}

class _GoalSettingsScreenState extends ConsumerState<GoalSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _goalNameController;
  late final TextEditingController _goalTargetController;
  late final TextEditingController _monthlyGoalController;

  bool _isSaving = false;
  bool _isResetting = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider);
    _goalNameController = TextEditingController(text: user?.goalTitle ?? '');
    _goalTargetController = TextEditingController(
      text: user?.savingsGoal != null
          ? _formatNumber(user!.savingsGoal!.toInt())
          : '',
    );
    _monthlyGoalController = TextEditingController(
      text: user?.monthlyGoal != null
          ? _formatNumber(user!.monthlyGoal!.toInt())
          : '',
    );
  }

  @override
  void dispose() {
    _goalNameController.dispose();
    _goalTargetController.dispose();
    _monthlyGoalController.dispose();
    super.dispose();
  }

  String _formatNumber(int value) {
    final str = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final indexFromEnd = str.length - i;
      buffer.write(str[i]);
      if (indexFromEnd > 1 && indexFromEnd % 3 == 1) {
        buffer.write(',');
      }
    }
    return buffer.toString();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await ref.read(userProvider.notifier).updateGoalSettings(
        goalTitle: _goalNameController.text.trim().isEmpty
            ? null
            : _goalNameController.text.trim(),
        savingsGoal: _goalTargetController.text.isEmpty
            ? null
            : double.parse(_goalTargetController.text.replaceAll(',', '')),
        monthlyGoal: _monthlyGoalController.text.isEmpty
            ? null
            : double.parse(_monthlyGoalController.text.replaceAll(',', '')),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Hedef ayarları kaydedildi ✓',
              style: AppTypography.bodyMain.copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.successEmerald,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppShapes.md),
            ),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Kaydetme hatası: $e',
              style: AppTypography.bodyMain.copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppShapes.md),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _completeGoalAndReset() async {
    final user = ref.read(userProvider);
    if (user == null || !user.hasGoal) return;

    // Confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppShapes.xl)),
        title: Text('Hedefi Tamamla', style: AppTypography.headlineSection),
        content: Text(
          '"${user.goalTitle}" hedefini tamamlandı olarak işaretlemek istediğinizden emin misiniz? '
          'Bu hedef "Tamamlanan Hedefler" listenize eklenecek ve yeni bir hedef belirleyebileceksiniz.',
          style: AppTypography.bodyMain.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('İptal', style: AppTypography.bodyBold.copyWith(color: AppColors.textSecondary)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.successEmerald,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppShapes.md)),
            ),
            child: Text('Tamamla ve Sıfırla', style: AppTypography.bodyBold.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isResetting = true);

    try {
      await ref.read(userProvider.notifier).completeGoalAndReset();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Hedef tamamlandı ve sıfırlandı ✓ Yeni hedef belirleyebilirsiniz.',
              style: AppTypography.bodyMain.copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.successEmerald,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppShapes.md),
            ),
          ),
        );
        // Form alanlarını temizle
        _goalNameController.clear();
        _goalTargetController.clear();
        _monthlyGoalController.clear();
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Hata: $e',
              style: AppTypography.bodyMain.copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppShapes.md),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isResetting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final progress = user?.goalProgress ?? 0.0;
    final isCompleted = user?.isGoalCompleted ?? false;
    final completedGoals = user?.completedGoals ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Hedef Ayarları', style: AppTypography.headlineSection),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Mevcut ilerleme özeti
              SliverToBoxAdapter(
                child: Padding(
                  padding: Responsive.screenHorizontal(context).copyWith(
                    top: AppSpacing.md,
                    bottom: AppSpacing.lg,
                  ),
                  child: _ProgressSummaryCard(
                    goalName: user?.goalTitle ?? 'Hedef Belirle',
                    currentAmount: user?.totalSaved ?? 0,
                    targetAmount: user?.savingsGoal ?? 10000,
                    progress: progress,
                    isCompleted: isCompleted,
                  ),
                ),
              ),

              // Form alanları
              SliverToBoxAdapter(
                child: Padding(
                  padding: Responsive.screenHorizontal(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hedef Bilgileri',
                        style: AppTypography.labelCaps.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Hedef Adı
                      _FormField(
                        label: 'Hedef Adı',
                        hint: 'Örn: Avrupa Tatili, Yeni Telefon, Acil Durum Fonu',
                        controller: _goalNameController,
                        icon: Icons.flag_outlined,
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty && value.trim().length < 2) {
                            return 'En az 2 karakter girin';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Toplam Hedef Tutar
                      _FormField(
                        label: 'Toplam Hedef Tutar (TL)',
                        hint: 'Örn: 10.000',
                        controller: _goalTargetController,
                        icon: Icons.attach_money_rounded,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          ThousandsSeparatorInputFormatter(),
                        ],
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final num = double.tryParse(value.replaceAll(',', ''));
                            if (num == null || num <= 0) {
                              return 'Geçerli bir tutar girin';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Aylık Hedef
                      _FormField(
                        label: 'Aylık Hedef (TL)',
                        hint: 'Örn: 5.000',
                        controller: _monthlyGoalController,
                        icon: Icons.calendar_month_rounded,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          ThousandsSeparatorInputFormatter(),
                        ],
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final num = double.tryParse(value.replaceAll(',', ''));
                            if (num == null || num <= 0) {
                              return 'Geçerli bir tutar girin';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Hedefi Tamamla butonu (sadece hedef varsa ve %100+ ise)
                      if (user != null && user.hasGoal && isCompleted) ...[
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: _isResetting ? null : _completeGoalAndReset,
                            icon: _isResetting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.check_circle_outline_rounded),
                            label: Text(
                              _isResetting ? 'Tamamlanıyor...' : 'Hedefi Tamamla ve Yeni Hedef Belirle',
                              style: AppTypography.bodyBold.copyWith(fontSize: 16),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.successEmerald,
                              side: BorderSide(color: AppColors.successEmerald, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppShapes.lg),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],

                      // İpucu
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(AppShapes.md),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                'Hedefinize ulaşmanızı motive edecek bir isim ve gerçekçi tutarlar belirleyin. '
                                'Aylık hedef, içgörüler sayfasındaki ilerleme çubuğu için kullanılır.',
                                style: AppTypography.labelSubtext.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Kaydet butonu
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed: _isSaving ? null : _save,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppShapes.lg),
                            ),
                            elevation: 0,
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(Colors.white),
                                  ),
                                )
                              : Text(
                                  'Kaydet',
                                  style: AppTypography.bodyBold.copyWith(fontSize: 16),
                                ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Tamamlanan Hedefler Geçmişi
                      if (completedGoals.isNotEmpty) ...[
                        Text(
                          'Tamamlanan Hedefler',
                          style: AppTypography.labelCaps.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ...completedGoals.map((goal) => _CompletedGoalCard(goal: goal)).toList(),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ],
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

/// İlerleme özet kartı
class _ProgressSummaryCard extends StatelessWidget {
  const _ProgressSummaryCard({
    required this.goalName,
    required this.currentAmount,
    required this.targetAmount,
    required this.progress,
    required this.isCompleted,
    super.key,
  });

  final String goalName;
  final double currentAmount;
  final double targetAmount;
  final double progress;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCompleted
              ? [AppColors.successEmerald, AppColors.successEmerald.withOpacity(0.8)]
              : [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppShapes.xl),
        boxShadow: [
          BoxShadow(
            color: (isCompleted ? AppColors.successEmerald : AppColors.primary).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppShapes.md),
                ),
                child: Icon(
                  isCompleted ? Icons.celebration_rounded : Icons.flag_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCompleted ? '🎉 Hedef Tamamlandı!' : 'Mevcut Hedef',
                      style: AppTypography.labelSubtext.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      goalName,
                      style: AppTypography.headlineSection.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${Formatting.currency(currentAmount, decimal: false)} / ${Formatting.currency(targetAmount, decimal: false)}',
                    style: AppTypography.bodyBold.copyWith(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '%${(progress * 100).round()}',
                    style: AppTypography.bodyBold.copyWith(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppShapes.full),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation(
                    isCompleted ? Colors.amber : Colors.white,
                  ),
                ),
              ),
            ],
          ),
          if (isCompleted) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Tebrikler! Hedefinize ulaştınız 🎉',
                  style: AppTypography.bodyMain.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Form alanı bileşeni
class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    super.key,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelCaps.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: AppTypography.bodyMain.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyMain.copyWith(
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 22),
            filled: true,
            fillColor: AppColors.surfaceContainerLowest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppShapes.lg),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppShapes.lg),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppShapes.lg),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppShapes.lg),
              borderSide: BorderSide(color: AppColors.error, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ],
    );
  }
}

/// Binlik ayracı formatter
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    // Sadece rakam izin ver
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return const TextEditingValue(text: '');

    // Binlik ayracı ekle
    final formatted = _formatNumber(digitsOnly);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatNumber(String digits) {
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      final indexFromEnd = digits.length - i;
      buffer.write(digits[i]);
      if (indexFromEnd > 1 && indexFromEnd % 3 == 1) {
        buffer.write(',');
      }
    }
    return buffer.toString();
  }
}

/// Tamamlanan hedef kartı
class _CompletedGoalCard extends StatelessWidget {
  const _CompletedGoalCard({required this.goal, super.key});

  final CompletedGoal goal;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppShapes.lg),
        border: Border.all(color: AppColors.surfaceContainerHigh),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.successEmerald.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppShapes.md),
            ),
            child: const Icon(Icons.emoji_events_rounded, color: AppColors.successEmerald, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.goalTitle,
                  style: AppTypography.bodyBold.copyWith(color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Hedef: ${Formatting.currency(goal.targetAmount, decimal: false)} • '
                  'Biriken: ${Formatting.currency(goal.totalSavedAtCompletion, decimal: false)} • '
                  '${goal.durationDays} gün',
                  style: AppTypography.labelSubtext.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            Formatting.date(goal.completedAt),
            style: AppTypography.labelSubtext.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}