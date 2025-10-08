class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult({
    required this.isValid,
    this.errorMessage,
  });

  factory ValidationResult.valid() => const ValidationResult(isValid: true);

  factory ValidationResult.invalid(String message) => ValidationResult(
    isValid: false,
    errorMessage: message,
  );
}

class ValidationService {
  static final ValidationService _instance = ValidationService._internal();
  factory ValidationService() => _instance;
  ValidationService._internal();

  // Email validation
  ValidationResult validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return ValidationResult.invalid('Email is required');
    }

    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      return ValidationResult.invalid('Please enter a valid email address');
    }

    return ValidationResult.valid();
  }

  // Password validation
  ValidationResult validatePassword(String? password, {int minLength = 8}) {
    if (password == null || password.isEmpty) {
      return ValidationResult.invalid('Password is required');
    }

    if (password.length < minLength) {
      return ValidationResult.invalid('Password must be at least $minLength characters long');
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      return ValidationResult.invalid('Password must contain at least one uppercase letter');
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      return ValidationResult.invalid('Password must contain at least one lowercase letter');
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      return ValidationResult.invalid('Password must contain at least one number');
    }

    return ValidationResult.valid();
  }

  // Name validation
  ValidationResult validateName(String? name, {String fieldName = 'Name'}) {
    if (name == null || name.isEmpty) {
      return ValidationResult.invalid('$fieldName is required');
    }

    if (name.length < 2) {
      return ValidationResult.invalid('$fieldName must be at least 2 characters long');
    }

    if (name.length > 50) {
      return ValidationResult.invalid('$fieldName must not exceed 50 characters');
    }

    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
      return ValidationResult.invalid('$fieldName can only contain letters and spaces');
    }

    return ValidationResult.valid();
  }

  // Marks validation
  ValidationResult validateMarks(String? marks, {int? maxMarks}) {
    if (marks == null || marks.isEmpty) {
      return ValidationResult.invalid('Marks are required');
    }

    final marksValue = int.tryParse(marks);
    if (marksValue == null) {
      return ValidationResult.invalid('Please enter a valid number');
    }

    if (marksValue < 0) {
      return ValidationResult.invalid('Marks cannot be negative');
    }

    if (maxMarks != null && marksValue > maxMarks) {
      return ValidationResult.invalid('Marks cannot exceed maximum marks ($maxMarks)');
    }

    return ValidationResult.valid();
  }

  // Percentage validation
  ValidationResult validatePercentage(String? percentage) {
    if (percentage == null || percentage.isEmpty) {
      return ValidationResult.invalid('Percentage is required');
    }

    final percentageValue = double.tryParse(percentage);
    if (percentageValue == null) {
      return ValidationResult.invalid('Please enter a valid percentage');
    }

    if (percentageValue < 0 || percentageValue > 100) {
      return ValidationResult.invalid('Percentage must be between 0 and 100');
    }

    return ValidationResult.valid();
  }

  // Date validation
  ValidationResult validateDate(DateTime? date, {DateTime? minDate, DateTime? maxDate}) {
    if (date == null) {
      return ValidationResult.invalid('Date is required');
    }

    if (minDate != null && date.isBefore(minDate)) {
      return ValidationResult.invalid('Date cannot be before ${minDate.toString().split(' ')[0]}');
    }

    if (maxDate != null && date.isAfter(maxDate)) {
      return ValidationResult.invalid('Date cannot be after ${maxDate.toString().split(' ')[0]}');
    }

    return ValidationResult.valid();
  }

  // Phone number validation (optional)
  ValidationResult validatePhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) {
      return ValidationResult.valid(); // Phone is optional
    }

    final phoneRegex = RegExp(r'^[\+]?[0-9\-\s\(\)]{10,15}$');
    if (!phoneRegex.hasMatch(phone)) {
      return ValidationResult.invalid('Please enter a valid phone number');
    }

    return ValidationResult.valid();
  }

  // Exam name validation
  ValidationResult validateExamName(String? name) {
    return validateName(name, fieldName: 'Exam name');
  }

  // Subject name validation
  ValidationResult validateSubjectName(String? name) {
    return validateName(name, fieldName: 'Subject name');
  }

  // Class name validation
  ValidationResult validateClassName(String? name) {
    return validateName(name, fieldName: 'Class name');
  }

  // Grade validation
  ValidationResult validateGrade(String? grade, int minPercentage, int maxPercentage) {
    if (grade == null || grade.isEmpty) {
      return ValidationResult.invalid('Grade is required');
    }

    if (minPercentage >= maxPercentage) {
      return ValidationResult.invalid('Minimum percentage must be less than maximum percentage');
    }

    if (minPercentage < 0 || minPercentage > 100) {
      return ValidationResult.invalid('Minimum percentage must be between 0 and 100');
    }

    if (maxPercentage < 0 || maxPercentage > 100) {
      return ValidationResult.invalid('Maximum percentage must be between 0 and 100');
    }

    return ValidationResult.valid();
  }

  // Batch validation for multiple fields
  Map<String, ValidationResult> validateExamData({
    String? examName,
    String? examinerName,
    DateTime? examDate,
    String? maxMarks,
    String? classId,
  }) {
    return {
      'examName': validateExamName(examName),
      'examinerName': validateName(examinerName, fieldName: 'Examiner name'),
      'examDate': validateDate(examDate, minDate: DateTime.now()),
      'maxMarks': maxMarks != null && maxMarks.isNotEmpty
          ? validateMarks(maxMarks)
          : ValidationResult.valid(),
      'classId': classId == null || classId.isEmpty
          ? ValidationResult.invalid('Please select a class')
          : ValidationResult.valid(),
    };
  }

  Map<String, ValidationResult> validateStudentMarks({
    String? studentId,
    String? subjectId,
    String? marks,
    int? maxMarks,
  }) {
    return {
      'studentId': studentId == null || studentId.isEmpty
          ? ValidationResult.invalid('Student selection is required')
          : ValidationResult.valid(),
      'subjectId': subjectId == null || subjectId.isEmpty
          ? ValidationResult.invalid('Subject selection is required')
          : ValidationResult.valid(),
      'marks': validateMarks(marks, maxMarks: maxMarks),
    };
  }

  // Check if all validations in a map are valid
  bool areAllValid(Map<String, ValidationResult> validations) {
    return validations.values.every((result) => result.isValid);
  }

  // Get all error messages from validations
  List<String> getErrorMessages(Map<String, ValidationResult> validations) {
    return validations.entries
        .where((entry) => !entry.value.isValid)
        .map((entry) => '${entry.key}: ${entry.value.errorMessage}')
        .toList();
  }
}
