import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locations_app/l10n/app_localizations.dart';

import '../data/firestore_service.dart';
import '../database/app_providers.dart';
import '../theme/app_theme.dart';
import 'contracts_export_table.dart';
import 'csv_exporter.dart';
import 'excel_exporter.dart';
import 'image_table_exporter.dart';
import 'pdf_table_exporter.dart';
import 'share_files.dart';

enum ExportFormat { csv, excel, pdf, image }

extension ExportFormatUi on ExportFormat {
  String label(AppLocalizations l10n) => switch (this) {
        ExportFormat.csv => l10n.formatCsv,
        ExportFormat.excel => l10n.formatExcel,
        ExportFormat.pdf => l10n.formatPdf,
        ExportFormat.image => l10n.formatImage,
      };

  String description(AppLocalizations l10n) => switch (this) {
        ExportFormat.csv => l10n.formatCsvDescription,
        ExportFormat.excel => l10n.formatExcelDescription,
        ExportFormat.pdf => l10n.formatPdfDescription,
        ExportFormat.image => l10n.formatImageDescription,
      };

  IconData get icon => switch (this) {
        ExportFormat.csv => Icons.table_rows_rounded,
        ExportFormat.excel => Icons.grid_on_rounded,
        ExportFormat.pdf => Icons.picture_as_pdf_rounded,
        ExportFormat.image => Icons.image_rounded,
      };
}

enum ExportAction { share, download }

/// Génère puis partage ou télécharge le fichier de contrats dans le format
/// choisi. Les noms arabes des locataires sont pris en charge dans les 4
/// formats : texte brut en CSV/Excel, police arabe embarquée
/// (NotoNaskhArabic) en PDF, rendu natif Flutter en image. Inclut aussi la
/// date du dernier loyer et des dernières factures STEG/SONEDE réglées par
/// chaque locataire.
class ContractsExportService {
  /// Retourne `true` si le fichier a été partagé/téléchargé, `false` si
  /// l'utilisateur a annulé (boîte "Enregistrer sous" fermée sans choix).
  static Future<bool> export({
    required BuildContext context,
    required ExportFormat format,
    required ExportAction action,
    required List<Contract> contracts,
    required String currency,
    required FirestoreService firestoreService,
  }) async {
    final results = await Future.wait([
      firestoreService.fetchAllPaymentsOnce(),
      firestoreService.fetchAllUtilityBillsOnce(),
    ]);
    if (!context.mounted) {
      // Jamais affiché à l'utilisateur (le SnackBar qui suit vérifie aussi
      // `context.mounted`) — pas besoin de traduire ce message.
      throw Exception('Screen closed before the export finished.');
    }
    // ignore: use_build_context_synchronously
    final l10n = AppLocalizations.of(context);
    final table = buildContractsExportTable(
      l10n,
      contracts,
      currency,
      payments: results[0] as List<Payment>,
      utilityBills: results[1] as List<UtilityBill>,
    );

    final stamp = DateTime.now();
    final datePart =
        '${stamp.year}-${stamp.month.toString().padLeft(2, '0')}-${stamp.day.toString().padLeft(2, '0')}';
    const baseName = 'locatrack_contrats';
    final title = l10n.exportDocumentTitle;

    final ShareableFile file;
    switch (format) {
      case ExportFormat.csv:
        file = ShareableFile('${baseName}_$datePart.csv', 'text/csv', CsvExporter.encode(table));
      case ExportFormat.excel:
        final bytes = ExcelExporter.encode(table, l10n: l10n);
        if (bytes == null) {
          throw Exception(l10n.excelGenerationFailed);
        }
        file = ShareableFile(
          '${baseName}_$datePart.xlsx',
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          bytes,
        );
      case ExportFormat.pdf:
        final bytes = await PdfTableExporter.encode(table, title: title, l10n: l10n);
        file = ShareableFile('${baseName}_$datePart.pdf', 'application/pdf', bytes);
      case ExportFormat.image:
        if (!context.mounted) {
          throw Exception('Screen closed before the export finished.');
        }
        // ignore: use_build_context_synchronously
        final bytes = await ImageTableExporter.capture(context: context, table: table, title: title, l10n: l10n);
        file = ShareableFile('${baseName}_$datePart.png', 'image/png', bytes);
    }

    switch (action) {
      case ExportAction.share:
        await shareFiles([file]);
        return true;
      case ExportAction.download:
        return downloadFile(file);
    }
  }
}

/// Logique partagée par les boutons "Export" de Réglages et d'Analyses :
/// choisit le format puis l'action, exporte et affiche le résultat. Gère
/// elle-même ses erreurs (SnackBar) — l'appelant n'a qu'à entourer l'appel
/// d'un indicateur de chargement s'il le souhaite.
Future<void> runContractsExport(BuildContext context, WidgetRef ref) async {
  final choice = await chooseExportFormat(context);
  if (choice == null || !context.mounted) return;
  final (format, action) = choice;

  try {
    final active = ref.read(contractsProvider).valueOrNull ?? [];
    final vacant = ref.read(vacantContractsProvider).valueOrNull ?? [];
    final currency = ref.read(currencyProvider);
    final firestoreService = ref.read(firestoreServiceProvider);
    final done = await ContractsExportService.export(
      context: context,
      format: format,
      action: action,
      contracts: [...active, ...vacant],
      currency: currency,
      firestoreService: firestoreService,
    );
    if (!context.mounted) return;
    if (action == ExportAction.download) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(done ? l10n.fileDownloaded : l10n.downloadCancelled)),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).exportFailed('$e'))),
      );
    }
  }
}

/// Feuille de choix du format puis de l'action (partager ou télécharger) —
/// retourne `null` si l'utilisateur annule.
Future<(ExportFormat, ExportAction)?> chooseExportFormat(BuildContext context) {
  return showModalBottomSheet<(ExportFormat, ExportAction)>(
    context: context,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).exportSheetTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context).exportSheetSubtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            for (final format in ExportFormat.values) ...[
              _FormatTile(
                format: format,
                onDownload: () => Navigator.of(context).pop((format, ExportAction.download)),
                onShare: () => Navigator.of(context).pop((format, ExportAction.share)),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    ),
  );
}

class _FormatTile extends StatelessWidget {
  const _FormatTile({required this.format, required this.onDownload, required this.onShare});

  final ExportFormat format;
  final VoidCallback onDownload;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
      ),
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
                Text(format.label(l10n), style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(
                  format.description(l10n),
                  style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: l10n.download,
            onPressed: onDownload,
            icon: Icon(Icons.download_rounded, color: scheme.onSurfaceVariant),
          ),
          IconButton(
            tooltip: l10n.share,
            onPressed: onShare,
            icon: Icon(Icons.ios_share_rounded, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
