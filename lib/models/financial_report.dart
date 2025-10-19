class FinancialReport {
  final String id;
  final String type;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, dynamic> data;
  final DateTime generatedAt;

  FinancialReport({
    required this.id,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.data,
    required this.generatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'start_date': startDate.toIso8601String(),
    'end_date': endDate.toIso8601String(),
    'data': data,
    'generated_at': generatedAt.toIso8601String(),
  };

  factory FinancialReport.fromJson(Map<String, dynamic> json) => FinancialReport(
    id: json['id'],
    type: json['type'],
    startDate: DateTime.parse(json['start_date']),
    endDate: DateTime.parse(json['end_date']),
    data: json['data'],
    generatedAt: DateTime.parse(json['generated_at']),
  );
}
