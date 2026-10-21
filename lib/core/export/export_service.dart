import 'package:flutter/material.dart';

import '../data/models.dart';
import '../theme/app_theme.dart';
import 'contracts_export_table.dart';
import 'csv_exporter.dart';
import 'excel_exporter.dart';
import 'image_table_exporter.dart';
import 'pdf_table_exporter.dart';
import 'share_files.dart';

enum ExportFormat { csv, excel, pdf, image }

extension ExportFormatUi on ExportFormat {
  String get label => switch (this) {
        ExportFormat.csv => 'CSV',
        ExportFormat.excel => 'Excel',
        ExportFormat.pdf => 'PDF',
        ExportFormat.image => 'Image',
      };

  String get description => switch (this) {
        ExportFormat.csv => 'Fichier .csv, compatible Excel',
        ExportFormat.excel => 'Classeur .xlsx avec mise en forme',
        ExportFormat.pdf => 'Document PDF prêt à imprimer',
        ExportFormat.image => 'Capture PNG du tableau, à partager',
      };

  IconData get icon => switch (this) {
        ExportFormat.csv => Icons.table_rows_rounded,
        ExportFormat.excel => Icons.grid_on_rounded,
        ExportFormat.pdf => Icons.picture_as_pdf_rounded,
        ExportFormat.image => Icons.image_rounded,
      };
}

/// Génère puis partage le fichier de contrats dans le format choisi. Les
/// noms arabes des locataires sont pris en charge dans les 4 formats :
/// texte brut en CSV/Excel, police arabe embarquée (NotoNaskhArabic) en
/// PDF, rendu natif Flutter en image.
class ContractsExportService {
  static Future<void> export({
    required BuildContext context,
    required ExportFormat format,
    required List<Contract> contracts,
    required String currency,
  }) async {
    final table = buildContractsExportTable(contracts, currency);
    final stamp = DateTime.now();
    final datePart =
        '${stamp.year}-${stamp.month.toString().padLeft(2, '0')}-${stamp.day.toString().padLeft(2, '0')}';
    const baseName = 'locatrack_contrats';
    const title = 'Contrats de location';

    switch (format) {
      case ExportFormat.csv:
        final bytes = CsvExporter.encode(table);
        await shareFiles([ShareableFile('${baseName}_$datePart.csv', 'text/csv', bytes)]);
      case ExportFormat.excel:
        final bytes = ExcelExporter.encode(table);
        if (bytes == null) {
          throw Exception('Échec de la génération du fichier Excel.');
        }
        await shareFiles([
          ShareableFile(
            '${baseName}_$datePart.xlsx',
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            bytes,
          ),
        ]);
      case ExportFormat.pdf:
        final bytes = await PdfTableExporter.encode(table, title: title);
        await shareFiles([ShareableFile('${baseName}_$datePart.pdf', 'application/pdf', bytes)]);
      case ExportFormat.image:
        final bytes = await ImageTableExporter.capture(context: context, table: table, title: title);
        await shareFiles([ShareableFile('${baseName}_$datePart.png', 'image/png', bytes)]);
    }
  }
}

/// Feuille de choix du format d'export — retourne le format choisi, ou
/// `null` si l'utilisateur annule.
Future<ExportFormat?> chooseExportFormat(BuildContext context) {
  return showModalBottomSheet<ExportFormat>(
    context: context,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exporter les contrats',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Les noms des locataires en arabe s\'affichent correctement dans tous les formats.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            for (final format in ExportFormat.values) ...[
              _FormatTile(format: format, onTap: () => Navigator.of(context).pop(format)),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    ),
  );
}

class _FormatTile extends StatelessWidget {
  const _FormatTile({required this.format, required this.onTap});

  final ExportFormat format;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(format.icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(format.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(
                      format.description,
                      style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
