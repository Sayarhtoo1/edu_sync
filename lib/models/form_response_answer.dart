// Required for ForeignKey
// Required for ForeignKey
import 'dart:convert'; // Import for jsonEncode/Decode

class FormResponseAnswer {
  final String id; // uuid

  final String responseId; // uuid
  final String fieldId; // uuid
  
  // Answer can be text, number, boolean (for yes/no), or list of strings (for checkbox)
  // Storing as JSON string in DB for flexibility, then parsing in model.
  // Supabase can handle JSONB directly. Floor needs a String.
  final String answerJson; 

  // Not persisted, helper getter
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
    String answerJsonValue;
    if (map['answer'] == null) {
      answerJsonValue = jsonEncode(null);
    } else if (map['answer'] is String) {
      answerJsonValue = map['answer'];
    } else {
      try {
        answerJsonValue = jsonEncode(map['answer']);
      } catch (e) {
        answerJsonValue = map['answer'].toString();
      }
    }

    return FormResponseAnswer(
      id: map['id'] ?? '',
      responseId: map['response_id'] ?? '',
      fieldId: map['field_id'] ?? '',
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

  /// Serializes the answer into a format suitable for the RPC function.
  Map<String, dynamic> toRpcJson() {
    // The RPC function expects a JSON object with 'field_id' and 'answer_text' or 'answer_json'.
    // Based on the SQL function, we should provide the answer in a structured way.
    // The SQL function seems to prefer `answer_text` for simple values and `answer_json` for complex ones.
    
    dynamic decodedAnswer = answer; // Use the getter to decode the JSON string

    return {
      'field_id': fieldId,
      // If the answer is a simple string, pass it as answer_text.
      // Otherwise, pass the raw JSON string to the answer_json parameter.
      'answer_text': decodedAnswer is String ? decodedAnswer : null,
      'answer_json': decodedAnswer is String ? null : jsonDecode(answerJson),
    };
  }
}
