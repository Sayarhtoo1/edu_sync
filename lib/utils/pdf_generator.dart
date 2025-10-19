import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfGenerator {
  static Future<pw.Font> _loadFont() async {
    return PdfGoogleFonts.notoSansRegular();
  }

  static Future<void> generateProfitLossReport(Map<String, dynamic> data, DateTime startDate, DateTime endDate) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd MMM yyyy');
    final font = await _loadFont();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Profit & Loss Statement', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, font: font)),
            pw.SizedBox(height: 8),
            pw.Text('Period: ${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}', style: pw.TextStyle(font: font)),
            pw.Divider(thickness: 2),
            pw.SizedBox(height: 16),
            pw.Text('Income', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, font: font)),
            ...((data['incomeByCategory'] as Map<String, double>? ?? {}).entries.map((e) =>
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Text(e.key, style: pw.TextStyle(font: font)),
                pw.Text(NumberFormat.currency(symbol: '\$').format(e.value), style: pw.TextStyle(font: font)),
              ])
            )),
            pw.Divider(),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Text('Total Income', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: font)),
              pw.Text(NumberFormat.currency(symbol: '\$').format(data['totalIncome'] ?? 0), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: font)),
            ]),
            pw.SizedBox(height: 16),
            pw.Text('Expenses', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, font: font)),
            ...((data['expenseByCategory'] as Map<String, double>? ?? {}).entries.map((e) =>
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Text(e.key, style: pw.TextStyle(font: font)),
                pw.Text(NumberFormat.currency(symbol: '\$').format(e.value), style: pw.TextStyle(font: font)),
              ])
            )),
            pw.Divider(),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Text('Total Expenses', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: font)),
              pw.Text(NumberFormat.currency(symbol: '\$').format(data['totalExpense'] ?? 0), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: font)),
            ]),
            pw.SizedBox(height: 16),
            pw.Divider(thickness: 2),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Text('Net Profit/Loss', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, font: font)),
              pw.Text(NumberFormat.currency(symbol: '\$').format(data['netProfit'] ?? 0), style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, font: font)),
            ]),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  static Future<void> generateCashFlowReport(Map<String, dynamic> data, DateTime startDate, DateTime endDate) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd MMM yyyy');
    final font = await _loadFont();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Cash Flow Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, font: font)),
            pw.SizedBox(height: 8),
            pw.Text('Period: ${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}', style: pw.TextStyle(font: font)),
            pw.Divider(thickness: 2),
            pw.SizedBox(height: 16),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Text('Final Balance', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, font: font)),
              pw.Text(NumberFormat.currency(symbol: '\$').format(data['finalBalance'] ?? 0), style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, font: font)),
            ]),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}
