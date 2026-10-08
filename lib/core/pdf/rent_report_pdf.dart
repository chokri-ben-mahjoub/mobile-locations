import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../database/app_database.dart';
import '../utils/format_utils.dart';

class RentReportRow {
  final Contract contract;
  final Payment? payment;

  RentReportRow({required this.contract, required this.payment});

  bool get paid => payment != null;
}

/// Construit le PDF du rapport des loyers pour un mois donné.
Future<Uint8List> buildMonthlyRentReportPdf({
  required DateTime month,
  required List<RentReportRow> rows,
  required String currency,
}) async {
  final latin = await PdfGoogleFonts.interRegular();
  final latinBold = await PdfGoogleFonts.interBold();
  final arabic = await PdfGoogleFonts.notoNaskhArabicRegular();

  final doc = pw.Document();

  final totalExpected = rows.fold<double>(0, (sum, r) => sum + r.contract.monthlyAmount);
  final totalCollected =
      rows.where((r) => r.paid).fold<double>(0, (sum, r) => sum + (r.payment?.amount ?? 0));
  final unpaidCount = rows.where((r) => !r.paid).length;
  final monthLabel = FormatUtils.monthYear.format(month);

  pw.TextStyle style({bool bold = false, double size = 10, PdfColor? color}) => pw.TextStyle(
        font: bold ? latinBold : latin,
        fontFallback: [arabic],
        fontSize: size,
        color: color,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      );

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      header: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('LocaTrack — Rapport des loyers', style: style(bold: true, size: 18)),
          pw.SizedBox(height: 4),
          pw.Text(
            monthLabel[0].toUpperCase() + monthLabel.substring(1),
            style: style(size: 13, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 12),
        ],
      ),
      build: (context) => [
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          columnWidths: const {
            0: pw.FlexColumnWidth(1.2),
            1: pw.FlexColumnWidth(2.6),
            2: pw.FlexColumnWidth(1.6),
            3: pw.FlexColumnWidth(1.4),
            4: pw.FlexColumnWidth(1.6),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.teal50),
              children: [
                _cell('Local', style(bold: true)),
                _cell('Locataire', style(bold: true)),
                _cell('Loyer attendu', style(bold: true)),
                _cell('Statut', style(bold: true)),
                _cell('Date paiement', style(bold: true)),
              ],
            ),
            for (final row in rows)
              pw.TableRow(
                children: [
                  _cell(row.contract.unitNumber, style()),
                  _cell(row.contract.tenantName, style()),
                  _cell(
                    FormatUtils.currency(row.contract.monthlyAmount, currency),
                    style(),
                  ),
                  _cell(
                    row.paid ? 'Payé' : 'Impayé',
                    style(bold: true, color: row.paid ? PdfColors.green700 : PdfColors.red700),
                  ),
                  _cell(
                    row.payment != null
                        ? FormatUtils.shortDate.format(row.payment!.paidDate)
                        : '—',
                    style(),
                  ),
                ],
              ),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Container(
          padding: const pw.EdgeInsets.all(14),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _summaryLine('Locaux inclus', '${rows.length}', style),
              _summaryLine(
                'Total attendu',
                FormatUtils.currency(totalExpected, currency),
                style,
              ),
              _summaryLine(
                'Total encaissé',
                FormatUtils.currency(totalCollected, currency),
                style,
                color: PdfColors.green700,
              ),
              _summaryLine(
                'Locaux impayés',
                '$unpaidCount',
                style,
                color: unpaidCount > 0 ? PdfColors.red700 : null,
              ),
            ],
          ),
        ),
      ],
      footer: (context) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          'Généré le ${FormatUtils.shortDate.format(DateTime.now())}',
          style: style(size: 8, color: PdfColors.grey500),
        ),
      ),
    ),
  );

  return doc.save();
}

pw.Widget _cell(String text, pw.TextStyle style) => pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text, style: style),
    );

pw.Widget _summaryLine(
  String label,
  String value,
  pw.TextStyle Function({bool bold, double size, PdfColor? color}) style, {
  PdfColor? color,
}) =>
    pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: style()),
          pw.Text(value, style: style(bold: true, color: color)),
        ],
      ),
    );

Future<void> shareMonthlyRentReport({
  required DateTime month,
  required List<RentReportRow> rows,
  required String currency,
}) async {
  final bytes = await buildMonthlyRentReportPdf(month: month, rows: rows, currency: currency);
  await Printing.sharePdf(
    bytes: bytes,
    filename: 'rapport_loyers_${month.year}_${month.month.toString().padLeft(2, '0')}.pdf',
  );
}
