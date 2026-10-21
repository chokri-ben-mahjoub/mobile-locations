import 'dart:convert';

import 'package:intl/intl.dart';

import 'export_table.dart';

/// Génère le contenu d'un fichier CSV encodé en UTF-8 avec BOM, séparateur
/// `;` (format Excel FR). Les noms arabes des locataires n'ont besoin
/// d'aucun traitement spécial — c'est du texte brut, pas des glyphes
/// dessinés avec une police comme dans un PDF.
class CsvExporter {
  static final _dateFormat = DateFormat('dd/MM/yyyy');

  static List<int> encode(ExportTable table) {
    final buffer = StringBuffer();
    buffer.write(table.headers.map(_escape).join(';'));
    buffer.write('\r\n');
    for (final row in table.rows) {
      buffer.write(row.map((cell) => _escape(_format(cell))).join(';'));
      buffer.write('\r\n');
    }
    // BOM UTF-8 : indispensable pour qu'Excel affiche correctement l'arabe
    // à l'ouverture directe du fichier.
    return [0xEF, 0xBB, 0xBF, ...utf8.encode(buffer.toString())];
  }

  static String _format(Object? cell) {
    if (cell == null) return '';
    if (cell is DateOnly) return _dateFormat.format(cell.date);
    if (cell is DateTime) return _dateFormat.format(cell);
    if (cell is int) return cell.toString();
    if (cell is double) {
      if (cell.isNaN || cell.isInfinite) return '';
      if (cell == cell.roundToDouble() && cell.abs() < 1e15) return cell.toInt().toString();
      return cell.toString().replaceAll('.', ',');
    }
    return cell.toString();
  }

  static String _escape(String value) {
    if (value.contains(';') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
