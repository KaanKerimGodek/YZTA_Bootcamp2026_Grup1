import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shapes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Ana Sayfada günün motivasyon sözünü gösteren şık metin kartı.
///
/// DESIGN.md → Motivasyon Kartı:
/// - Gradient arka plan (Primary → Emerald, düşük opaklık)
/// - Sol tarafta dekoratif ikon
/// - Şık tipografi, yumuşak gölge
/// - Günlük değişen motivasyon metni
class MotivationQuoteCard extends StatelessWidget {
  const MotivationQuoteCard({
    super.key,
    required this.quote,
    this.author,
    this.icon = Icons.format_quote_rounded,
    this.onTap,
  });

  final String quote;
  final String? author;
  final IconData icon;
  final VoidCallback? onTap;

  /// Günlük motivasyon sözleri havuzu.
  static const List<Quote> _quotes = [
    Quote(
      'Küçük vazgeçişler, büyük birikimler yaratır.',
      'Vazgeçtim Felsefesi',
    ),
    Quote(
      'Bugün yaptığın bir vazgeçiş, yarın için bir özgürlük.',
      'Anonim',
    ),
    Quote(
      'Disiplin, motivasyonun yerine geçen süper güçtür.',
      'James Clear',
    ),
    Quote(
      'Her "hayır" dendiğinde, geleceğine "evet" dersin.',
      'Vazgeçtim Felsefesi',
    ),
    Quote(
      'Tasarruf, kendine yapabileceğin en güzel hediyedir.',
      'Warren Buffett',
    ),
    Quote(
      'Zenginlik, ne kazandığın değil, ne biriktirdiğinle ölçülür.',
      'Anonim',
    ),
    Quote(
      'Küçük alışkanlıklar, zamanla devasa sonuçlar doğurur.',
      'Atomik Alışkanlıklar',
    ),
    Quote(
      'Bugün vazgeçtiğin şey, yarın hayal ettiğin şeydir.',
      'Vazgeçtim Felsefesi',
    ),
    Quote(
      'Sabır ve istikrar, finansal özgürlüğün iki anahtarıdır.',
      'Anonim',
    ),
    Quote(
      'Her büyük yolculuk, tek bir adımla başlar. Bugün senin adım günün.',
      'Lao Tzu',
    ),
  ];

  /// Günün tarihine göre deterministik bir söz seçer.
  static Quote getDailyQuote() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return _quotes[dayOfYear % _quotes.length];
  }

  @override
  Widget build(BuildContext context) {
    final dailyQuote = quote.isNotEmpty ? quote : getDailyQuote().text;
    final dailyAuthor = author ?? getDailyQuote().author;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.successEmerald.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(AppShapes.xl),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppShapes.xl),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppShapes.xl),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sol dekoratif ikon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.15),
                        AppColors.successEmerald.withValues(alpha: 0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppShapes.md),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Söz metni
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Günün Motivasyonu',
                        style: AppTypography.labelCaps.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs + 2),
                      Text(
                        '"$dailyQuote"',
                        style: AppTypography.bodyMain.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.5,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      if (dailyAuthor.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs + 2),
                        Text(
                          '— $dailyAuthor',
                          style: AppTypography.labelSubtext.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
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

/// Motivasyon sözü veri sınıfı.
class Quote {
  const Quote(this.text, this.author);
  final String text;
  final String author;
}