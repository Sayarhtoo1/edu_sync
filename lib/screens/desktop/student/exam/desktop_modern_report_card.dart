import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../../providers/exam_provider.dart';
import '../../../../providers/school_provider.dart';
import '../../../../models/grade.dart';
import '../../../../services/exam_analytics_service.dart';

class DesktopModernReportCard extends StatefulWidget {
  final String studentId;
  final String examId;

  const DesktopModernReportCard({
    super.key,
    required this.studentId,
    required this.examId,
  });

  @override
  State<DesktopModernReportCard> createState() => _DesktopModernReportCardState();
}

class _DesktopModernReportCardState extends State<DesktopModernReportCard> {
  late Future<void> _fetchReportCardFuture;
  bool _isGeneratingPDF = false;

  @override
  void initState() {
    super.initState();
    _fetchReportCardFuture = _fetchData();
  }

  Future<void> _fetchData() async {
    final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
    final examProvider = Provider.of<ExamProvider>(context, listen: false);
    final schoolId = schoolProvider.currentSchool?.id;

    if (schoolId != null) {
      try {
        await examProvider.getDetailedStudentReportCard(
          studentId: int.parse(widget.studentId),
          examId: widget.examId,
        );
        await examProvider.fetchGrades(schoolId.toString());
      } catch (e) {
        throw Exception('Failed to load report card: $e');
      }
    } else {
      throw Exception('School ID not found');
    }
  }

  Future<void> _generatePDF() async {
    setState(() => _isGeneratingPDF = true);
    try {
      final examProvider = Provider.of<ExamProvider>(context, listen: false);
      final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
      
      final studentName = examProvider.detailedReportCard.first['student_name'] ?? 'Student';
      final examName = examProvider.detailedReportCard.first['exam_name'] ?? 'Exam';
      final schoolName = schoolProvider.currentSchool?.name ?? 'School';
      
      final subjectResults = _calculateSubjectResults(examProvider, examProvider.grades);
      final overallResult = _calculateOverallResult(subjectResults, examProvider.grades);

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      schoolName,
                      style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Student Report Card',
                      style: pw.TextStyle(fontSize: 16, color: PdfColors.white),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Student Name:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(studentName.toString(), style: const pw.TextStyle(fontSize: 16)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Exam:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(examName.toString(), style: const pw.TextStyle(fontSize: 16)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _buildPDFStat('Total Score', '${overallResult['totalMarksObtained']}/${overallResult['totalMaxMarks']}'),
                    _buildPDFStat('Percentage', '${overallResult['overallPercentage'].toStringAsFixed(1)}%'),
                    _buildPDFStat('Grade', overallResult['overallGrade']),
                    _buildPDFStat('Result', (overallResult['overallPassed'] as bool) ? 'PASS' : 'FAIL'),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Subject-wise Performance', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      _buildTableCell('Subject', isHeader: true),
                      _buildTableCell('Marks', isHeader: true),
                      _buildTableCell('Max Marks', isHeader: true),
                      _buildTableCell('Percentage', isHeader: true),
                      _buildTableCell('Grade', isHeader: true),
                      _buildTableCell('Status', isHeader: true),
                    ],
                  ),
                  ...subjectResults.map((subject) => pw.TableRow(
                    children: [
                      _buildTableCell(subject['subject_name'] ?? 'N/A'),
                      _buildTableCell('${subject['marks_obtained']}'),
                      _buildTableCell('${subject['max_marks']}'),
                      _buildTableCell('${(subject['percentage'] as double).toStringAsFixed(1)}%'),
                      _buildTableCell(subject['grade'] ?? 'N/A'),
                      _buildTableCell((subject['passed'] as bool) ? 'Pass' : 'Fail'),
                    ],
                  )),
                ],
              ),
              pw.Spacer(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Generated on: ${DateTime.now().toString().split('.')[0]}', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('Signature: _______________', style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
            ],
          ),
        ),
      );

      await Printing.layoutPdf(onLayout: (format) async => pdf.save());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating PDF: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isGeneratingPDF = false);
    }
  }

  pw.Widget _buildPDFStat(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(value, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
      ],
    );
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: isHeader ? 12 : 10,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Report Card'),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          if (_isGeneratingPDF)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              onPressed: _generatePDF,
              icon: const Icon(Icons.print),
              tooltip: 'Print / Export PDF',
            ),
          IconButton(
            onPressed: () => setState(() => _fetchReportCardFuture = _fetchData()),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder(
        future: _fetchReportCardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() => _fetchReportCardFuture = _fetchData()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else {
            return Consumer<ExamProvider>(
              builder: (context, examProvider, child) {
                if (examProvider.detailedReportCard.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('No report card data available'),
                        const SizedBox(height: 8),
                        Text('Student ID: ${widget.studentId}, Exam ID: ${widget.examId}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() => _fetchReportCardFuture = _fetchData()),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final studentName = examProvider.detailedReportCard.first['student_name'] ?? 'Student';
                final examName = examProvider.detailedReportCard.first['exam_name'] ?? 'Exam';
                final schoolName = Provider.of<SchoolProvider>(context).currentSchool?.name ?? 'School';
                final grades = examProvider.grades;

                return _buildReportCardContent(
                  studentName: studentName.toString(),
                  examName: examName.toString(),
                  schoolName: schoolName,
                  examProvider: examProvider,
                  grades: grades,
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildReportCardContent({
    required String studentName,
    required String examName,
    required String schoolName,
    required ExamProvider examProvider,
    required List<Grade> grades,
  }) {
    final subjectResults = _calculateSubjectResults(examProvider, grades);
    final overallResult = _calculateOverallResult(subjectResults, grades);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              _buildHeaderCard(studentName, examName, schoolName),
              const SizedBox(height: 32),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildOverallSummaryCard(overallResult),
                        const SizedBox(height: 24),
                        _buildSubjectsTable(subjectResults),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      children: [
                        _buildPerformanceGauge(overallResult),
                        const SizedBox(height: 24),
                        _buildGradeDistribution(subjectResults),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(String studentName, String examName, String schoolName) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Text(
            schoolName,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'Student Report Card',
            style: TextStyle(fontSize: 18, color: Colors.white70),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text('Student Name', style: TextStyle(fontSize: 12, color: Colors.white70)),
                  const SizedBox(height: 4),
                  Text(studentName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              Container(width: 2, height: 40, color: Colors.white30),
              Column(
                children: [
                  const Text('Examination', style: TextStyle(fontSize: 12, color: Colors.white70)),
                  const SizedBox(height: 4),
                  Text(examName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverallSummaryCard(Map<String, dynamic> overallResult) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.analytics, color: Color(0xFF3498DB), size: 24),
              SizedBox(width: 12),
              Text('Overall Summary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildStatCard('Total Score', '${overallResult['totalMarksObtained']}/${overallResult['totalMaxMarks']}', Icons.score, const Color(0xFF3498DB))),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Percentage', '${overallResult['overallPercentage'].toStringAsFixed(1)}%', Icons.percent, const Color(0xFF2ECC71))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatCard('Grade', overallResult['overallGrade'], Icons.grade, const Color(0xFFF39C12))),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (overallResult['overallPassed'] as bool) ? const Color(0xFF2ECC71).withOpacity(0.1) : const Color(0xFFE74C3C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: (overallResult['overallPassed'] as bool) ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C)),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        (overallResult['overallPassed'] as bool) ? Icons.check_circle : Icons.cancel,
                        color: (overallResult['overallPassed'] as bool) ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C),
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        (overallResult['overallPassed'] as bool) ? 'PASSED' : 'FAILED',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: (overallResult['overallPassed'] as bool) ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildSubjectsTable(List<Map<String, dynamic>> subjectResults) {
    final groupedSubjects = _groupSubjectsByParent(subjectResults);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF2C3E50),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text('Subject', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                Expanded(child: Text('Marks', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center)),
                Expanded(child: Text('%', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center)),
                Expanded(child: Text('Grade', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center)),
                Expanded(child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center)),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: groupedSubjects.length,
            itemBuilder: (context, index) {
              final group = groupedSubjects[index];
              return _buildSubjectGroup(group, index);
            },
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _groupSubjectsByParent(List<Map<String, dynamic>> subjectResults) {
    final Map<String, Map<String, dynamic>> parentMap = {};

    for (var subject in subjectResults) {
      final parentId = subject['parent_subject_id'];
      final parentName = subject['parent_subject_name'];
      
      if (parentId == null) {
        // Standalone subject (no parent)
        if (!parentMap.containsKey(subject['subject_id'])) {
          parentMap[subject['subject_id']] = {
            'parent': subject,
            'parent_name': subject['subject_name'],
            'children': [],
          };
        }
      } else {
        // Sub-subject (has parent)
        if (!parentMap.containsKey(parentId)) {
          parentMap[parentId] = {
            'parent': null,
            'parent_name': parentName,
            'children': [],
          };
        }
        parentMap[parentId]!['children'].add(subject);
      }
    }

    return parentMap.values.toList();
  }

  Widget _buildSubjectGroup(Map<String, dynamic> group, int groupIndex) {
    final parent = group['parent'] as Map<String, dynamic>?;
    final parentName = group['parent_name'] as String?;
    final children = (group['children'] as List).cast<Map<String, dynamic>>();
    
    // Standalone subject (no children)
    if (children.isEmpty && parent != null) {
      return _buildSubjectRow(parent, groupIndex, false, false);
    }
    
    // Empty group
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate totals for parent
    int totalMarks = 0;
    int totalMaxMarks = 0;
    bool allPassed = true;

    for (var child in children) {
      totalMarks += child['marks_obtained'] as int;
      totalMaxMarks += child['max_marks'] as int;
      if (!(child['passed'] as bool)) allPassed = false;
    }

    final percentage = totalMaxMarks > 0 ? (totalMarks / totalMaxMarks) * 100 : 0.0;
    
    // Calculate grade for parent based on total percentage
    String parentGrade = 'N/A';
    final examProvider = Provider.of<ExamProvider>(context, listen: false);
    if (examProvider.grades.isNotEmpty) {
      for (var grade in examProvider.grades) {
        if (percentage >= grade.minPercentage && percentage <= grade.maxPercentage) {
          parentGrade = grade.gradeName ?? 'N/A';
          break;
        }
      }
    }

    return Column(
      children: [
        // Parent subject header with totals
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            color: const Color(0xFFE8F4F8),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  parentName ?? 'N/A',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Expanded(
                child: Text(
                  '$totalMarks/$totalMaxMarks',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Text(
                  '${percentage.toStringAsFixed(1)}%',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: allPassed ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: allPassed ? const Color(0xFF2ECC71).withOpacity(0.1) : const Color(0xFFE74C3C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    parentGrade,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: allPassed ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Icon(
                  allPassed ? Icons.check_circle : Icons.cancel,
                  color: allPassed ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
        // Sub-subjects
        ...children.asMap().entries.map((entry) {
          return _buildSubjectRow(entry.value, entry.key, true, groupIndex % 2 == 0);
        }),
      ],
    );
  }

  Widget _buildSubjectRow(Map<String, dynamic> subject, int index, bool isChild, bool isEvenGroup) {
    final passed = subject['passed'] as bool;
    
    return Container(
      padding: EdgeInsets.only(
        left: isChild ? 48 : 16,
        right: 16,
        top: 12,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
        color: isChild 
            ? (index % 2 == 0 ? Colors.grey[50] : Colors.white)
            : (isEvenGroup ? Colors.grey[50] : Colors.white),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                if (isChild) ...[
                  const Icon(Icons.subdirectory_arrow_right, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    subject['subject_name'] ?? 'N/A',
                    style: TextStyle(
                      fontWeight: isChild ? FontWeight.normal : FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              '${subject['marks_obtained']}/${subject['max_marks']}',
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              '${(subject['percentage'] as double).toStringAsFixed(1)}%',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: passed ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C),
              ),
            ),
          ),
          Expanded(child: SizedBox()),
          Expanded(
            child: Icon(
              passed ? Icons.check_circle : Icons.cancel,
              color: passed ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceGauge(Map<String, dynamic> overallResult) {
    final percentage = overallResult['overallPercentage'] as double;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          const Text('Overall Performance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: percentage / 100,
                    strokeWidth: 16,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      percentage >= 80 ? const Color(0xFF2ECC71) :
                      percentage >= 60 ? const Color(0xFFF39C12) :
                      percentage >= 40 ? Colors.orange : const Color(0xFFE74C3C),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF3498DB)),
                    ),
                    const Text('Score', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeDistribution(List<Map<String, dynamic>> subjectResults) {
    final passCount = subjectResults.where((s) => s['passed'] as bool).length;
    final failCount = subjectResults.length - passCount;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          const Text('Subject Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFF2ECC71), size: 48),
                    const SizedBox(height: 8),
                    Text('$passCount', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF2ECC71))),
                    const Text('Passed', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Icon(Icons.cancel, color: Color(0xFFE74C3C), size: 48),
                    const SizedBox(height: 8),
                    Text('$failCount', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFE74C3C))),
                    const Text('Failed', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _calculateSubjectResults(ExamProvider examProvider, List<Grade> grades) {
    final examAnalyticsService = ExamAnalyticsService();
    List<Map<String, dynamic>> subjectResults = [];

    for (var report in examProvider.detailedReportCard) {
      final marksObtained = report['marks_obtained'] as int;
      final maxMarks = report['max_marks'] as int;
      final passingMarks = report['passing_marks'] as int;

      final subjectGradeAndStatus = examAnalyticsService.getSubjectGradeAndStatus(
        marksObtained: marksObtained,
        maxMarks: maxMarks,
        passingMarks: passingMarks,
        grades: grades,
      );

      subjectResults.add({
        ...report,
        'percentage': subjectGradeAndStatus['percentage'],
        'grade': subjectGradeAndStatus['grade'],
        'passed': subjectGradeAndStatus['passed'],
      });
    }

    return subjectResults;
  }

  Map<String, dynamic> _calculateOverallResult(List<Map<String, dynamic>> subjectResults, List<Grade> grades) {
    final examAnalyticsService = ExamAnalyticsService();

    final overallResult = examAnalyticsService.getOverallExamResult(
      subjectResults: subjectResults.map((e) => {
        'marksObtained': e['marks_obtained'],
        'maxMarks': e['max_marks'],
        'passed': e['passed'],
      }).toList(),
      grades: grades,
    );

    int totalMarksObtained = 0;
    int totalMaxMarks = 0;

    for (var result in subjectResults) {
      totalMarksObtained += result['marks_obtained'] as int;
      totalMaxMarks += result['max_marks'] as int;
    }

    return {
      ...overallResult,
      'totalMarksObtained': totalMarksObtained,
      'totalMaxMarks': totalMaxMarks,
    };
  }
}
