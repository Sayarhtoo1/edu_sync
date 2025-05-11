// Defines the types of fields that can be used in a custom form.
enum FormFieldType {
  text,
  yesNo,
  multipleChoice,
  checkbox,
  number,
}

// Helper to convert string from DB to enum and vice-versa
String formFieldTypeToString(FormFieldType type) {
  switch (type) {
    case FormFieldType.text:
      return 'text';
    case FormFieldType.yesNo:
      return 'yes_no';
    case FormFieldType.multipleChoice:
      return 'multiple_choice';
    case FormFieldType.checkbox:
      return 'checkbox';
    case FormFieldType.number:
      return 'number';
    default:
      throw ArgumentError('Invalid FormFieldType');
  }
}

FormFieldType formFieldTypeFromString(String typeString) {
  switch (typeString.toLowerCase()) {
    case 'text':
      return FormFieldType.text;
    case 'yes_no':
      return FormFieldType.yesNo;
    case 'multiple_choice':
      return FormFieldType.multipleChoice;
    case 'checkbox':
      return FormFieldType.checkbox;
    case 'number':
      return FormFieldType.number;
    default:
      // Fallback or throw error
      print("Warning: Unknown FormFieldType string '$typeString', defaulting to text.");
      return FormFieldType.text; 
  }
}
