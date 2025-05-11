import 'package:floor/floor.dart';
import 'form_response.dart'; // Required for ForeignKey
import 'form_field_item.dart'; // Required for ForeignKey
import 'dart:convert'; // Import for jsonEncode/Decode

@Entity(
  tableName: 'form_response_answers',
  foreignKeys: [
    ForeignKey(
      childColumns: ['response_id'],
      parentColumns: ['id'],
      entity: FormResponse,
      onDelete: ForeignKeyAction.cascade,
    ),
    ForeignKey(
      childColumns: ['field_id'],
      parentColumns: ['id'],
      entity: FormFieldItem,
      onDelete: ForeignKeyAction.cascade,
    )
  ],
  indices: [
    Index(value: ['response_id']),
    Index(value: ['field_id']),
    // Ensures one answer per field per response
    Index(value: ['response_id', 'field_id'], unique: true) 
  ]
)
class FormResponseAnswer {
  @PrimaryKey()
  final String id; // uuid

  @ColumnInfo(name: 'response_id')
  final String responseId; // uuid
  @ColumnInfo(name: 'field_id')
  final String fieldId; // uuid
  
  // Answer can be text, number, boolean (for yes/no), or list of strings (for checkbox)
  // Storing as JSON string in DB for flexibility, then parsing in model.
  // Supabase can handle JSONB directly. Floor needs a String.
  final String answerJson; 

  // Not persisted, helper getter
  @ignore
  dynamic get answer {
    try {
      return jsonDecode(answerJson);
    } catch (e) {
      return answerJson; // Fallback to raw string if not valid JSON
    }
  }

  FormResponseAnswer({
    required this.id,
    required this.responseId,
    required this.fieldId,
    required this.answerJson,
  });

  factory FormResponseAnswer.fromMap(Map<String, dynamic> map) {
    // Supabase might return 'answer' as already parsed JSON/JSONB or as a string.
    // For consistency, we expect 'answer' to be the direct value or a JSON string.
    String answerJsonValue;
    if (map['answer'] == null) {
      answerJsonValue = 'null'; // Store null as a JSON null string
    } else if (map['answer'] is String) {
      // If it's already a JSON string (e.g. from text field, or already encoded)
      // or just a plain string for text answers.
      // We need to decide if plain strings should be wrapped in JSON quotes.
      // For simplicity, let's assume text answers are stored as plain strings,
      // and other types (list, bool, num) are JSON encoded.
      // The `answer` getter will try to decode.
      // For fromMap, we just take the string value if it's a string.
      // If it's not a string (e.g. bool, num, list from Supabase JSONB), encode it.
      answerJsonValue = map['answer'] as String; // This assumes DB stores it as text that might be JSON
    } else {
      answerJsonValue = jsonEncode(map['answer']);
    }
    
    return FormResponseAnswer(
      id: map['id'] as String,
      responseId: map['response_id'] as String,
      fieldId: map['field_id'] as String,
      answerJson: answerJsonValue,
    );
  }

  Map<String, dynamic> toMap() {
    // When sending to Supabase, 'answer' should be the actual value type for JSONB
    // not necessarily a JSON string for simple types.
    return {
      'id': id,
      'response_id': responseId,
      'field_id': fieldId,
      'answer': answer, // Send the parsed dynamic value
    };
  }

  // Constructor for Floor
  FormResponseAnswer.forFloor({
    required this.id,
    required this.responseId,
    required this.fieldId,
    required this.answerJson,
  });
}
