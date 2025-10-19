// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SchoolsTable extends Schools with TableInfo<$SchoolsTable, School> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SchoolsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _logoUrlMeta = const VerificationMeta(
    'logoUrl',
  );
  @override
  late final GeneratedColumn<String> logoUrl = GeneratedColumn<String>(
    'logo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _academicYearMeta = const VerificationMeta(
    'academicYear',
  );
  @override
  late final GeneratedColumn<String> academicYear = GeneratedColumn<String>(
    'academic_year',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _themeMeta = const VerificationMeta('theme');
  @override
  late final GeneratedColumn<String> theme = GeneratedColumn<String>(
    'theme',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contactInfoMeta = const VerificationMeta(
    'contactInfo',
  );
  @override
  late final GeneratedColumn<String> contactInfo = GeneratedColumn<String>(
    'contact_info',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hijriDayAdjustmentMeta =
      const VerificationMeta('hijriDayAdjustment');
  @override
  late final GeneratedColumn<int> hijriDayAdjustment = GeneratedColumn<int>(
    'hijri_day_adjustment',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    logoUrl,
    academicYear,
    theme,
    contactInfo,
    createdAt,
    updatedAt,
    hijriDayAdjustment,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schools';
  @override
  VerificationContext validateIntegrity(
    Insertable<School> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('logo_url')) {
      context.handle(
        _logoUrlMeta,
        logoUrl.isAcceptableOrUnknown(data['logo_url']!, _logoUrlMeta),
      );
    }
    if (data.containsKey('academic_year')) {
      context.handle(
        _academicYearMeta,
        academicYear.isAcceptableOrUnknown(
          data['academic_year']!,
          _academicYearMeta,
        ),
      );
    }
    if (data.containsKey('theme')) {
      context.handle(
        _themeMeta,
        theme.isAcceptableOrUnknown(data['theme']!, _themeMeta),
      );
    }
    if (data.containsKey('contact_info')) {
      context.handle(
        _contactInfoMeta,
        contactInfo.isAcceptableOrUnknown(
          data['contact_info']!,
          _contactInfoMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('hijri_day_adjustment')) {
      context.handle(
        _hijriDayAdjustmentMeta,
        hijriDayAdjustment.isAcceptableOrUnknown(
          data['hijri_day_adjustment']!,
          _hijriDayAdjustmentMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  School map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return School(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      logoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logo_url'],
      ),
      academicYear: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}academic_year'],
      ),
      theme: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme'],
      ),
      contactInfo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_info'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      hijriDayAdjustment: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hijri_day_adjustment'],
      ),
    );
  }

  @override
  $SchoolsTable createAlias(String alias) {
    return $SchoolsTable(attachedDatabase, alias);
  }
}

class School extends DataClass implements Insertable<School> {
  final int id;
  final String name;
  final String? logoUrl;
  final String? academicYear;
  final String? theme;
  final String? contactInfo;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? hijriDayAdjustment;
  const School({
    required this.id,
    required this.name,
    this.logoUrl,
    this.academicYear,
    this.theme,
    this.contactInfo,
    this.createdAt,
    this.updatedAt,
    this.hijriDayAdjustment,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || logoUrl != null) {
      map['logo_url'] = Variable<String>(logoUrl);
    }
    if (!nullToAbsent || academicYear != null) {
      map['academic_year'] = Variable<String>(academicYear);
    }
    if (!nullToAbsent || theme != null) {
      map['theme'] = Variable<String>(theme);
    }
    if (!nullToAbsent || contactInfo != null) {
      map['contact_info'] = Variable<String>(contactInfo);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || hijriDayAdjustment != null) {
      map['hijri_day_adjustment'] = Variable<int>(hijriDayAdjustment);
    }
    return map;
  }

  SchoolsCompanion toCompanion(bool nullToAbsent) {
    return SchoolsCompanion(
      id: Value(id),
      name: Value(name),
      logoUrl:
          logoUrl == null && nullToAbsent
              ? const Value.absent()
              : Value(logoUrl),
      academicYear:
          academicYear == null && nullToAbsent
              ? const Value.absent()
              : Value(academicYear),
      theme:
          theme == null && nullToAbsent ? const Value.absent() : Value(theme),
      contactInfo:
          contactInfo == null && nullToAbsent
              ? const Value.absent()
              : Value(contactInfo),
      createdAt:
          createdAt == null && nullToAbsent
              ? const Value.absent()
              : Value(createdAt),
      updatedAt:
          updatedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(updatedAt),
      hijriDayAdjustment:
          hijriDayAdjustment == null && nullToAbsent
              ? const Value.absent()
              : Value(hijriDayAdjustment),
    );
  }

  factory School.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return School(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      logoUrl: serializer.fromJson<String?>(json['logoUrl']),
      academicYear: serializer.fromJson<String?>(json['academicYear']),
      theme: serializer.fromJson<String?>(json['theme']),
      contactInfo: serializer.fromJson<String?>(json['contactInfo']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      hijriDayAdjustment: serializer.fromJson<int?>(json['hijriDayAdjustment']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'logoUrl': serializer.toJson<String?>(logoUrl),
      'academicYear': serializer.toJson<String?>(academicYear),
      'theme': serializer.toJson<String?>(theme),
      'contactInfo': serializer.toJson<String?>(contactInfo),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'hijriDayAdjustment': serializer.toJson<int?>(hijriDayAdjustment),
    };
  }

  School copyWith({
    int? id,
    String? name,
    Value<String?> logoUrl = const Value.absent(),
    Value<String?> academicYear = const Value.absent(),
    Value<String?> theme = const Value.absent(),
    Value<String?> contactInfo = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<int?> hijriDayAdjustment = const Value.absent(),
  }) => School(
    id: id ?? this.id,
    name: name ?? this.name,
    logoUrl: logoUrl.present ? logoUrl.value : this.logoUrl,
    academicYear: academicYear.present ? academicYear.value : this.academicYear,
    theme: theme.present ? theme.value : this.theme,
    contactInfo: contactInfo.present ? contactInfo.value : this.contactInfo,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    hijriDayAdjustment:
        hijriDayAdjustment.present
            ? hijriDayAdjustment.value
            : this.hijriDayAdjustment,
  );
  School copyWithCompanion(SchoolsCompanion data) {
    return School(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      logoUrl: data.logoUrl.present ? data.logoUrl.value : this.logoUrl,
      academicYear:
          data.academicYear.present
              ? data.academicYear.value
              : this.academicYear,
      theme: data.theme.present ? data.theme.value : this.theme,
      contactInfo:
          data.contactInfo.present ? data.contactInfo.value : this.contactInfo,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      hijriDayAdjustment:
          data.hijriDayAdjustment.present
              ? data.hijriDayAdjustment.value
              : this.hijriDayAdjustment,
    );
  }

  @override
  String toString() {
    return (StringBuffer('School(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('academicYear: $academicYear, ')
          ..write('theme: $theme, ')
          ..write('contactInfo: $contactInfo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('hijriDayAdjustment: $hijriDayAdjustment')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    logoUrl,
    academicYear,
    theme,
    contactInfo,
    createdAt,
    updatedAt,
    hijriDayAdjustment,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is School &&
          other.id == this.id &&
          other.name == this.name &&
          other.logoUrl == this.logoUrl &&
          other.academicYear == this.academicYear &&
          other.theme == this.theme &&
          other.contactInfo == this.contactInfo &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.hijriDayAdjustment == this.hijriDayAdjustment);
}

class SchoolsCompanion extends UpdateCompanion<School> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> logoUrl;
  final Value<String?> academicYear;
  final Value<String?> theme;
  final Value<String?> contactInfo;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int?> hijriDayAdjustment;
  const SchoolsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.logoUrl = const Value.absent(),
    this.academicYear = const Value.absent(),
    this.theme = const Value.absent(),
    this.contactInfo = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.hijriDayAdjustment = const Value.absent(),
  });
  SchoolsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.logoUrl = const Value.absent(),
    this.academicYear = const Value.absent(),
    this.theme = const Value.absent(),
    this.contactInfo = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.hijriDayAdjustment = const Value.absent(),
  }) : name = Value(name);
  static Insertable<School> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? logoUrl,
    Expression<String>? academicYear,
    Expression<String>? theme,
    Expression<String>? contactInfo,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? hijriDayAdjustment,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (logoUrl != null) 'logo_url': logoUrl,
      if (academicYear != null) 'academic_year': academicYear,
      if (theme != null) 'theme': theme,
      if (contactInfo != null) 'contact_info': contactInfo,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (hijriDayAdjustment != null)
        'hijri_day_adjustment': hijriDayAdjustment,
    });
  }

  SchoolsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? logoUrl,
    Value<String?>? academicYear,
    Value<String?>? theme,
    Value<String?>? contactInfo,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<int?>? hijriDayAdjustment,
  }) {
    return SchoolsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      academicYear: academicYear ?? this.academicYear,
      theme: theme ?? this.theme,
      contactInfo: contactInfo ?? this.contactInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hijriDayAdjustment: hijriDayAdjustment ?? this.hijriDayAdjustment,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (logoUrl.present) {
      map['logo_url'] = Variable<String>(logoUrl.value);
    }
    if (academicYear.present) {
      map['academic_year'] = Variable<String>(academicYear.value);
    }
    if (theme.present) {
      map['theme'] = Variable<String>(theme.value);
    }
    if (contactInfo.present) {
      map['contact_info'] = Variable<String>(contactInfo.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (hijriDayAdjustment.present) {
      map['hijri_day_adjustment'] = Variable<int>(hijriDayAdjustment.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SchoolsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('academicYear: $academicYear, ')
          ..write('theme: $theme, ')
          ..write('contactInfo: $contactInfo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('hijriDayAdjustment: $hijriDayAdjustment')
          ..write(')'))
        .toString();
  }
}

class $StudentsTable extends Students with TableInfo<$StudentsTable, Student> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  @override
  late final GeneratedColumn<int> schoolId = GeneratedColumn<int>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _classIdMeta = const VerificationMeta(
    'classId',
  );
  @override
  late final GeneratedColumn<int> classId = GeneratedColumn<int>(
    'class_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profilePhotoUrlMeta = const VerificationMeta(
    'profilePhotoUrl',
  );
  @override
  late final GeneratedColumn<String> profilePhotoUrl = GeneratedColumn<String>(
    'profile_photo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateOfBirthMeta = const VerificationMeta(
    'dateOfBirth',
  );
  @override
  late final GeneratedColumn<DateTime> dateOfBirth = GeneratedColumn<DateTime>(
    'date_of_birth',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneNumber1Meta = const VerificationMeta(
    'phoneNumber1',
  );
  @override
  late final GeneratedColumn<String> phoneNumber1 = GeneratedColumn<String>(
    'phone_number_1',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneNumber2Meta = const VerificationMeta(
    'phoneNumber2',
  );
  @override
  late final GeneratedColumn<String> phoneNumber2 = GeneratedColumn<String>(
    'phone_number_2',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    schoolId,
    classId,
    fullName,
    profilePhotoUrl,
    dateOfBirth,
    createdAt,
    updatedAt,
    gender,
    phoneNumber1,
    phoneNumber2,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'students';
  @override
  VerificationContext validateIntegrity(
    Insertable<Student> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('class_id')) {
      context.handle(
        _classIdMeta,
        classId.isAcceptableOrUnknown(data['class_id']!, _classIdMeta),
      );
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('profile_photo_url')) {
      context.handle(
        _profilePhotoUrlMeta,
        profilePhotoUrl.isAcceptableOrUnknown(
          data['profile_photo_url']!,
          _profilePhotoUrlMeta,
        ),
      );
    }
    if (data.containsKey('date_of_birth')) {
      context.handle(
        _dateOfBirthMeta,
        dateOfBirth.isAcceptableOrUnknown(
          data['date_of_birth']!,
          _dateOfBirthMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    }
    if (data.containsKey('phone_number_1')) {
      context.handle(
        _phoneNumber1Meta,
        phoneNumber1.isAcceptableOrUnknown(
          data['phone_number_1']!,
          _phoneNumber1Meta,
        ),
      );
    }
    if (data.containsKey('phone_number_2')) {
      context.handle(
        _phoneNumber2Meta,
        phoneNumber2.isAcceptableOrUnknown(
          data['phone_number_2']!,
          _phoneNumber2Meta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Student map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Student(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      schoolId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}school_id'],
          )!,
      classId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}class_id'],
      ),
      fullName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}full_name'],
          )!,
      profilePhotoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_photo_url'],
      ),
      dateOfBirth: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_of_birth'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      ),
      phoneNumber1: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number_1'],
      ),
      phoneNumber2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number_2'],
      ),
    );
  }

  @override
  $StudentsTable createAlias(String alias) {
    return $StudentsTable(attachedDatabase, alias);
  }
}

class Student extends DataClass implements Insertable<Student> {
  final int id;
  final int schoolId;
  final int? classId;
  final String fullName;
  final String? profilePhotoUrl;
  final DateTime? dateOfBirth;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? gender;
  final String? phoneNumber1;
  final String? phoneNumber2;
  const Student({
    required this.id,
    required this.schoolId,
    this.classId,
    required this.fullName,
    this.profilePhotoUrl,
    this.dateOfBirth,
    this.createdAt,
    this.updatedAt,
    this.gender,
    this.phoneNumber1,
    this.phoneNumber2,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['school_id'] = Variable<int>(schoolId);
    if (!nullToAbsent || classId != null) {
      map['class_id'] = Variable<int>(classId);
    }
    map['full_name'] = Variable<String>(fullName);
    if (!nullToAbsent || profilePhotoUrl != null) {
      map['profile_photo_url'] = Variable<String>(profilePhotoUrl);
    }
    if (!nullToAbsent || dateOfBirth != null) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<String>(gender);
    }
    if (!nullToAbsent || phoneNumber1 != null) {
      map['phone_number_1'] = Variable<String>(phoneNumber1);
    }
    if (!nullToAbsent || phoneNumber2 != null) {
      map['phone_number_2'] = Variable<String>(phoneNumber2);
    }
    return map;
  }

  StudentsCompanion toCompanion(bool nullToAbsent) {
    return StudentsCompanion(
      id: Value(id),
      schoolId: Value(schoolId),
      classId:
          classId == null && nullToAbsent
              ? const Value.absent()
              : Value(classId),
      fullName: Value(fullName),
      profilePhotoUrl:
          profilePhotoUrl == null && nullToAbsent
              ? const Value.absent()
              : Value(profilePhotoUrl),
      dateOfBirth:
          dateOfBirth == null && nullToAbsent
              ? const Value.absent()
              : Value(dateOfBirth),
      createdAt:
          createdAt == null && nullToAbsent
              ? const Value.absent()
              : Value(createdAt),
      updatedAt:
          updatedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(updatedAt),
      gender:
          gender == null && nullToAbsent ? const Value.absent() : Value(gender),
      phoneNumber1:
          phoneNumber1 == null && nullToAbsent
              ? const Value.absent()
              : Value(phoneNumber1),
      phoneNumber2:
          phoneNumber2 == null && nullToAbsent
              ? const Value.absent()
              : Value(phoneNumber2),
    );
  }

  factory Student.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Student(
      id: serializer.fromJson<int>(json['id']),
      schoolId: serializer.fromJson<int>(json['schoolId']),
      classId: serializer.fromJson<int?>(json['classId']),
      fullName: serializer.fromJson<String>(json['fullName']),
      profilePhotoUrl: serializer.fromJson<String?>(json['profilePhotoUrl']),
      dateOfBirth: serializer.fromJson<DateTime?>(json['dateOfBirth']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      gender: serializer.fromJson<String?>(json['gender']),
      phoneNumber1: serializer.fromJson<String?>(json['phoneNumber1']),
      phoneNumber2: serializer.fromJson<String?>(json['phoneNumber2']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'schoolId': serializer.toJson<int>(schoolId),
      'classId': serializer.toJson<int?>(classId),
      'fullName': serializer.toJson<String>(fullName),
      'profilePhotoUrl': serializer.toJson<String?>(profilePhotoUrl),
      'dateOfBirth': serializer.toJson<DateTime?>(dateOfBirth),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'gender': serializer.toJson<String?>(gender),
      'phoneNumber1': serializer.toJson<String?>(phoneNumber1),
      'phoneNumber2': serializer.toJson<String?>(phoneNumber2),
    };
  }

  Student copyWith({
    int? id,
    int? schoolId,
    Value<int?> classId = const Value.absent(),
    String? fullName,
    Value<String?> profilePhotoUrl = const Value.absent(),
    Value<DateTime?> dateOfBirth = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<String?> gender = const Value.absent(),
    Value<String?> phoneNumber1 = const Value.absent(),
    Value<String?> phoneNumber2 = const Value.absent(),
  }) => Student(
    id: id ?? this.id,
    schoolId: schoolId ?? this.schoolId,
    classId: classId.present ? classId.value : this.classId,
    fullName: fullName ?? this.fullName,
    profilePhotoUrl:
        profilePhotoUrl.present ? profilePhotoUrl.value : this.profilePhotoUrl,
    dateOfBirth: dateOfBirth.present ? dateOfBirth.value : this.dateOfBirth,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    gender: gender.present ? gender.value : this.gender,
    phoneNumber1: phoneNumber1.present ? phoneNumber1.value : this.phoneNumber1,
    phoneNumber2: phoneNumber2.present ? phoneNumber2.value : this.phoneNumber2,
  );
  Student copyWithCompanion(StudentsCompanion data) {
    return Student(
      id: data.id.present ? data.id.value : this.id,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      classId: data.classId.present ? data.classId.value : this.classId,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      profilePhotoUrl:
          data.profilePhotoUrl.present
              ? data.profilePhotoUrl.value
              : this.profilePhotoUrl,
      dateOfBirth:
          data.dateOfBirth.present ? data.dateOfBirth.value : this.dateOfBirth,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      gender: data.gender.present ? data.gender.value : this.gender,
      phoneNumber1:
          data.phoneNumber1.present
              ? data.phoneNumber1.value
              : this.phoneNumber1,
      phoneNumber2:
          data.phoneNumber2.present
              ? data.phoneNumber2.value
              : this.phoneNumber2,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Student(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('classId: $classId, ')
          ..write('fullName: $fullName, ')
          ..write('profilePhotoUrl: $profilePhotoUrl, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('gender: $gender, ')
          ..write('phoneNumber1: $phoneNumber1, ')
          ..write('phoneNumber2: $phoneNumber2')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    schoolId,
    classId,
    fullName,
    profilePhotoUrl,
    dateOfBirth,
    createdAt,
    updatedAt,
    gender,
    phoneNumber1,
    phoneNumber2,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Student &&
          other.id == this.id &&
          other.schoolId == this.schoolId &&
          other.classId == this.classId &&
          other.fullName == this.fullName &&
          other.profilePhotoUrl == this.profilePhotoUrl &&
          other.dateOfBirth == this.dateOfBirth &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.gender == this.gender &&
          other.phoneNumber1 == this.phoneNumber1 &&
          other.phoneNumber2 == this.phoneNumber2);
}

class StudentsCompanion extends UpdateCompanion<Student> {
  final Value<int> id;
  final Value<int> schoolId;
  final Value<int?> classId;
  final Value<String> fullName;
  final Value<String?> profilePhotoUrl;
  final Value<DateTime?> dateOfBirth;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<String?> gender;
  final Value<String?> phoneNumber1;
  final Value<String?> phoneNumber2;
  const StudentsCompanion({
    this.id = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.classId = const Value.absent(),
    this.fullName = const Value.absent(),
    this.profilePhotoUrl = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.gender = const Value.absent(),
    this.phoneNumber1 = const Value.absent(),
    this.phoneNumber2 = const Value.absent(),
  });
  StudentsCompanion.insert({
    this.id = const Value.absent(),
    required int schoolId,
    this.classId = const Value.absent(),
    required String fullName,
    this.profilePhotoUrl = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.gender = const Value.absent(),
    this.phoneNumber1 = const Value.absent(),
    this.phoneNumber2 = const Value.absent(),
  }) : schoolId = Value(schoolId),
       fullName = Value(fullName);
  static Insertable<Student> custom({
    Expression<int>? id,
    Expression<int>? schoolId,
    Expression<int>? classId,
    Expression<String>? fullName,
    Expression<String>? profilePhotoUrl,
    Expression<DateTime>? dateOfBirth,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? gender,
    Expression<String>? phoneNumber1,
    Expression<String>? phoneNumber2,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schoolId != null) 'school_id': schoolId,
      if (classId != null) 'class_id': classId,
      if (fullName != null) 'full_name': fullName,
      if (profilePhotoUrl != null) 'profile_photo_url': profilePhotoUrl,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (gender != null) 'gender': gender,
      if (phoneNumber1 != null) 'phone_number_1': phoneNumber1,
      if (phoneNumber2 != null) 'phone_number_2': phoneNumber2,
    });
  }

  StudentsCompanion copyWith({
    Value<int>? id,
    Value<int>? schoolId,
    Value<int?>? classId,
    Value<String>? fullName,
    Value<String?>? profilePhotoUrl,
    Value<DateTime?>? dateOfBirth,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<String?>? gender,
    Value<String?>? phoneNumber1,
    Value<String?>? phoneNumber2,
  }) {
    return StudentsCompanion(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      classId: classId ?? this.classId,
      fullName: fullName ?? this.fullName,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      gender: gender ?? this.gender,
      phoneNumber1: phoneNumber1 ?? this.phoneNumber1,
      phoneNumber2: phoneNumber2 ?? this.phoneNumber2,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<int>(schoolId.value);
    }
    if (classId.present) {
      map['class_id'] = Variable<int>(classId.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (profilePhotoUrl.present) {
      map['profile_photo_url'] = Variable<String>(profilePhotoUrl.value);
    }
    if (dateOfBirth.present) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (phoneNumber1.present) {
      map['phone_number_1'] = Variable<String>(phoneNumber1.value);
    }
    if (phoneNumber2.present) {
      map['phone_number_2'] = Variable<String>(phoneNumber2.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudentsCompanion(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('classId: $classId, ')
          ..write('fullName: $fullName, ')
          ..write('profilePhotoUrl: $profilePhotoUrl, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('gender: $gender, ')
          ..write('phoneNumber1: $phoneNumber1, ')
          ..write('phoneNumber2: $phoneNumber2')
          ..write(')'))
        .toString();
  }
}

class $ClassesTable extends Classes with TableInfo<$ClassesTable, ClassesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClassesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  @override
  late final GeneratedColumn<int> schoolId = GeneratedColumn<int>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _teacherIdMeta = const VerificationMeta(
    'teacherId',
  );
  @override
  late final GeneratedColumn<String> teacherId = GeneratedColumn<String>(
    'teacher_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sectionMeta = const VerificationMeta(
    'section',
  );
  @override
  late final GeneratedColumn<String> section = GeneratedColumn<String>(
    'section',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    schoolId,
    name,
    teacherId,
    createdAt,
    updatedAt,
    section,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'classes';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClassesData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('teacher_id')) {
      context.handle(
        _teacherIdMeta,
        teacherId.isAcceptableOrUnknown(data['teacher_id']!, _teacherIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('section')) {
      context.handle(
        _sectionMeta,
        section.isAcceptableOrUnknown(data['section']!, _sectionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClassesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClassesData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      schoolId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}school_id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      teacherId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}teacher_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      section: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}section'],
      ),
    );
  }

  @override
  $ClassesTable createAlias(String alias) {
    return $ClassesTable(attachedDatabase, alias);
  }
}

class ClassesData extends DataClass implements Insertable<ClassesData> {
  final int id;
  final int schoolId;
  final String name;
  final String? teacherId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? section;
  const ClassesData({
    required this.id,
    required this.schoolId,
    required this.name,
    this.teacherId,
    this.createdAt,
    this.updatedAt,
    this.section,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['school_id'] = Variable<int>(schoolId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || teacherId != null) {
      map['teacher_id'] = Variable<String>(teacherId);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || section != null) {
      map['section'] = Variable<String>(section);
    }
    return map;
  }

  ClassesCompanion toCompanion(bool nullToAbsent) {
    return ClassesCompanion(
      id: Value(id),
      schoolId: Value(schoolId),
      name: Value(name),
      teacherId:
          teacherId == null && nullToAbsent
              ? const Value.absent()
              : Value(teacherId),
      createdAt:
          createdAt == null && nullToAbsent
              ? const Value.absent()
              : Value(createdAt),
      updatedAt:
          updatedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(updatedAt),
      section:
          section == null && nullToAbsent
              ? const Value.absent()
              : Value(section),
    );
  }

  factory ClassesData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClassesData(
      id: serializer.fromJson<int>(json['id']),
      schoolId: serializer.fromJson<int>(json['schoolId']),
      name: serializer.fromJson<String>(json['name']),
      teacherId: serializer.fromJson<String?>(json['teacherId']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      section: serializer.fromJson<String?>(json['section']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'schoolId': serializer.toJson<int>(schoolId),
      'name': serializer.toJson<String>(name),
      'teacherId': serializer.toJson<String?>(teacherId),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'section': serializer.toJson<String?>(section),
    };
  }

  ClassesData copyWith({
    int? id,
    int? schoolId,
    String? name,
    Value<String?> teacherId = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<String?> section = const Value.absent(),
  }) => ClassesData(
    id: id ?? this.id,
    schoolId: schoolId ?? this.schoolId,
    name: name ?? this.name,
    teacherId: teacherId.present ? teacherId.value : this.teacherId,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    section: section.present ? section.value : this.section,
  );
  ClassesData copyWithCompanion(ClassesCompanion data) {
    return ClassesData(
      id: data.id.present ? data.id.value : this.id,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      name: data.name.present ? data.name.value : this.name,
      teacherId: data.teacherId.present ? data.teacherId.value : this.teacherId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      section: data.section.present ? data.section.value : this.section,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClassesData(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('name: $name, ')
          ..write('teacherId: $teacherId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('section: $section')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, schoolId, name, teacherId, createdAt, updatedAt, section);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClassesData &&
          other.id == this.id &&
          other.schoolId == this.schoolId &&
          other.name == this.name &&
          other.teacherId == this.teacherId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.section == this.section);
}

class ClassesCompanion extends UpdateCompanion<ClassesData> {
  final Value<int> id;
  final Value<int> schoolId;
  final Value<String> name;
  final Value<String?> teacherId;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<String?> section;
  const ClassesCompanion({
    this.id = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.name = const Value.absent(),
    this.teacherId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.section = const Value.absent(),
  });
  ClassesCompanion.insert({
    this.id = const Value.absent(),
    required int schoolId,
    required String name,
    this.teacherId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.section = const Value.absent(),
  }) : schoolId = Value(schoolId),
       name = Value(name);
  static Insertable<ClassesData> custom({
    Expression<int>? id,
    Expression<int>? schoolId,
    Expression<String>? name,
    Expression<String>? teacherId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? section,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schoolId != null) 'school_id': schoolId,
      if (name != null) 'name': name,
      if (teacherId != null) 'teacher_id': teacherId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (section != null) 'section': section,
    });
  }

  ClassesCompanion copyWith({
    Value<int>? id,
    Value<int>? schoolId,
    Value<String>? name,
    Value<String?>? teacherId,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<String?>? section,
  }) {
    return ClassesCompanion(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      name: name ?? this.name,
      teacherId: teacherId ?? this.teacherId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      section: section ?? this.section,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<int>(schoolId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (teacherId.present) {
      map['teacher_id'] = Variable<String>(teacherId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (section.present) {
      map['section'] = Variable<String>(section.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClassesCompanion(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('name: $name, ')
          ..write('teacherId: $teacherId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('section: $section')
          ..write(')'))
        .toString();
  }
}

class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profilePhotoUrlMeta = const VerificationMeta(
    'profilePhotoUrl',
  );
  @override
  late final GeneratedColumn<String> profilePhotoUrl = GeneratedColumn<String>(
    'profile_photo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  @override
  late final GeneratedColumn<int> schoolId = GeneratedColumn<int>(
    'school_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneNumber1Meta = const VerificationMeta(
    'phoneNumber1',
  );
  @override
  late final GeneratedColumn<String> phoneNumber1 = GeneratedColumn<String>(
    'phone_number_1',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _salaryMeta = const VerificationMeta('salary');
  @override
  late final GeneratedColumn<double> salary = GeneratedColumn<double>(
    'salary',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneNumber2Meta = const VerificationMeta(
    'phoneNumber2',
  );
  @override
  late final GeneratedColumn<String> phoneNumber2 = GeneratedColumn<String>(
    'phone_number_2',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fullName,
    role,
    profilePhotoUrl,
    schoolId,
    createdAt,
    updatedAt,
    email,
    phoneNumber1,
    salary,
    phoneNumber2,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('profile_photo_url')) {
      context.handle(
        _profilePhotoUrlMeta,
        profilePhotoUrl.isAcceptableOrUnknown(
          data['profile_photo_url']!,
          _profilePhotoUrlMeta,
        ),
      );
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('phone_number_1')) {
      context.handle(
        _phoneNumber1Meta,
        phoneNumber1.isAcceptableOrUnknown(
          data['phone_number_1']!,
          _phoneNumber1Meta,
        ),
      );
    }
    if (data.containsKey('salary')) {
      context.handle(
        _salaryMeta,
        salary.isAcceptableOrUnknown(data['salary']!, _salaryMeta),
      );
    }
    if (data.containsKey('phone_number_2')) {
      context.handle(
        _phoneNumber2Meta,
        phoneNumber2.isAcceptableOrUnknown(
          data['phone_number_2']!,
          _phoneNumber2Meta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      ),
      role:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}role'],
          )!,
      profilePhotoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_photo_url'],
      ),
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}school_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      phoneNumber1: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number_1'],
      ),
      salary: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}salary'],
      ),
      phoneNumber2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number_2'],
      ),
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final String id;
  final String? fullName;
  final String role;
  final String? profilePhotoUrl;
  final int? schoolId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? email;
  final String? phoneNumber1;
  final double? salary;
  final String? phoneNumber2;
  const User({
    required this.id,
    this.fullName,
    required this.role,
    this.profilePhotoUrl,
    this.schoolId,
    this.createdAt,
    this.updatedAt,
    this.email,
    this.phoneNumber1,
    this.salary,
    this.phoneNumber2,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || fullName != null) {
      map['full_name'] = Variable<String>(fullName);
    }
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || profilePhotoUrl != null) {
      map['profile_photo_url'] = Variable<String>(profilePhotoUrl);
    }
    if (!nullToAbsent || schoolId != null) {
      map['school_id'] = Variable<int>(schoolId);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || phoneNumber1 != null) {
      map['phone_number_1'] = Variable<String>(phoneNumber1);
    }
    if (!nullToAbsent || salary != null) {
      map['salary'] = Variable<double>(salary);
    }
    if (!nullToAbsent || phoneNumber2 != null) {
      map['phone_number_2'] = Variable<String>(phoneNumber2);
    }
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      fullName:
          fullName == null && nullToAbsent
              ? const Value.absent()
              : Value(fullName),
      role: Value(role),
      profilePhotoUrl:
          profilePhotoUrl == null && nullToAbsent
              ? const Value.absent()
              : Value(profilePhotoUrl),
      schoolId:
          schoolId == null && nullToAbsent
              ? const Value.absent()
              : Value(schoolId),
      createdAt:
          createdAt == null && nullToAbsent
              ? const Value.absent()
              : Value(createdAt),
      updatedAt:
          updatedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(updatedAt),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      phoneNumber1:
          phoneNumber1 == null && nullToAbsent
              ? const Value.absent()
              : Value(phoneNumber1),
      salary:
          salary == null && nullToAbsent ? const Value.absent() : Value(salary),
      phoneNumber2:
          phoneNumber2 == null && nullToAbsent
              ? const Value.absent()
              : Value(phoneNumber2),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      fullName: serializer.fromJson<String?>(json['fullName']),
      role: serializer.fromJson<String>(json['role']),
      profilePhotoUrl: serializer.fromJson<String?>(json['profilePhotoUrl']),
      schoolId: serializer.fromJson<int?>(json['schoolId']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      email: serializer.fromJson<String?>(json['email']),
      phoneNumber1: serializer.fromJson<String?>(json['phoneNumber1']),
      salary: serializer.fromJson<double?>(json['salary']),
      phoneNumber2: serializer.fromJson<String?>(json['phoneNumber2']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fullName': serializer.toJson<String?>(fullName),
      'role': serializer.toJson<String>(role),
      'profilePhotoUrl': serializer.toJson<String?>(profilePhotoUrl),
      'schoolId': serializer.toJson<int?>(schoolId),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'email': serializer.toJson<String?>(email),
      'phoneNumber1': serializer.toJson<String?>(phoneNumber1),
      'salary': serializer.toJson<double?>(salary),
      'phoneNumber2': serializer.toJson<String?>(phoneNumber2),
    };
  }

  User copyWith({
    String? id,
    Value<String?> fullName = const Value.absent(),
    String? role,
    Value<String?> profilePhotoUrl = const Value.absent(),
    Value<int?> schoolId = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> phoneNumber1 = const Value.absent(),
    Value<double?> salary = const Value.absent(),
    Value<String?> phoneNumber2 = const Value.absent(),
  }) => User(
    id: id ?? this.id,
    fullName: fullName.present ? fullName.value : this.fullName,
    role: role ?? this.role,
    profilePhotoUrl:
        profilePhotoUrl.present ? profilePhotoUrl.value : this.profilePhotoUrl,
    schoolId: schoolId.present ? schoolId.value : this.schoolId,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    email: email.present ? email.value : this.email,
    phoneNumber1: phoneNumber1.present ? phoneNumber1.value : this.phoneNumber1,
    salary: salary.present ? salary.value : this.salary,
    phoneNumber2: phoneNumber2.present ? phoneNumber2.value : this.phoneNumber2,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      role: data.role.present ? data.role.value : this.role,
      profilePhotoUrl:
          data.profilePhotoUrl.present
              ? data.profilePhotoUrl.value
              : this.profilePhotoUrl,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      email: data.email.present ? data.email.value : this.email,
      phoneNumber1:
          data.phoneNumber1.present
              ? data.phoneNumber1.value
              : this.phoneNumber1,
      salary: data.salary.present ? data.salary.value : this.salary,
      phoneNumber2:
          data.phoneNumber2.present
              ? data.phoneNumber2.value
              : this.phoneNumber2,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('role: $role, ')
          ..write('profilePhotoUrl: $profilePhotoUrl, ')
          ..write('schoolId: $schoolId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('email: $email, ')
          ..write('phoneNumber1: $phoneNumber1, ')
          ..write('salary: $salary, ')
          ..write('phoneNumber2: $phoneNumber2')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    fullName,
    role,
    profilePhotoUrl,
    schoolId,
    createdAt,
    updatedAt,
    email,
    phoneNumber1,
    salary,
    phoneNumber2,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.fullName == this.fullName &&
          other.role == this.role &&
          other.profilePhotoUrl == this.profilePhotoUrl &&
          other.schoolId == this.schoolId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.email == this.email &&
          other.phoneNumber1 == this.phoneNumber1 &&
          other.salary == this.salary &&
          other.phoneNumber2 == this.phoneNumber2);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String?> fullName;
  final Value<String> role;
  final Value<String?> profilePhotoUrl;
  final Value<int?> schoolId;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<String?> email;
  final Value<String?> phoneNumber1;
  final Value<double?> salary;
  final Value<String?> phoneNumber2;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.fullName = const Value.absent(),
    this.role = const Value.absent(),
    this.profilePhotoUrl = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.email = const Value.absent(),
    this.phoneNumber1 = const Value.absent(),
    this.salary = const Value.absent(),
    this.phoneNumber2 = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    this.fullName = const Value.absent(),
    required String role,
    this.profilePhotoUrl = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.email = const Value.absent(),
    this.phoneNumber1 = const Value.absent(),
    this.salary = const Value.absent(),
    this.phoneNumber2 = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       role = Value(role);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? fullName,
    Expression<String>? role,
    Expression<String>? profilePhotoUrl,
    Expression<int>? schoolId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? email,
    Expression<String>? phoneNumber1,
    Expression<double>? salary,
    Expression<String>? phoneNumber2,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fullName != null) 'full_name': fullName,
      if (role != null) 'role': role,
      if (profilePhotoUrl != null) 'profile_photo_url': profilePhotoUrl,
      if (schoolId != null) 'school_id': schoolId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (email != null) 'email': email,
      if (phoneNumber1 != null) 'phone_number_1': phoneNumber1,
      if (salary != null) 'salary': salary,
      if (phoneNumber2 != null) 'phone_number_2': phoneNumber2,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? id,
    Value<String?>? fullName,
    Value<String>? role,
    Value<String?>? profilePhotoUrl,
    Value<int?>? schoolId,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<String?>? email,
    Value<String?>? phoneNumber1,
    Value<double?>? salary,
    Value<String?>? phoneNumber2,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      schoolId: schoolId ?? this.schoolId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      email: email ?? this.email,
      phoneNumber1: phoneNumber1 ?? this.phoneNumber1,
      salary: salary ?? this.salary,
      phoneNumber2: phoneNumber2 ?? this.phoneNumber2,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (profilePhotoUrl.present) {
      map['profile_photo_url'] = Variable<String>(profilePhotoUrl.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<int>(schoolId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phoneNumber1.present) {
      map['phone_number_1'] = Variable<String>(phoneNumber1.value);
    }
    if (salary.present) {
      map['salary'] = Variable<double>(salary.value);
    }
    if (phoneNumber2.present) {
      map['phone_number_2'] = Variable<String>(phoneNumber2.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('role: $role, ')
          ..write('profilePhotoUrl: $profilePhotoUrl, ')
          ..write('schoolId: $schoolId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('email: $email, ')
          ..write('phoneNumber1: $phoneNumber1, ')
          ..write('salary: $salary, ')
          ..write('phoneNumber2: $phoneNumber2, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttendanceTable extends Attendance
    with TableInfo<$AttendanceTable, AttendanceData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttendanceTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<int> studentId = GeneratedColumn<int>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _classIdMeta = const VerificationMeta(
    'classId',
  );
  @override
  late final GeneratedColumn<int> classId = GeneratedColumn<int>(
    'class_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _markedByTeacherIdMeta = const VerificationMeta(
    'markedByTeacherId',
  );
  @override
  late final GeneratedColumn<String> markedByTeacherId =
      GeneratedColumn<String>(
        'marked_by_teacher_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studentId,
    classId,
    date,
    markedByTeacherId,
    createdAt,
    updatedAt,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attendance';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttendanceData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('class_id')) {
      context.handle(
        _classIdMeta,
        classId.isAcceptableOrUnknown(data['class_id']!, _classIdMeta),
      );
    } else if (isInserting) {
      context.missing(_classIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('marked_by_teacher_id')) {
      context.handle(
        _markedByTeacherIdMeta,
        markedByTeacherId.isAcceptableOrUnknown(
          data['marked_by_teacher_id']!,
          _markedByTeacherIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AttendanceData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttendanceData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      studentId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}student_id'],
          )!,
      classId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}class_id'],
          )!,
      date:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}date'],
          )!,
      markedByTeacherId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}marked_by_teacher_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      status:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}status'],
          )!,
    );
  }

  @override
  $AttendanceTable createAlias(String alias) {
    return $AttendanceTable(attachedDatabase, alias);
  }
}

class AttendanceData extends DataClass implements Insertable<AttendanceData> {
  final int id;
  final int studentId;
  final int classId;
  final DateTime date;
  final String? markedByTeacherId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String status;
  const AttendanceData({
    required this.id,
    required this.studentId,
    required this.classId,
    required this.date,
    this.markedByTeacherId,
    this.createdAt,
    this.updatedAt,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['student_id'] = Variable<int>(studentId);
    map['class_id'] = Variable<int>(classId);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || markedByTeacherId != null) {
      map['marked_by_teacher_id'] = Variable<String>(markedByTeacherId);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['status'] = Variable<String>(status);
    return map;
  }

  AttendanceCompanion toCompanion(bool nullToAbsent) {
    return AttendanceCompanion(
      id: Value(id),
      studentId: Value(studentId),
      classId: Value(classId),
      date: Value(date),
      markedByTeacherId:
          markedByTeacherId == null && nullToAbsent
              ? const Value.absent()
              : Value(markedByTeacherId),
      createdAt:
          createdAt == null && nullToAbsent
              ? const Value.absent()
              : Value(createdAt),
      updatedAt:
          updatedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(updatedAt),
      status: Value(status),
    );
  }

  factory AttendanceData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttendanceData(
      id: serializer.fromJson<int>(json['id']),
      studentId: serializer.fromJson<int>(json['studentId']),
      classId: serializer.fromJson<int>(json['classId']),
      date: serializer.fromJson<DateTime>(json['date']),
      markedByTeacherId: serializer.fromJson<String?>(
        json['markedByTeacherId'],
      ),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'studentId': serializer.toJson<int>(studentId),
      'classId': serializer.toJson<int>(classId),
      'date': serializer.toJson<DateTime>(date),
      'markedByTeacherId': serializer.toJson<String?>(markedByTeacherId),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'status': serializer.toJson<String>(status),
    };
  }

  AttendanceData copyWith({
    int? id,
    int? studentId,
    int? classId,
    DateTime? date,
    Value<String?> markedByTeacherId = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
    String? status,
  }) => AttendanceData(
    id: id ?? this.id,
    studentId: studentId ?? this.studentId,
    classId: classId ?? this.classId,
    date: date ?? this.date,
    markedByTeacherId:
        markedByTeacherId.present
            ? markedByTeacherId.value
            : this.markedByTeacherId,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    status: status ?? this.status,
  );
  AttendanceData copyWithCompanion(AttendanceCompanion data) {
    return AttendanceData(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      classId: data.classId.present ? data.classId.value : this.classId,
      date: data.date.present ? data.date.value : this.date,
      markedByTeacherId:
          data.markedByTeacherId.present
              ? data.markedByTeacherId.value
              : this.markedByTeacherId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceData(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('classId: $classId, ')
          ..write('date: $date, ')
          ..write('markedByTeacherId: $markedByTeacherId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    studentId,
    classId,
    date,
    markedByTeacherId,
    createdAt,
    updatedAt,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttendanceData &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.classId == this.classId &&
          other.date == this.date &&
          other.markedByTeacherId == this.markedByTeacherId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.status == this.status);
}

class AttendanceCompanion extends UpdateCompanion<AttendanceData> {
  final Value<int> id;
  final Value<int> studentId;
  final Value<int> classId;
  final Value<DateTime> date;
  final Value<String?> markedByTeacherId;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<String> status;
  const AttendanceCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.classId = const Value.absent(),
    this.date = const Value.absent(),
    this.markedByTeacherId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.status = const Value.absent(),
  });
  AttendanceCompanion.insert({
    this.id = const Value.absent(),
    required int studentId,
    required int classId,
    required DateTime date,
    this.markedByTeacherId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String status,
  }) : studentId = Value(studentId),
       classId = Value(classId),
       date = Value(date),
       status = Value(status);
  static Insertable<AttendanceData> custom({
    Expression<int>? id,
    Expression<int>? studentId,
    Expression<int>? classId,
    Expression<DateTime>? date,
    Expression<String>? markedByTeacherId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (classId != null) 'class_id': classId,
      if (date != null) 'date': date,
      if (markedByTeacherId != null) 'marked_by_teacher_id': markedByTeacherId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (status != null) 'status': status,
    });
  }

  AttendanceCompanion copyWith({
    Value<int>? id,
    Value<int>? studentId,
    Value<int>? classId,
    Value<DateTime>? date,
    Value<String?>? markedByTeacherId,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<String>? status,
  }) {
    return AttendanceCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      classId: classId ?? this.classId,
      date: date ?? this.date,
      markedByTeacherId: markedByTeacherId ?? this.markedByTeacherId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<int>(studentId.value);
    }
    if (classId.present) {
      map['class_id'] = Variable<int>(classId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (markedByTeacherId.present) {
      map['marked_by_teacher_id'] = Variable<String>(markedByTeacherId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('classId: $classId, ')
          ..write('date: $date, ')
          ..write('markedByTeacherId: $markedByTeacherId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $FinanceEntriesTable extends FinanceEntries
    with TableInfo<$FinanceEntriesTable, FinanceEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FinanceEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  @override
  late final GeneratedColumn<int> schoolId = GeneratedColumn<int>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryTypeMeta = const VerificationMeta(
    'entryType',
  );
  @override
  late final GeneratedColumn<String> entryType = GeneratedColumn<String>(
    'entry_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    schoolId,
    entryType,
    amount,
    description,
    category,
    date,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'finance_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<FinanceEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('entry_type')) {
      context.handle(
        _entryTypeMeta,
        entryType.isAcceptableOrUnknown(data['entry_type']!, _entryTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entryTypeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FinanceEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FinanceEntry(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      schoolId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}school_id'],
          )!,
      entryType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}entry_type'],
          )!,
      amount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}amount'],
          )!,
      description:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}description'],
          )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      date:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}date'],
          )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
    );
  }

  @override
  $FinanceEntriesTable createAlias(String alias) {
    return $FinanceEntriesTable(attachedDatabase, alias);
  }
}

class FinanceEntry extends DataClass implements Insertable<FinanceEntry> {
  final int id;
  final int schoolId;
  final String entryType;
  final double amount;
  final String description;
  final String? category;
  final DateTime date;
  final DateTime? createdAt;
  const FinanceEntry({
    required this.id,
    required this.schoolId,
    required this.entryType,
    required this.amount,
    required this.description,
    this.category,
    required this.date,
    this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['school_id'] = Variable<int>(schoolId);
    map['entry_type'] = Variable<String>(entryType);
    map['amount'] = Variable<double>(amount);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    return map;
  }

  FinanceEntriesCompanion toCompanion(bool nullToAbsent) {
    return FinanceEntriesCompanion(
      id: Value(id),
      schoolId: Value(schoolId),
      entryType: Value(entryType),
      amount: Value(amount),
      description: Value(description),
      category:
          category == null && nullToAbsent
              ? const Value.absent()
              : Value(category),
      date: Value(date),
      createdAt:
          createdAt == null && nullToAbsent
              ? const Value.absent()
              : Value(createdAt),
    );
  }

  factory FinanceEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FinanceEntry(
      id: serializer.fromJson<int>(json['id']),
      schoolId: serializer.fromJson<int>(json['schoolId']),
      entryType: serializer.fromJson<String>(json['entryType']),
      amount: serializer.fromJson<double>(json['amount']),
      description: serializer.fromJson<String>(json['description']),
      category: serializer.fromJson<String?>(json['category']),
      date: serializer.fromJson<DateTime>(json['date']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'schoolId': serializer.toJson<int>(schoolId),
      'entryType': serializer.toJson<String>(entryType),
      'amount': serializer.toJson<double>(amount),
      'description': serializer.toJson<String>(description),
      'category': serializer.toJson<String?>(category),
      'date': serializer.toJson<DateTime>(date),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
    };
  }

  FinanceEntry copyWith({
    int? id,
    int? schoolId,
    String? entryType,
    double? amount,
    String? description,
    Value<String?> category = const Value.absent(),
    DateTime? date,
    Value<DateTime?> createdAt = const Value.absent(),
  }) => FinanceEntry(
    id: id ?? this.id,
    schoolId: schoolId ?? this.schoolId,
    entryType: entryType ?? this.entryType,
    amount: amount ?? this.amount,
    description: description ?? this.description,
    category: category.present ? category.value : this.category,
    date: date ?? this.date,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
  );
  FinanceEntry copyWithCompanion(FinanceEntriesCompanion data) {
    return FinanceEntry(
      id: data.id.present ? data.id.value : this.id,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      entryType: data.entryType.present ? data.entryType.value : this.entryType,
      amount: data.amount.present ? data.amount.value : this.amount,
      description:
          data.description.present ? data.description.value : this.description,
      category: data.category.present ? data.category.value : this.category,
      date: data.date.present ? data.date.value : this.date,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FinanceEntry(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('entryType: $entryType, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    schoolId,
    entryType,
    amount,
    description,
    category,
    date,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FinanceEntry &&
          other.id == this.id &&
          other.schoolId == this.schoolId &&
          other.entryType == this.entryType &&
          other.amount == this.amount &&
          other.description == this.description &&
          other.category == this.category &&
          other.date == this.date &&
          other.createdAt == this.createdAt);
}

class FinanceEntriesCompanion extends UpdateCompanion<FinanceEntry> {
  final Value<int> id;
  final Value<int> schoolId;
  final Value<String> entryType;
  final Value<double> amount;
  final Value<String> description;
  final Value<String?> category;
  final Value<DateTime> date;
  final Value<DateTime?> createdAt;
  const FinanceEntriesCompanion({
    this.id = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.entryType = const Value.absent(),
    this.amount = const Value.absent(),
    this.description = const Value.absent(),
    this.category = const Value.absent(),
    this.date = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FinanceEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int schoolId,
    required String entryType,
    required double amount,
    required String description,
    this.category = const Value.absent(),
    required DateTime date,
    this.createdAt = const Value.absent(),
  }) : schoolId = Value(schoolId),
       entryType = Value(entryType),
       amount = Value(amount),
       description = Value(description),
       date = Value(date);
  static Insertable<FinanceEntry> custom({
    Expression<int>? id,
    Expression<int>? schoolId,
    Expression<String>? entryType,
    Expression<double>? amount,
    Expression<String>? description,
    Expression<String>? category,
    Expression<DateTime>? date,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schoolId != null) 'school_id': schoolId,
      if (entryType != null) 'entry_type': entryType,
      if (amount != null) 'amount': amount,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
      if (date != null) 'date': date,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FinanceEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? schoolId,
    Value<String>? entryType,
    Value<double>? amount,
    Value<String>? description,
    Value<String?>? category,
    Value<DateTime>? date,
    Value<DateTime?>? createdAt,
  }) {
    return FinanceEntriesCompanion(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      entryType: entryType ?? this.entryType,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      category: category ?? this.category,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<int>(schoolId.value);
    }
    if (entryType.present) {
      map['entry_type'] = Variable<String>(entryType.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FinanceEntriesCompanion(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('entryType: $entryType, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TimetablesTable extends Timetables
    with TableInfo<$TimetablesTable, Timetable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimetablesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _classIdMeta = const VerificationMeta(
    'classId',
  );
  @override
  late final GeneratedColumn<int> classId = GeneratedColumn<int>(
    'class_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayOfWeekMeta = const VerificationMeta(
    'dayOfWeek',
  );
  @override
  late final GeneratedColumn<String> dayOfWeek = GeneratedColumn<String>(
    'day_of_week',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<String> startTime = GeneratedColumn<String>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<String> endTime = GeneratedColumn<String>(
    'end_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectNameMeta = const VerificationMeta(
    'subjectName',
  );
  @override
  late final GeneratedColumn<String> subjectName = GeneratedColumn<String>(
    'subject_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _teacherIdMeta = const VerificationMeta(
    'teacherId',
  );
  @override
  late final GeneratedColumn<String> teacherId = GeneratedColumn<String>(
    'teacher_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    classId,
    dayOfWeek,
    startTime,
    endTime,
    subjectName,
    teacherId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timetables';
  @override
  VerificationContext validateIntegrity(
    Insertable<Timetable> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('class_id')) {
      context.handle(
        _classIdMeta,
        classId.isAcceptableOrUnknown(data['class_id']!, _classIdMeta),
      );
    } else if (isInserting) {
      context.missing(_classIdMeta);
    }
    if (data.containsKey('day_of_week')) {
      context.handle(
        _dayOfWeekMeta,
        dayOfWeek.isAcceptableOrUnknown(data['day_of_week']!, _dayOfWeekMeta),
      );
    } else if (isInserting) {
      context.missing(_dayOfWeekMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    if (data.containsKey('subject_name')) {
      context.handle(
        _subjectNameMeta,
        subjectName.isAcceptableOrUnknown(
          data['subject_name']!,
          _subjectNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subjectNameMeta);
    }
    if (data.containsKey('teacher_id')) {
      context.handle(
        _teacherIdMeta,
        teacherId.isAcceptableOrUnknown(data['teacher_id']!, _teacherIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Timetable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Timetable(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      classId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}class_id'],
          )!,
      dayOfWeek:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}day_of_week'],
          )!,
      startTime:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}start_time'],
          )!,
      endTime:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}end_time'],
          )!,
      subjectName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}subject_name'],
          )!,
      teacherId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}teacher_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $TimetablesTable createAlias(String alias) {
    return $TimetablesTable(attachedDatabase, alias);
  }
}

class Timetable extends DataClass implements Insertable<Timetable> {
  final int id;
  final int classId;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String subjectName;
  final String? teacherId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const Timetable({
    required this.id,
    required this.classId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.subjectName,
    this.teacherId,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['class_id'] = Variable<int>(classId);
    map['day_of_week'] = Variable<String>(dayOfWeek);
    map['start_time'] = Variable<String>(startTime);
    map['end_time'] = Variable<String>(endTime);
    map['subject_name'] = Variable<String>(subjectName);
    if (!nullToAbsent || teacherId != null) {
      map['teacher_id'] = Variable<String>(teacherId);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  TimetablesCompanion toCompanion(bool nullToAbsent) {
    return TimetablesCompanion(
      id: Value(id),
      classId: Value(classId),
      dayOfWeek: Value(dayOfWeek),
      startTime: Value(startTime),
      endTime: Value(endTime),
      subjectName: Value(subjectName),
      teacherId:
          teacherId == null && nullToAbsent
              ? const Value.absent()
              : Value(teacherId),
      createdAt:
          createdAt == null && nullToAbsent
              ? const Value.absent()
              : Value(createdAt),
      updatedAt:
          updatedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(updatedAt),
    );
  }

  factory Timetable.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Timetable(
      id: serializer.fromJson<int>(json['id']),
      classId: serializer.fromJson<int>(json['classId']),
      dayOfWeek: serializer.fromJson<String>(json['dayOfWeek']),
      startTime: serializer.fromJson<String>(json['startTime']),
      endTime: serializer.fromJson<String>(json['endTime']),
      subjectName: serializer.fromJson<String>(json['subjectName']),
      teacherId: serializer.fromJson<String?>(json['teacherId']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'classId': serializer.toJson<int>(classId),
      'dayOfWeek': serializer.toJson<String>(dayOfWeek),
      'startTime': serializer.toJson<String>(startTime),
      'endTime': serializer.toJson<String>(endTime),
      'subjectName': serializer.toJson<String>(subjectName),
      'teacherId': serializer.toJson<String?>(teacherId),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  Timetable copyWith({
    int? id,
    int? classId,
    String? dayOfWeek,
    String? startTime,
    String? endTime,
    String? subjectName,
    Value<String?> teacherId = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => Timetable(
    id: id ?? this.id,
    classId: classId ?? this.classId,
    dayOfWeek: dayOfWeek ?? this.dayOfWeek,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    subjectName: subjectName ?? this.subjectName,
    teacherId: teacherId.present ? teacherId.value : this.teacherId,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  Timetable copyWithCompanion(TimetablesCompanion data) {
    return Timetable(
      id: data.id.present ? data.id.value : this.id,
      classId: data.classId.present ? data.classId.value : this.classId,
      dayOfWeek: data.dayOfWeek.present ? data.dayOfWeek.value : this.dayOfWeek,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      subjectName:
          data.subjectName.present ? data.subjectName.value : this.subjectName,
      teacherId: data.teacherId.present ? data.teacherId.value : this.teacherId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Timetable(')
          ..write('id: $id, ')
          ..write('classId: $classId, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('subjectName: $subjectName, ')
          ..write('teacherId: $teacherId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    classId,
    dayOfWeek,
    startTime,
    endTime,
    subjectName,
    teacherId,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Timetable &&
          other.id == this.id &&
          other.classId == this.classId &&
          other.dayOfWeek == this.dayOfWeek &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.subjectName == this.subjectName &&
          other.teacherId == this.teacherId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TimetablesCompanion extends UpdateCompanion<Timetable> {
  final Value<int> id;
  final Value<int> classId;
  final Value<String> dayOfWeek;
  final Value<String> startTime;
  final Value<String> endTime;
  final Value<String> subjectName;
  final Value<String?> teacherId;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  const TimetablesCompanion({
    this.id = const Value.absent(),
    this.classId = const Value.absent(),
    this.dayOfWeek = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.subjectName = const Value.absent(),
    this.teacherId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TimetablesCompanion.insert({
    this.id = const Value.absent(),
    required int classId,
    required String dayOfWeek,
    required String startTime,
    required String endTime,
    required String subjectName,
    this.teacherId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : classId = Value(classId),
       dayOfWeek = Value(dayOfWeek),
       startTime = Value(startTime),
       endTime = Value(endTime),
       subjectName = Value(subjectName);
  static Insertable<Timetable> custom({
    Expression<int>? id,
    Expression<int>? classId,
    Expression<String>? dayOfWeek,
    Expression<String>? startTime,
    Expression<String>? endTime,
    Expression<String>? subjectName,
    Expression<String>? teacherId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (classId != null) 'class_id': classId,
      if (dayOfWeek != null) 'day_of_week': dayOfWeek,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (subjectName != null) 'subject_name': subjectName,
      if (teacherId != null) 'teacher_id': teacherId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TimetablesCompanion copyWith({
    Value<int>? id,
    Value<int>? classId,
    Value<String>? dayOfWeek,
    Value<String>? startTime,
    Value<String>? endTime,
    Value<String>? subjectName,
    Value<String?>? teacherId,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? updatedAt,
  }) {
    return TimetablesCompanion(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      subjectName: subjectName ?? this.subjectName,
      teacherId: teacherId ?? this.teacherId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (classId.present) {
      map['class_id'] = Variable<int>(classId.value);
    }
    if (dayOfWeek.present) {
      map['day_of_week'] = Variable<String>(dayOfWeek.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<String>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<String>(endTime.value);
    }
    if (subjectName.present) {
      map['subject_name'] = Variable<String>(subjectName.value);
    }
    if (teacherId.present) {
      map['teacher_id'] = Variable<String>(teacherId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimetablesCompanion(')
          ..write('id: $id, ')
          ..write('classId: $classId, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('subjectName: $subjectName, ')
          ..write('teacherId: $teacherId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $AnnouncementsTable extends Announcements
    with TableInfo<$AnnouncementsTable, Announcement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnnouncementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  @override
  late final GeneratedColumn<int> schoolId = GeneratedColumn<int>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdByUserIdMeta = const VerificationMeta(
    'createdByUserId',
  );
  @override
  late final GeneratedColumn<String> createdByUserId = GeneratedColumn<String>(
    'created_by_user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetRoleMeta = const VerificationMeta(
    'targetRole',
  );
  @override
  late final GeneratedColumn<String> targetRole = GeneratedColumn<String>(
    'target_role',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetClassIdMeta = const VerificationMeta(
    'targetClassId',
  );
  @override
  late final GeneratedColumn<int> targetClassId = GeneratedColumn<int>(
    'target_class_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    schoolId,
    title,
    content,
    createdByUserId,
    createdAt,
    updatedAt,
    targetRole,
    targetClassId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'announcements';
  @override
  VerificationContext validateIntegrity(
    Insertable<Announcement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('created_by_user_id')) {
      context.handle(
        _createdByUserIdMeta,
        createdByUserId.isAcceptableOrUnknown(
          data['created_by_user_id']!,
          _createdByUserIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('target_role')) {
      context.handle(
        _targetRoleMeta,
        targetRole.isAcceptableOrUnknown(data['target_role']!, _targetRoleMeta),
      );
    }
    if (data.containsKey('target_class_id')) {
      context.handle(
        _targetClassIdMeta,
        targetClassId.isAcceptableOrUnknown(
          data['target_class_id']!,
          _targetClassIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Announcement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Announcement(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      schoolId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}school_id'],
          )!,
      title:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}title'],
          )!,
      content:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}content'],
          )!,
      createdByUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by_user_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      targetRole: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_role'],
      ),
      targetClassId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_class_id'],
      ),
    );
  }

  @override
  $AnnouncementsTable createAlias(String alias) {
    return $AnnouncementsTable(attachedDatabase, alias);
  }
}

class Announcement extends DataClass implements Insertable<Announcement> {
  final int id;
  final int schoolId;
  final String title;
  final String content;
  final String? createdByUserId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? targetRole;
  final int? targetClassId;
  const Announcement({
    required this.id,
    required this.schoolId,
    required this.title,
    required this.content,
    this.createdByUserId,
    this.createdAt,
    this.updatedAt,
    this.targetRole,
    this.targetClassId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['school_id'] = Variable<int>(schoolId);
    map['title'] = Variable<String>(title);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || createdByUserId != null) {
      map['created_by_user_id'] = Variable<String>(createdByUserId);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || targetRole != null) {
      map['target_role'] = Variable<String>(targetRole);
    }
    if (!nullToAbsent || targetClassId != null) {
      map['target_class_id'] = Variable<int>(targetClassId);
    }
    return map;
  }

  AnnouncementsCompanion toCompanion(bool nullToAbsent) {
    return AnnouncementsCompanion(
      id: Value(id),
      schoolId: Value(schoolId),
      title: Value(title),
      content: Value(content),
      createdByUserId:
          createdByUserId == null && nullToAbsent
              ? const Value.absent()
              : Value(createdByUserId),
      createdAt:
          createdAt == null && nullToAbsent
              ? const Value.absent()
              : Value(createdAt),
      updatedAt:
          updatedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(updatedAt),
      targetRole:
          targetRole == null && nullToAbsent
              ? const Value.absent()
              : Value(targetRole),
      targetClassId:
          targetClassId == null && nullToAbsent
              ? const Value.absent()
              : Value(targetClassId),
    );
  }

  factory Announcement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Announcement(
      id: serializer.fromJson<int>(json['id']),
      schoolId: serializer.fromJson<int>(json['schoolId']),
      title: serializer.fromJson<String>(json['title']),
      content: serializer.fromJson<String>(json['content']),
      createdByUserId: serializer.fromJson<String?>(json['createdByUserId']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      targetRole: serializer.fromJson<String?>(json['targetRole']),
      targetClassId: serializer.fromJson<int?>(json['targetClassId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'schoolId': serializer.toJson<int>(schoolId),
      'title': serializer.toJson<String>(title),
      'content': serializer.toJson<String>(content),
      'createdByUserId': serializer.toJson<String?>(createdByUserId),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'targetRole': serializer.toJson<String?>(targetRole),
      'targetClassId': serializer.toJson<int?>(targetClassId),
    };
  }

  Announcement copyWith({
    int? id,
    int? schoolId,
    String? title,
    String? content,
    Value<String?> createdByUserId = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<String?> targetRole = const Value.absent(),
    Value<int?> targetClassId = const Value.absent(),
  }) => Announcement(
    id: id ?? this.id,
    schoolId: schoolId ?? this.schoolId,
    title: title ?? this.title,
    content: content ?? this.content,
    createdByUserId:
        createdByUserId.present ? createdByUserId.value : this.createdByUserId,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    targetRole: targetRole.present ? targetRole.value : this.targetRole,
    targetClassId:
        targetClassId.present ? targetClassId.value : this.targetClassId,
  );
  Announcement copyWithCompanion(AnnouncementsCompanion data) {
    return Announcement(
      id: data.id.present ? data.id.value : this.id,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
      createdByUserId:
          data.createdByUserId.present
              ? data.createdByUserId.value
              : this.createdByUserId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      targetRole:
          data.targetRole.present ? data.targetRole.value : this.targetRole,
      targetClassId:
          data.targetClassId.present
              ? data.targetClassId.value
              : this.targetClassId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Announcement(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('createdByUserId: $createdByUserId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('targetRole: $targetRole, ')
          ..write('targetClassId: $targetClassId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    schoolId,
    title,
    content,
    createdByUserId,
    createdAt,
    updatedAt,
    targetRole,
    targetClassId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Announcement &&
          other.id == this.id &&
          other.schoolId == this.schoolId &&
          other.title == this.title &&
          other.content == this.content &&
          other.createdByUserId == this.createdByUserId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.targetRole == this.targetRole &&
          other.targetClassId == this.targetClassId);
}

class AnnouncementsCompanion extends UpdateCompanion<Announcement> {
  final Value<int> id;
  final Value<int> schoolId;
  final Value<String> title;
  final Value<String> content;
  final Value<String?> createdByUserId;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<String?> targetRole;
  final Value<int?> targetClassId;
  const AnnouncementsCompanion({
    this.id = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.createdByUserId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.targetRole = const Value.absent(),
    this.targetClassId = const Value.absent(),
  });
  AnnouncementsCompanion.insert({
    this.id = const Value.absent(),
    required int schoolId,
    required String title,
    required String content,
    this.createdByUserId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.targetRole = const Value.absent(),
    this.targetClassId = const Value.absent(),
  }) : schoolId = Value(schoolId),
       title = Value(title),
       content = Value(content);
  static Insertable<Announcement> custom({
    Expression<int>? id,
    Expression<int>? schoolId,
    Expression<String>? title,
    Expression<String>? content,
    Expression<String>? createdByUserId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? targetRole,
    Expression<int>? targetClassId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schoolId != null) 'school_id': schoolId,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (createdByUserId != null) 'created_by_user_id': createdByUserId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (targetRole != null) 'target_role': targetRole,
      if (targetClassId != null) 'target_class_id': targetClassId,
    });
  }

  AnnouncementsCompanion copyWith({
    Value<int>? id,
    Value<int>? schoolId,
    Value<String>? title,
    Value<String>? content,
    Value<String?>? createdByUserId,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<String?>? targetRole,
    Value<int?>? targetClassId,
  }) {
    return AnnouncementsCompanion(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      title: title ?? this.title,
      content: content ?? this.content,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      targetRole: targetRole ?? this.targetRole,
      targetClassId: targetClassId ?? this.targetClassId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<int>(schoolId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (createdByUserId.present) {
      map['created_by_user_id'] = Variable<String>(createdByUserId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (targetRole.present) {
      map['target_role'] = Variable<String>(targetRole.value);
    }
    if (targetClassId.present) {
      map['target_class_id'] = Variable<int>(targetClassId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnnouncementsCompanion(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('createdByUserId: $createdByUserId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('targetRole: $targetRole, ')
          ..write('targetClassId: $targetClassId')
          ..write(')'))
        .toString();
  }
}

class $DonationsTable extends Donations
    with TableInfo<$DonationsTable, Donation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DonationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  @override
  late final GeneratedColumn<int> schoolId = GeneratedColumn<int>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _donatorNameMeta = const VerificationMeta(
    'donatorName',
  );
  @override
  late final GeneratedColumn<String> donatorName = GeneratedColumn<String>(
    'donator_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _donatorEmailMeta = const VerificationMeta(
    'donatorEmail',
  );
  @override
  late final GeneratedColumn<String> donatorEmail = GeneratedColumn<String>(
    'donator_email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _donatorPhoneMeta = const VerificationMeta(
    'donatorPhone',
  );
  @override
  late final GeneratedColumn<String> donatorPhone = GeneratedColumn<String>(
    'donator_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _donationDateMeta = const VerificationMeta(
    'donationDate',
  );
  @override
  late final GeneratedColumn<DateTime> donationDate = GeneratedColumn<DateTime>(
    'donation_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purposeMeta = const VerificationMeta(
    'purpose',
  );
  @override
  late final GeneratedColumn<String> purpose = GeneratedColumn<String>(
    'purpose',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    schoolId,
    donatorName,
    donatorEmail,
    donatorPhone,
    amount,
    donationDate,
    paymentMethod,
    purpose,
    status,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'donations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Donation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('donator_name')) {
      context.handle(
        _donatorNameMeta,
        donatorName.isAcceptableOrUnknown(
          data['donator_name']!,
          _donatorNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_donatorNameMeta);
    }
    if (data.containsKey('donator_email')) {
      context.handle(
        _donatorEmailMeta,
        donatorEmail.isAcceptableOrUnknown(
          data['donator_email']!,
          _donatorEmailMeta,
        ),
      );
    }
    if (data.containsKey('donator_phone')) {
      context.handle(
        _donatorPhoneMeta,
        donatorPhone.isAcceptableOrUnknown(
          data['donator_phone']!,
          _donatorPhoneMeta,
        ),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('donation_date')) {
      context.handle(
        _donationDateMeta,
        donationDate.isAcceptableOrUnknown(
          data['donation_date']!,
          _donationDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_donationDateMeta);
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentMethodMeta);
    }
    if (data.containsKey('purpose')) {
      context.handle(
        _purposeMeta,
        purpose.isAcceptableOrUnknown(data['purpose']!, _purposeMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Donation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Donation(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      schoolId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}school_id'],
          )!,
      donatorName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}donator_name'],
          )!,
      donatorEmail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}donator_email'],
      ),
      donatorPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}donator_phone'],
      ),
      amount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}amount'],
          )!,
      donationDate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}donation_date'],
          )!,
      paymentMethod:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}payment_method'],
          )!,
      purpose: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purpose'],
      ),
      status:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}status'],
          )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
    );
  }

  @override
  $DonationsTable createAlias(String alias) {
    return $DonationsTable(attachedDatabase, alias);
  }
}

class Donation extends DataClass implements Insertable<Donation> {
  final String id;
  final int schoolId;
  final String donatorName;
  final String? donatorEmail;
  final String? donatorPhone;
  final double amount;
  final DateTime donationDate;
  final String paymentMethod;
  final String? purpose;
  final String status;
  final DateTime? createdAt;
  const Donation({
    required this.id,
    required this.schoolId,
    required this.donatorName,
    this.donatorEmail,
    this.donatorPhone,
    required this.amount,
    required this.donationDate,
    required this.paymentMethod,
    this.purpose,
    required this.status,
    this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['school_id'] = Variable<int>(schoolId);
    map['donator_name'] = Variable<String>(donatorName);
    if (!nullToAbsent || donatorEmail != null) {
      map['donator_email'] = Variable<String>(donatorEmail);
    }
    if (!nullToAbsent || donatorPhone != null) {
      map['donator_phone'] = Variable<String>(donatorPhone);
    }
    map['amount'] = Variable<double>(amount);
    map['donation_date'] = Variable<DateTime>(donationDate);
    map['payment_method'] = Variable<String>(paymentMethod);
    if (!nullToAbsent || purpose != null) {
      map['purpose'] = Variable<String>(purpose);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    return map;
  }

  DonationsCompanion toCompanion(bool nullToAbsent) {
    return DonationsCompanion(
      id: Value(id),
      schoolId: Value(schoolId),
      donatorName: Value(donatorName),
      donatorEmail:
          donatorEmail == null && nullToAbsent
              ? const Value.absent()
              : Value(donatorEmail),
      donatorPhone:
          donatorPhone == null && nullToAbsent
              ? const Value.absent()
              : Value(donatorPhone),
      amount: Value(amount),
      donationDate: Value(donationDate),
      paymentMethod: Value(paymentMethod),
      purpose:
          purpose == null && nullToAbsent
              ? const Value.absent()
              : Value(purpose),
      status: Value(status),
      createdAt:
          createdAt == null && nullToAbsent
              ? const Value.absent()
              : Value(createdAt),
    );
  }

  factory Donation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Donation(
      id: serializer.fromJson<String>(json['id']),
      schoolId: serializer.fromJson<int>(json['schoolId']),
      donatorName: serializer.fromJson<String>(json['donatorName']),
      donatorEmail: serializer.fromJson<String?>(json['donatorEmail']),
      donatorPhone: serializer.fromJson<String?>(json['donatorPhone']),
      amount: serializer.fromJson<double>(json['amount']),
      donationDate: serializer.fromJson<DateTime>(json['donationDate']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      purpose: serializer.fromJson<String?>(json['purpose']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'schoolId': serializer.toJson<int>(schoolId),
      'donatorName': serializer.toJson<String>(donatorName),
      'donatorEmail': serializer.toJson<String?>(donatorEmail),
      'donatorPhone': serializer.toJson<String?>(donatorPhone),
      'amount': serializer.toJson<double>(amount),
      'donationDate': serializer.toJson<DateTime>(donationDate),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'purpose': serializer.toJson<String?>(purpose),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
    };
  }

  Donation copyWith({
    String? id,
    int? schoolId,
    String? donatorName,
    Value<String?> donatorEmail = const Value.absent(),
    Value<String?> donatorPhone = const Value.absent(),
    double? amount,
    DateTime? donationDate,
    String? paymentMethod,
    Value<String?> purpose = const Value.absent(),
    String? status,
    Value<DateTime?> createdAt = const Value.absent(),
  }) => Donation(
    id: id ?? this.id,
    schoolId: schoolId ?? this.schoolId,
    donatorName: donatorName ?? this.donatorName,
    donatorEmail: donatorEmail.present ? donatorEmail.value : this.donatorEmail,
    donatorPhone: donatorPhone.present ? donatorPhone.value : this.donatorPhone,
    amount: amount ?? this.amount,
    donationDate: donationDate ?? this.donationDate,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    purpose: purpose.present ? purpose.value : this.purpose,
    status: status ?? this.status,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
  );
  Donation copyWithCompanion(DonationsCompanion data) {
    return Donation(
      id: data.id.present ? data.id.value : this.id,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      donatorName:
          data.donatorName.present ? data.donatorName.value : this.donatorName,
      donatorEmail:
          data.donatorEmail.present
              ? data.donatorEmail.value
              : this.donatorEmail,
      donatorPhone:
          data.donatorPhone.present
              ? data.donatorPhone.value
              : this.donatorPhone,
      amount: data.amount.present ? data.amount.value : this.amount,
      donationDate:
          data.donationDate.present
              ? data.donationDate.value
              : this.donationDate,
      paymentMethod:
          data.paymentMethod.present
              ? data.paymentMethod.value
              : this.paymentMethod,
      purpose: data.purpose.present ? data.purpose.value : this.purpose,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Donation(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('donatorName: $donatorName, ')
          ..write('donatorEmail: $donatorEmail, ')
          ..write('donatorPhone: $donatorPhone, ')
          ..write('amount: $amount, ')
          ..write('donationDate: $donationDate, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('purpose: $purpose, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    schoolId,
    donatorName,
    donatorEmail,
    donatorPhone,
    amount,
    donationDate,
    paymentMethod,
    purpose,
    status,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Donation &&
          other.id == this.id &&
          other.schoolId == this.schoolId &&
          other.donatorName == this.donatorName &&
          other.donatorEmail == this.donatorEmail &&
          other.donatorPhone == this.donatorPhone &&
          other.amount == this.amount &&
          other.donationDate == this.donationDate &&
          other.paymentMethod == this.paymentMethod &&
          other.purpose == this.purpose &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class DonationsCompanion extends UpdateCompanion<Donation> {
  final Value<String> id;
  final Value<int> schoolId;
  final Value<String> donatorName;
  final Value<String?> donatorEmail;
  final Value<String?> donatorPhone;
  final Value<double> amount;
  final Value<DateTime> donationDate;
  final Value<String> paymentMethod;
  final Value<String?> purpose;
  final Value<String> status;
  final Value<DateTime?> createdAt;
  final Value<int> rowid;
  const DonationsCompanion({
    this.id = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.donatorName = const Value.absent(),
    this.donatorEmail = const Value.absent(),
    this.donatorPhone = const Value.absent(),
    this.amount = const Value.absent(),
    this.donationDate = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.purpose = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DonationsCompanion.insert({
    required String id,
    required int schoolId,
    required String donatorName,
    this.donatorEmail = const Value.absent(),
    this.donatorPhone = const Value.absent(),
    required double amount,
    required DateTime donationDate,
    required String paymentMethod,
    this.purpose = const Value.absent(),
    required String status,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       schoolId = Value(schoolId),
       donatorName = Value(donatorName),
       amount = Value(amount),
       donationDate = Value(donationDate),
       paymentMethod = Value(paymentMethod),
       status = Value(status);
  static Insertable<Donation> custom({
    Expression<String>? id,
    Expression<int>? schoolId,
    Expression<String>? donatorName,
    Expression<String>? donatorEmail,
    Expression<String>? donatorPhone,
    Expression<double>? amount,
    Expression<DateTime>? donationDate,
    Expression<String>? paymentMethod,
    Expression<String>? purpose,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schoolId != null) 'school_id': schoolId,
      if (donatorName != null) 'donator_name': donatorName,
      if (donatorEmail != null) 'donator_email': donatorEmail,
      if (donatorPhone != null) 'donator_phone': donatorPhone,
      if (amount != null) 'amount': amount,
      if (donationDate != null) 'donation_date': donationDate,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (purpose != null) 'purpose': purpose,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DonationsCompanion copyWith({
    Value<String>? id,
    Value<int>? schoolId,
    Value<String>? donatorName,
    Value<String?>? donatorEmail,
    Value<String?>? donatorPhone,
    Value<double>? amount,
    Value<DateTime>? donationDate,
    Value<String>? paymentMethod,
    Value<String?>? purpose,
    Value<String>? status,
    Value<DateTime?>? createdAt,
    Value<int>? rowid,
  }) {
    return DonationsCompanion(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      donatorName: donatorName ?? this.donatorName,
      donatorEmail: donatorEmail ?? this.donatorEmail,
      donatorPhone: donatorPhone ?? this.donatorPhone,
      amount: amount ?? this.amount,
      donationDate: donationDate ?? this.donationDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      purpose: purpose ?? this.purpose,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<int>(schoolId.value);
    }
    if (donatorName.present) {
      map['donator_name'] = Variable<String>(donatorName.value);
    }
    if (donatorEmail.present) {
      map['donator_email'] = Variable<String>(donatorEmail.value);
    }
    if (donatorPhone.present) {
      map['donator_phone'] = Variable<String>(donatorPhone.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (donationDate.present) {
      map['donation_date'] = Variable<DateTime>(donationDate.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (purpose.present) {
      map['purpose'] = Variable<String>(purpose.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DonationsCompanion(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('donatorName: $donatorName, ')
          ..write('donatorEmail: $donatorEmail, ')
          ..write('donatorPhone: $donatorPhone, ')
          ..write('amount: $amount, ')
          ..write('donationDate: $donationDate, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('purpose: $purpose, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SchoolsTable schools = $SchoolsTable(this);
  late final $StudentsTable students = $StudentsTable(this);
  late final $ClassesTable classes = $ClassesTable(this);
  late final $UsersTable users = $UsersTable(this);
  late final $AttendanceTable attendance = $AttendanceTable(this);
  late final $FinanceEntriesTable financeEntries = $FinanceEntriesTable(this);
  late final $TimetablesTable timetables = $TimetablesTable(this);
  late final $AnnouncementsTable announcements = $AnnouncementsTable(this);
  late final $DonationsTable donations = $DonationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    schools,
    students,
    classes,
    users,
    attendance,
    financeEntries,
    timetables,
    announcements,
    donations,
  ];
}

typedef $$SchoolsTableCreateCompanionBuilder =
    SchoolsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> logoUrl,
      Value<String?> academicYear,
      Value<String?> theme,
      Value<String?> contactInfo,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<int?> hijriDayAdjustment,
    });
typedef $$SchoolsTableUpdateCompanionBuilder =
    SchoolsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> logoUrl,
      Value<String?> academicYear,
      Value<String?> theme,
      Value<String?> contactInfo,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<int?> hijriDayAdjustment,
    });

class $$SchoolsTableFilterComposer
    extends Composer<_$AppDatabase, $SchoolsTable> {
  $$SchoolsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logoUrl => $composableBuilder(
    column: $table.logoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get academicYear => $composableBuilder(
    column: $table.academicYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contactInfo => $composableBuilder(
    column: $table.contactInfo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hijriDayAdjustment => $composableBuilder(
    column: $table.hijriDayAdjustment,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SchoolsTableOrderingComposer
    extends Composer<_$AppDatabase, $SchoolsTable> {
  $$SchoolsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logoUrl => $composableBuilder(
    column: $table.logoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get academicYear => $composableBuilder(
    column: $table.academicYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contactInfo => $composableBuilder(
    column: $table.contactInfo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hijriDayAdjustment => $composableBuilder(
    column: $table.hijriDayAdjustment,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SchoolsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SchoolsTable> {
  $$SchoolsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get logoUrl =>
      $composableBuilder(column: $table.logoUrl, builder: (column) => column);

  GeneratedColumn<String> get academicYear => $composableBuilder(
    column: $table.academicYear,
    builder: (column) => column,
  );

  GeneratedColumn<String> get theme =>
      $composableBuilder(column: $table.theme, builder: (column) => column);

  GeneratedColumn<String> get contactInfo => $composableBuilder(
    column: $table.contactInfo,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get hijriDayAdjustment => $composableBuilder(
    column: $table.hijriDayAdjustment,
    builder: (column) => column,
  );
}

class $$SchoolsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SchoolsTable,
          School,
          $$SchoolsTableFilterComposer,
          $$SchoolsTableOrderingComposer,
          $$SchoolsTableAnnotationComposer,
          $$SchoolsTableCreateCompanionBuilder,
          $$SchoolsTableUpdateCompanionBuilder,
          (School, BaseReferences<_$AppDatabase, $SchoolsTable, School>),
          School,
          PrefetchHooks Function()
        > {
  $$SchoolsTableTableManager(_$AppDatabase db, $SchoolsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SchoolsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$SchoolsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$SchoolsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> logoUrl = const Value.absent(),
                Value<String?> academicYear = const Value.absent(),
                Value<String?> theme = const Value.absent(),
                Value<String?> contactInfo = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int?> hijriDayAdjustment = const Value.absent(),
              }) => SchoolsCompanion(
                id: id,
                name: name,
                logoUrl: logoUrl,
                academicYear: academicYear,
                theme: theme,
                contactInfo: contactInfo,
                createdAt: createdAt,
                updatedAt: updatedAt,
                hijriDayAdjustment: hijriDayAdjustment,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> logoUrl = const Value.absent(),
                Value<String?> academicYear = const Value.absent(),
                Value<String?> theme = const Value.absent(),
                Value<String?> contactInfo = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int?> hijriDayAdjustment = const Value.absent(),
              }) => SchoolsCompanion.insert(
                id: id,
                name: name,
                logoUrl: logoUrl,
                academicYear: academicYear,
                theme: theme,
                contactInfo: contactInfo,
                createdAt: createdAt,
                updatedAt: updatedAt,
                hijriDayAdjustment: hijriDayAdjustment,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SchoolsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SchoolsTable,
      School,
      $$SchoolsTableFilterComposer,
      $$SchoolsTableOrderingComposer,
      $$SchoolsTableAnnotationComposer,
      $$SchoolsTableCreateCompanionBuilder,
      $$SchoolsTableUpdateCompanionBuilder,
      (School, BaseReferences<_$AppDatabase, $SchoolsTable, School>),
      School,
      PrefetchHooks Function()
    >;
typedef $$StudentsTableCreateCompanionBuilder =
    StudentsCompanion Function({
      Value<int> id,
      required int schoolId,
      Value<int?> classId,
      required String fullName,
      Value<String?> profilePhotoUrl,
      Value<DateTime?> dateOfBirth,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<String?> gender,
      Value<String?> phoneNumber1,
      Value<String?> phoneNumber2,
    });
typedef $$StudentsTableUpdateCompanionBuilder =
    StudentsCompanion Function({
      Value<int> id,
      Value<int> schoolId,
      Value<int?> classId,
      Value<String> fullName,
      Value<String?> profilePhotoUrl,
      Value<DateTime?> dateOfBirth,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<String?> gender,
      Value<String?> phoneNumber1,
      Value<String?> phoneNumber2,
    });

class $$StudentsTableFilterComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get classId => $composableBuilder(
    column: $table.classId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profilePhotoUrl => $composableBuilder(
    column: $table.profilePhotoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneNumber1 => $composableBuilder(
    column: $table.phoneNumber1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneNumber2 => $composableBuilder(
    column: $table.phoneNumber2,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StudentsTableOrderingComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get classId => $composableBuilder(
    column: $table.classId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profilePhotoUrl => $composableBuilder(
    column: $table.profilePhotoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneNumber1 => $composableBuilder(
    column: $table.phoneNumber1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneNumber2 => $composableBuilder(
    column: $table.phoneNumber2,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StudentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<int> get classId =>
      $composableBuilder(column: $table.classId, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get profilePhotoUrl => $composableBuilder(
    column: $table.profilePhotoUrl,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber1 => $composableBuilder(
    column: $table.phoneNumber1,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phoneNumber2 => $composableBuilder(
    column: $table.phoneNumber2,
    builder: (column) => column,
  );
}

class $$StudentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudentsTable,
          Student,
          $$StudentsTableFilterComposer,
          $$StudentsTableOrderingComposer,
          $$StudentsTableAnnotationComposer,
          $$StudentsTableCreateCompanionBuilder,
          $$StudentsTableUpdateCompanionBuilder,
          (Student, BaseReferences<_$AppDatabase, $StudentsTable, Student>),
          Student,
          PrefetchHooks Function()
        > {
  $$StudentsTableTableManager(_$AppDatabase db, $StudentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$StudentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$StudentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$StudentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> schoolId = const Value.absent(),
                Value<int?> classId = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<String?> profilePhotoUrl = const Value.absent(),
                Value<DateTime?> dateOfBirth = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                Value<String?> phoneNumber1 = const Value.absent(),
                Value<String?> phoneNumber2 = const Value.absent(),
              }) => StudentsCompanion(
                id: id,
                schoolId: schoolId,
                classId: classId,
                fullName: fullName,
                profilePhotoUrl: profilePhotoUrl,
                dateOfBirth: dateOfBirth,
                createdAt: createdAt,
                updatedAt: updatedAt,
                gender: gender,
                phoneNumber1: phoneNumber1,
                phoneNumber2: phoneNumber2,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int schoolId,
                Value<int?> classId = const Value.absent(),
                required String fullName,
                Value<String?> profilePhotoUrl = const Value.absent(),
                Value<DateTime?> dateOfBirth = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                Value<String?> phoneNumber1 = const Value.absent(),
                Value<String?> phoneNumber2 = const Value.absent(),
              }) => StudentsCompanion.insert(
                id: id,
                schoolId: schoolId,
                classId: classId,
                fullName: fullName,
                profilePhotoUrl: profilePhotoUrl,
                dateOfBirth: dateOfBirth,
                createdAt: createdAt,
                updatedAt: updatedAt,
                gender: gender,
                phoneNumber1: phoneNumber1,
                phoneNumber2: phoneNumber2,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StudentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudentsTable,
      Student,
      $$StudentsTableFilterComposer,
      $$StudentsTableOrderingComposer,
      $$StudentsTableAnnotationComposer,
      $$StudentsTableCreateCompanionBuilder,
      $$StudentsTableUpdateCompanionBuilder,
      (Student, BaseReferences<_$AppDatabase, $StudentsTable, Student>),
      Student,
      PrefetchHooks Function()
    >;
typedef $$ClassesTableCreateCompanionBuilder =
    ClassesCompanion Function({
      Value<int> id,
      required int schoolId,
      required String name,
      Value<String?> teacherId,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<String?> section,
    });
typedef $$ClassesTableUpdateCompanionBuilder =
    ClassesCompanion Function({
      Value<int> id,
      Value<int> schoolId,
      Value<String> name,
      Value<String?> teacherId,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<String?> section,
    });

class $$ClassesTableFilterComposer
    extends Composer<_$AppDatabase, $ClassesTable> {
  $$ClassesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teacherId => $composableBuilder(
    column: $table.teacherId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get section => $composableBuilder(
    column: $table.section,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ClassesTableOrderingComposer
    extends Composer<_$AppDatabase, $ClassesTable> {
  $$ClassesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teacherId => $composableBuilder(
    column: $table.teacherId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get section => $composableBuilder(
    column: $table.section,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClassesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClassesTable> {
  $$ClassesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get teacherId =>
      $composableBuilder(column: $table.teacherId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get section =>
      $composableBuilder(column: $table.section, builder: (column) => column);
}

class $$ClassesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClassesTable,
          ClassesData,
          $$ClassesTableFilterComposer,
          $$ClassesTableOrderingComposer,
          $$ClassesTableAnnotationComposer,
          $$ClassesTableCreateCompanionBuilder,
          $$ClassesTableUpdateCompanionBuilder,
          (
            ClassesData,
            BaseReferences<_$AppDatabase, $ClassesTable, ClassesData>,
          ),
          ClassesData,
          PrefetchHooks Function()
        > {
  $$ClassesTableTableManager(_$AppDatabase db, $ClassesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ClassesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$ClassesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$ClassesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> schoolId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> teacherId = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String?> section = const Value.absent(),
              }) => ClassesCompanion(
                id: id,
                schoolId: schoolId,
                name: name,
                teacherId: teacherId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                section: section,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int schoolId,
                required String name,
                Value<String?> teacherId = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String?> section = const Value.absent(),
              }) => ClassesCompanion.insert(
                id: id,
                schoolId: schoolId,
                name: name,
                teacherId: teacherId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                section: section,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ClassesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClassesTable,
      ClassesData,
      $$ClassesTableFilterComposer,
      $$ClassesTableOrderingComposer,
      $$ClassesTableAnnotationComposer,
      $$ClassesTableCreateCompanionBuilder,
      $$ClassesTableUpdateCompanionBuilder,
      (ClassesData, BaseReferences<_$AppDatabase, $ClassesTable, ClassesData>),
      ClassesData,
      PrefetchHooks Function()
    >;
typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      required String id,
      Value<String?> fullName,
      required String role,
      Value<String?> profilePhotoUrl,
      Value<int?> schoolId,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<String?> email,
      Value<String?> phoneNumber1,
      Value<double?> salary,
      Value<String?> phoneNumber2,
      Value<int> rowid,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<String> id,
      Value<String?> fullName,
      Value<String> role,
      Value<String?> profilePhotoUrl,
      Value<int?> schoolId,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<String?> email,
      Value<String?> phoneNumber1,
      Value<double?> salary,
      Value<String?> phoneNumber2,
      Value<int> rowid,
    });

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profilePhotoUrl => $composableBuilder(
    column: $table.profilePhotoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneNumber1 => $composableBuilder(
    column: $table.phoneNumber1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get salary => $composableBuilder(
    column: $table.salary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneNumber2 => $composableBuilder(
    column: $table.phoneNumber2,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profilePhotoUrl => $composableBuilder(
    column: $table.profilePhotoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneNumber1 => $composableBuilder(
    column: $table.phoneNumber1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get salary => $composableBuilder(
    column: $table.salary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneNumber2 => $composableBuilder(
    column: $table.phoneNumber2,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get profilePhotoUrl => $composableBuilder(
    column: $table.profilePhotoUrl,
    builder: (column) => column,
  );

  GeneratedColumn<int> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber1 => $composableBuilder(
    column: $table.phoneNumber1,
    builder: (column) => column,
  );

  GeneratedColumn<double> get salary =>
      $composableBuilder(column: $table.salary, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber2 => $composableBuilder(
    column: $table.phoneNumber2,
    builder: (column) => column,
  );
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
          User,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> fullName = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String?> profilePhotoUrl = const Value.absent(),
                Value<int?> schoolId = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phoneNumber1 = const Value.absent(),
                Value<double?> salary = const Value.absent(),
                Value<String?> phoneNumber2 = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                fullName: fullName,
                role: role,
                profilePhotoUrl: profilePhotoUrl,
                schoolId: schoolId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                email: email,
                phoneNumber1: phoneNumber1,
                salary: salary,
                phoneNumber2: phoneNumber2,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> fullName = const Value.absent(),
                required String role,
                Value<String?> profilePhotoUrl = const Value.absent(),
                Value<int?> schoolId = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phoneNumber1 = const Value.absent(),
                Value<double?> salary = const Value.absent(),
                Value<String?> phoneNumber2 = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                fullName: fullName,
                role: role,
                profilePhotoUrl: profilePhotoUrl,
                schoolId: schoolId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                email: email,
                phoneNumber1: phoneNumber1,
                salary: salary,
                phoneNumber2: phoneNumber2,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
      User,
      PrefetchHooks Function()
    >;
typedef $$AttendanceTableCreateCompanionBuilder =
    AttendanceCompanion Function({
      Value<int> id,
      required int studentId,
      required int classId,
      required DateTime date,
      Value<String?> markedByTeacherId,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      required String status,
    });
typedef $$AttendanceTableUpdateCompanionBuilder =
    AttendanceCompanion Function({
      Value<int> id,
      Value<int> studentId,
      Value<int> classId,
      Value<DateTime> date,
      Value<String?> markedByTeacherId,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<String> status,
    });

class $$AttendanceTableFilterComposer
    extends Composer<_$AppDatabase, $AttendanceTable> {
  $$AttendanceTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get classId => $composableBuilder(
    column: $table.classId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get markedByTeacherId => $composableBuilder(
    column: $table.markedByTeacherId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AttendanceTableOrderingComposer
    extends Composer<_$AppDatabase, $AttendanceTable> {
  $$AttendanceTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get classId => $composableBuilder(
    column: $table.classId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get markedByTeacherId => $composableBuilder(
    column: $table.markedByTeacherId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttendanceTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttendanceTable> {
  $$AttendanceTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<int> get classId =>
      $composableBuilder(column: $table.classId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get markedByTeacherId => $composableBuilder(
    column: $table.markedByTeacherId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$AttendanceTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttendanceTable,
          AttendanceData,
          $$AttendanceTableFilterComposer,
          $$AttendanceTableOrderingComposer,
          $$AttendanceTableAnnotationComposer,
          $$AttendanceTableCreateCompanionBuilder,
          $$AttendanceTableUpdateCompanionBuilder,
          (
            AttendanceData,
            BaseReferences<_$AppDatabase, $AttendanceTable, AttendanceData>,
          ),
          AttendanceData,
          PrefetchHooks Function()
        > {
  $$AttendanceTableTableManager(_$AppDatabase db, $AttendanceTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$AttendanceTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$AttendanceTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$AttendanceTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> studentId = const Value.absent(),
                Value<int> classId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> markedByTeacherId = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => AttendanceCompanion(
                id: id,
                studentId: studentId,
                classId: classId,
                date: date,
                markedByTeacherId: markedByTeacherId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                status: status,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int studentId,
                required int classId,
                required DateTime date,
                Value<String?> markedByTeacherId = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                required String status,
              }) => AttendanceCompanion.insert(
                id: id,
                studentId: studentId,
                classId: classId,
                date: date,
                markedByTeacherId: markedByTeacherId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                status: status,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AttendanceTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttendanceTable,
      AttendanceData,
      $$AttendanceTableFilterComposer,
      $$AttendanceTableOrderingComposer,
      $$AttendanceTableAnnotationComposer,
      $$AttendanceTableCreateCompanionBuilder,
      $$AttendanceTableUpdateCompanionBuilder,
      (
        AttendanceData,
        BaseReferences<_$AppDatabase, $AttendanceTable, AttendanceData>,
      ),
      AttendanceData,
      PrefetchHooks Function()
    >;
typedef $$FinanceEntriesTableCreateCompanionBuilder =
    FinanceEntriesCompanion Function({
      Value<int> id,
      required int schoolId,
      required String entryType,
      required double amount,
      required String description,
      Value<String?> category,
      required DateTime date,
      Value<DateTime?> createdAt,
    });
typedef $$FinanceEntriesTableUpdateCompanionBuilder =
    FinanceEntriesCompanion Function({
      Value<int> id,
      Value<int> schoolId,
      Value<String> entryType,
      Value<double> amount,
      Value<String> description,
      Value<String?> category,
      Value<DateTime> date,
      Value<DateTime?> createdAt,
    });

class $$FinanceEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $FinanceEntriesTable> {
  $$FinanceEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryType => $composableBuilder(
    column: $table.entryType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FinanceEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $FinanceEntriesTable> {
  $$FinanceEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryType => $composableBuilder(
    column: $table.entryType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FinanceEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FinanceEntriesTable> {
  $$FinanceEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get entryType =>
      $composableBuilder(column: $table.entryType, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FinanceEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FinanceEntriesTable,
          FinanceEntry,
          $$FinanceEntriesTableFilterComposer,
          $$FinanceEntriesTableOrderingComposer,
          $$FinanceEntriesTableAnnotationComposer,
          $$FinanceEntriesTableCreateCompanionBuilder,
          $$FinanceEntriesTableUpdateCompanionBuilder,
          (
            FinanceEntry,
            BaseReferences<_$AppDatabase, $FinanceEntriesTable, FinanceEntry>,
          ),
          FinanceEntry,
          PrefetchHooks Function()
        > {
  $$FinanceEntriesTableTableManager(
    _$AppDatabase db,
    $FinanceEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$FinanceEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$FinanceEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$FinanceEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> schoolId = const Value.absent(),
                Value<String> entryType = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
              }) => FinanceEntriesCompanion(
                id: id,
                schoolId: schoolId,
                entryType: entryType,
                amount: amount,
                description: description,
                category: category,
                date: date,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int schoolId,
                required String entryType,
                required double amount,
                required String description,
                Value<String?> category = const Value.absent(),
                required DateTime date,
                Value<DateTime?> createdAt = const Value.absent(),
              }) => FinanceEntriesCompanion.insert(
                id: id,
                schoolId: schoolId,
                entryType: entryType,
                amount: amount,
                description: description,
                category: category,
                date: date,
                createdAt: createdAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FinanceEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FinanceEntriesTable,
      FinanceEntry,
      $$FinanceEntriesTableFilterComposer,
      $$FinanceEntriesTableOrderingComposer,
      $$FinanceEntriesTableAnnotationComposer,
      $$FinanceEntriesTableCreateCompanionBuilder,
      $$FinanceEntriesTableUpdateCompanionBuilder,
      (
        FinanceEntry,
        BaseReferences<_$AppDatabase, $FinanceEntriesTable, FinanceEntry>,
      ),
      FinanceEntry,
      PrefetchHooks Function()
    >;
typedef $$TimetablesTableCreateCompanionBuilder =
    TimetablesCompanion Function({
      Value<int> id,
      required int classId,
      required String dayOfWeek,
      required String startTime,
      required String endTime,
      required String subjectName,
      Value<String?> teacherId,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
    });
typedef $$TimetablesTableUpdateCompanionBuilder =
    TimetablesCompanion Function({
      Value<int> id,
      Value<int> classId,
      Value<String> dayOfWeek,
      Value<String> startTime,
      Value<String> endTime,
      Value<String> subjectName,
      Value<String?> teacherId,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
    });

class $$TimetablesTableFilterComposer
    extends Composer<_$AppDatabase, $TimetablesTable> {
  $$TimetablesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get classId => $composableBuilder(
    column: $table.classId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dayOfWeek => $composableBuilder(
    column: $table.dayOfWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjectName => $composableBuilder(
    column: $table.subjectName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teacherId => $composableBuilder(
    column: $table.teacherId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TimetablesTableOrderingComposer
    extends Composer<_$AppDatabase, $TimetablesTable> {
  $$TimetablesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get classId => $composableBuilder(
    column: $table.classId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dayOfWeek => $composableBuilder(
    column: $table.dayOfWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjectName => $composableBuilder(
    column: $table.subjectName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teacherId => $composableBuilder(
    column: $table.teacherId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TimetablesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimetablesTable> {
  $$TimetablesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get classId =>
      $composableBuilder(column: $table.classId, builder: (column) => column);

  GeneratedColumn<String> get dayOfWeek =>
      $composableBuilder(column: $table.dayOfWeek, builder: (column) => column);

  GeneratedColumn<String> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<String> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get subjectName => $composableBuilder(
    column: $table.subjectName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get teacherId =>
      $composableBuilder(column: $table.teacherId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TimetablesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimetablesTable,
          Timetable,
          $$TimetablesTableFilterComposer,
          $$TimetablesTableOrderingComposer,
          $$TimetablesTableAnnotationComposer,
          $$TimetablesTableCreateCompanionBuilder,
          $$TimetablesTableUpdateCompanionBuilder,
          (
            Timetable,
            BaseReferences<_$AppDatabase, $TimetablesTable, Timetable>,
          ),
          Timetable,
          PrefetchHooks Function()
        > {
  $$TimetablesTableTableManager(_$AppDatabase db, $TimetablesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$TimetablesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$TimetablesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$TimetablesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> classId = const Value.absent(),
                Value<String> dayOfWeek = const Value.absent(),
                Value<String> startTime = const Value.absent(),
                Value<String> endTime = const Value.absent(),
                Value<String> subjectName = const Value.absent(),
                Value<String?> teacherId = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => TimetablesCompanion(
                id: id,
                classId: classId,
                dayOfWeek: dayOfWeek,
                startTime: startTime,
                endTime: endTime,
                subjectName: subjectName,
                teacherId: teacherId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int classId,
                required String dayOfWeek,
                required String startTime,
                required String endTime,
                required String subjectName,
                Value<String?> teacherId = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => TimetablesCompanion.insert(
                id: id,
                classId: classId,
                dayOfWeek: dayOfWeek,
                startTime: startTime,
                endTime: endTime,
                subjectName: subjectName,
                teacherId: teacherId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TimetablesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimetablesTable,
      Timetable,
      $$TimetablesTableFilterComposer,
      $$TimetablesTableOrderingComposer,
      $$TimetablesTableAnnotationComposer,
      $$TimetablesTableCreateCompanionBuilder,
      $$TimetablesTableUpdateCompanionBuilder,
      (Timetable, BaseReferences<_$AppDatabase, $TimetablesTable, Timetable>),
      Timetable,
      PrefetchHooks Function()
    >;
typedef $$AnnouncementsTableCreateCompanionBuilder =
    AnnouncementsCompanion Function({
      Value<int> id,
      required int schoolId,
      required String title,
      required String content,
      Value<String?> createdByUserId,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<String?> targetRole,
      Value<int?> targetClassId,
    });
typedef $$AnnouncementsTableUpdateCompanionBuilder =
    AnnouncementsCompanion Function({
      Value<int> id,
      Value<int> schoolId,
      Value<String> title,
      Value<String> content,
      Value<String?> createdByUserId,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<String?> targetRole,
      Value<int?> targetClassId,
    });

class $$AnnouncementsTableFilterComposer
    extends Composer<_$AppDatabase, $AnnouncementsTable> {
  $$AnnouncementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdByUserId => $composableBuilder(
    column: $table.createdByUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetRole => $composableBuilder(
    column: $table.targetRole,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetClassId => $composableBuilder(
    column: $table.targetClassId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AnnouncementsTableOrderingComposer
    extends Composer<_$AppDatabase, $AnnouncementsTable> {
  $$AnnouncementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdByUserId => $composableBuilder(
    column: $table.createdByUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetRole => $composableBuilder(
    column: $table.targetRole,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetClassId => $composableBuilder(
    column: $table.targetClassId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AnnouncementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnnouncementsTable> {
  $$AnnouncementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get createdByUserId => $composableBuilder(
    column: $table.createdByUserId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get targetRole => $composableBuilder(
    column: $table.targetRole,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetClassId => $composableBuilder(
    column: $table.targetClassId,
    builder: (column) => column,
  );
}

class $$AnnouncementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AnnouncementsTable,
          Announcement,
          $$AnnouncementsTableFilterComposer,
          $$AnnouncementsTableOrderingComposer,
          $$AnnouncementsTableAnnotationComposer,
          $$AnnouncementsTableCreateCompanionBuilder,
          $$AnnouncementsTableUpdateCompanionBuilder,
          (
            Announcement,
            BaseReferences<_$AppDatabase, $AnnouncementsTable, Announcement>,
          ),
          Announcement,
          PrefetchHooks Function()
        > {
  $$AnnouncementsTableTableManager(_$AppDatabase db, $AnnouncementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$AnnouncementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$AnnouncementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$AnnouncementsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> schoolId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> createdByUserId = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String?> targetRole = const Value.absent(),
                Value<int?> targetClassId = const Value.absent(),
              }) => AnnouncementsCompanion(
                id: id,
                schoolId: schoolId,
                title: title,
                content: content,
                createdByUserId: createdByUserId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                targetRole: targetRole,
                targetClassId: targetClassId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int schoolId,
                required String title,
                required String content,
                Value<String?> createdByUserId = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String?> targetRole = const Value.absent(),
                Value<int?> targetClassId = const Value.absent(),
              }) => AnnouncementsCompanion.insert(
                id: id,
                schoolId: schoolId,
                title: title,
                content: content,
                createdByUserId: createdByUserId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                targetRole: targetRole,
                targetClassId: targetClassId,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AnnouncementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AnnouncementsTable,
      Announcement,
      $$AnnouncementsTableFilterComposer,
      $$AnnouncementsTableOrderingComposer,
      $$AnnouncementsTableAnnotationComposer,
      $$AnnouncementsTableCreateCompanionBuilder,
      $$AnnouncementsTableUpdateCompanionBuilder,
      (
        Announcement,
        BaseReferences<_$AppDatabase, $AnnouncementsTable, Announcement>,
      ),
      Announcement,
      PrefetchHooks Function()
    >;
typedef $$DonationsTableCreateCompanionBuilder =
    DonationsCompanion Function({
      required String id,
      required int schoolId,
      required String donatorName,
      Value<String?> donatorEmail,
      Value<String?> donatorPhone,
      required double amount,
      required DateTime donationDate,
      required String paymentMethod,
      Value<String?> purpose,
      required String status,
      Value<DateTime?> createdAt,
      Value<int> rowid,
    });
typedef $$DonationsTableUpdateCompanionBuilder =
    DonationsCompanion Function({
      Value<String> id,
      Value<int> schoolId,
      Value<String> donatorName,
      Value<String?> donatorEmail,
      Value<String?> donatorPhone,
      Value<double> amount,
      Value<DateTime> donationDate,
      Value<String> paymentMethod,
      Value<String?> purpose,
      Value<String> status,
      Value<DateTime?> createdAt,
      Value<int> rowid,
    });

class $$DonationsTableFilterComposer
    extends Composer<_$AppDatabase, $DonationsTable> {
  $$DonationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get donatorName => $composableBuilder(
    column: $table.donatorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get donatorEmail => $composableBuilder(
    column: $table.donatorEmail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get donatorPhone => $composableBuilder(
    column: $table.donatorPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get donationDate => $composableBuilder(
    column: $table.donationDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DonationsTableOrderingComposer
    extends Composer<_$AppDatabase, $DonationsTable> {
  $$DonationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get donatorName => $composableBuilder(
    column: $table.donatorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get donatorEmail => $composableBuilder(
    column: $table.donatorEmail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get donatorPhone => $composableBuilder(
    column: $table.donatorPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get donationDate => $composableBuilder(
    column: $table.donationDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DonationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DonationsTable> {
  $$DonationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get donatorName => $composableBuilder(
    column: $table.donatorName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get donatorEmail => $composableBuilder(
    column: $table.donatorEmail,
    builder: (column) => column,
  );

  GeneratedColumn<String> get donatorPhone => $composableBuilder(
    column: $table.donatorPhone,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get donationDate => $composableBuilder(
    column: $table.donationDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get purpose =>
      $composableBuilder(column: $table.purpose, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DonationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DonationsTable,
          Donation,
          $$DonationsTableFilterComposer,
          $$DonationsTableOrderingComposer,
          $$DonationsTableAnnotationComposer,
          $$DonationsTableCreateCompanionBuilder,
          $$DonationsTableUpdateCompanionBuilder,
          (Donation, BaseReferences<_$AppDatabase, $DonationsTable, Donation>),
          Donation,
          PrefetchHooks Function()
        > {
  $$DonationsTableTableManager(_$AppDatabase db, $DonationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$DonationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$DonationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$DonationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> schoolId = const Value.absent(),
                Value<String> donatorName = const Value.absent(),
                Value<String?> donatorEmail = const Value.absent(),
                Value<String?> donatorPhone = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<DateTime> donationDate = const Value.absent(),
                Value<String> paymentMethod = const Value.absent(),
                Value<String?> purpose = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DonationsCompanion(
                id: id,
                schoolId: schoolId,
                donatorName: donatorName,
                donatorEmail: donatorEmail,
                donatorPhone: donatorPhone,
                amount: amount,
                donationDate: donationDate,
                paymentMethod: paymentMethod,
                purpose: purpose,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int schoolId,
                required String donatorName,
                Value<String?> donatorEmail = const Value.absent(),
                Value<String?> donatorPhone = const Value.absent(),
                required double amount,
                required DateTime donationDate,
                required String paymentMethod,
                Value<String?> purpose = const Value.absent(),
                required String status,
                Value<DateTime?> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DonationsCompanion.insert(
                id: id,
                schoolId: schoolId,
                donatorName: donatorName,
                donatorEmail: donatorEmail,
                donatorPhone: donatorPhone,
                amount: amount,
                donationDate: donationDate,
                paymentMethod: paymentMethod,
                purpose: purpose,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DonationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DonationsTable,
      Donation,
      $$DonationsTableFilterComposer,
      $$DonationsTableOrderingComposer,
      $$DonationsTableAnnotationComposer,
      $$DonationsTableCreateCompanionBuilder,
      $$DonationsTableUpdateCompanionBuilder,
      (Donation, BaseReferences<_$AppDatabase, $DonationsTable, Donation>),
      Donation,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SchoolsTableTableManager get schools =>
      $$SchoolsTableTableManager(_db, _db.schools);
  $$StudentsTableTableManager get students =>
      $$StudentsTableTableManager(_db, _db.students);
  $$ClassesTableTableManager get classes =>
      $$ClassesTableTableManager(_db, _db.classes);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$AttendanceTableTableManager get attendance =>
      $$AttendanceTableTableManager(_db, _db.attendance);
  $$FinanceEntriesTableTableManager get financeEntries =>
      $$FinanceEntriesTableTableManager(_db, _db.financeEntries);
  $$TimetablesTableTableManager get timetables =>
      $$TimetablesTableTableManager(_db, _db.timetables);
  $$AnnouncementsTableTableManager get announcements =>
      $$AnnouncementsTableTableManager(_db, _db.announcements);
  $$DonationsTableTableManager get donations =>
      $$DonationsTableTableManager(_db, _db.donations);
}
