import 'package:floor/floor.dart';

@entity
class School {
  @primaryKey
  final int id;
  final String name;
  final String logoUrl;
  final String academicYear;
  final String theme;
  final String contact;

  School({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.academicYear,
    required this.theme,
    required this.contact,
  });

  School copyWith({
    int? id,
    String? name,
    String? logoUrl,
    String? academicYear,
    String? theme,
    String? contact,
  }) {
    return School(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      academicYear: academicYear ?? this.academicYear,
      theme: theme ?? this.theme,
      contact: contact ?? this.contact,
    );
  }
}
