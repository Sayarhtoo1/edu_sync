class School {
  final int id;
  final String name;
  final String logoUrl;
  final String academicYear;
  final String theme;
  final String contact;
  final int? hijriDayAdjustment;

  School({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.academicYear,
    required this.theme,
    required this.contact,
    this.hijriDayAdjustment,
  });

  School copyWith({
    int? id,
    String? name,
    String? logoUrl,
    String? academicYear,
    String? theme,
    String? contact,
    int? hijriDayAdjustment,
  }) {
    return School(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      academicYear: academicYear ?? this.academicYear,
      theme: theme ?? this.theme,
      contact: contact ?? this.contact,
      hijriDayAdjustment: hijriDayAdjustment ?? this.hijriDayAdjustment,
    );
  }

  factory School.fromJson(Map<String, dynamic> json) => School(
        id: json['id'] as int,
        name: json['name'] as String,
        logoUrl: json['logoUrl'] as String,
        academicYear: json['academicYear'] as String,
        theme: json['theme'] as String,
        contact: json['contact'] as String,
        hijriDayAdjustment: json['hijriDayAdjustment'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'logoUrl': logoUrl,
        'academicYear': academicYear,
        'theme': theme,
        'contact': contact,
        'hijriDayAdjustment': hijriDayAdjustment,
      };
}
