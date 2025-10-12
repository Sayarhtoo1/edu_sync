class FinanceCategory {
  final String id;
  final int? schoolId;
  final String name;
  final String type;
  final String? icon;
  final String? color;
  final String? parentCategoryId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  FinanceCategory({
    required this.id,
    this.schoolId,
    required this.name,
    required this.type,
    this.icon,
    this.color,
    this.parentCategoryId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FinanceCategory.fromJson(Map<String, dynamic> json) {
    return FinanceCategory(
      id: json['id'],
      schoolId: json['school_id'],
      name: json['name'],
      type: json['type'],
      icon: json['icon'],
      color: json['color'],
      parentCategoryId: json['parent_category_id'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_id': schoolId,
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
      'parent_category_id': parentCategoryId,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
