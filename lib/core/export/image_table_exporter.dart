import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';
import 'export_table.dart';

/// Capture un [ExportTable] sous forme d'image PNG (comme une capture
/// d'écran d'un tableau Excel) — pratique pour partager rapidement sur
/// WhatsApp sans pièce jointe "fichier".
///
/// Les noms arabes des locataires s'affichent exactement comme dans le
/// reste de l'app : ce sont de vrais widgets `Text` Flutter, pas des
/// glyphes dessinés manuellement comme dans le PDF — aucun traitement
/// spécial n'est donc nécessaire ici, contrairement au PDF.
class ImageTableExporter {
  static final _dateFormat = DateFormat('dd/MM/yyyy');

  /// [context] doit avoir un `Overlay` au-dessus de lui dans l'arbre (tout
  /// écran normal de l'app convient).
  static Future<Uint8List> capture({
    required BuildContext context,
    required ExportTable table,
    required String title,
    double pixelRatio = 2.5,
  }) async {
    final overlay = Overlay.of(context, rootOverlay: true);
    final boundaryKey = GlobalKey();
    late OverlayEntry entry;
    final completer = Completer<Uint8List>();

    entry = OverlayEntry(
      builder: (context) => Positioned(
        // Hors de l'écran visible, mais toujours construit/peint — une
        // opacité à 0 ne suffirait pas, `RepaintBoundary` a besoin d'un
        // vrai passage de layout + peinture pour produire une image.
        left: -10000,
        top: 0,
        child: Material(
          color: Colors.transparent,
          child: RepaintBoundary(
            key: boundaryKey,
            child: _TableCard(table: table, title: title, dateFormat: _dateFormat),
          ),
        ),
      ),
    );

    overlay.insert(entry);

    try {
      // Deux frames : la première construit/layout, la seconde garantit
      // que la peinture est bien terminée avant la capture.
      await WidgetsBinding.instance.endOfFrame;
      await WidgetsBinding.instance.endOfFrame;

      final boundary = boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      completer.complete(byteData!.buffer.asUint8List());
    } catch (e, st) {
      completer.completeError(e, st);
    } finally {
      entry.remove();
    }

    return completer.future;
  }
}

class _TableCard extends StatelessWidget {
  const _TableCard({required this.table, required this.title, required this.dateFormat});

  final ExportTable table;
  final String title;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(fontFamily: 'Inter', color: Color(0xFF0B1214)),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'LocaTrack',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: accentColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              border: TableBorder.symmetric(inside: const BorderSide(color: Color(0xFFE2E8E8))),
              defaultColumnWidth: const IntrinsicColumnWidth(),
              children: [
                TableRow(
                  decoration: const BoxDecoration(color: Color(0xFF0B1E2D)),
                  children: [
                    for (final header in table.headers) _cell(header, header: true),
                  ],
                ),
                for (final (i, row) in table.rows.indexed)
                  TableRow(
                    decoration: BoxDecoration(color: i.isEven ? Colors.white : const Color(0xFFF5F8F8)),
                    children: [for (final value in row) _cell(_format(value))],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Généré le ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
              style: const TextStyle(fontSize: 10, color: Color(0xFF9AA5A5)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cell(String text, {bool header = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      child: Text(
        text,
        softWrap: false,
        overflow: TextOverflow.visible,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: header ? FontWeight.w700 : FontWeight.w500,
          color: header ? Colors.white : const Color(0xFF14262A),
        ),
      ),
    );
  }

  String _format(Object? value) {
    if (value == null) return '';
    if (value is DateOnly) return dateFormat.format(value.date);
    if (value is DateTime) return dateFormat.format(value);
    if (value is double) {
      return value == value.roundToDouble() ? value.toInt().toString() : value.toString();
    }
    return value.toString();
  }
}
