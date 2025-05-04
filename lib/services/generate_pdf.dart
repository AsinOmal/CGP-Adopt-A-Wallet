import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

Future<void> generateAndShowPdf(
    BuildContext context,
    List<Map<String, dynamic>> incomeData,
    List<Map<String, dynamic>> expenseData,
    String startDate,
    String endDate) async {
  final pdf = pw.Document();

  // Load the custom font from the fonts folder
  final fontData = await rootBundle.load('fonts/NotoSans-Regular.ttf');
  final fontDataBold = await rootBundle.load('fonts/NotoSans-Bold.ttf');
  final ttf = pw.Font.ttf(fontData);
  final ttfBold = pw.Font.ttf(fontDataBold);

  // Calculate total income and expenses
  final totalIncome = incomeData.fold(0.0, (sum, item) => sum + item['amount']);
  final totalExpense =
      expenseData.fold(0.0, (sum, item) => sum + item['amount']);

  pdf.addPage(
    pw.MultiPage(
      build: (pw.Context context) {
        return [
          // Decorated Header
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Income and Expenses Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  font: ttfBold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Date Range: $startDate to $endDate',
                style: pw.TextStyle(
                  fontSize: 16,
                  font: ttf,
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 20),

          // Income Section
          pw.Center(
            child: pw.Text(
              'Income',
              style: pw.TextStyle(fontSize: 20, font: ttfBold),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: null,
            children: [
              // Header row with different alignments
              pw.TableRow(
                children: [
                  pw.Container(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    alignment: pw.Alignment.centerLeft,
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Date',
                        style: pw.TextStyle(
                          font: ttfBold,
                        )),
                  ),
                  pw.Container(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    alignment: pw.Alignment.centerRight,
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Amount',
                        style: pw.TextStyle(
                          font: ttfBold,
                        )),
                  ),
                  pw.Container(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    alignment: pw.Alignment.centerRight,
                    padding: const pw.EdgeInsets.all(8),
                    child:
                        pw.Text('Category', style: pw.TextStyle(font: ttfBold)),
                  ),
                ],
              ),
              // Data rows with different alignments
              ...incomeData.map(
                (income) => pw.TableRow(
                  children: [
                    pw.Container(
                      alignment: pw.Alignment.centerLeft,
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(income['date'],
                          style: pw.TextStyle(font: ttf)),
                    ),
                    pw.Container(
                      alignment: pw.Alignment.centerRight,
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(income['amount'].toString(),
                          style: pw.TextStyle(font: ttf)),
                    ),
                    pw.Container(
                      alignment: pw.Alignment.centerRight,
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(income['category'],
                          style: pw.TextStyle(font: ttf)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 20), // Add some space before the expense section

          // Expense Section
          pw.Center(
            child: pw.Text(
              'Expenses',
              style: pw.TextStyle(fontSize: 20, font: ttfBold),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: null,
            children: [
              pw.TableRow(
                children: [
                  pw.Container(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    alignment: pw.Alignment.centerLeft,
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Date',
                        style: pw.TextStyle(
                            font: ttfBold, fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Container(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    alignment: pw.Alignment.centerRight,
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Amount',
                        style: pw.TextStyle(
                            font: ttfBold, fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Container(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    alignment: pw.Alignment.centerRight,
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Category',
                        style: pw.TextStyle(
                            font: ttfBold, fontWeight: pw.FontWeight.bold)),
                  ),
                ],
              ),
              ...expenseData.map(
                (expense) => pw.TableRow(
                  children: [
                    pw.Container(
                      alignment: pw.Alignment.centerLeft,
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(expense['date'],
                          style: pw.TextStyle(font: ttf)),
                    ),
                    pw.Container(
                      alignment: pw.Alignment.centerRight,
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(expense['amount'].toString(),
                          style: pw.TextStyle(font: ttf)),
                    ),
                    pw.Container(
                      alignment: pw.Alignment.centerRight,
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(expense['category'],
                          style: pw.TextStyle(font: ttf)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 20), // Add space before the totals section

          // Totals Section
          pw.Divider(),
          pw.Center(
            child: pw.Text(
              'Totals',
              style: pw.TextStyle(fontSize: 20, font: ttfBold),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Total Income:',
                  style: pw.TextStyle(fontSize: 16, font: ttfBold)),
              pw.Text('\$${totalIncome.toStringAsFixed(2)}',
                  style: pw.TextStyle(fontSize: 16, font: ttfBold)),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Total Expenses:',
                  style: pw.TextStyle(fontSize: 16, font: ttfBold)),
              pw.Text('\$${totalExpense.toStringAsFixed(2)}',
                  style: pw.TextStyle(fontSize: 16, font: ttfBold)),
            ],
          ),
        ];
      },
    ),
  );

  // Create temporary directory and save the file there
  final directory = await getTemporaryDirectory();
  final filePath =
      '${directory.path}/income_expenses_report_${startDate}_to_$endDate.pdf';
  final file = File(filePath);

  // Write PDF data to the temp file
  await file.writeAsBytes(await pdf.save());

  // Open the PDF file using OpenFile package
  await OpenFile.open(filePath);
}
