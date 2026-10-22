import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:locations_app/l10n/app_localizations.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../utils/arabic_text.dart';
import 'export_table.dart';

const _navy = PdfColor.fromInt(0xFF0B1E2D);
const _accent = PdfColor.fromInt(0xFF1F6F78); // accentColor de AppTheme
const _grey = PdfColor.fromInt(0xFF757575);

// Fonds de ligne par statut — mêmes couleurs que le tableau papier
// d'origine (rouge = expiré/urgent, jaune = en attente, blanc = actif).
const _expiredRowColor = PdfColor.fromInt(0xFFF4C7C7);
const _pendingRowColor = PdfColor.fromInt(0xFFFCE588);

/// Document PDF pour un [ExportTable] (export des contrats).
///
/// Les noms de locataires sont souvent en arabe : la police par défaut du
/// PDF (Helvetica) ne sait pas dessiner ces glyphes. On embarque donc une
/// police arabe (NotoNaskhArabic, bundlée hors ligne dans
/// `assets/fonts/`) en `fontFallback` de la police latine — le moteur
/// `pdf` choisit automatiquement la bonne police caractère par caractère,
/// donc un nom mixte (ex: "Ahmed BEN SALAH") s'affiche correctement.
///
/// IMPORTANT : la mise en forme/jointure correcte des lettres arabes
/// (« shaping ») n'est activée dans le package `pdf` que si l'app est
/// compilée avec `--dart-define=use_arabic=true` (flag interne au
/// package, voir `scripts/build_release.ps1`). Sans ce flag, les noms
/// arabes peuvent s'afficher déformés ou incomplets dans le PDF généré.
class PdfTableExporter {
  static final _dateFormat = DateFormat('dd/MM/yyyy');

  static pw.Font? _arabicFont;
  static pw.Font? _latinFont;
  static pw.Font? _latinBoldFont;

  static Future<void> _ensureFontsLoaded() async {
    _arabicFont ??= pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoNaskhArabic-Regular.ttf'),
    );
    _latinFont ??= pw.Font.ttf(await rootBundle.load('assets/fonts/Inter-Regular.ttf'));
    _latinBoldFont ??= pw.Font.ttf(await rootBundle.load('assets/fonts/Inter-Bold.ttf'));
  }

  static Future<Uint8List> encode(
    ExportTable table, {
    required String title,
    AppLocalizations? l10n,
  }) async {
    await _ensureFontsLoaded();

    // Colore chaque ligne selon son statut (colonne "Statut") — permet de
    // repérer d'un coup d'œil les contrats expirés/en attente, comme sur
    // le tableau papier d'origine.
    final statusColumn = l10n == null ? -1 : table.headers.indexOf(l10n.exportColStatus);
    PdfColor? rowColorFor(int rowNum) {
      // `rowNum` compte la ligne d'en-tête (headerCount, 1 par défaut) :
      // la première ligne de données a rowNum == 1, pas 0.
      final index = rowNum - 1;
      if (statusColumn == -1 || index < 0 || index >= table.rows.length) return null;
      final status = table.rows[index][statusColumn]?.toString();
      if (status == l10n!.statusExpired) return _expiredRowColor;
      if (status == l10n.statusPending) return _pendingRowColor;
      return null;
    }

    final textStyle = pw.TextStyle(font: _latinFont, fontFallback: [_arabicFont!]);
    final boldStyle = pw.TextStyle(font: _latinBoldFont, fontFallback: [_arabicFont!]);

    final doc = pw.Document(title: title, author: 'LocaTrack');
    final generated = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    final columns = table.headers.length;
    final fontSize = columns > 8 ? 7.5 : 9.0;
    final cellPadding = columns > 8
        ? const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 4)
        : const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5);
    final pageFormat = columns > 6 ? PdfPageFormat.a4.landscape : PdfPageFormat.a4;

    doc.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.fromLTRB(20, 24, 20, 24),
        theme: pw.ThemeData.withFont(base: _latinFont, bold: _latinBoldFont, fontFallback: [_arabicFont!]),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              children: [
                pw.Text('LocaTrack', style: pw.TextStyle(font: _latinBoldFont, color: _accent, fontSize: 13)),
                pw.Spacer(),
                pw.Text(title, style: pw.TextStyle(font: _latinFont, color: _grey, fontSize: 9)),
              ],
            ),
            pw.Divider(color: _accent, thickness: 1.5),
          ],
        ),
        footer: (context) => pw.Row(
          children: [
            pw.Text('Généré le $generated', style: pw.TextStyle(font: _latinFont, color: _grey, fontSize: 8)),
            pw.Spacer(),
            pw.Text(
              '${context.pageNumber} / ${context.pagesCount}',
              style: pw.TextStyle(font: _latinFont, color: _grey, fontSize: 8),
            ),
          ],
        ),
        build: (context) => [
          pw.Text(title, style: pw.TextStyle(font: _latinBoldFont, fontSize: 16, color: _navy)),
          pw.SizedBox(height: 14),
          pw.TableHelper.fromTextArray(
            headers: table.headers,
            headerStyle: boldStyle.copyWith(fontSize: fontSize, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: _navy),
            headerPadding: cellPadding,
            cellStyle: textStyle.copyWith(fontSize: fontSize),
            cellPadding: cellPadding,
            cellAlignment: pw.Alignment.centerLeft,
            cellDecoration: (columnIndex, data, rowNum) {
              final color = rowColorFor(rowNum);
              return pw.BoxDecoration(color: color);
            },
            // La mise en forme arabe (jointure des lettres + ordre de
            // lecture) n'est appliquée par le moteur `pdf` que sur un
            // `Text` dont `textDirection` vaut `rtl` — sans ça, même avec
            // `--dart-define=use_arabic=true`, les lettres arabes
            // s'affichent isolées et dans le mauvais sens (voir le nom du
            // locataire). On ne force le `rtl` que sur les cellules
            // réellement arabes (les autres restent inchangées, sinon un
            // texte français à plusieurs mots comme "Non payé" se
            // retrouverait lui aussi réordonné par erreur).
            cellBuilder: (columnIndex, data, rowNum) {
              final text = _cell(data);
              if (!isArabicText(text)) return null;
              return pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  mirrorBracketsForRtl(text),
                  textDirection: pw.TextDirection.rtl,
                  textAlign: pw.TextAlign.right,
                  style: textStyle.copyWith(fontSize: fontSize),
                ),
              );
            },
            data: [for (final row in table.rows) row.map(_cell).toList()],
          ),
        ],
      ),
    );
    return doc.save();
  }

  static String _cell(Object? value) {
    if (value == null) return '';
    if (value is DateOnly) return _dateFormat.format(value.date);
    if (value is DateTime) return _dateFormat.format(value);
    if (value is int) return value.toString();
    if (value is double) {
      if (value.isNaN || value.isInfinite) return '';
      return value == value.roundToDouble() && value.abs() < 1e15 ? value.toInt().toString() : value.toString();
    }
    return value.toString();
  }
}
