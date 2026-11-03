import 'dart:convert';

import 'package:excel/excel.dart' as xl;
import 'package:flutter_test/flutter_test.dart';
import 'package:locations_app/core/data/models.dart';
import 'package:locations_app/core/export/contracts_export_table.dart';
import 'package:locations_app/core/export/csv_exporter.dart';
import 'package:locations_app/core/export/excel_exporter.dart';
import 'package:locations_app/l10n/app_localizations_ar.dart';
import 'package:locations_app/l10n/app_localizations_en.dart';
import 'package:locations_app/l10n/app_localizations_fr.dart';

// L'export image (ImageTableExporter.capture) n'est pas couvert ici : il
// insère un OverlayEntry et attend deux frames réelles (`endOfFrame`),
// un idiome standard (utilisé par ex. par le package `screenshot`) qui
// fonctionne avec le moteur Flutter réel, mais qui est instable sous le
// faux scheduler de `flutter_test` (les frames n'y sont produites que
// par un `pump()` manuel, pas en continu comme sur un vrai appareil).
// Vérifié manuellement à l'écran à la place.
//
// Le PDF a été retiré de l'export (son moteur de rendu arabe manuel
// produisait des résultats incorrects selon la langue de l'interface et
// les noms) — CSV, Excel et Image restent, tous les trois affichant
// l'arabe via du texte Unicode brut ou un vrai moteur de rendu Flutter,
// indépendamment de la langue choisie pour l'interface de l'app.

Contract _contract({required String tenantName}) => Contract(
      id: 'c1',
      tenantName: tenantName,
      unitNumber: 'A1-4',
      startDate: DateTime(2025, 8, 1),
      endDate: DateTime(2026, 8, 1),
      monthlyAmount: 400,
      stegMeter: '731907450',
      sonedeMeter: '7353558',
      createdAt: DateTime(2025, 8, 1),
    );

void main() {
  // Nom arabe réel tiré de la capture fournie par l'utilisateur.
  const arabicName = 'علاء الدين الطرابلسي';

  // Le nom du locataire est une DONNÉE, pas une chaîne traduite : il doit
  // s'afficher correctement en CSV/Excel quelle que soit la langue
  // choisie pour l'interface (FR/EN/AR) — c'est justement ce qui s'est
  // cassé pour le PDF retiré.
  for (final (localeName, l10n) in [
    ('fr', AppLocalizationsFr()),
    ('en', AppLocalizationsEn()),
    ('ar', AppLocalizationsAr()),
  ]) {
    group('export des contrats — nom de locataire en arabe (interface $localeName)', () {
      final contracts = [_contract(tenantName: arabicName)];
      final table = buildContractsExportTable(l10n, contracts, 'DT');

      test('ExportTable conserve le nom arabe tel quel', () {
        expect(table.rows.single[1], arabicName);
      });

      test('CSV : le nom arabe est préservé en UTF-8 avec BOM', () {
        final bytes = CsvExporter.encode(table);
        expect(bytes[0], 0xEF);
        expect(bytes[1], 0xBB);
        expect(bytes[2], 0xBF);
        final text = utf8.decode(bytes.sublist(3));
        expect(text, contains(arabicName));
      });

      test('Excel : le nom arabe est préservé comme texte brut', () {
        final bytes = ExcelExporter.encode(table);
        expect(bytes, isNotNull);
        final decoded = xl.Excel.decodeBytes(bytes!);
        final sheet = decoded.sheets.values.first;
        final nameCell = sheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 1));
        expect(nameCell.value.toString(), arabicName);
      });
    });
  }
}
