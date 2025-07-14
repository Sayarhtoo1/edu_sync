import 'form_field_type.dart'; // Import the enum
// Import CustomForm
import 'dart:convert'; // For jsonEncode/Decode if storing options as JSON string

class FormFieldItem {
  final String id; // uuid

  final String formId; // uuid, foreign key to custom_forms
  final String question;

  // Store enum as String in DB, convert in model
  final FormFieldType type;
  
  final String typeString;

  // For multiple_choice, checkbox: store options as JSON string
  final String? optionsJson; 
  final bool required;

  List<String> get options {
    if (optionsJson == null || optionsJson!.isEmpty) return [];
    try {
      final decoded = jsonDecode(optionsJson!);
      if (decoded is List) {
        return List<String>.from(decoded.map((e) => e.toString()));
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  FormFieldItem({
    required this.id,
    required this.formId,
    required this.question,
    required this.type,
    this.optionsJson,
    required this.required,
  }) : typeString = formFieldTypeToString(type); // Initialize typeString from type

  // Constructor for Floor to use when reading from DB
  // It needs to map DB columns directly to fields, including typeString
  // and then initialize 'type' from 'typeString'.
  // Or, make a factory constructor for fromMap that handles this.
  
  factory FormFieldItem.fromMap(Map<String, dynamic> map) {
    final type = formFieldTypeFromString(map['type'] as String);
    List<String>? optList;
    if (map['options'] != null) {
      // Supabase might return JSONB as List<dynamic> or Map, or string.
      // If it's already a list (e.g. from JSONB array of strings):
      if (map['options'] is List) {
         optList = List<String>.from(map['options'].map((e) => e.toString()));
      } 
      // If it's a JSON string (less likely for direct Supabase query but good for Floor)
      else if (map['options'] is String) {
        try {
          final decoded = jsonDecode(map['options'] as String);
          if (decoded is List) {
            optList = List<String>.from(decoded.map((e) => e.toString()));
          }
        } catch (e) { /* ignore if not valid JSON */ }
      }
    }

    return FormFieldItem(
      id: map['id'] as String,
      formId: map['form_id'] as String,
      question: map['question'] as String,
      type: type,
      optionsJson: optList != null ? jsonEncode(optList) : null, // Store as JSON string for Floor
      required: map['required'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'form_id': formId,
      'question': question,
      'type': formFieldTypeToString(type), // Send enum as string
      'options': options, // Send as List<String> for Supabase json/jsonb
      'required': required,
    };
  }

  // Special constructor for Floor if it can't use the default one due to @ignore or getters
  // This is often needed if the default constructor has fields Floor can't map directly (like 'type' enum)
  // and you have a separate 'typeString' for the DB.
  // Floor uses this constructor to instantiate objects from the database.
  // The names of parameters must match the column names (or @ColumnInfo names).
  FormFieldItem.forFloor({
    required this.id,
    required this.formId,
    required this.question,
    required this.typeString, // Floor will use this
    this.optionsJson,
    required this.required,
  }) : type = formFieldTypeFromString(typeString); // Initialize the enum from string
}
