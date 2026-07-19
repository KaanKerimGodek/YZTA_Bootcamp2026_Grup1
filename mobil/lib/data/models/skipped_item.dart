import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Bir "vazgeçiş" kaydı — Backend Steering → Tablo 2: Skipped_Items.
///
/// `raw_category` kullanıcı girdisi (opsiyonel), `aiCategory` ise n8n
/// workflow'undaki LLM tarafından atanır (LLM başarısızsa [AppConstants.fallbackCategory]).
@immutable
class SkippedItem {
  const SkippedItem({
    required this.id,
    required this.userId,
    required this.name,
    required this.price,
    required this.aiCategory,
    this.rawCategory,
    required this.createdAt,
  });

  factory SkippedItem.fromJson(Map<String, dynamic> json) {
    return SkippedItem(
      id: json['item_id'] as String? ?? json['id'] as String,
      userId: json['user_id'] as String,
      name: json['item_name'] as String? ?? json['name'] as String,
      price: (json['price'] as num).toDouble(),
      rawCategory: json['raw_category'] as String?,
      aiCategory: json['ai_category'] as String? ?? json['aiCategory'] as String? ?? 'Diğer',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
    );
  }

  final String id;
  final String userId;
  final String name;
  final double price;
  final String? rawCategory;
  final String aiCategory;
  final DateTime createdAt;

  /// Kategori → gösterilecek ikon. UI katmanı bunu kullanır.
  IconData get icon => CategoryMeta.iconFor(aiCategory);

  /// Kategori → renk tonu.
  Color get color => CategoryMeta.colorFor(aiCategory);

  Map<String, dynamic> toJson() => {
        'item_id': id,
        'user_id': userId,
        'item_name': name,
        'price': price,
        'raw_category': rawCategory,
        'ai_category': aiCategory,
        'created_at': createdAt.toIso8601String(),
      };

  SkippedItem copyWith({
    String? id,
    String? userId,
    String? name,
    double? price,
    String? rawCategory,
    String? aiCategory,
    DateTime? createdAt,
  }) {
    return SkippedItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      price: price ?? this.price,
      rawCategory: rawCategory ?? this.rawCategory,
      aiCategory: aiCategory ?? this.aiCategory,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Kategori → ikon/renk eşlemesi. DESIGN.md ikonlarıyla uyumlu Material ikonlar.
///
/// Burası hem frontend hem de n8n LLM prompt'undaki kategori setiyle
/// ([AppConstants.knownCategories]) hizalıdır.
class CategoryMeta {
  CategoryMeta._();

  static const Map<String, IconData> _icons = {
    'Yemek': Icons.restaurant_outlined,
    'İçecek': Icons.local_cafe_outlined,
    'Giyim': Icons.checkroom_outlined,
    'Eğlence': Icons.movie_outlined,
    'Ulaşım': Icons.directions_car_outlined,
    'Teknoloji': Icons.devices_outlined,
    'Kişisel Bakım': Icons.spa_outlined,
    'Diğer': Icons.savings_outlined,
  };

  static const Map<String, Color> _colors = {
    'Yemek': Color(0xFFEF4444),
    'İçecek': Color(0xFFF59E0B),
    'Giyim': Color(0xFF8B5CF6),
    'Eğlence': Color(0xFFEC4899),
    'Ulaşım': Color(0xFF3B82F6),
    'Teknoloji': Color(0xFF06B6D4),
    'Kişisel Bakım': Color(0xFF14B8A6),
    'Diğer': AppColors.primary,
  };

  static IconData iconFor(String category) =>
      _icons[category] ?? Icons.savings_outlined;

  static Color colorFor(String category) =>
      _colors[category] ?? AppColors.primary;
}
