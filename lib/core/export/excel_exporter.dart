import 'package:excel/excel.dart';

import 'export_table.dart';

/// Génère un classeur Excel (.xlsx) à partir d'un [ExportTable] : en-tête en
/// gras, nombres et dates exportés comme de vraies valeurs (triables,
/// filtrables). Les noms arabes (locataires) s'affichent correctement — le
/// format Excel est du texte Unicode brut, sans police à embarquer,
/// contrairement au PDF.
class ExcelExporter {
  static List<int>? encode(ExportTable table) {
    final excel = Excel.createExcel();
    final defaultSheet = excel.getDefaultSheet()!;
    final sheetName = _sanitizeSheetName(table.name);
    excel.rename(defaultSheet, sheetName);
    final sheet = excel[sheetName];

    final headerStyle = CellStyle(bold: true, backgroundColorHex: ExcelColor.grey100);
    final numberStyle = CellStyle(numberFormat: NumFormat.standard_0);

    for (var c = 0; c < table.headers.length; c++) {
      sheet.updateCell(
        CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0),
        TextCellValue(table.headers[c]),
        cellStyle: headerStyle,
      );
    }
    for (var r = 0; r < table.rows.length; r++) {
      final row = table.rows[r];
      for (var c = 0; c < row.length; c++) {
        final value = _cellValue(row[c]);
        if (value == null) continue;
        sheet.updateCell(
          CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r + 1),
          value,
          cellStyle: value is DoubleCellValue ? numberStyle : null,
        );
      }
    }
    for (var c = 0; c < table.headers.length; c++) {
      sheet.setColumnWidth(c, _columnWidth(table, c));
    }

    return excel.encode();
  }

  static CellValue? _cellValue(Object? cell) {
    if (cell == null) return null;
    if (cell is DateOnly) {
      return DateCellValue(year: cell.date.year, month: cell.date.month, day: cell.date.day);
    }
    if (cell is DateTime) {
      return DateTimeCellValue(
        year: cell.year,
        month: cell.month,
        day: cell.day,
        hour: cell.hour,
        minute: cell.minute,
      );
    }
    if (cell is int) return IntCellValue(cell);
    if (cell is double) {
      if (cell.isNaN || cell.isInfinite) return null;
      return DoubleCellValue(cell);
    }
    return TextCellValue(cell.toString());
  }

  /// Largeur approximative d'une colonne d'après son contenu le plus long.
  static double _columnWidth(ExportTable table, int column) {
    var longest = table.headers[column].length;
    for (final row in table.rows) {
      if (column >= row.length) continue;
      final cell = row[column];
      final length = cell is DateTime
          ? 16
          : cell is DateOnly
              ? 10
              : (cell?.toString().length ?? 0);
      if (length > longest) longest = length;
    }
    return (longest + 2).clamp(8, 50).toDouble();
  }

  static String _sanitizeSheetName(String raw) {
    var name = raw.replaceAll(RegExp(r'[\[\]:*?/\\]'), ' ').trim();
    if (name.isEmpty) name = 'Contrats';
    if (name.length > 31) name = name.substring(0, 31);
    return name;
  }
}
