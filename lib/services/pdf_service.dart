import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import '../utils/logger.dart';

class PdfService {
  Future<void> generateAndShareReportCard({
    required Map<String, dynamic> reportData,
    required int rank,
    required double classAverage,
  }) async {
    try {
      final pdf = await _buildReportCardPdf(reportData, rank, classAverage);
      final bytes = await pdf.save();
      
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/report_card_${reportData['student']['full_name']}.pdf');
      await file.writeAsBytes(bytes);
      
      await Share.shareXFiles([XFile(file.path)], text: 'Report Card');
    } catch (e) {
      logger.e('Error sharing report card: $e');
      rethrow;
    }
  }

  Future<void> printReportCard({
    required Map<String, dynamic> reportData,
    required int rank,
    required double classAverage,
  }) async {
    try {
      final pdf = await _buildReportCardPdf(reportData, rank, classAverage);
      await Printing.layoutPdf(onLayout: (format) => pdf.save());
    } catch (e) {
      logger.e('Error printing report card: $e');
      rethrow;
    }
  }

  Future<pw.Document> _buildReportCardPdf(
    Map<String, dynamic> reportData,
    int rank,
    double classAverage,
  ) async {
    final student = reportData['student'] as Map<String, dynamic>;
    final exam = reportData['exam'] as Map<String, dynamic>;
    final subjects = List<Map<String, dynamic>>.from(reportData['subjects']);
    final totalMarks = reportData['totalMarksObtained'] as int;
    final maxMarks = reportData['totalMaxMarks'] as int;
    final percentage = (reportData['overallPercentage'] as num).toDouble();
    final result = reportData['result'] as String;

    // Use Noto Sans for broad Unicode support
    final font = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();
    
    // Fallback fonts for Myanmar and Arabic scripts
    final fontMyanmar = await PdfGoogleFonts.notoSansMyanmarRegular();
    final fontArabic = await PdfGoogleFonts.notoSansArabicRegular();

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: font,
          bold: fontBold,
          fontFallback: [fontArabic, fontMyanmar],
        ),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildHeader(
              student['full_name']?.toString() ?? 'N/A',
              exam['name']?.toString() ?? 'N/A',
              exam['exam_date']?.toString() ?? '',
              font,
              fontBold,
              fontMyanmar,
            ),
            pw.SizedBox(height: 20),
            _buildSubjectsTable(subjects, font, fontBold, fontMyanmar),
            pw.SizedBox(height: 20),
            _buildSummary(totalMarks, maxMarks, percentage, result, rank, classAverage, font, fontBold, fontMyanmar),
          ],
        ),
      ),
    );

    return pdf;
  }

  pw.Widget _buildHeader(String studentName, String examName, String examDate, pw.Font font, pw.Font fontBold, [pw.Font? fontMyanmar]) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue700,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'STUDENT REPORT CARD',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.white, font: fontBold),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Student: $studentName', style: pw.TextStyle(color: PdfColors.white, font: font)),
              pw.Text('Exam: $examName', style: pw.TextStyle(color: PdfColors.white, font: font)),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Text('Date: $examDate', style: pw.TextStyle(color: PdfColors.white, font: font)),
        ],
      ),
    );
  }

  pw.Widget _buildSubjectsTable(List<Map<String, dynamic>> subjects, pw.Font font, pw.Font fontBold, [pw.Font? fontMyanmar]) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _tableCell('Subject', isHeader: true, font: font, fontBold: fontBold, fontMyanmar: fontMyanmar),
            _tableCell('Marks', isHeader: true, font: font, fontBold: fontBold, fontMyanmar: fontMyanmar),
            _tableCell('Grade', isHeader: true, font: font, fontBold: fontBold, fontMyanmar: fontMyanmar),
            _tableCell('Remarks', isHeader: true, font: font, fontBold: fontBold, fontMyanmar: fontMyanmar),
          ],
        ),
        ...subjects.map((subject) {
          final marksObtained = subject['marksObtained'] ?? 0;
          final totalMarks = subject['totalMarks'] ?? 0;
          final percentage = subject['percentage'] ?? 0.0;
          final passed = subject['passed'] ?? false;
          final grade = _calculateGrade(percentage);
          final remarks = passed ? 'Pass' : 'Fail';
          
          return pw.TableRow(
            children: [
              _tableCell(subject['subjectName']?.toString() ?? 'N/A', font: font, fontBold: fontBold, fontMyanmar: fontMyanmar),
              _tableCell('$marksObtained/$totalMarks', font: font, fontBold: fontBold, fontMyanmar: fontMyanmar),
              _tableCell(grade, font: font, fontBold: fontBold, fontMyanmar: fontMyanmar),
              _tableCell(remarks, font: font, fontBold: fontBold, fontMyanmar: fontMyanmar),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _tableCell(String text, {bool isHeader = false, required pw.Font font, required pw.Font fontBold, pw.Font? fontMyanmar}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          font: isHeader ? fontBold : font,
        ),
      ),
    );
  }

  String _calculateGrade(double percentage) {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B+';
    if (percentage >= 60) return 'B';
    if (percentage >= 50) return 'C+';
    if (percentage >= 40) return 'C';
    if (percentage >= 30) return 'D';
    return 'F';
  }

  pw.Widget _buildSummary(
    int totalMarks,
    int maxMarks,
    double percentage,
    String result,
    int rank,
    double classAverage,
    pw.Font font,
    pw.Font fontBold,
    pw.Font? fontMyanmar,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Overall Performance', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, font: fontBold)),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Total Marks: $totalMarks/$maxMarks', style: pw.TextStyle(font: font)),
              pw.Text('Percentage: ${percentage.toStringAsFixed(2)}%', style: pw.TextStyle(font: font)),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Result: $result', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: fontBold)),
              pw.Text('Rank: $rank', style: pw.TextStyle(font: font)),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Text('Class Average: ${classAverage.toStringAsFixed(2)}%', style: pw.TextStyle(font: font)),
        ],
      ),
    );
  }
}
