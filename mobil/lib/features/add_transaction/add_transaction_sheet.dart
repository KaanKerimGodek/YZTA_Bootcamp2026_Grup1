import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shapes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatting.dart';
import '../../data/providers/savings_providers.dart';
import '../../data/services/api_client.dart';
import '../../shared/widgets/gradient_button.dart';

/// Vazgeçiş Ekle bottom sheet.
///
/// DESIGN.md → Add Transaction (Bottom Sheet):
/// - Alt taraftan kayarak gelir, ekranın %60-80'i
/// - 32px üst köşe radius
/// - Tutar girişine odaklı, net input alanları
class AddTransactionSheet extends ConsumerStatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  ConsumerState<AddTransactionSheet> createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  String? _category;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.replaceAll(',', '.'));
    return name.isNotEmpty && price != null && price > 0;
  }

  Future<void> _submit() async {
    if (!_isFormValid || _submitting) return;
    setState(() => _submitting = true);

    try {
      final price = double.tryParse(
              _priceController.text.replaceAll(',', '.')) ??
          0;
      await submitVazgecis(
        ref,
        itemName: _nameController.text,
        price: price,
        rawCategory: _category,
      );

      if (!mounted) return;
      // Kullanıcıya pozitif geri bildirim
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.successEmerald, size: 22),
              const SizedBox(width: AppSpacing.xs + 2),
              Expanded(
                child: Text(
                  '${Formatting.saved(price)} cüzdanına eklendi 🎉',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppShapes.md),
          ),
        ),
      );
      context.pop();
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (e) {
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Başlık
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Vazgeçiş Ekle',
                      style: AppTypography.headlineSection.copyWith(
                        fontSize: 22,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: AppColors.textSecondary),
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Vazgeçtiğin harcamayı kaydet, geleceğine yatırım olsun.',
                  style: AppTypography.bodyMain.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Ürün adı
                _FieldLabel(text: 'Ne vazgeçtin?'),
                const SizedBox(height: AppSpacing.xs + 2),
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Örn. Starbucks Latte',
                    prefixIcon: Icon(Icons.shopping_bag_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Fiyat
                _FieldLabel(text: 'Tutar (₺)'),
                const SizedBox(height: AppSpacing.xs + 2),
                TextField(
                  controller: _priceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^[\d.,]+$'),
                    ),
                  ],
                  onChanged: (_) => setState(() {}),
                  style: AppTypography.bodyBold.copyWith(fontSize: 18),
                  decoration: InputDecoration(
                    hintText: '0,00',
                    prefixText: '${AppConstants.currencySymbol} ',
                    prefixIcon:
                        const Icon(Icons.account_balance_wallet_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Kategori (opsiyonel — boşsa AI atar)
                _FieldLabel(text: 'Kategori (opsiyonel)'),
                const SizedBox(height: AppSpacing.xs + 2),
                Wrap(
                  spacing: AppSpacing.xs + 2,
                  runSpacing: AppSpacing.xs + 2,
                  children: AppConstants.knownCategories.map((c) {
                    final selected = _category == c;
                    return ChoiceChip(
                      label: Text(c),
                      selected: selected,
                      onSelected: (v) => setState(
                        () => _category = v ? c : null,
                      ),
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : AppColors.textSecondary,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 13,
                      ),
                      backgroundColor: AppColors.surfaceContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppShapes.full),
                      ),
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs + 2,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Submit butonu
                GradientButton(
                  label: 'Vazgeç ve Kaydet',
                  icon: Icons.check_rounded,
                  isLoading: _submitting,
                  onPressed: _isFormValid ? _submit : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: Text(
                    'Boş bırakırsan kategoriyi AI otomatik atayacak.',
                    style: AppTypography.labelSubtext.copyWith(
                      color: AppColors.textSecondary,
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

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.labelCaps.copyWith(
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }
}
