import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/exam_provider.dart';
import '../../services/pdf_service.dart';
import 'widgets/report_card_header.dart';
import 'widgets/report_card_table.dart';
import 'widgets/report_card_summary.dart';

class ReportCardScreen extends StatefulWidget {
  final int studentId;
  final String examId;

  const ReportCardScreen({
    super.key,
    required this.studentId,
    required this.examId,
  });

  @override
  State<ReportCardScreen> createState() => _ReportCardScreenState();
}

class _ReportCardScreenState extends State<ReportCardScreen> {
  Map<String, dynamic>? _reportData;
  int? _rank;
  Map<String, dynamic>? _classAverage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReportCard();
  }

  Future<void> _loadReportCard() async {
    setState(() => _isLoading = true);
    try {
      final examProvider = Provider.of<ExamProvider>(context, listen: false);
      
      final reportData = await examProvider.getReportCard(
        studentId: widget.studentId,
        examId: widget.examId,
      );
      
      final rank = await examProvider.getStudentRank(
        studentId: widget.studentId,
        examId: widget.examId,
      );
      
      final classAverage = await examProvider.getClassAverage(widget.examId);

      setState(() {
        _reportData = reportData;
        _rank = rank;
        _classAverage = classAverage;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading report card: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Card'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _reportData != null ? _shareReportCard : null,
            tooltip: 'Share',
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _reportData != null ? _printReportCard : null,
            tooltip: 'Print',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reportData == null
              ? const Center(child: Text('No data available'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ReportCardHeader(
                        studentName: _reportData!['student']['full_name'] ?? 'Unknown',
                        examName: _reportData!['exam']['name'] ?? 'Unknown Exam',
                        examDate: _reportData!['exam']['exam_date'] != null 
                            ? DateTime.parse(_reportData!['exam']['exam_date'])
                            : DateTime.now(),
                      ),
                      const SizedBox(height: 24),
                      ReportCardTable(
                        subjects: List<Map<String, dynamic>>.from(_reportData!['subjects']),
                      ),
                      const SizedBox(height: 24),
                      ReportCardSummary(
                        totalMarksObtained: _reportData!['totalMarksObtained'],
                        totalMaxMarks: _reportData!['totalMaxMarks'],
                        overallPercentage: _reportData!['overallPercentage'],
                        result: _reportData!['result'],
                        rank: _rank ?? 0,
                        classAverage: _classAverage?['percentage'] ?? 0.0,
                      ),
                    ],
                  ),
                ),
    );
  }

  Future<void> _shareReportCard() async {
    try {
      final pdfService = PdfService();
      await pdfService.generateAndShareReportCard(
        reportData: _reportData!,
        rank: _rank ?? 0,
        classAverage: _classAverage?['percentage'] ?? 0.0,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing: $e')),
        );
      }
    }
  }

  Future<void> _printReportCard() async {
    try {
      final pdfService = PdfService();
      await pdfService.printReportCard(
        reportData: _reportData!,
        rank: _rank ?? 0,
        classAverage: _classAverage?['percentage'] ?? 0.0,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error printing: $e')),
        );
      }
    }
  }
}
